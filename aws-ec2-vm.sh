#!/usr/bin/env bash
set -Eeuo pipefail

readonly VERSION="1.0.0"
readonly DEFAULT_NAME="dev-vm"
readonly DEFAULT_VCPUS="2"
readonly DEFAULT_MEMORY_GIB="4"
readonly DEFAULT_DISK_GIB="50"
readonly DEFAULT_REGION="us-east-1"
readonly DEVICE_NAME="/dev/sdf"

COMMAND="help"
NAME="$DEFAULT_NAME"
PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-}}"
PROFILE_EXPLICIT=0
REGION_EXPLICIT=0
VCPUS="$DEFAULT_VCPUS"
MEMORY_GIB="$DEFAULT_MEMORY_GIB"
DISK_GIB="$DEFAULT_DISK_GIB"
INSTANCE_TYPE=""
SUBNET_ID=""
SSH_CIDR=""
YES=0
NON_INTERACTIVE=0
STATE_DIR="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
STATE_FILE=""
AWS=()

# State fields. These are written after every resource-creating operation.
ACCOUNT_ID=""
INSTANCE_ID=""
VOLUME_ID=""
VPC_ID=""
AZ=""
SG_ID=""
KEY_NAME=""
KEY_PATH=""
AMI_ID=""
PUBLIC_IP=""
VOLUME_TOKEN=""
INSTANCE_TOKEN=""
INSTANCE_READY="0"
LOCK_DIR=""

info() { printf '==> %s\n' "$*" >&2; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
shell_quote() { printf '%q' "$1"; }

usage() {
  cat <<'EOF'
aws-ec2-vm.sh - create and manage a small EC2 development VM

USAGE
  aws-ec2-vm.sh setup [--profile PROFILE] [--region REGION]
  aws-ec2-vm.sh create [NAME] [OPTIONS]
  aws-ec2-vm.sh {status|ssh|start|restart|stop|terminate} [NAME] [OPTIONS]
  aws-ec2-vm.sh destroy-storage [NAME] [--yes] [OPTIONS]

CREATE OPTIONS
  --vcpus N             Exact vCPU count (default: 2)
  --memory GIB          Exact RAM in GiB (default: 4)
  --instance-type TYPE  Use this EC2 type instead of resolving vCPU/RAM
  --disk GIB            Persistent encrypted gp3 data disk (default: 50)
  --subnet-id ID        Subnet to use; otherwise a default subnet is selected
  --ssh-cidr CIDR       IPv4 CIDR allowed to SSH; default: your public IP /32

COMMON OPTIONS
  --profile PROFILE     AWS CLI profile (default: AWS_PROFILE or default)
  --region REGION       AWS region (default: profile region or us-east-1)
  --yes                 Skip destructive confirmation
  --non-interactive     Never prompt; fail when input/authentication is needed
  -h, --help            Show help

EXAMPLES
  ./aws-ec2-vm.sh setup
  ./aws-ec2-vm.sh create
  ./aws-ec2-vm.sh create mlbox --vcpus 4 --memory 16 --disk 200
  ./aws-ec2-vm.sh status mlbox
  ./aws-ec2-vm.sh ssh mlbox
  ./aws-ec2-vm.sh stop mlbox
  ./aws-ec2-vm.sh start mlbox
  ./aws-ec2-vm.sh terminate mlbox       # keeps mlbox's data EBS volume
  ./aws-ec2-vm.sh create mlbox          # new VM, same persistent volume
  ./aws-ec2-vm.sh destroy-storage mlbox # permanently deletes that volume

STORAGE AND COST
  The root disk is disposable. A separate encrypted EBS volume is attached with
  DeleteOnTermination=false, so it survives reboot, stop, and termination.
  EBS is tied to one Availability Zone; replacement VMs are created there.
  Stopped VMs and retained EBS volumes can still cost money. AWS also charges
  for public IPv4 while allocated. Public IPv4 may change after stop/start. The
  script never deletes persistent storage as part of termination or failure.

  The data disk is intentionally not formatted automatically. After first SSH,
  use `lsblk -f` to identify the unformatted disk, then follow the first-use
  instructions printed by `create`. Never run mkfs on a disk containing data.

AUTHENTICATION
  Credentials are never accepted as flags or stored by this script. `setup`
  installs AWS CLI v2 if needed, then offers existing credentials, SSO, or the
  standard AWS CLI configuration flow.
EOF
}

validate_name() {
  case "$NAME" in
    ''|*[!a-zA-Z0-9._-]*) die "NAME may contain only letters, digits, dot, underscore, and hyphen" ;;
  esac
  [ "${#NAME}" -le 48 ] || die "NAME must be at most 48 characters"
}

is_uint() { case "$1" in ''|*[!0-9]*) return 1 ;; *) [ "$1" -gt 0 ] ;; esac; }

need_value() { [ "$#" -ge 2 ] || die "$1 requires a value"; }

parse_args() {
  [ "$#" -gt 0 ] || { COMMAND="help"; return; }
  COMMAND="$1"
  shift
  case "$COMMAND" in
    -h|--help|help) COMMAND="help" ;;
    setup|create|status|ssh|start|restart|stop|terminate|destroy-storage|version) ;;
    *) die "unknown command: $COMMAND (run --help)" ;;
  esac

  if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then
    NAME="$1"
    shift
  fi

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --profile) need_value "$@"; PROFILE="$2"; PROFILE_EXPLICIT=1; shift 2 ;;
      --region) need_value "$@"; REGION="$2"; REGION_EXPLICIT=1; shift 2 ;;
      --vcpus) need_value "$@"; VCPUS="$2"; shift 2 ;;
      --memory) need_value "$@"; MEMORY_GIB="$2"; shift 2 ;;
      --disk) need_value "$@"; DISK_GIB="$2"; shift 2 ;;
      --instance-type) need_value "$@"; INSTANCE_TYPE="$2"; shift 2 ;;
      --subnet-id) need_value "$@"; SUBNET_ID="$2"; shift 2 ;;
      --ssh-cidr) need_value "$@"; SSH_CIDR="$2"; shift 2 ;;
      --yes) YES=1; shift ;;
      --non-interactive) NON_INTERACTIVE=1; shift ;;
      -h|--help) COMMAND="help"; shift ;;
      *) die "unknown option: $1" ;;
    esac
  done
}

validate_args() {
  validate_name
  is_uint "$VCPUS" || die "--vcpus must be a positive integer"
  is_uint "$MEMORY_GIB" || die "--memory must be a positive integer"
  is_uint "$DISK_GIB" || die "--disk must be a positive integer"
  case "$VCPUS:$MEMORY_GIB:$DISK_GIB" in *:0*|0*) die "numeric values must not have leading zeros" ;; esac
  [ "$DISK_GIB" -le 16384 ] || die "--disk exceeds gp3's 16384 GiB limit"
  case "$REGION" in *[!a-z0-9-]*) [ -z "$REGION" ] || die "invalid region: $REGION" ;; esac
  case "$PROFILE" in ''|*[!a-zA-Z0-9_+=,.@-]*) die "invalid profile name" ;; esac
  [ -z "$SSH_CIDR" ] || valid_cidr "$SSH_CIDR" || die "invalid IPv4 CIDR: $SSH_CIDR"
}

valid_cidr() {
  local cidr="$1" ip prefix old_ifs a b c d octet
  case "$cidr" in *[!0-9./]*|*/*/*|/*|*/) return 1 ;; esac
  ip="${cidr%/*}"
  prefix="${cidr#*/}"
  case "$prefix" in ''|*[!0-9]*) return 1 ;; esac
  [ "$prefix" -le 32 ] 2>/dev/null || return 1
  old_ifs="$IFS"; IFS=.; set -- $ip; IFS="$old_ifs"
  [ "$#" -eq 4 ] || return 1
  a="$1"; b="$2"; c="$3"; d="$4"
  for octet in "$a" "$b" "$c" "$d"; do
    case "$octet" in ''|*[!0-9]*) return 1 ;; esac
    [ "$octet" -le 255 ] 2>/dev/null || return 1
  done
}

save_state() {
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"
  local tmp="$STATE_FILE.tmp.$$" key value
  umask 077
  : > "$tmp"
  for key in PROFILE REGION ACCOUNT_ID INSTANCE_ID VOLUME_ID VPC_ID SUBNET_ID AZ SG_ID KEY_NAME KEY_PATH AMI_ID INSTANCE_TYPE DISK_GIB PUBLIC_IP VOLUME_TOKEN INSTANCE_TOKEN INSTANCE_READY; do
    eval "value=\${$key}"
    case "$value" in *$'\n'*|*$'\r'*) rm -f "$tmp"; die "state value contains a newline" ;; esac
    printf '%s=%s\n' "$key" "$value" >> "$tmp"
  done
  chmod 600 "$tmp"
  mv -f "$tmp" "$STATE_FILE"
}

load_state() {
  [ -f "$STATE_FILE" ] || die "no state for '$NAME'; run create first ($STATE_FILE)"
  [ ! -L "$STATE_FILE" ] || die "refusing symlinked state file: $STATE_FILE"
  local key value saved_profile="" saved_region=""
  while IFS='=' read -r key value; do
    case "$key" in
      PROFILE) saved_profile="$value" ;;
      REGION) saved_region="$value" ;;
      ACCOUNT_ID) ACCOUNT_ID="$value" ;;
      INSTANCE_ID) INSTANCE_ID="$value" ;;
      VOLUME_ID) VOLUME_ID="$value" ;;
      VPC_ID) VPC_ID="$value" ;;
      SUBNET_ID) SUBNET_ID="$value" ;;
      AZ) AZ="$value" ;;
      SG_ID) SG_ID="$value" ;;
      KEY_NAME) KEY_NAME="$value" ;;
      KEY_PATH) KEY_PATH="$value" ;;
      AMI_ID) AMI_ID="$value" ;;
      INSTANCE_TYPE) INSTANCE_TYPE="$value" ;;
      DISK_GIB) DISK_GIB="$value" ;;
      PUBLIC_IP) PUBLIC_IP="$value" ;;
      VOLUME_TOKEN) VOLUME_TOKEN="$value" ;;
      INSTANCE_TOKEN) INSTANCE_TOKEN="$value" ;;
      INSTANCE_READY) INSTANCE_READY="$value" ;;
      '') ;;
      *) die "unknown field in state file: $key" ;;
    esac
  done < "$STATE_FILE"
  [ "$PROFILE_EXPLICIT" -eq 0 ] || [ "$PROFILE" = "$saved_profile" ] || die "state uses profile '$saved_profile', not requested '$PROFILE'"
  [ "$REGION_EXPLICIT" -eq 0 ] || [ "$REGION" = "$saved_region" ] || die "state uses region '$saved_region', not requested '$REGION'"
  PROFILE="$saved_profile"; REGION="$saved_region"
  case "$INSTANCE_ID" in ''|i-[a-zA-Z0-9]*) ;; *) die "invalid instance ID in state" ;; esac
  case "$VOLUME_ID" in ''|vol-[a-zA-Z0-9]*) ;; *) die "invalid volume ID in state" ;; esac
  case "$SG_ID" in ''|sg-[a-zA-Z0-9]*) ;; *) die "invalid security group ID in state" ;; esac
  case "$INSTANCE_READY" in 0|1) ;; *) die "invalid readiness marker in state" ;; esac
  is_uint "$DISK_GIB" || die "invalid disk size in state"
}

release_lock() { [ -z "$LOCK_DIR" ] || rmdir "$LOCK_DIR" 2>/dev/null || true; }

acquire_lock() {
  mkdir -p "$STATE_DIR"
  LOCK_DIR="$STATE_FILE.lock"
  mkdir "$LOCK_DIR" 2>/dev/null || die "another operation for '$NAME' is running (remove stale $LOCK_DIR only after verifying)"
  trap release_lock EXIT
  trap 'release_lock; exit 130' INT
  trap 'release_lock; exit 143' TERM
  trap 'release_lock; exit 129' HUP
}

configure_aws_array() {
  AWS=(aws --no-cli-pager --profile "$PROFILE")
  [ -n "$REGION" ] && AWS+=(--region "$REGION")
}

install_aws_cli() {
  command -v curl >/dev/null 2>&1 || die "curl is required to install AWS CLI"
  local os arch tmp signature
  os="$(uname -s)"
  arch="$(uname -m)"
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/awscli.XXXXXX")"
  if [ "$os" = "Darwin" ]; then
    info "Downloading the official AWS CLI v2 macOS package"
    curl -fL --proto '=https' --tlsv1.2 -o "$tmp/AWSCLIV2.pkg" "https://awscli.amazonaws.com/AWSCLIV2.pkg"
    signature="$(pkgutil --check-signature "$tmp/AWSCLIV2.pkg" 2>&1)" || {
      rm -rf "$tmp"; die "AWS CLI package signature verification failed";
    }
    case "$signature" in
      *'Status: signed by a certificate trusted by macOS'*) ;;
      *'Status: signed by a developer certificate issued by Apple for distribution'*'Notarization: trusted by the Apple notary service'*) ;;
      *) rm -rf "$tmp"; die "AWS CLI package is not trusted by macOS" ;;
    esac
    printf '%s\n' "$signature" | grep -Eq 'Developer ID Installer: .* \(94KV3E626L\)' || {
      rm -rf "$tmp"; die "AWS CLI package signer is not the expected AWS Team ID";
    }
    sudo installer -pkg "$tmp/AWSCLIV2.pkg" -target /
  elif [ "$os" = "Linux" ]; then
    command -v unzip >/dev/null 2>&1 || die "unzip is required to install AWS CLI"
    case "$arch" in
      x86_64|amd64) arch="x86_64" ;;
      arm64|aarch64) arch="aarch64" ;;
      *) rm -rf "$tmp"; die "unsupported Linux architecture: $arch" ;;
    esac
    info "Downloading the official AWS CLI v2 Linux installer"
    curl -fL --proto '=https' --tlsv1.2 -o "$tmp/awscliv2.zip" "https://awscli.amazonaws.com/awscli-exe-linux-${arch}.zip"
    unzip -q "$tmp/awscliv2.zip" -d "$tmp"
    sudo "$tmp/aws/install" --update
  else
    rm -rf "$tmp"
    die "automatic AWS CLI installation supports macOS and Linux; see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
  fi
  rm -rf "$tmp"
  command -v aws >/dev/null 2>&1 || die "AWS CLI installed but is not on PATH; open a new shell and rerun"
}

ensure_cli() {
  command -v aws >/dev/null 2>&1 && return 0
  if [ "$NON_INTERACTIVE" -eq 1 ]; then
    die "AWS CLI is missing; run '$0 setup' first"
  fi
  printf 'AWS CLI v2 is not installed. Install it now? [Y/n] ' >&2
  local answer
  IFS= read -r answer || true
  case "$answer" in n|N|no|NO) die "AWS CLI is required" ;; esac
  install_aws_cli
}

resolve_region() {
  [ -n "$REGION" ] && return 0
  REGION="$(aws configure get region --profile "$PROFILE" 2>/dev/null || true)"
  REGION="${REGION:-$DEFAULT_REGION}"
}

identity_ok() { "${AWS[@]}" sts get-caller-identity --query Account --output text >/dev/null 2>&1; }

ensure_auth() {
  ensure_cli
  resolve_region
  configure_aws_array
  if identity_ok; then return; fi
  [ "$NON_INTERACTIVE" -eq 0 ] || die "AWS authentication failed for profile '$PROFILE'; run '$0 setup --profile $PROFILE'"
  printf '\nNo working AWS session for profile %s.\n  1) AWS IAM Identity Center (SSO, recommended)\n  2) Standard aws configure\n  3) Credentials are already configured; retry/login only\nChoose [1]: ' "$PROFILE" >&2
  local choice
  IFS= read -r choice || true
  case "${choice:-1}" in
    1) aws configure sso --profile "$PROFILE"; aws sso login --profile "$PROFILE" ;;
    2) aws configure --profile "$PROFILE" ;;
    3) aws sso login --profile "$PROFILE" 2>/dev/null || true ;;
    *) die "invalid choice" ;;
  esac
  resolve_region
  configure_aws_array
  identity_ok || die "AWS authentication still failed for profile '$PROFILE'"
}

setup() {
  ensure_cli
  resolve_region
  configure_aws_array
  ensure_auth
  ACCOUNT_ID="$("${AWS[@]}" sts get-caller-identity --query Account --output text)"
  info "AWS CLI ready: profile=$PROFILE region=$REGION account=$ACCOUNT_ID"
}

aws_text() { "${AWS[@]}" "$@" --output text; }

discover_ssh_cidr() {
  [ -n "$SSH_CIDR" ] && return 0
  command -v curl >/dev/null 2>&1 || die "set --ssh-cidr because curl is unavailable"
  local ip
  ip="$(curl -fsS --max-time 10 https://checkip.amazonaws.com 2>/dev/null | tr -d '[:space:]' || true)"
  case "$ip" in ''|*[!0-9.]*) die "could not detect your public IPv4 address; pass --ssh-cidr YOUR_IP/32" ;; esac
  SSH_CIDR="$ip/32"
  valid_cidr "$SSH_CIDR" || die "public IP service returned an invalid address; pass --ssh-cidr YOUR_IP/32"
  info "SSH access restricted to $SSH_CIDR"
}

resolve_existing_volume() {
  [ -n "$VOLUME_ID" ] || return 0
  local result state attachment attached_state
  result="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].[AvailabilityZone,State,Attachments[0].InstanceId]')" || die "cannot inspect persistent volume $VOLUME_ID"
  AZ="$(printf '%s\n' "$result" | awk '{print $1}')"
  state="$(printf '%s\n' "$result" | awk '{print $2}')"
  attachment="$(printf '%s\n' "$result" | awk '{print $3}')"
  [ -n "$AZ" ] && [ "$AZ" != "None" ] || die "persistent volume $VOLUME_ID no longer exists"
  case "$state" in
    available) ;;
    in-use)
      [ -n "$INSTANCE_ID" ] && [ "$attachment" = "$INSTANCE_ID" ] || die "persistent volume $VOLUME_ID is attached to ${attachment:-another instance}; refusing to launch"
      attached_state="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name')" || die "cannot inspect instance attached to $VOLUME_ID"
      case "$attached_state" in
        pending|running|stopped) ;;
        shutting-down|terminated)
          info "Waiting for $VOLUME_ID to detach from terminated instance $INSTANCE_ID"
          "${AWS[@]}" ec2 wait volume-available --volume-ids "$VOLUME_ID"
          ;;
        *) die "volume $VOLUME_ID is attached to an instance in state $attached_state; wait and retry" ;;
      esac
      ;;
    *) die "persistent volume $VOLUME_ID is $state; wait or investigate" ;;
  esac
}

resolve_subnet() {
  local result
  if [ -n "$SUBNET_ID" ]; then
    result="$(aws_text ec2 describe-subnets --subnet-ids "$SUBNET_ID" --query 'Subnets[0].[VpcId,AvailabilityZone,State]')"
    VPC_ID="$(printf '%s\n' "$result" | awk '{print $1}')"
    local subnet_az subnet_state
    subnet_az="$(printf '%s\n' "$result" | awk '{print $2}')"
    subnet_state="$(printf '%s\n' "$result" | awk '{print $3}')"
    [ "$subnet_state" = "available" ] || die "subnet $SUBNET_ID is not available"
    [ -z "$AZ" ] || [ "$AZ" = "$subnet_az" ] || die "persistent EBS is in $AZ but subnet is in $subnet_az"
    AZ="$subnet_az"
    return
  fi
  VPC_ID="$(aws_text ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId')"
  [ -n "$VPC_ID" ] && [ "$VPC_ID" != "None" ] || die "no default VPC; pass --subnet-id"
  if [ -n "$AZ" ]; then
    SUBNET_ID="$(aws_text ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" "Name=availability-zone,Values=$AZ" Name=default-for-az,Values=true Name=state,Values=available --query 'Subnets[0].SubnetId')"
  else
    result="$(aws_text ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID" Name=default-for-az,Values=true Name=state,Values=available --query 'sort_by(Subnets,&AvailabilityZone)[0].[SubnetId,AvailabilityZone]')"
    SUBNET_ID="$(printf '%s\n' "$result" | awk '{print $1}')"
    AZ="$(printf '%s\n' "$result" | awk '{print $2}')"
  fi
  [ -n "$SUBNET_ID" ] && [ "$SUBNET_ID" != "None" ] || die "no default subnet found${AZ:+ in $AZ}; pass --subnet-id"
}

verify_public_route() {
  local route
  route="$(aws_text ec2 describe-route-tables --filters "Name=association.subnet-id,Values=$SUBNET_ID" --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0' && State=='active'].GatewayId | [0]")"
  if [ -z "$route" ] || [ "$route" = "None" ]; then
    route="$(aws_text ec2 describe-route-tables --filters "Name=vpc-id,Values=$VPC_ID" Name=association.main,Values=true --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0' && State=='active'].GatewayId | [0]")"
  fi
  case "$route" in igw-*) ;; *) die "subnet $SUBNET_ID has no active public route through an Internet Gateway; choose a public subnet" ;; esac
}

resolve_instance_type() {
  if [ -n "$INSTANCE_TYPE" ]; then
    local specs
    specs="$(aws_text ec2 describe-instance-types --instance-types "$INSTANCE_TYPE" --query "InstanceTypes[0].[VCpuInfo.DefaultVCpus,MemoryInfo.SizeInMiB,contains(ProcessorInfo.SupportedArchitectures, 'x86_64'),contains(SupportedRootDeviceTypes, 'ebs')]")" || die "invalid instance type: $INSTANCE_TYPE"
    case "$specs" in *True*True|*true*true) ;; *) die "$INSTANCE_TYPE is not compatible with the x86_64 EBS-backed image" ;; esac
    info "Using requested instance type $INSTANCE_TYPE ($specs)"
    return
  fi
  local memory_mib candidates candidate family preferred
  memory_mib=$((MEMORY_GIB * 1024))
  candidates="$(aws_text ec2 describe-instance-types --filters "Name=vcpu-info.default-vcpus,Values=$VCPUS" "Name=memory-info.size-in-mib,Values=$memory_mib" Name=current-generation,Values=true Name=bare-metal,Values=false Name=processor-info.supported-architecture,Values=x86_64 Name=supported-root-device-type,Values=ebs Name=supported-usage-class,Values=on-demand --query 'sort_by(InstanceTypes,&InstanceType)[].InstanceType')"
  [ -n "$candidates" ] && [ "$candidates" != "None" ] || die "no current x86_64 type exactly matches $VCPUS vCPU / $MEMORY_GIB GiB; pass --instance-type"
  for preferred in t3a t3 m7i-flex m7i m6i c7i c6i r7i r6i; do
    for candidate in $candidates; do
      family="${candidate%%.*}"
      if [ "$family" = "$preferred" ]; then INSTANCE_TYPE="$candidate"; break 2; fi
    done
  done
  [ -n "$INSTANCE_TYPE" ] || INSTANCE_TYPE="$(printf '%s\n' "$candidates" | awk '{print $1}')"
  info "Selected $INSTANCE_TYPE for exactly $VCPUS vCPU / $MEMORY_GIB GiB (override with --instance-type)"
}

verify_instance_offering() {
  local count
  count="$(aws_text ec2 describe-instance-type-offerings --location-type availability-zone --filters "Name=location,Values=$AZ" "Name=instance-type,Values=$INSTANCE_TYPE" --query 'length(InstanceTypeOfferings)')"
  [ "$count" != "0" ] || die "$INSTANCE_TYPE is not offered in $AZ; pass another --instance-type"
}

ensure_key() {
  KEY_NAME="${KEY_NAME:-aws-vm-$NAME}"
  KEY_PATH="${KEY_PATH:-$STATE_DIR/keys/$NAME}"
  if aws_text ec2 describe-key-pairs --key-names "$KEY_NAME" --query 'KeyPairs[0].KeyName' >/dev/null 2>&1; then
    [ -f "$KEY_PATH" ] || die "AWS key $KEY_NAME exists but private key $KEY_PATH is missing; choose a different NAME or restore the key"
    return
  fi
  command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen is required"
  [ ! -e "$KEY_PATH" ] && [ ! -e "$KEY_PATH.pub" ] || die "local key $KEY_PATH exists but AWS key $KEY_NAME does not; resolve this mismatch manually"
  mkdir -p "$(dirname "$KEY_PATH")"
  chmod 700 "$(dirname "$KEY_PATH")"
  umask 077
  ssh-keygen -q -t ed25519 -N '' -C "$KEY_NAME" -f "$KEY_PATH"
  aws_text ec2 import-key-pair --key-name "$KEY_NAME" --public-key-material "fileb://$KEY_PATH.pub" --query KeyPairId >/dev/null
  save_state
}

ensure_security_group() {
  local found existing managed cidr
  if [ -n "$SG_ID" ]; then
    found="$(aws_text ec2 describe-security-groups --group-ids "$SG_ID" --query 'SecurityGroups[0].VpcId' 2>/dev/null || true)"
    [ "$found" = "$VPC_ID" ] || SG_ID=""
  fi
  if [ -z "$SG_ID" ]; then
    found="$(aws_text ec2 describe-security-groups --filters "Name=group-name,Values=aws-vm-$NAME" "Name=vpc-id,Values=$VPC_ID" Name=tag:ManagedBy,Values=aws-ec2-vm --query 'SecurityGroups[0].GroupId' 2>/dev/null || true)"
    if [ -n "$found" ] && [ "$found" != "None" ]; then
      SG_ID="$found"
    else
      SG_ID="$(aws_text ec2 create-security-group --group-name "aws-vm-$NAME" --description "SSH for aws-ec2-vm $NAME" --vpc-id "$VPC_ID" --tag-specifications "ResourceType=security-group,Tags=[{Key=Name,Value=aws-vm-$NAME},{Key=ManagedBy,Value=aws-ec2-vm}]" --query GroupId)"
    fi
    save_state
  fi
  existing="$(aws_text ec2 describe-security-groups --group-ids "$SG_ID" --query 'SecurityGroups[0].IpPermissions[?IpProtocol==`tcp` && FromPort==`22` && ToPort==`22`].IpRanges[].CidrIp')"
  managed="$(aws_text ec2 describe-security-groups --group-ids "$SG_ID" --query "SecurityGroups[0].IpPermissions[?IpProtocol==\`tcp\` && FromPort==\`22\` && ToPort==\`22\`].IpRanges[?Description=='aws-ec2-vm'].CidrIp")"
  case " $existing " in *" $SSH_CIDR "*) ;; *) aws_text ec2 authorize-security-group-ingress --group-id "$SG_ID" --ip-permissions "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=$SSH_CIDR,Description=aws-ec2-vm}]" >/dev/null ;; esac
  for cidr in $managed; do
    [ "$cidr" = "$SSH_CIDR" ] || aws_text ec2 revoke-security-group-ingress --group-id "$SG_ID" --protocol tcp --port 22 --cidr "$cidr" >/dev/null
  done
}

ensure_volume() {
  if [ -n "$VOLUME_ID" ]; then return; fi
  if [ -z "$VOLUME_TOKEN" ]; then VOLUME_TOKEN="v-$ACCOUNT_ID-$(date +%s)-$$"; save_state; fi
  VOLUME_ID="$(aws_text ec2 create-volume --availability-zone "$AZ" --size "$DISK_GIB" --volume-type gp3 --encrypted --client-token "$VOLUME_TOKEN" --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$NAME-data},{Key=ManagedBy,Value=aws-ec2-vm}]" --query VolumeId)"
  save_state
  info "Created persistent volume $VOLUME_ID; it will not be deleted automatically"
  "${AWS[@]}" ec2 wait volume-available --volume-ids "$VOLUME_ID"
}

resolve_ami() {
  [ -z "$AMI_ID" ] || return 0
  AMI_ID="$(aws_text ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query Parameter.Value)"
  [ -n "$AMI_ID" ] && [ "$AMI_ID" != "None" ] || die "could not resolve Amazon Linux 2023 AMI"
}

create_instance() {
  local prior_state="" attachment=""
  if [ -n "$INSTANCE_ID" ]; then
    prior_state="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name')" || die "cannot inspect recorded instance $INSTANCE_ID"
    case "$prior_state" in
      terminated) INSTANCE_ID=""; INSTANCE_TOKEN=""; INSTANCE_READY="0"; PUBLIC_IP=""; save_state ;;
      pending|running) info "Resuming setup for $INSTANCE_ID ($prior_state)" ;;
      stopped) info "Starting partial instance $INSTANCE_ID to finish setup"; aws_text ec2 start-instances --instance-ids "$INSTANCE_ID" --query 'StartingInstances[0].CurrentState.Name' >/dev/null ;;
      shutting-down|stopping) die "instance $INSTANCE_ID is $prior_state; wait and retry" ;;
      None|'') die "recorded instance $INSTANCE_ID was not found; inspect state before retrying" ;;
      *) die "instance $INSTANCE_ID is $prior_state; cannot resume" ;;
    esac
  fi
  if [ -z "$INSTANCE_ID" ]; then
    if [ -z "$INSTANCE_TOKEN" ]; then INSTANCE_TOKEN="i-$ACCOUNT_ID-$(date +%s)-$$"; save_state; fi
    INSTANCE_ID="$(aws_text ec2 run-instances --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" --count 1 --subnet-id "$SUBNET_ID" --security-group-ids "$SG_ID" --key-name "$KEY_NAME" --associate-public-ip-address --metadata-options HttpEndpoint=enabled,HttpTokens=required --instance-initiated-shutdown-behavior stop --client-token "$INSTANCE_TOKEN" --block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"DeleteOnTermination":true,"VolumeType":"gp3"}}]' --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=ManagedBy,Value=aws-ec2-vm}]" --query 'Instances[0].InstanceId')"
    save_state
    info "Created instance $INSTANCE_ID"
  fi
  "${AWS[@]}" ec2 wait instance-running --instance-ids "$INSTANCE_ID"
  attachment="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].Attachments[0].InstanceId')"
  if [ -z "$attachment" ] || [ "$attachment" = "None" ]; then
    aws_text ec2 attach-volume --volume-id "$VOLUME_ID" --instance-id "$INSTANCE_ID" --device "$DEVICE_NAME" --query State >/dev/null
  elif [ "$attachment" != "$INSTANCE_ID" ]; then
    die "persistent volume $VOLUME_ID is unexpectedly attached to $attachment"
  fi
  "${AWS[@]}" ec2 wait volume-in-use --volume-ids "$VOLUME_ID"
  aws_text ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --block-device-mappings "[{\"DeviceName\":\"$DEVICE_NAME\",\"Ebs\":{\"DeleteOnTermination\":false}}]" >/dev/null
  local persistent
  persistent="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].BlockDeviceMappings[?DeviceName=='$DEVICE_NAME'].Ebs.DeleteOnTermination | [0]")"
  [ "$persistent" = "False" ] || [ "$persistent" = "false" ] || die "could not verify persistent attachment; volume $VOLUME_ID is retained, investigate before terminating"
  info "Waiting for EC2 health checks"
  "${AWS[@]}" ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID"
  refresh_public_ip
  INSTANCE_READY="1"
  save_state
}

refresh_public_ip() {
  PUBLIC_IP="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' 2>/dev/null || true)"
  [ "$PUBLIC_IP" != "None" ] || PUBLIC_IP=""
  save_state
}

print_commands() {
  local script
  script="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  printf '\nVM: %s  Instance: %s  Persistent EBS: %s  AZ: %s\n' "$NAME" "${INSTANCE_ID:-none}" "${VOLUME_ID:-none}" "${AZ:-unknown}"
  if [ -n "$PUBLIC_IP" ] && [ -f "$KEY_PATH" ]; then
    printf 'SSH:       ssh -i '; shell_quote "$KEY_PATH"; printf ' ec2-user@%s\n' "$PUBLIC_IP"
  else
    printf 'SSH:       %q ssh %q\n' "$script" "$NAME"
  fi
  printf 'Status:    %q status %q\n' "$script" "$NAME"
  printf 'Stop:      %q stop %q\n' "$script" "$NAME"
  printf 'Start:     %q start %q\n' "$script" "$NAME"
  printf 'Restart:   %q restart %q\n' "$script" "$NAME"
  printf 'Terminate: %q terminate %q\n' "$script" "$NAME"
  printf 'Recreate:  %q create %q\n' "$script" "$NAME"
  printf '\nState: %s\n' "$STATE_FILE"
}

print_disk_instructions() {
  cat <<'EOF'

FIRST USE ONLY - initialize the persistent disk after SSH:
  1. Run: lsblk -f
  2. Identify the unformatted disk matching the requested size (often /dev/nvme1n1).
  3. Only if it has NO filesystem/data: sudo mkfs.ext4 /dev/DEVICE
  4. sudo mkdir -p /data && sudo mount /dev/DEVICE /data
  5. Mount by UUID, not device name:
       UUID=$(sudo blkid -s UUID -o value /dev/DEVICE)
       echo "UUID=$UUID /data ext4 defaults,nofail 0 2" | sudo tee -a /etc/fstab
       sudo chown "$USER":"$USER" /data
On a reused disk, never run mkfs. Its filesystem UUID survives, but the disposable
root disk does not, so repeat the mount/fstab steps after instance recreation.
EOF
}

create_vm() {
  mkdir -p "$STATE_DIR"
  if [ -f "$STATE_FILE" ]; then load_state; fi
  ensure_auth
  local live_account
  live_account="$(aws_text sts get-caller-identity --query Account)"
  [ -z "$ACCOUNT_ID" ] || [ "$ACCOUNT_ID" = "$live_account" ] || die "state belongs to AWS account $ACCOUNT_ID, but current credentials use $live_account"
  ACCOUNT_ID="$live_account"
  if [ "$INSTANCE_READY" = "1" ] && [ -n "$INSTANCE_ID" ]; then
    local existing_state
    existing_state="$(instance_state)"
    case "$existing_state" in
      pending|running|stopping|stopped)
        die "VM '$NAME' already exists as $INSTANCE_ID ($existing_state); use '$0 status $NAME' instead"
        ;;
      shutting-down) die "VM '$NAME' is shutting down; wait, then run create again to reuse its storage" ;;
      terminated|not-found|None) INSTANCE_READY="0" ;;
      *) die "cannot safely create: recorded instance $INSTANCE_ID is $existing_state" ;;
    esac
  fi
  discover_ssh_cidr
  info "Resolving VPC, subnet, and Availability Zone"
  resolve_existing_volume
  resolve_subnet
  verify_public_route
  info "Resolving AMI and instance type"
  resolve_instance_type
  verify_instance_offering
  resolve_ami
  save_state
  ensure_key
  ensure_security_group
  info "Preparing persistent EBS storage"
  ensure_volume
  create_instance
  print_commands
  print_disk_instructions
  warn "The root disk is disposable. Data on $VOLUME_ID persists and continues to incur EBS charges."
}

instance_state() {
  aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].State.Name' 2>/dev/null || printf 'not-found\n'
}

prepare_existing() {
  load_state
  ensure_auth
  local live_account
  live_account="$(aws_text sts get-caller-identity --query Account)"
  [ "$live_account" = "$ACCOUNT_ID" ] || die "state belongs to AWS account $ACCOUNT_ID, but current credentials use $live_account"
}

status_vm() {
  prepare_existing
  local state volume_state
  state="$(instance_state)"
  volume_state="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].State' 2>/dev/null || printf 'not-found')"
  if [ "$state" = "running" ]; then refresh_public_ip; else PUBLIC_IP=""; fi
  printf 'Name:              %s\nInstance:          %s (%s)\nInstance type:     %s\nPersistent volume: %s (%s, %s GiB)\nLocation:          %s / %s\nPublic IP:         %s\n' \
    "$NAME" "$INSTANCE_ID" "$state" "$INSTANCE_TYPE" "$VOLUME_ID" "$volume_state" "$DISK_GIB" "$REGION" "$AZ" "${PUBLIC_IP:-none}"
  print_commands
}

start_vm() {
  prepare_existing
  local state
  state="$(instance_state)"
  case "$state" in
    running) info "$INSTANCE_ID is already running" ;;
    stopped) aws_text ec2 start-instances --instance-ids "$INSTANCE_ID" --query 'StartingInstances[0].CurrentState.Name' >/dev/null; "${AWS[@]}" ec2 wait instance-running --instance-ids "$INSTANCE_ID" ;;
    terminated|shutting-down|not-found|None) die "instance is $state; run '$0 create $NAME' to reuse persistent storage" ;;
    *) die "instance is $state; wait and retry" ;;
  esac
  refresh_public_ip
  print_commands
}

stop_vm() {
  prepare_existing
  local state
  state="$(instance_state)"
  case "$state" in
    stopped) info "$INSTANCE_ID is already stopped" ;;
    running) aws_text ec2 stop-instances --instance-ids "$INSTANCE_ID" --query 'StoppingInstances[0].CurrentState.Name' >/dev/null; "${AWS[@]}" ec2 wait instance-stopped --instance-ids "$INSTANCE_ID" ;;
    *) die "instance is $state; cannot stop it now" ;;
  esac
  PUBLIC_IP=""
  save_state
  warn "EBS storage still incurs charges while stopped."
  print_commands
}

restart_vm() {
  prepare_existing
  local state
  state="$(instance_state)"
  [ "$state" = "running" ] || die "instance is $state; use start instead"
  aws_text ec2 reboot-instances --instance-ids "$INSTANCE_ID" >/dev/null
  info "Restart requested for $INSTANCE_ID"
  print_commands
}

ssh_vm() {
  prepare_existing
  local state
  state="$(instance_state)"
  [ "$state" = "running" ] || die "instance is $state; run '$0 start $NAME' first"
  refresh_public_ip
  [ -n "$PUBLIC_IP" ] || die "instance has no public IPv4 address; check subnet routing or use AWS Systems Manager"
  [ -f "$KEY_PATH" ] || die "private key missing: $KEY_PATH"
  release_lock
  trap - EXIT INT TERM HUP
  exec ssh -o StrictHostKeyChecking=accept-new -i "$KEY_PATH" "ec2-user@$PUBLIC_IP"
}

confirm() {
  [ "$YES" -eq 1 ] && return 0
  [ "$NON_INTERACTIVE" -eq 0 ] || die "confirmation required; rerun with --yes"
  local answer
  printf '%s Type %s to continue: ' "$1" "$NAME" >&2
  IFS= read -r answer || true
  [ "$answer" = "$NAME" ] || die "cancelled"
}

terminate_vm() {
  prepare_existing
  local state
  state="$(instance_state)"
  case "$state" in terminated|not-found|None) info "instance is already $state"; return ;; esac
  local persistent
  aws_text ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --block-device-mappings "[{\"DeviceName\":\"$DEVICE_NAME\",\"Ebs\":{\"DeleteOnTermination\":false}}]" >/dev/null
  persistent="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query "Reservations[0].Instances[0].BlockDeviceMappings[?Ebs.VolumeId=='$VOLUME_ID'].Ebs.DeleteOnTermination | [0]")"
  [ "$persistent" = "False" ] || [ "$persistent" = "false" ] || die "persistent volume protection could not be verified; refusing termination"
  confirm "Terminate instance $INSTANCE_ID? Persistent volume $VOLUME_ID will be kept."
  aws_text ec2 terminate-instances --instance-ids "$INSTANCE_ID" --query 'TerminatingInstances[0].CurrentState.Name' >/dev/null
  "${AWS[@]}" ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
  PUBLIC_IP=""
  INSTANCE_READY="0"
  save_state
  info "Instance terminated. Persistent volume retained: $VOLUME_ID"
  printf 'Recreate in %s with: %q create %q\n' "$AZ" "$0" "$NAME"
  warn "The retained EBS volume continues to incur charges."
  print_commands
}

destroy_storage() {
  prepare_existing
  [ -n "$VOLUME_ID" ] || die "state has no persistent volume"
  local attachment
  attachment="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].Attachments[0].InstanceId' 2>/dev/null || true)"
  if [ -n "$attachment" ] && [ "$attachment" != "None" ]; then
    die "volume $VOLUME_ID is attached to $attachment; terminate that instance and wait before deleting storage"
  fi
  confirm "PERMANENTLY delete $VOLUME_ID and all data? This cannot be undone."
  aws_text ec2 delete-volume --volume-id "$VOLUME_ID" >/dev/null
  info "Deleted persistent volume $VOLUME_ID"
  VOLUME_ID=""
  VOLUME_TOKEN=""
  save_state
  print_commands
}

main() {
  parse_args "$@"
  [ "$COMMAND" = "help" ] && { usage; exit 0; }
  [ "$COMMAND" = "version" ] && { printf '%s\n' "$VERSION"; exit 0; }
  validate_args
  STATE_FILE="$STATE_DIR/$NAME.state"
  case "$COMMAND" in setup) ;; *) acquire_lock ;; esac
  case "$COMMAND" in
    setup) setup ;;
    create) create_vm ;;
    status) status_vm ;;
    ssh) ssh_vm ;;
    start) start_vm ;;
    restart) restart_vm ;;
    stop) stop_vm ;;
    terminate) terminate_vm ;;
    destroy-storage) destroy_storage ;;
  esac
}

main "$@"
