#!/usr/bin/env bash
set -Eeuo pipefail

readonly VERSION="1.2.0"
readonly DEFAULT_NAME="dev-vm"
readonly DEFAULT_VCPUS="2"
readonly DEFAULT_MEMORY_GIB="4"
readonly DEFAULT_MODEL_VCPUS="4"
readonly DEFAULT_MODEL_MEMORY_GIB="16"
readonly DEFAULT_DISK_GIB="50"
readonly DEFAULT_ROOT_DISK_GIB="30"
readonly DEFAULT_MODEL="gemma3:4b"
readonly OLLAMA_PORT="11434"
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
VCPUS_EXPLICIT=0
MEMORY_EXPLICIT=0
DISK_EXPLICIT=0
VCPUS_SAVED=0
MEMORY_SAVED=0
INSTANCE_TYPE=""
INSTANCE_TYPE_EXPLICIT=0
SUBNET_ID=""
SSH_CIDR=""
PORT=""
PORT_CIDR=""
PORT_CIDR_EXPLICIT=0
MODEL="$DEFAULT_MODEL"
MODEL_EXPLICIT=0
OLLAMA_CIDR=""
OLLAMA_READY="0"
OLLAMA_MODE=""
YES=0
NON_INTERACTIVE=0
STATE_DIR="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
STATE_FILE=""
AWS=()
SSH_FORWARD_AGENT=0
SSH_TTY=0
SSH_QUIET="${AWS_VM_SSH_QUIET:-0}"
SSH_QUIET_OPTION=0
SSH_CONTROL_PATH="${AWS_VM_SSH_CONTROL_PATH:-}"
SSH_CONTROL_COMMAND="${AWS_VM_SSH_CONTROL_COMMAND:-}"
SSH_REMOTE_COMMAND=()
SSH_KNOWN_HOSTS=""
SSH_ARGS=()
MOUNT_DIR=""
MOUNT_DIR_EXPLICIT=0
INSTALL_DEPS=0
FORCE=0
RECOVER_STALE_MOUNT=0
STORAGE_UUID=""
STORAGE_RESULT=""
MOUNT_CONFIG=""
SSHFS_BIN=""

readonly DATA_MARKER=".aws-ec2-vm-volume"
readonly SSHFS_VERSION="3.7.6"
readonly SSHFS_SHA256="6a1bcb31450a077e9cb1b7ff158c71de34db697c3c0da6cb362502131e495893"

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
ROOT_DEVICE_NAME=""
ROOT_DISK_GIB="$DEFAULT_ROOT_DISK_GIB"
PUBLIC_IP=""
PUBLIC_DNS=""
VOLUME_TOKEN=""
INSTANCE_TOKEN=""
INSTANCE_READY="0"
LOCK_DIR=""
MOUNT_PATH_LOCK_DIR=""
MOUNT_CLAIM_FILE=""

info() { printf '==> %s\n' "$*" >&2; }
warn() { printf 'Warning: %s\n' "$*" >&2; }
die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
shell_quote() { printf '%q' "$1"; }

usage() {
  cat <<'EOF'
aws-ec2-vm.sh - create a small EC2 development VM with optional Ollama

USAGE
  aws-ec2-vm.sh setup [--profile PROFILE] [--region REGION]
  aws-ec2-vm.sh create [NAME] [OPTIONS]
  aws-ec2-vm.sh {status|ssh|start|restart|stop|terminate} [NAME] [OPTIONS]
  aws-ec2-vm.sh {init-storage|prepare} [NAME] [OPTIONS]
  aws-ec2-vm.sh mount [NAME] [--mount-dir PATH] [--install-deps] [OPTIONS]
  aws-ec2-vm.sh unmount [NAME] [--mount-dir PATH] [--force]
  aws-ec2-vm.sh expose-port NAME PORT [--cidr CIDR] [OPTIONS]
  aws-ec2-vm.sh close-port NAME PORT [OPTIONS]
  aws-ec2-vm.sh destroy-storage [NAME] [--yes] [OPTIONS]

CREATE OPTIONS
  --vcpus N             Exact vCPU count (default: 2, or 4 with --model)
  --memory GIB          Exact RAM in GiB (default: 4, or 16 with --model)
  --instance-type TYPE  Use this EC2 type instead of resolving vCPU/RAM
  --disk GIB            Persistent encrypted gp3 data disk (default: 50)
  --subnet-id ID        Subnet to use; otherwise a default subnet is selected
  --ssh-cidr CIDR       IPv4 CIDR allowed to SSH; default: your public IP /32
  --model MODEL         Opt into Ollama and pull/test MODEL (recommended: gemma3:4b)
  --cidr CIDR           IPv4 CIDR allowed to reach Ollama; requires Ollama mode

COMMON OPTIONS
  --profile PROFILE     AWS CLI profile (default: AWS_PROFILE or default)
  --region REGION       AWS region (default: profile region or us-east-1)
  --yes                 Skip destructive confirmation
  --non-interactive     Never prompt; fail when input/authentication is needed
  -h, --help            Show help

STORAGE OPTIONS
  --mount-dir PATH      Local data mountpoint (default: ~/mnt/aws-ec2-vm/NAME)
  --install-deps        Install macFUSE/build dependencies and verified SSHFS
  --force               Force only an unresponsive managed mount to unmount

SSH OPTIONS
  --forward-agent       Forward the local SSH agent for this connection
  --tty                 Force pseudo-terminal allocation
  --quiet               Suppress non-error OpenSSH client diagnostics
  -- COMMAND [ARG...]   Run a remote command with arguments preserved safely

PORT OPTIONS
  --cidr CIDR           IPv4 CIDR for model create or expose-port; default: your public IP /32

EXAMPLES
  ./aws-ec2-vm.sh setup
  ./aws-ec2-vm.sh create                    # small 2 vCPU / 4 GiB development VM
  ./aws-ec2-vm.sh create llmbox --model gemma4 --instance-type g6.xlarge --disk 100
  ./aws-ec2-vm.sh create devbox --vcpus 4 --memory 8 --disk 200
  ./aws-ec2-vm.sh status mlbox
  ./aws-ec2-vm.sh ssh mlbox
  ./aws-ec2-vm.sh ssh mlbox --forward-agent -- git status
  ./aws-ec2-vm.sh init-storage mlbox # first use only; requires exact TTY confirmation
  ./aws-ec2-vm.sh prepare mlbox      # safely mount and prepare persistent paths
  ./aws-ec2-vm.sh mount mlbox        # mount /data at ~/mnt/aws-ec2-vm/mlbox
  ./aws-ec2-vm.sh unmount mlbox
  ./aws-ec2-vm.sh stop mlbox
  ./aws-ec2-vm.sh start mlbox
  ./aws-ec2-vm.sh expose-port mlbox 8080                    # your current IP only
  ./aws-ec2-vm.sh expose-port mlbox 3000 --cidr 0.0.0.0/0  # public internet
  ./aws-ec2-vm.sh expose-port mlbox 8443 --cidr 203.0.113.0/24
  ./aws-ec2-vm.sh close-port mlbox 8080
  ./aws-ec2-vm.sh terminate mlbox       # keeps mlbox's data EBS volume
  ./aws-ec2-vm.sh create mlbox          # new VM, same persistent volume
  ./aws-ec2-vm.sh destroy-storage mlbox # permanently deletes that volume

STORAGE AND COST
  The AMI-sized root disk is disposable (Ollama mode uses at least 30 GiB). A
  separate encrypted EBS volume is attached with DeleteOnTermination=false, so
  it survives reboot, stop, and termination.
  EBS is tied to one Availability Zone; replacement VMs are created there.
  Stopped VMs and retained EBS volumes can still cost money. AWS also charges
  for public IPv4 while allocated. Public IPv4 may change after stop/start. The
  script never deletes persistent storage as part of termination or failure.

  The data disk is never formatted automatically. On first use, run
  `init-storage`; it proves the EBS/NVMe identity and blank state, then requires
  the exact TTY phrase it prints. `prepare` never formats storage.

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
    setup|create|status|ssh|start|restart|stop|terminate|init-storage|prepare|mount|unmount|expose-port|close-port|destroy-storage|version) ;;
    *) die "unknown command: $COMMAND (run --help)" ;;
  esac

  if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then
    NAME="$1"
    shift
  fi

  if [ "$COMMAND" = "expose-port" ] || [ "$COMMAND" = "close-port" ]; then
    [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ] || die "$COMMAND requires NAME and PORT"
    PORT="$1"
    shift
  fi

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --)
        [ "$COMMAND" = "ssh" ] || die "-- COMMAND is supported only by ssh"
        shift
        [ "$#" -gt 0 ] || die "-- requires a remote command"
        SSH_REMOTE_COMMAND=("$@")
        break
        ;;
      --profile) need_value "$@"; PROFILE="$2"; PROFILE_EXPLICIT=1; shift 2 ;;
      --region) need_value "$@"; REGION="$2"; REGION_EXPLICIT=1; shift 2 ;;
      --vcpus) need_value "$@"; VCPUS="$2"; VCPUS_EXPLICIT=1; shift 2 ;;
      --memory) need_value "$@"; MEMORY_GIB="$2"; MEMORY_EXPLICIT=1; shift 2 ;;
      --disk) need_value "$@"; DISK_GIB="$2"; DISK_EXPLICIT=1; shift 2 ;;
      --instance-type) need_value "$@"; INSTANCE_TYPE="$2"; INSTANCE_TYPE_EXPLICIT=1; shift 2 ;;
      --subnet-id) need_value "$@"; SUBNET_ID="$2"; shift 2 ;;
      --ssh-cidr) need_value "$@"; SSH_CIDR="$2"; shift 2 ;;
      --model) need_value "$@"; MODEL="$2"; MODEL_EXPLICIT=1; shift 2 ;;
      --cidr) need_value "$@"; PORT_CIDR="$2"; PORT_CIDR_EXPLICIT=1; shift 2 ;;
      --forward-agent) SSH_FORWARD_AGENT=1; shift ;;
      --tty) SSH_TTY=1; shift ;;
      --quiet) SSH_QUIET=1; SSH_QUIET_OPTION=1; shift ;;
      --mount-dir) need_value "$@"; MOUNT_DIR="$2"; MOUNT_DIR_EXPLICIT=1; shift 2 ;;
      --install-deps) INSTALL_DEPS=1; shift ;;
      --recover-stale-mount) RECOVER_STALE_MOUNT=1; shift ;;
      --force) FORCE=1; shift ;;
      --yes) YES=1; shift ;;
      --non-interactive) NON_INTERACTIVE=1; shift ;;
      -h|--help) COMMAND="help"; shift ;;
      *) die "unknown option: $1" ;;
    esac
  done
}

validate_args() {
  validate_name
  case "$SSH_QUIET" in 0|1) ;; *) die "AWS_VM_SSH_QUIET must be 0 or 1" ;; esac
  is_uint "$VCPUS" || die "--vcpus must be a positive integer"
  is_uint "$MEMORY_GIB" || die "--memory must be a positive integer"
  is_uint "$DISK_GIB" || die "--disk must be a positive integer"
  case "$VCPUS:$MEMORY_GIB:$DISK_GIB" in *:0*|0*) die "numeric values must not have leading zeros" ;; esac
  [ "$DISK_GIB" -le 16384 ] || die "--disk exceeds gp3's 16384 GiB limit"
  case "$REGION" in *[!a-z0-9-]*) [ -z "$REGION" ] || die "invalid region: $REGION" ;; esac
  case "$PROFILE" in ''|*[!a-zA-Z0-9_+=,.@-]*) die "invalid profile name" ;; esac
  [ -z "$SSH_CIDR" ] || valid_cidr "$SSH_CIDR" || die "invalid IPv4 CIDR: $SSH_CIDR"
  [[ "$MODEL" =~ ^[a-zA-Z0-9][a-zA-Z0-9._:/-]*$ ]] || die "invalid Ollama model: $MODEL"
  if [ "$COMMAND" = "expose-port" ] || [ "$COMMAND" = "close-port" ]; then
    is_uint "$PORT" || die "PORT must be an integer from 1 to 65535"
    case "$PORT" in 0*) die "PORT must not have leading zeros" ;; esac
    [ "$PORT" -le 65535 ] || die "PORT must be an integer from 1 to 65535"
    [ "$PORT" -ne 22 ] || die "port 22 is managed as SSH access; use create --ssh-cidr to configure it"
  fi
  [ -z "$PORT_CIDR" ] || valid_cidr "$PORT_CIDR" || die "invalid IPv4 CIDR: $PORT_CIDR"
  [ "$COMMAND" = "expose-port" ] || [ "$COMMAND" = "create" ] || [ -z "$PORT_CIDR" ] || die "--cidr is supported only by create and expose-port"
  [ "$COMMAND" = "create" ] || [ "$MODEL_EXPLICIT" -eq 0 ] || die "--model is supported only by create"
  if [ "$MOUNT_DIR_EXPLICIT" -eq 1 ]; then
    [ -n "$MOUNT_DIR" ] || die "--mount-dir requires a non-empty path"
    case "$MOUNT_DIR" in *[[:cntrl:]]*) die "--mount-dir must not contain control characters" ;; esac
  fi
  case "$STATE_DIR" in *[[:cntrl:]]*) die "AWS_VM_STATE_DIR must not contain control characters" ;; esac
  case "$COMMAND" in mount|unmount) ;; *) [ "$MOUNT_DIR_EXPLICIT" -eq 0 ] || die "--mount-dir is supported only by mount and unmount" ;; esac
  [ "$COMMAND" = "mount" ] || [ "$INSTALL_DEPS" -eq 0 ] || die "--install-deps is supported only by mount"
  [ "$COMMAND" = "mount" ] || [ "$RECOVER_STALE_MOUNT" -eq 0 ] || die "--recover-stale-mount is supported only by mount"
  [ "$COMMAND" = "unmount" ] || [ "$FORCE" -eq 0 ] || die "--force is supported only by unmount"
  if [ "$COMMAND" = "unmount" ]; then
    [ "$PROFILE_EXPLICIT" -eq 0 ] || die "--profile is not used by fully local unmount"
    [ "$REGION_EXPLICIT" -eq 0 ] || die "--region is not used by fully local unmount"
    [ "$YES" -eq 0 ] || die "--yes is not used by unmount; use --force only for an unresponsive managed mount"
    [ "$NON_INTERACTIVE" -eq 0 ] || die "--non-interactive is not used by fully local unmount"
  fi
  if [ "$COMMAND" = "init-storage" ]; then
    [ "$YES" -eq 0 ] || die "init-storage does not accept --yes; exact TTY confirmation is required"
    [ "$NON_INTERACTIVE" -eq 0 ] || die "init-storage does not accept --non-interactive; exact TTY confirmation is required"
  fi
  if [ "$COMMAND" != "ssh" ] && { [ "$SSH_FORWARD_AGENT" -eq 1 ] || [ "$SSH_TTY" -eq 1 ] || [ "$SSH_QUIET_OPTION" -eq 1 ] || [ "${#SSH_REMOTE_COMMAND[@]}" -gt 0 ]; }; then
    die "SSH options are supported only by ssh"
  fi
  if [ -n "$SSH_CONTROL_PATH" ]; then
    case "$SSH_CONTROL_PATH" in /*) ;; *) die "AWS_VM_SSH_CONTROL_PATH must be absolute" ;; esac
    case "$SSH_CONTROL_PATH" in *[[:cntrl:]]*) die "AWS_VM_SSH_CONTROL_PATH must not contain control characters" ;; esac
    case "$SSH_CONTROL_PATH" in *%*) die "AWS_VM_SSH_CONTROL_PATH must not contain percent expansions" ;; esac
    [ "$(LC_ALL=C printf %s "$SSH_CONTROL_PATH" | wc -c | tr -d ' ')" -le 90 ] || die "AWS_VM_SSH_CONTROL_PATH is too long"
  fi
  case "$SSH_CONTROL_COMMAND" in ''|check|exit|attach) ;; *) die "invalid AWS_VM_SSH_CONTROL_COMMAND" ;; esac
  [ -z "$SSH_CONTROL_COMMAND" ] || { [ "$COMMAND" = "ssh" ] && [ -n "$SSH_CONTROL_PATH" ]; } ||
    die "AWS_VM_SSH_CONTROL_COMMAND requires ssh and AWS_VM_SSH_CONTROL_PATH"
  case "$SSH_CONTROL_COMMAND" in
    check|exit) [ "${#SSH_REMOTE_COMMAND[@]}" -eq 0 ] || die "AWS_VM_SSH_CONTROL_COMMAND=$SSH_CONTROL_COMMAND does not accept a remote command" ;;
  esac
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

canonicalize_cidr() {
  valid_cidr "$1" || return 1
  awk -F'[./]' '{
    ip = ((($1 * 256) + $2) * 256 + $3) * 256 + $4
    block = 2 ^ (32 - $5)
    ip = int(ip / block) * block
    printf "%d.%d.%d.%d/%d\n", int(ip / 16777216), int(ip / 65536) % 256,
      int(ip / 256) % 256, ip % 256, $5
  }' <<EOF
$1
EOF
}

save_state() {
  mkdir -p "$STATE_DIR"
  chmod 700 "$STATE_DIR"
  local tmp="$STATE_FILE.tmp.$$" key value
  umask 077
  : > "$tmp"
  for key in PROFILE REGION ACCOUNT_ID INSTANCE_ID VOLUME_ID VPC_ID SUBNET_ID AZ SG_ID KEY_NAME KEY_PATH AMI_ID INSTANCE_TYPE VCPUS MEMORY_GIB DISK_GIB PUBLIC_IP VOLUME_TOKEN INSTANCE_TOKEN INSTANCE_READY MODEL OLLAMA_MODE OLLAMA_CIDR OLLAMA_READY; do
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
  local key value saved_profile="" saved_region="" ollama_mode_present=0
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
      INSTANCE_TYPE) [ "$INSTANCE_TYPE_EXPLICIT" -eq 1 ] || INSTANCE_TYPE="$value" ;;
      VCPUS) VCPUS_SAVED=1; [ "$VCPUS_EXPLICIT" -eq 1 ] || VCPUS="$value" ;;
      MEMORY_GIB) MEMORY_SAVED=1; [ "$MEMORY_EXPLICIT" -eq 1 ] || MEMORY_GIB="$value" ;;
      DISK_GIB) [ "$DISK_EXPLICIT" -eq 1 ] || DISK_GIB="$value" ;;
      SPOT) case "$value" in 0|1) ;; *) die "invalid legacy Spot marker in state" ;; esac ;;
      PUBLIC_IP) PUBLIC_IP="$value" ;;
      VOLUME_TOKEN) VOLUME_TOKEN="$value" ;;
      INSTANCE_TOKEN) INSTANCE_TOKEN="$value" ;;
      INSTANCE_READY) INSTANCE_READY="$value" ;;
      MODEL) [ "$MODEL_EXPLICIT" -eq 1 ] || MODEL="$value" ;;
      OLLAMA_MODE) OLLAMA_MODE="$value"; ollama_mode_present=1 ;;
      OLLAMA_CIDR) OLLAMA_CIDR="$value" ;;
      OLLAMA_READY) OLLAMA_READY="$value" ;;
      '') ;;
      *) die "unknown field in state file: $key" ;;
    esac
  done < "$STATE_FILE"
  [ "$PROFILE_EXPLICIT" -eq 0 ] || [ "$PROFILE" = "$saved_profile" ] || die "state uses profile '$saved_profile', not requested '$PROFILE'"
  [ "$REGION_EXPLICIT" -eq 0 ] || [ "$REGION" = "$saved_region" ] || die "state uses region '$saved_region', not requested '$REGION'"
  PROFILE="$saved_profile"; REGION="$saved_region"
  if [ "$ollama_mode_present" -eq 0 ]; then
    if [ -n "$OLLAMA_CIDR" ] || [ "$OLLAMA_READY" = "1" ]; then OLLAMA_MODE="1"; else OLLAMA_MODE="0"; fi
  fi
  if [ "$OLLAMA_MODE" = "1" ]; then
    [ "$VCPUS_EXPLICIT" -eq 1 ] || [ "$VCPUS_SAVED" -eq 1 ] || VCPUS="$DEFAULT_MODEL_VCPUS"
    [ "$MEMORY_EXPLICIT" -eq 1 ] || [ "$MEMORY_SAVED" -eq 1 ] || MEMORY_GIB="$DEFAULT_MODEL_MEMORY_GIB"
  fi
  case "$INSTANCE_ID" in ''|i-*) ;; *) die "invalid instance ID in state" ;; esac
  case "${INSTANCE_ID#i-}" in ''|*[!a-zA-Z0-9]*) [ -z "$INSTANCE_ID" ] || die "invalid instance ID in state" ;; esac
  case "$VOLUME_ID" in ''|vol-[a-zA-Z0-9]*) ;; *) die "invalid volume ID in state" ;; esac
  case "$SG_ID" in ''|sg-[a-zA-Z0-9]*) ;; *) die "invalid security group ID in state" ;; esac
  case "$INSTANCE_READY" in 0|1) ;; *) die "invalid readiness marker in state" ;; esac
  is_uint "$VCPUS" || die "invalid vCPU count in state"
  is_uint "$MEMORY_GIB" || die "invalid memory size in state"
  case "$VCPUS:$MEMORY_GIB" in *:0*|0*) die "invalid numeric value with leading zeros in state" ;; esac
  is_uint "$DISK_GIB" || die "invalid disk size in state"
  [[ "$MODEL" =~ ^[a-zA-Z0-9][a-zA-Z0-9._:/-]*$ ]] || die "invalid Ollama model in state"
  [ -z "$OLLAMA_CIDR" ] || valid_cidr "$OLLAMA_CIDR" || die "invalid Ollama CIDR in state"
  case "$OLLAMA_READY" in 0|1) ;; *) die "invalid Ollama readiness marker in state" ;; esac
  case "$OLLAMA_MODE" in 0|1) ;; *) die "invalid Ollama mode marker in state" ;; esac
}

release_mount_path_lock() {
  [ -n "$MOUNT_PATH_LOCK_DIR" ] || return 0
  rm -f -- "$MOUNT_PATH_LOCK_DIR/owner" 2>/dev/null || true
  rm -f -- "$MOUNT_PATH_LOCK_DIR/path" 2>/dev/null || true
  rmdir "$MOUNT_PATH_LOCK_DIR" 2>/dev/null || true
  MOUNT_PATH_LOCK_DIR=""
}

release_lock() {
  release_mount_path_lock
  [ -z "$LOCK_DIR" ] || rm -f -- "$LOCK_DIR/owner" 2>/dev/null || true
  [ -z "$LOCK_DIR" ] || rmdir "$LOCK_DIR" 2>/dev/null || true
}

write_lock_owner() {
  local lock="$1" host start tmp
  host="$(/bin/hostname)" || return 1
  start="$(/bin/ps -o lstart= -p "$$")" || return 1
  [ -n "$host" ] && [ -n "$start" ] || return 1
  case "$host$start" in *$'\n'*|*$'\r'*) return 1 ;; esac
  tmp="$lock/owner.tmp.$$"
  umask 077
  printf 'PID=%s\nHOST=%s\nSTART=%s\n' "$$" "$host" "$start" > "$tmp" || return 1
  chmod 600 "$tmp" || return 1
  mv -f -- "$tmp" "$lock/owner" || return 1
}

reclaim_stale_lock() {
  local lock="$1" description="$2" expected_path="${3:-}" key value pid="" saved_host="" saved_start="" host metadata current tombstone permissions links stored
  local pid_count=0 host_count=0 start_count=0
  local -a entries=()
  [ ! -L "$lock" ] && [ -d "$lock" ] && [ -O "$lock" ] || die "$description lock is insecure: $lock"
  [ ! -L "$lock/owner" ] && [ -f "$lock/owner" ] && [ -O "$lock/owner" ] || die "$description lock has malformed owner metadata; inspect manually: $lock"
  read -r permissions links <<< "$(stat -f '%Lp %l' "$lock/owner" 2>/dev/null || stat -c '%a %h' "$lock/owner" 2>/dev/null || true)"
  [ "$permissions" = "600" ] && [ "$links" = "1" ] || die "$description lock owner metadata is not a private, single-link file: $lock"
  metadata="$(/bin/cat "$lock/owner")" || die "cannot read $description lock metadata: $lock"
  while IFS='=' read -r key value; do
    case "$key" in PID) pid="$value"; pid_count=$((pid_count + 1)) ;; HOST) saved_host="$value"; host_count=$((host_count + 1)) ;; START) saved_start="$value"; start_count=$((start_count + 1)) ;; *) die "$description lock has unknown owner metadata; inspect manually: $lock" ;; esac
  done <<< "$metadata"
  [ "$pid_count" -eq 1 ] && [ "$host_count" -eq 1 ] && [ "$start_count" -eq 1 ] || die "$description lock owner metadata has duplicate or missing fields: $lock"
  case "$pid" in ''|*[!0-9]*) die "$description lock has an invalid PID; inspect manually: $lock" ;; esac
  [ -n "$saved_host" ] && [ -n "$saved_start" ] || die "$description lock metadata is incomplete; inspect manually: $lock"
  host="$(/bin/hostname)" || die "cannot identify the local host to inspect $description lock"
  [ "$saved_host" = "$host" ] || die "$description lock belongs to host $saved_host; inspect manually: $lock"
  if kill -0 "$pid" 2>/dev/null; then
    current="$(/bin/ps -o lstart= -p "$pid" 2>/dev/null || true)"
    [ "$current" = "$saved_start" ] && die "$description is held by live PID $pid on $host"
    die "$description lock PID $pid was reused or is ambiguous; inspect manually: $lock"
  fi
  [ "$(/bin/cat "$lock/owner" 2>/dev/null || true)" = "$metadata" ] || die "$description lock changed during stale inspection; retry"
  tombstone="$lock.stale.$$.$RANDOM"
  [ ! -e "$tombstone" ] && [ ! -L "$tombstone" ] || die "stale-lock tombstone unexpectedly exists: $tombstone"
  mv -- "$lock" "$tombstone" 2>/dev/null || die "$description lock changed while reclaiming; retry"
  [ "$(/bin/cat "$tombstone/owner" 2>/dev/null || true)" = "$metadata" ] || die "reclaimed $description lock metadata changed; inspect $tombstone"
  read -r permissions links <<< "$(stat -f '%Lp %l' "$tombstone/owner" 2>/dev/null || stat -c '%a %h' "$tombstone/owner" 2>/dev/null || true)"
  [ "$permissions" = "600" ] && [ "$links" = "1" ] || die "reclaimed $description owner metadata changed security properties"
  [ ! -L "$tombstone" ] && [ -d "$tombstone" ] && [ -O "$tombstone" ] || die "reclaimed $description lock is insecure: $tombstone"
  permissions="$(stat -f '%Lp' "$tombstone" 2>/dev/null || stat -c '%a' "$tombstone" 2>/dev/null || true)"
  [ "$permissions" = "700" ] || die "reclaimed $description lock directory is not mode 0700: $tombstone"
  shopt -s nullglob dotglob
  entries=("$tombstone"/*)
  shopt -u dotglob
  if [ -n "$expected_path" ]; then
    [ "${#entries[@]}" -eq 2 ] && [ -e "$tombstone/owner" ] && [ -e "$tombstone/path" ] || die "reclaimed $description lock has unexpected metadata: $tombstone"
    [ ! -L "$tombstone/path" ] && [ -f "$tombstone/path" ] && [ -O "$tombstone/path" ] || die "reclaimed $description lock path metadata is insecure: $tombstone"
    read -r permissions links <<< "$(stat -f '%Lp %l' "$tombstone/path" 2>/dev/null || stat -c '%a %h' "$tombstone/path" 2>/dev/null || true)"
    [ "$permissions" = "600" ] && [ "$links" = "1" ] || die "reclaimed $description lock path metadata is not private and single-link"
    stored="$(< "$tombstone/path")"
    [ "$stored" = "$expected_path" ] || die "reclaimed $description lock path does not match $expected_path"
    rm -f -- "$tombstone/path"
  else
    [ "${#entries[@]}" -eq 1 ] && [ -e "$tombstone/owner" ] || die "reclaimed $description lock has unexpected metadata: $tombstone"
  fi
  rm -f -- "$tombstone/owner"
  rmdir "$tombstone" || die "reclaimed $description lock contained unexpected files: $tombstone"
}

acquire_lock() {
  [ ! -L "$STATE_DIR" ] || die "refusing symlinked state directory: $STATE_DIR"
  [ ! -e "$STATE_DIR" ] || [ -d "$STATE_DIR" ] || die "state path is not a directory: $STATE_DIR"
  mkdir -p "$STATE_DIR"
  [ -O "$STATE_DIR" ] || die "state directory is not owned by the current user: $STATE_DIR"
  chmod 700 "$STATE_DIR"
  LOCK_DIR="$STATE_FILE.lock"
  if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    reclaim_stale_lock "$LOCK_DIR" "operation for '$NAME'"
    mkdir "$LOCK_DIR" 2>/dev/null || die "another operation for '$NAME' acquired the lock; retry"
  fi
  trap release_lock EXIT
  trap 'release_lock; exit 130' INT
  trap 'release_lock; exit 143' TERM
  trap 'release_lock; exit 129' HUP
  chmod 700 "$LOCK_DIR"
  write_lock_owner "$LOCK_DIR" || die "could not record lock ownership for '$NAME'"
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

discover_port_cidr() {
  if [ -n "$PORT_CIDR" ]; then
    local prefix="${PORT_CIDR#*/}"
    PORT_CIDR="$(canonicalize_cidr "$PORT_CIDR")" || die "invalid IPv4 CIDR: $PORT_CIDR"
    [ "$prefix" -eq 32 ] || warn "Exposing TCP port $PORT to the broad CIDR $PORT_CIDR"
    return
  fi
  command -v curl >/dev/null 2>&1 || die "pass --cidr because curl is unavailable"
  local ip
  ip="$(curl -fsS --max-time 10 https://checkip.amazonaws.com 2>/dev/null | tr -d '[:space:]' || true)"
  PORT_CIDR="$(canonicalize_cidr "$ip/32")" || die "could not detect your public IPv4 address; pass --cidr YOUR_IP/32"
  info "TCP port $PORT access restricted to $PORT_CIDR"
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
  if [ -z "$AMI_ID" ]; then
    AMI_ID="$(aws_text ssm get-parameter --name /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query Parameter.Value)"
  fi
  [ -n "$AMI_ID" ] && [ "$AMI_ID" != "None" ] || die "could not resolve Amazon Linux 2023 AMI"
  if [ "$OLLAMA_MODE" = "1" ]; then
    ROOT_DEVICE_NAME="$(aws_text ec2 describe-images --image-ids "$AMI_ID" --query 'Images[0].RootDeviceName')"
    [[ "$ROOT_DEVICE_NAME" =~ ^/dev/[a-zA-Z0-9._-]+$ ]] || die "AMI $AMI_ID has an invalid root device"
    local ami_root_disk_gib
    ami_root_disk_gib="$(aws_text ec2 describe-images --image-ids "$AMI_ID" --query "Images[0].BlockDeviceMappings[?DeviceName=='$ROOT_DEVICE_NAME'].Ebs.VolumeSize | [0]")"
    is_uint "$ami_root_disk_gib" || die "AMI $AMI_ID has an invalid root volume size"
    if [ "$ami_root_disk_gib" -gt "$ROOT_DISK_GIB" ]; then ROOT_DISK_GIB="$ami_root_disk_gib"; fi
  fi
}

create_instance() {
  local prior_state="" attachment=""
  local -a root_mapping=()
  if [ -n "$INSTANCE_ID" ]; then
    prior_state="$(instance_state)"
    case "$prior_state" in
      terminated|not-found|None|'') INSTANCE_ID=""; INSTANCE_TOKEN=""; INSTANCE_READY="0"; PUBLIC_IP=""; save_state ;;
      pending|running) info "Resuming setup for $INSTANCE_ID ($prior_state)" ;;
      stopped) info "Starting partial instance $INSTANCE_ID to finish setup"; aws_text ec2 start-instances --instance-ids "$INSTANCE_ID" --query 'StartingInstances[0].CurrentState.Name' >/dev/null ;;
      shutting-down|stopping) die "instance $INSTANCE_ID is $prior_state; wait and retry" ;;
      *) die "instance $INSTANCE_ID is $prior_state; cannot resume" ;;
    esac
  fi
  if [ -z "$INSTANCE_ID" ]; then
    if [ -z "$INSTANCE_TOKEN" ]; then INSTANCE_TOKEN="i-$ACCOUNT_ID-$(date +%s)-$$"; save_state; fi
    if [ "$OLLAMA_MODE" = "1" ]; then
      root_mapping=(--block-device-mappings "[{\"DeviceName\":\"$ROOT_DEVICE_NAME\",\"Ebs\":{\"DeleteOnTermination\":true,\"Encrypted\":true,\"VolumeType\":\"gp3\",\"VolumeSize\":$ROOT_DISK_GIB}}]")
    else
      root_mapping=(--block-device-mappings '[{"DeviceName":"/dev/xvda","Ebs":{"DeleteOnTermination":true,"VolumeType":"gp3"}}]')
    fi
    INSTANCE_ID="$(aws_text ec2 run-instances --image-id "$AMI_ID" --instance-type "$INSTANCE_TYPE" --count 1 --subnet-id "$SUBNET_ID" --security-group-ids "$SG_ID" --key-name "$KEY_NAME" --associate-public-ip-address --metadata-options HttpEndpoint=enabled,HttpTokens=required --instance-initiated-shutdown-behavior stop --client-token "$INSTANCE_TOKEN" "${root_mapping[@]}" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=ManagedBy,Value=aws-ec2-vm}]" --query 'Instances[0].InstanceId')"
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
}

refresh_public_ip() {
  PUBLIC_IP="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' 2>/dev/null || true)"
  [ "$PUBLIC_IP" != "None" ] || PUBLIC_IP=""
  PUBLIC_DNS="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicDnsName' 2>/dev/null || true)"
  [ "$PUBLIC_DNS" != "None" ] || PUBLIC_DNS=""
  save_state
}

print_commands() {
  local script
  script="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
  printf '\nVM: %s  Instance: %s  Persistent EBS: %s  AZ: %s\n' "$NAME" "${INSTANCE_ID:-none}" "${VOLUME_ID:-none}" "${AZ:-unknown}"
  printf 'SSH:       %q ssh %q\n' "$script" "$NAME"
  printf 'Public DNS: %s\n' "${PUBLIC_DNS:-none}"
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

PERSISTENT STORAGE
  First use only: run this script's `init-storage NAME` command. It formats only
  after exact AWS attachment, Nitro serial, blank-device, and TTY confirmation
  checks. Then run `prepare NAME`. On reused storage, run only `prepare NAME`.
  Never run mkfs manually or use init-storage to repair an existing filesystem.
EOF
}

configure_ollama_cidr() {
  PORT="$OLLAMA_PORT"
  [ -n "$PORT_CIDR" ] || PORT_CIDR="$OLLAMA_CIDR"
  discover_port_cidr
  OLLAMA_CIDR="$PORT_CIDR"
}

ollama_rules() {
  aws_text ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_ID" \
    --query "SecurityGroupRules[?IpProtocol==\`tcp\` && FromPort==\`$OLLAMA_PORT\` && ToPort==\`$OLLAMA_PORT\`].[SecurityGroupRuleId,CidrIpv4,Description]"
}

ensure_ollama_ingress() {
  local rules owned_desired any_desired stale id remaining
  local description="aws-ec2-vm:${NAME}:ollama:${OLLAMA_PORT}"
  rules="$(ollama_rules)" || die "cannot inspect Ollama port rules in $SG_ID"
  owned_desired="$(awk -F '\t' -v cidr="$OLLAMA_CIDR" -v description="$description" '$2 == cidr && $3 == description { print $1 }' <<< "$rules")"
  any_desired="$(awk -F '\t' -v cidr="$OLLAMA_CIDR" '$2 == cidr { print $1 }' <<< "$rules")"
  if [ -z "$owned_desired" ] && [ -n "$any_desired" ]; then
    die "Ollama port $OLLAMA_PORT for $OLLAMA_CIDR already exists in an unowned rule; refusing to adopt or modify it"
  fi
  if [ -z "$owned_desired" ]; then
    if ! aws_text ec2 authorize-security-group-ingress --group-id "$SG_ID" --ip-permissions "IpProtocol=tcp,FromPort=$OLLAMA_PORT,ToPort=$OLLAMA_PORT,IpRanges=[{CidrIp=$OLLAMA_CIDR,Description=$description}]" >/dev/null; then
      rules="$(ollama_rules)" || die "cannot inspect Ollama rules after authorize failed"
      owned_desired="$(awk -F '\t' -v cidr="$OLLAMA_CIDR" -v description="$description" '$2 == cidr && $3 == description { print $1 }' <<< "$rules")"
      [ -n "$owned_desired" ] || die "could not expose Ollama port $OLLAMA_PORT to $OLLAMA_CIDR"
    fi
  fi
  rules="$(ollama_rules)" || die "cannot verify Ollama port rules"
  owned_desired="$(awk -F '\t' -v cidr="$OLLAMA_CIDR" -v description="$description" '$2 == cidr && $3 == description { print $1 }' <<< "$rules")"
  [ -n "$owned_desired" ] || die "new Ollama port rule could not be verified"
  stale="$(awk -F '\t' -v cidr="$OLLAMA_CIDR" -v description="$description" '$2 != cidr && $3 == description { print $1 }' <<< "$rules")"
  for id in $stale; do
    if ! aws_text ec2 revoke-security-group-ingress --group-id "$SG_ID" --security-group-rule-ids "$id" >/dev/null; then
      remaining="$(ollama_rules)" || die "cannot inspect Ollama rules after revoke failed"
      if awk -F '\t' -v id="$id" '$1 == id { found=1 } END { exit !found }' <<< "$remaining"; then
        die "could not revoke managed Ollama security group rule $id"
      fi
    fi
  done
  info "Ollama port $OLLAMA_PORT is exposed to $OLLAMA_CIDR"
}

ensure_ollama_remote() {
  prepare_ssh_endpoint
  build_ssh_args
  info "Ensuring Ollama service and model $MODEL"
  # The model argument is passed separately and interpreted only as data remotely.
  # shellcheck disable=SC2029
  ssh "${SSH_ARGS[@]}" "ec2-user@$PUBLIC_IP" "sudo -n /bin/bash -s -- $(shell_quote "$MODEL")" <<'REMOTE_OLLAMA' || die "Ollama provisioning failed on $INSTANCE_ID"
set -Eeuo pipefail
model="$1"

[ "$(uname -m)" = "x86_64" ] || { printf 'Error: Ollama provisioning requires x86_64\n' >&2; exit 1; }
. /etc/os-release
[ "${ID:-}" = "amzn" ] && [ "${VERSION_ID:-}" = "2023" ] || {
  printf 'Error: Ollama provisioning requires Amazon Linux 2023\n' >&2
  exit 1
}

if ! command -v ollama >/dev/null 2>&1 || ! systemctl cat ollama.service >/dev/null 2>&1; then
  command -v zstd >/dev/null 2>&1 || dnf install -y zstd
  tmp="$(mktemp /tmp/ollama-install.XXXXXX)"
  trap 'rm -f -- "$tmp"' EXIT
  curl -fsSL --proto '=https' --tlsv1.2 -o "$tmp" https://ollama.com/install.sh
  /bin/sh "$tmp"
  rm -f -- "$tmp"
  trap - EXIT
fi

install -d -o root -g root -m 0755 /etc/systemd/system/ollama.service.d
cat > /etc/systemd/system/ollama.service.d/aws-ec2-vm.conf <<'EOF'
[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
EOF
chown root:root /etc/systemd/system/ollama.service.d/aws-ec2-vm.conf
chmod 0644 /etc/systemd/system/ollama.service.d/aws-ec2-vm.conf
systemctl daemon-reload
systemctl enable --now ollama.service
systemctl restart ollama.service

ready=0
for attempt in $(seq 1 30); do
  if curl -fsS --max-time 5 http://127.0.0.1:11434/api/tags >/dev/null; then
    ready=1
    break
  fi
  [ "$attempt" -eq 30 ] || sleep 2
done
[ "$ready" -eq 1 ] || { printf 'Error: Ollama API did not become ready\n' >&2; exit 1; }

if ! ollama list | awk 'NR > 1 { print $1 }' | grep -Fxq -- "$model"; then
  ollama pull "$model"
fi
response="$(mktemp /tmp/ollama-smoke.XXXXXX)"
trap 'rm -f -- "$response"' EXIT
printf '{"model":"%s","prompt":"Reply with OK.","stream":false}' "$model" |
  curl -fsS --max-time 300 -H 'Content-Type: application/json' --data-binary @- -o "$response" http://127.0.0.1:11434/api/generate
grep -q '"response"' "$response" || { printf 'Error: Ollama smoke test returned an invalid response\n' >&2; exit 1; }
REMOTE_OLLAMA
}

print_ollama_endpoint() {
  printf 'Ollama public IP: %s\nOllama port:      %s\nOllama CIDR:      %s\nOllama model:     %s\nOllama endpoint:  http://%s:%s\n' \
    "$PUBLIC_IP" "$OLLAMA_PORT" "$OLLAMA_CIDR" "$MODEL" "$PUBLIC_IP" "$OLLAMA_PORT"
}

ensure_ollama() {
  if [ -z "$OLLAMA_CIDR" ] || { [ "$PORT_CIDR_EXPLICIT" -eq 1 ] && [ "$PORT_CIDR" != "$OLLAMA_CIDR" ]; }; then
    configure_ollama_cidr
  else
    PORT="$OLLAMA_PORT"
    PORT_CIDR="$OLLAMA_CIDR"
  fi
  save_state
  validate_port_security_group "$(instance_state)"
  ensure_ollama_remote
  ensure_ollama_ingress
  OLLAMA_READY="1"
  save_state
  print_ollama_endpoint
}

create_vm() {
  mkdir -p "$STATE_DIR"
  if [ -f "$STATE_FILE" ]; then load_state; fi
  [ -n "$OLLAMA_MODE" ] || OLLAMA_MODE="$MODEL_EXPLICIT"
  if [ "$OLLAMA_MODE" = "1" ]; then
    [ "$VCPUS_EXPLICIT" -eq 1 ] || [ "$VCPUS_SAVED" -eq 1 ] || VCPUS="$DEFAULT_MODEL_VCPUS"
    [ "$MEMORY_EXPLICIT" -eq 1 ] || [ "$MEMORY_SAVED" -eq 1 ] || MEMORY_GIB="$DEFAULT_MODEL_MEMORY_GIB"
  fi
  [ "$PORT_CIDR_EXPLICIT" -eq 0 ] || [ "$OLLAMA_MODE" = "1" ] || [ "$MODEL_EXPLICIT" -eq 1 ] || die "create --cidr requires --model or a VM already in Ollama mode"
  ensure_auth
  local live_account
  live_account="$(aws_text sts get-caller-identity --query Account)"
  [ -z "$ACCOUNT_ID" ] || [ "$ACCOUNT_ID" = "$live_account" ] || die "state belongs to AWS account $ACCOUNT_ID, but current credentials use $live_account"
  ACCOUNT_ID="$live_account"
  if [ "$INSTANCE_READY" = "1" ] && [ -n "$INSTANCE_ID" ]; then
    local existing_state
    existing_state="$(instance_state)"
    case "$existing_state" in
      terminated|not-found|None|'') ;;
      *)
        if [ "$OLLAMA_MODE" = "0" ] && [ "$MODEL_EXPLICIT" -eq 1 ]; then
          die "VM '$NAME' is a completed plain VM; terminate it, then recreate with '$0 create $NAME --model $MODEL' to retain its data volume"
        fi
        ;;
    esac
    case "$existing_state" in
      running)
        if [ "$OLLAMA_MODE" = "1" ] && [ "$OLLAMA_READY" = "0" ]; then
          info "Resuming Ollama setup for $INSTANCE_ID"
          ensure_ollama
          print_commands
          return
        fi
        die "VM '$NAME' already exists as $INSTANCE_ID ($existing_state); use '$0 status $NAME' instead"
        ;;
      pending|stopping|stopped)
        die "VM '$NAME' already exists as $INSTANCE_ID ($existing_state); use '$0 status $NAME' instead"
        ;;
      shutting-down) die "VM '$NAME' is shutting down; wait, then run create again to reuse its storage" ;;
      terminated|not-found|None) INSTANCE_READY="0" ;;
      *) die "cannot safely create: recorded instance $INSTANCE_ID is $existing_state" ;;
    esac
  fi
  if [ "$MODEL_EXPLICIT" -eq 1 ] && [ "$OLLAMA_MODE" = "0" ]; then
    if [ -n "$INSTANCE_ID" ]; then
      local upgrade_state
      upgrade_state="$(instance_state)"
      case "$upgrade_state" in terminated|not-found|None|'') ;; *) die "VM '$NAME' has a partial plain instance $INSTANCE_ID ($upgrade_state); terminate it before recreating with Ollama" ;; esac
    fi
    OLLAMA_MODE="1"
    [ "$VCPUS_EXPLICIT" -eq 1 ] || VCPUS="$DEFAULT_MODEL_VCPUS"
    [ "$MEMORY_EXPLICIT" -eq 1 ] || MEMORY_GIB="$DEFAULT_MODEL_MEMORY_GIB"
    [ "$INSTANCE_TYPE_EXPLICIT" -eq 1 ] || INSTANCE_TYPE=""
  fi
  save_state
  if [ "$OLLAMA_MODE" = "1" ]; then configure_ollama_cidr; fi
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
  if [ "$OLLAMA_MODE" = "1" ]; then ensure_ollama; fi
  INSTANCE_READY="1"
  save_state
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

validate_port_security_group() {
  local instance_status="$1" details actual_vpc managed attached
  [ -n "$SG_ID" ] || die "state has no security group"
  [ -n "$VPC_ID" ] || die "state has no VPC"
  details="$(aws_text ec2 describe-security-groups --group-ids "$SG_ID" --query "SecurityGroups[0].[VpcId,Tags[?Key=='ManagedBy']|[0].Value]" 2>/dev/null || true)"
  read -r actual_vpc managed <<< "$details"
  [ "$actual_vpc" = "$VPC_ID" ] || die "saved security group $SG_ID is not in saved VPC $VPC_ID"
  [ "$managed" = "aws-ec2-vm" ] || die "saved security group $SG_ID is not managed by aws-ec2-vm"
  case "$instance_status" in terminated|shutting-down|not-found|None|'') return ;; esac
  attached="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].SecurityGroups[].GroupId')"
  case " $attached " in *" $SG_ID "*) ;; *) die "saved security group $SG_ID is not attached to $INSTANCE_ID" ;; esac
}

port_rules() {
  aws_text ec2 describe-security-group-rules --filters "Name=group-id,Values=$SG_ID" \
    --query "SecurityGroupRules[?IpProtocol==\`tcp\` && FromPort==\`$PORT\` && ToPort==\`$PORT\`].[SecurityGroupRuleId,CidrIpv4,Description]"
}

owned_port_rule_ids() {
  local rules="$1" cidr="${2:-}" description="aws-ec2-vm:${NAME}:tcp:${PORT}"
  awk -F '\t' -v cidr="$cidr" -v description="$description" \
    '$3 == description && (cidr == "" || $2 == cidr) { print $1 }' <<< "$rules"
}

cidr_port_rule_ids() {
  awk -F '\t' -v cidr="$2" '$2 == cidr { print $1 }' <<< "$1"
}

stale_owned_port_rule_ids() {
  local description="aws-ec2-vm:${NAME}:tcp:${PORT}"
  awk -F '\t' -v cidr="$2" -v description="$description" \
    '$3 == description && $2 != cidr { print $1 }' <<< "$1"
}

revoke_owned_port_rules() {
  local ids="$1" id remaining
  for id in $ids; do
    if ! aws_text ec2 revoke-security-group-ingress --group-id "$SG_ID" --security-group-rule-ids "$id" >/dev/null; then
      remaining="$(port_rules)" || die "cannot inspect TCP port $PORT rules after revoke failed"
      if owned_port_rule_ids "$remaining" | grep -Fxq "$id"; then
        die "could not revoke managed security group rule $id"
      fi
    fi
  done
}

expose_port() {
  prepare_existing
  local state rules owned_desired any_desired stale description host
  state="$(instance_state)"
  case "$state" in
    running|stopped) ;;
    *) die "instance is $state; expose-port requires a running or stopped VM" ;;
  esac
  validate_port_security_group "$state"
  discover_port_cidr
  description="aws-ec2-vm:${NAME}:tcp:${PORT}"
  rules="$(port_rules)" || die "cannot inspect TCP port $PORT rules in $SG_ID"
  owned_desired="$(owned_port_rule_ids "$rules" "$PORT_CIDR")"
  any_desired="$(cidr_port_rule_ids "$rules" "$PORT_CIDR")"
  if [ -z "$owned_desired" ] && [ -n "$any_desired" ]; then
    die "TCP port $PORT for $PORT_CIDR already exists in an unowned rule; refusing to adopt or modify it"
  fi
  if [ -z "$owned_desired" ]; then
    if ! aws_text ec2 authorize-security-group-ingress --group-id "$SG_ID" --ip-permissions "IpProtocol=tcp,FromPort=$PORT,ToPort=$PORT,IpRanges=[{CidrIp=$PORT_CIDR,Description=$description}]" >/dev/null; then
      rules="$(port_rules)" || die "cannot inspect TCP port $PORT rules after authorize failed"
      owned_desired="$(owned_port_rule_ids "$rules" "$PORT_CIDR")"
      [ -n "$owned_desired" ] || die "could not expose TCP port $PORT to $PORT_CIDR"
    else
      rules="$(port_rules)" || die "cannot verify newly exposed TCP port $PORT"
      owned_desired="$(owned_port_rule_ids "$rules" "$PORT_CIDR")"
      [ -n "$owned_desired" ] || die "new TCP port $PORT rule could not be verified"
    fi
  else
    info "TCP port $PORT is already exposed to $PORT_CIDR"
  fi
  stale="$(stale_owned_port_rule_ids "$rules" "$PORT_CIDR")"
  [ -z "$stale" ] || revoke_owned_port_rules "$stale"
  info "Exposed TCP port $PORT to $PORT_CIDR"
  if [ "$state" = "running" ]; then
    refresh_public_ip
    host="${PUBLIC_DNS:-$PUBLIC_IP}"
    [ -n "$host" ] && printf 'Public endpoint: %s:%s\n' "$host" "$PORT" || printf 'Public endpoint unavailable: instance has no public DNS or IPv4 address\n'
  else
    printf 'Public endpoint unavailable until the instance is started\n'
  fi
}

close_port() {
  prepare_existing
  local state rules ids
  state="$(instance_state)"
  validate_port_security_group "$state"
  rules="$(port_rules)" || die "cannot inspect TCP port $PORT rules in $SG_ID"
  ids="$(owned_port_rule_ids "$rules")"
  if [ -z "$ids" ]; then
    info "TCP port $PORT has no managed exposure"
    return
  fi
  revoke_owned_port_rules "$ids"
  info "Closed managed TCP port $PORT"
}

status_vm() {
  prepare_existing
  local state volume_state
  state="$(instance_state)"
  volume_state="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].State' 2>/dev/null || printf 'not-found')"
  if [ "$state" = "running" ]; then refresh_public_ip; else PUBLIC_IP=""; PUBLIC_DNS=""; fi
  printf 'Name:              %s\nInstance:          %s (%s)\nInstance type:     %s\nPersistent volume: %s (%s, %s GiB)\nLocation:          %s / %s\nPublic IP:         %s\nPublic DNS:        %s\n' \
    "$NAME" "$INSTANCE_ID" "$state" "$INSTANCE_TYPE" "$VOLUME_ID" "$volume_state" "$DISK_GIB" "$REGION" "$AZ" "${PUBLIC_IP:-none}" "${PUBLIC_DNS:-none}"
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
  if [ "$OLLAMA_MODE" = "1" ]; then ensure_ollama; fi
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
  PUBLIC_DNS=""
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
  refresh_public_ip
  print_commands
}

authenticated_console_output() {
  aws_text ec2 get-console-output --instance-id "$INSTANCE_ID" --latest --query Output 2>/dev/null ||
    aws_text ec2 get-console-output --instance-id "$INSTANCE_ID" --query Output 2>/dev/null
}

valid_ssh_host_key() {
  local key_type="$1" key_data="$2" key_file="$4"
  case "$key_type" in ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp256|ecdsa-sha2-nistp384|ecdsa-sha2-nistp521) ;; *) return 1 ;; esac
  case "$key_data" in ''|*[!A-Za-z0-9+/=]*) return 1 ;; esac
  printf '%s %s\n' "$key_type" "$key_data" > "$key_file"
  ssh-keygen -l -f "$key_file" >/dev/null 2>&1
}

write_console_host_keys() {
  local keys="$1" target="$2" key_file="$3"
  local key_type key_data extra count=0
  : > "$target"
  while IFS=' ' read -r key_type key_data extra; do
    valid_ssh_host_key "$key_type" "$key_data" "$extra" "$key_file" || return 1
    printf '%s %s %s\n' "$PUBLIC_IP" "$key_type" "$key_data" >> "$target"
    count=$((count + 1))
  done < "$keys"
  [ "$count" -gt 0 ]
}

write_cached_host_keys() {
  local cache="$1" target="$2" key_file="$3"
  local cached_host first_host="" key_type key_data extra count=0
  [ ! -L "$cache" ] && [ -f "$cache" ] && [ -O "$cache" ] || return 1
  : > "$target"
  while IFS=' ' read -r cached_host key_type key_data extra; do
    valid_cidr "$cached_host/32" || return 1
    [ -z "$first_host" ] || [ "$cached_host" = "$first_host" ] || return 1
    first_host="$cached_host"
    valid_ssh_host_key "$key_type" "$key_data" "$extra" "$key_file" || return 1
    printf '%s %s %s\n' "$PUBLIC_IP" "$key_type" "$key_data" >> "$target"
    count=$((count + 1))
  done < "$cache"
  [ "$count" -gt 0 ]
}

prepare_ssh_known_hosts() {
  command -v ssh-keygen >/dev/null 2>&1 || die "ssh-keygen is required"
  valid_cidr "$PUBLIC_IP/32" || die "AWS returned an invalid public IPv4 address for $INSTANCE_ID"
  local host_dir="$STATE_DIR/known_hosts" cache work output attempt complete=0
  [ ! -L "$host_dir" ] || die "refusing symlinked known-hosts directory: $host_dir"
  [ ! -e "$host_dir" ] || [ -d "$host_dir" ] || die "known-hosts path is not a directory: $host_dir"
  mkdir -p "$host_dir"
  [ -O "$host_dir" ] || die "known-hosts directory is not owned by the current user: $host_dir"
  chmod 700 "$host_dir"
  umask 077
  work="$(mktemp -d "$host_dir/.verify-$INSTANCE_ID.XXXXXX")"
  cache="$host_dir/$INSTANCE_ID"
  attempt=1
  while [ "$attempt" -le 24 ]; do
    if output="$(authenticated_console_output)" &&
      printf '%s\n' "$output" | awk '
        BEGIN { inside = 0; seen = 0; bad = 0 }
        { sub(/\r$/, "") }
        $0 == "-----BEGIN SSH HOST KEY KEYS-----" {
          if (inside || seen) bad = 1
          inside = 1
          next
        }
        $0 == "-----END SSH HOST KEY KEYS-----" {
          if (!inside) bad = 1
          inside = 0
          seen = 1
          next
        }
        inside { print }
        END { if (inside || !seen || bad) exit 1 }
      ' > "$work/keys"; then
      if ! write_console_host_keys "$work/keys" "$work/known_hosts" "$work/key"; then
        rm -rf "$work"
        die "EC2 console output for $INSTANCE_ID contained malformed or invalid SSH host keys"
      fi
      complete=1
      break
    fi
    if write_cached_host_keys "$cache" "$work/known_hosts" "$work/key"; then
      info "Reusing authenticated cached SSH host keys for $INSTANCE_ID"
      complete=1
      break
    fi
    [ "$attempt" -ne 1 ] || info "Waiting for authenticated EC2 console SSH host keys"
    [ "$attempt" -eq 24 ] || sleep 5
    attempt=$((attempt + 1))
  done
  if [ "$complete" -ne 1 ]; then
    rm -rf "$work"
    die "no authenticated console SSH host keys or valid cache exist for $INSTANCE_ID"
  fi
  chmod 600 "$work/known_hosts"
  SSH_KNOWN_HOSTS="$cache"
  mv -f "$work/known_hosts" "$SSH_KNOWN_HOSTS"
  rm -rf "$work"
}

prepare_ssh_endpoint() {
  prepare_existing
  local state
  state="$(instance_state)"
  [ "$state" = "running" ] || die "instance is $state; run '$0 start $NAME' first"
  refresh_public_ip
  [ -n "$PUBLIC_IP" ] || die "instance has no public IPv4 address; check subnet routing or use AWS Systems Manager"
  [ -f "$KEY_PATH" ] || die "private key missing: $KEY_PATH"
  prepare_ssh_known_hosts
}

build_ssh_args() {
  local forward_agent=no
  [ "$SSH_FORWARD_AGENT" -eq 0 ] || forward_agent=yes
  SSH_ARGS=(
    -o StrictHostKeyChecking=yes
    -o "UserKnownHostsFile=$SSH_KNOWN_HOSTS"
    -o GlobalKnownHostsFile=/dev/null
    -o KnownHostsCommand=none
    -o UpdateHostKeys=no
    -o IdentitiesOnly=yes
    -o "ForwardAgent=$forward_agent"
    -o BatchMode=yes
    -o ConnectTimeout=10
    -o ServerAliveInterval=15
    -o ServerAliveCountMax=3
    -i "$KEY_PATH"
  )
  [ "$SSH_QUIET" -eq 0 ] || SSH_ARGS+=(-o LogLevel=ERROR)
  [ -z "$SSH_CONTROL_PATH" ] || SSH_ARGS+=(-o ControlMaster=auto -o ControlPersist=600 -o "ControlPath=$SSH_CONTROL_PATH")
}

fast_ssh_control() {
  local forward_agent=no remote_command="" quoted arg
  local -a args=(
    -F /dev/null
    -S "$SSH_CONTROL_PATH"
    -o ControlMaster=no
    -o "ProxyCommand=/usr/bin/false"
    -o StrictHostKeyChecking=yes
    -o UserKnownHostsFile=/dev/null
    -o GlobalKnownHostsFile=/dev/null
    -o KnownHostsCommand=none
    -o BatchMode=yes
  )
  [ "$SSH_QUIET" -eq 0 ] || args+=(-o LogLevel=ERROR)
  if [ "$SSH_CONTROL_COMMAND" != "attach" ]; then
    exec ssh "${args[@]}" -O "$SSH_CONTROL_COMMAND" ec2-user@aws-vm-control-master.invalid
  fi
  [ "$SSH_FORWARD_AGENT" -eq 0 ] || forward_agent=yes
  args+=(-o "ForwardAgent=$forward_agent")
  [ "$SSH_TTY" -eq 0 ] || args+=(-tt)
  if [ "${#SSH_REMOTE_COMMAND[@]}" -gt 0 ]; then
    for arg in "${SSH_REMOTE_COMMAND[@]}"; do
      printf -v quoted '%q' "$arg"
      remote_command+="${remote_command:+ }$quoted"
    done
    exec ssh "${args[@]}" ec2-user@aws-vm-control-master.invalid "$remote_command"
  fi
  exec ssh "${args[@]}" ec2-user@aws-vm-control-master.invalid
}

ssh_vm() {
  prepare_ssh_endpoint
  build_ssh_args
  release_lock
  trap - EXIT INT TERM HUP
  local remote_command="" quoted arg
  if [ -n "$SSH_CONTROL_COMMAND" ]; then
    exec ssh "${SSH_ARGS[@]}" -O "$SSH_CONTROL_COMMAND" "ec2-user@$PUBLIC_IP"
  fi
  [ "$SSH_TTY" -eq 0 ] || SSH_ARGS+=(-tt)
  if [ "${#SSH_REMOTE_COMMAND[@]}" -gt 0 ]; then
    for arg in "${SSH_REMOTE_COMMAND[@]}"; do
      printf -v quoted '%q' "$arg"
      remote_command+="${remote_command:+ }$quoted"
    done
    exec ssh "${SSH_ARGS[@]}" "ec2-user@$PUBLIC_IP" "$remote_command"
  fi
  exec ssh "${SSH_ARGS[@]}" "ec2-user@$PUBLIC_IP"
}

validate_storage_attachment() {
  local mappings attachments mapping_count attachment_count
  mappings="$(aws_text ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].BlockDeviceMappings[].[DeviceName,Ebs.VolumeId,Ebs.DeleteOnTermination]')" ||
    die "cannot verify block-device mappings for $INSTANCE_ID"
  mapping_count="$(awk -v volume="$VOLUME_ID" -v device="$DEVICE_NAME" '
    $2 == volume {
      count++
      if ($1 != device || ($3 != "False" && $3 != "false")) bad=1
    }
    END { if (bad) print "bad"; else print count + 0 }
  ' <<< "$mappings")"
  [ "$mapping_count" = "1" ] || die "saved volume $VOLUME_ID is not exactly once at $DEVICE_NAME with DeleteOnTermination=false on $INSTANCE_ID"

  attachments="$(aws_text ec2 describe-volumes --volume-ids "$VOLUME_ID" --query 'Volumes[0].Attachments[].[InstanceId,Device,State]')" ||
    die "cannot verify attachment for $VOLUME_ID"
  attachment_count="$(awk -v instance="$INSTANCE_ID" -v device="$DEVICE_NAME" '
    NF {
      count++
      if ($1 != instance || $2 != device || $3 != "attached") bad=1
    }
    END { if (bad) print "bad"; else print count + 0 }
  ' <<< "$attachments")"
  [ "$attachment_count" = "1" ] || die "$VOLUME_ID does not have exactly one attached $DEVICE_NAME mapping to $INSTANCE_ID"
}

init_command_text() {
  local command quoted arg
  printf -v command '%q init-storage %q' "$0" "$NAME"
  if [ "$PROFILE_EXPLICIT" -eq 1 ]; then
    printf -v quoted '%q' "$PROFILE"
    command+=" --profile $quoted"
  fi
  if [ "$REGION_EXPLICIT" -eq 1 ]; then
    printf -v quoted '%q' "$REGION"
    command+=" --region $quoted"
  fi
  printf '%s\n' "$command"
}

run_remote_storage() {
  local mode="$1" confirmation="${2:-}" remote_command quoted output
  printf -v remote_command 'sudo -n flock -w 30 -E 75 -x %q /bin/bash -s --' "/run/lock/aws-ec2-vm-storage.lock"
  for output in "$mode" "$NAME" "$INSTANCE_ID" "$VOLUME_ID" "$(init_command_text)" "$confirmation"; do
    printf -v quoted '%q' "$output"
    remote_command+=" $quoted"
  done
  # Values in the remote command are individually shell-quoted above.
  # shellcheck disable=SC2029
  if ssh "${SSH_ARGS[@]}" "ec2-user@$PUBLIC_IP" "$remote_command" <<'REMOTE_STORAGE'
set -Eeuo pipefail

mode="$1"
vm_name="$2"
instance_id="$3"
volume_id="$4"
init_command="$5"
confirmation="$6"
marker_name=".aws-ec2-vm-volume"
disk=""
fs_node=""
fs_uuid=""
classification=""
cleanup_mount_on_failure=0

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

arm_mount_failure_cleanup() {
  cleanup_mount_on_failure=1
  trap 'mount_failure_exit "$?"' EXIT
}

mount_failure_exit() {
  local status="$1"
  trap - EXIT
  if [ "$cleanup_mount_on_failure" -eq 1 ]; then
    cleanup_mount_on_failure=0
    if ! umount /data >/dev/null 2>&1; then
      printf 'Error: storage setup failed and automatic /data unmount also failed; investigate immediately\n' >&2
    fi
  fi
  exit "$status"
}

disarm_mount_failure_cleanup() {
  cleanup_mount_on_failure=0
  trap - EXIT
}

resolve_disk() {
  [[ "$volume_id" =~ ^vol-[0-9a-f]{8}([0-9a-f]{9})?$ ]] || die "invalid EBS volume ID: $volume_id"
  local expected="${volume_id//-/}" serial_file serial block attempt
  local -a matches=()
  shopt -s nullglob
  for ((attempt=1; attempt<=30; attempt++)); do
    command -v udevadm >/dev/null 2>&1 && udevadm settle --timeout=1 >/dev/null 2>&1 || true
    matches=()
    for serial_file in /sys/block/nvme*n1/device/serial; do
      serial="$(tr -d '[:space:]' < "$serial_file")"
      [ "$serial" = "$expected" ] || continue
      block="${serial_file#/sys/block/}"
      block="${block%%/*}"
      matches+=("/dev/$block")
    done
    [ "${#matches[@]}" -le 1 ] || die "multiple NVMe disks match exact serial $expected"
    [ "${#matches[@]}" -eq 0 ] || break
    [ "$attempt" -eq 30 ] || sleep 1
  done
  [ "${#matches[@]}" -eq 1 ] || die "no NVMe disk has exact serial $expected"
  disk="$(readlink -f -- "${matches[0]}")"
  [ "$(lsblk -dnro TYPE -- "$disk")" = "disk" ] || die "matched NVMe device is not a whole disk: $disk"
}

classify_disk() {
  local node type canonical probe_status
  local filesystem_count=0
  local -a nodes=() uuid_nodes=()
  fs_node=""
  fs_uuid=""
  mapfile -t nodes < <(lsblk -nrpo NAME,TYPE -- "$disk")
  [ "${#nodes[@]}" -gt 0 ] || die "lsblk returned no nodes for $disk"
  for node in "${nodes[@]}"; do
    read -r node type <<< "$node"
    case "$type" in disk|part) ;; *) die "unsupported child type $type below $disk" ;; esac
    canonical="$(readlink -f -- "$node")"
    set +e
    type="$(blkid -c /dev/null -p -s TYPE -o value -- "$canonical" 2>/dev/null)"
    probe_status=$?
    set -e
    case "$probe_status" in 0|2) ;; *) die "blkid could not safely inspect $canonical" ;; esac
    [ -n "$type" ] || continue
    filesystem_count=$((filesystem_count + 1))
    [ "$type" = "ext4" ] || die "unsupported $type signature on $canonical; refusing storage mutation"
    fs_node="$canonical"
  done
  [ "$filesystem_count" -le 1 ] || die "multiple filesystem-bearing nodes exist below $disk"
  if [ "$filesystem_count" -eq 0 ]; then
    classification="blank"
    return
  fi
  fs_uuid="$(blkid -c /dev/null -p -s UUID -o value -- "$fs_node" 2>/dev/null || true)"
  [ -n "$fs_uuid" ] || die "ext4 filesystem on $fs_node has no UUID"
  mapfile -t uuid_nodes < <(blkid -c /dev/null -t "UUID=$fs_uuid" -o device 2>/dev/null || true)
  [ "${#uuid_nodes[@]}" -eq 1 ] || die "filesystem UUID $fs_uuid is not unique"
  [ "$(readlink -f -- "${uuid_nodes[0]}")" = "$fs_node" ] || die "filesystem UUID $fs_uuid resolves to another device"
  classification="ready"
}

prove_blank() {
  local -a nodes=()
  local signature
  mapfile -t nodes < <(lsblk -nrpo NAME,TYPE -- "$disk")
  [ "${#nodes[@]}" -eq 1 ] || die "blank initialization requires a whole disk with no partitions or children"
  [ "${nodes[0]}" = "$disk disk" ] || die "unexpected node below candidate disk"
  signature="$(wipefs -n --noheadings --output TYPE -- "$disk" 2>/dev/null)" || die "wipefs could not safely inspect $disk"
  [ -z "${signature//[[:space:]]/}" ] || die "candidate disk contains a signature; refusing to format"
}

write_profile() {
  local uid="$1" tmp
  tmp="$(mktemp /etc/profile.d/.aws-ec2-vm-data.sh.XXXXXX)"
  trap 'rm -f -- "$tmp"' RETURN
  cat > "$tmp" <<EOF
if [ "\$(id -u)" -eq $uid ]; then
  export WORKSPACE_ROOT=/data/workspace
  export BUN_INSTALL=/data/tools/bun
  export NPM_CONFIG_PREFIX=/data/tools/npm
  for _aws_vm_path in /data/tools/bin "\$NPM_CONFIG_PREFIX/bin" "\$BUN_INSTALL/bin"; do
    case ":\$PATH:" in
      *":\$_aws_vm_path:"*) ;;
      *) PATH="\$_aws_vm_path:\$PATH" ;;
    esac
  done
  unset _aws_vm_path
  export PATH
fi
EOF
  chown root:root "$tmp"
  chmod 0644 "$tmp"
  mv -f -- "$tmp" /etc/profile.d/aws-ec2-vm-data.sh
  trap - RETURN
}

ensure_user_directory() {
  local path="$1" uid="$2" gid="$3" details
  if [ -e "$path" ] || [ -L "$path" ]; then
    details="$(stat -c '%u:%g:%a:%F' -- "$path" 2>/dev/null || true)"
    [ "$details" = "$uid:$gid:755:directory" ] || die "$path must be a real mode-0755 directory owned by $uid:$gid; refusing privileged repair"
    return
  fi
  [ -x /usr/bin/setpriv ] || die "/usr/bin/setpriv is required to create persistent user directories safely"
  /usr/bin/setpriv --reuid="$uid" --regid="$gid" --clear-groups /usr/bin/mkdir -m 0755 -- "$path"
  details="$(stat -c '%u:%g:%a:%F' -- "$path" 2>/dev/null || true)"
  [ "$details" = "$uid:$gid:755:directory" ] || die "new persistent directory did not verify safely: $path"
}

ensure_top_user_directory() {
  local path="$1" uid="$2" gid="$3" details
  if [ -e "$path" ] || [ -L "$path" ]; then
    details="$(stat -c '%u:%g:%a:%F' -- "$path" 2>/dev/null || true)"
    [ "$details" = "$uid:$gid:755:directory" ] || die "$path must be a real mode-0755 directory owned by $uid:$gid; refusing privileged repair"
    return
  fi
  /usr/bin/mkdir -m 0755 -- "$path"
  chown --no-dereference "$uid:$gid" "$path"
  details="$(stat -c '%u:%g:%a:%F' -- "$path" 2>/dev/null || true)"
  [ "$details" = "$uid:$gid:755:directory" ] || die "new top-level persistent directory did not verify safely: $path"
}

verify_data_mount() {
  local expected_node="$1" expected_uuid="$2" expected_majmin="$3"
  local details source uuid type majmin options canonical_source
  details="$(findmnt -rn -M /data -o SOURCE,UUID,FSTYPE,MAJ:MIN,OPTIONS 2>/dev/null || true)"
  [ -n "$details" ] || return 1
  read -r source uuid type majmin options <<< "$details"
  canonical_source="$(readlink -f -- "$source" 2>/dev/null || true)"
  [ "$canonical_source" = "$expected_node" ] && [ "$uuid" = "$expected_uuid" ] && [ "$type" = "ext4" ] && [ "$majmin" = "$expected_majmin" ] ||
    die "/data mount identity does not match the proven EBS filesystem"
  case ",$options," in *,nodev,*) ;; *) die "/data mount is missing nodev" ;; esac
  case ",$options," in *,nosuid,*) ;; *) die "/data mount is missing nosuid" ;; esac
  case ",$options," in *,noexec,*) die "/data mount unexpectedly disables executable tools" ;; esac
}

prepare_filesystem() {
  local uid gid mount_details target found_uuid tmp marker_tmp marker_dir data_stat need_fstab=0
  local original_disk original_node original_uuid expected_majmin
  local -a data_entries=()
  uid="$(id -u ec2-user)"
  gid="$(id -g ec2-user)"
  [ "$uid" -gt 0 ] || die "invalid ec2-user UID"

  while read -r target found_uuid; do
    [ "$found_uuid" != "$fs_uuid" ] || [ "$target" = "/data" ] || die "UUID $fs_uuid is already mounted at $target"
  done < <(findmnt -rn -o TARGET,UUID)

  if [ -e /data ] || [ -L /data ]; then
    [ ! -L /data ] || die "/data is a symlink"
    [ -d /data ] || die "/data is not a directory"
  else
    mkdir -m 0755 /data
  fi
  expected_majmin="$(lsblk -dnro MAJ:MIN -- "$fs_node")"
  [ -n "$expected_majmin" ] || die "could not resolve major:minor identity for $fs_node"
  mount_details="$(findmnt -rn -M /data -o SOURCE 2>/dev/null || true)"
  if [ -z "$mount_details" ] && [ -n "$(find /data -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    die "/data is nonempty and is not a mountpoint"
  fi
  if [ -n "$mount_details" ]; then
    verify_data_mount "$fs_node" "$fs_uuid" "$expected_majmin"
  fi

  mapfile -t data_entries < <(awk '!/^[[:space:]]*#/ && NF && $2 == "/data" { print $1 " " $3 " " $4 }' /etc/fstab)
  [ "${#data_entries[@]}" -le 1 ] || die "/etc/fstab has multiple active /data entries"
  if [ "${#data_entries[@]}" -eq 1 ]; then
    [ "${data_entries[0]}" = "UUID=$fs_uuid ext4 defaults,nodev,nosuid,nofail,x-systemd.device-timeout=30s" ] || die "/etc/fstab has a conflicting or unsafe /data entry"
  else
    need_fstab=1
  fi

  original_disk="$disk"; original_node="$fs_node"; original_uuid="$fs_uuid"
  if [ -z "$mount_details" ]; then
    resolve_disk
    [ "$disk" = "$original_disk" ] || die "EBS disk identity changed before mount"
    classify_disk
    [ "$classification" = "ready" ] && [ "$fs_node" = "$original_node" ] && [ "$fs_uuid" = "$original_uuid" ] || die "filesystem identity changed before mount"
    expected_majmin="$(lsblk -dnro MAJ:MIN -- "$fs_node")"
    [ -n "$expected_majmin" ] || die "could not revalidate major:minor identity before mount"
    mount -t ext4 -o defaults,nodev,nosuid -- "$fs_node" /data || die "could not explicitly mount proven filesystem $fs_node at /data"
    arm_mount_failure_cleanup
  fi
  resolve_disk
  [ "$disk" = "$original_disk" ] || die "EBS disk identity changed after mount"
  classify_disk
  [ "$classification" = "ready" ] && [ "$fs_node" = "$original_node" ] && [ "$fs_uuid" = "$original_uuid" ] || die "filesystem identity changed after mount"
  expected_majmin="$(lsblk -dnro MAJ:MIN -- "$fs_node")"
  [ -n "$expected_majmin" ] || die "could not revalidate major:minor identity after mount"
  verify_data_mount "$fs_node" "$fs_uuid" "$expected_majmin" || die "mounted /data could not be verified"

  if [ "$need_fstab" -eq 1 ]; then
    tmp="$(mktemp /etc/.fstab.aws-ec2-vm.XXXXXX)"
    cp -p -- /etc/fstab "$tmp"
    printf '\n# aws-ec2-vm persistent data: %s\nUUID=%s /data ext4 defaults,nodev,nosuid,nofail,x-systemd.device-timeout=30s 0 2\n' "$volume_id" "$fs_uuid" >> "$tmp"
    chown root:root "$tmp"
    mv -f -- "$tmp" /etc/fstab
    mapfile -t data_entries < <(awk '!/^[[:space:]]*#/ && NF && $2 == "/data" { print $1 " " $3 " " $4 }' /etc/fstab)
    [ "${#data_entries[@]}" -eq 1 ] && [ "${data_entries[0]}" = "UUID=$fs_uuid ext4 defaults,nodev,nosuid,nofail,x-systemd.device-timeout=30s" ] || die "could not verify managed /etc/fstab entry"
    systemctl daemon-reload
  fi

  chown --no-dereference root:root /data
  chmod 0755 /data
  data_stat="$(stat -c '%u:%g:%a:%F' -- /data 2>/dev/null || true)"
  [ "$data_stat" = "0:0:755:directory" ] || die "/data filesystem root is not exactly root:root mode 0755"

  marker_dir="/data/.aws-ec2-vm"
  [ ! -L "$marker_dir" ] || die "$marker_dir is a symlink"
  if [ -e "$marker_dir" ]; then
    [ "$(stat -c '%u:%g:%a:%F' -- "$marker_dir" 2>/dev/null || true)" = "0:0:700:directory" ] || die "$marker_dir is not a secure root-only directory"
  else
    install -d -o root -g root -m 0700 "$marker_dir"
  fi
  if [ -L "/data/$marker_name" ]; then rm -f -- "/data/$marker_name"; fi
  [ ! -e "/data/$marker_name" ] || [ -f "/data/$marker_name" ] || die "storage marker is not a regular file"
  marker_tmp="$(mktemp "$marker_dir/marker.XXXXXX")"
  printf 'NAME=%s\nINSTANCE_ID=%s\nVOLUME_ID=%s\nUUID=%s\n' "$vm_name" "$instance_id" "$volume_id" "$fs_uuid" > "$marker_tmp"
  chown root:root "$marker_tmp"
  chmod 0644 "$marker_tmp"
  mv -f -- "$marker_tmp" "/data/$marker_name"
  [ "$(stat -c '%u:%g:%a:%F' -- "/data/$marker_name" 2>/dev/null || true)" = "0:0:644:regular file" ] || die "storage marker permissions did not verify"

  ensure_top_user_directory /data/workspace "$uid" "$gid"
  ensure_top_user_directory /data/tools "$uid" "$gid"
  ensure_user_directory /data/tools/bun "$uid" "$gid"
  ensure_user_directory /data/tools/npm "$uid" "$gid"
  ensure_user_directory /data/tools/bin "$uid" "$gid"
  write_profile "$uid"
  disarm_mount_failure_cleanup
}

resolve_disk
classify_disk
case "$mode" in
  probe)
    if [ "$classification" = "blank" ]; then
      prove_blank
      printf 'BLANK\n'
    else
      printf 'READY\t%s\n' "$fs_uuid"
    fi
    ;;
  init)
    if [ "$classification" = "blank" ]; then
      prove_blank
      [ "$confirmation" = "FORMAT $volume_id" ] || die "invalid format confirmation"
      original_disk="$disk"
      resolve_disk
      [ "$disk" = "$original_disk" ] || die "EBS device identity changed before format"
      classify_disk
      [ "$classification" = "blank" ] || die "filesystem appeared before format; refusing"
      prove_blank
      mkfs.ext4 -L aws-vm-data "$disk" >/dev/null
      classify_disk
      [ "$classification" = "ready" ] || die "new ext4 filesystem could not be verified"
    fi
    prepare_filesystem
    printf 'READY\t%s\n' "$fs_uuid"
    ;;
  prepare)
    [ "$classification" = "ready" ] || die "persistent volume is blank; run exactly: $init_command"
    prepare_filesystem
    printf 'READY\t%s\n' "$fs_uuid"
    ;;
  *) die "invalid storage mode" ;;
esac
REMOTE_STORAGE
  then
    printf '\036'
    return 0
  else
    local status=$?
    [ "$status" -ne 75 ] || die "timed out after 30 seconds waiting for the remote host storage lock; inspect other storage operations on $INSTANCE_ID"
    return "$status"
  fi
}

prepare_storage_endpoint() {
  prepare_ssh_endpoint
  build_ssh_args
  validate_storage_attachment
}

parse_storage_result() {
  local result="$1"
  case "$result" in *$'\n') result="${result%$'\n'}" ;; *) die "remote storage response did not end with exactly one newline" ;; esac
  case "$result" in *$'\n'*|*$'\r'*|*$'\t'*$'\t'*) die "remote storage response contained unexpected framing" ;; esac
  [[ "$result" =~ ^READY$'\t'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$ ]] || die "remote storage response was invalid"
  STORAGE_UUID="${BASH_REMATCH[1]}"
}

unframe_storage_result() {
  local framed="$1" sentinel=$'\036'
  case "$framed" in *"$sentinel") STORAGE_RESULT="${framed%"$sentinel"}" ;; *) die "remote storage response sentinel was missing" ;; esac
}

prepare_storage() {
  local result
  prepare_storage_endpoint
  result="$(run_remote_storage prepare)"
  unframe_storage_result "$result"
  parse_storage_result "$STORAGE_RESULT"
  info "Persistent storage ready: name=$NAME volume=$VOLUME_ID uuid=$STORAGE_UUID path=/data"
}

init_storage() {
  local result answer
  [ -c /dev/tty ] || die "init-storage requires a controlling terminal at /dev/tty"
  if ! (: <> /dev/tty) 2>/dev/null; then
    die "init-storage requires a readable and writable controlling terminal at /dev/tty"
  fi
  prepare_storage_endpoint
  result="$(run_remote_storage probe)"
  unframe_storage_result "$result"
  case "$STORAGE_RESULT" in
    READY$'\t'*)
      parse_storage_result "$STORAGE_RESULT"
      result="$(run_remote_storage prepare)"
      unframe_storage_result "$result"
      parse_storage_result "$STORAGE_RESULT"
      info "Persistent storage was already initialized and is ready: volume=$VOLUME_ID uuid=$STORAGE_UUID"
      return
      ;;
    BLANK$'\n') ;;
    *) die "remote storage probe returned an invalid response" ;;
  esac
  printf 'Verified blank persistent volume %s. Type FORMAT %s to continue: ' "$VOLUME_ID" "$VOLUME_ID" > /dev/tty || die "could not write format confirmation prompt to /dev/tty"
  IFS= read -r answer < /dev/tty || die "could not read format confirmation from /dev/tty"
  [ "$answer" = "FORMAT $VOLUME_ID" ] || die "cancelled; confirmation must exactly match FORMAT $VOLUME_ID"
  result="$(run_remote_storage init "$answer")"
  unframe_storage_result "$result"
  parse_storage_result "$STORAGE_RESULT"
  info "Initialized and prepared persistent storage: volume=$VOLUME_ID uuid=$STORAGE_UUID path=/data"
}

sshfs_version_ok() {
  local binary="$1" output major minor patch
  output="$("$binary" -V 2>&1 || true)"
  [[ "$output" =~ SSHFS[[:space:]]+version[[:space:]]+([0-9]+)\.([0-9]+)\.([0-9]+) ]] || return 1
  major="${BASH_REMATCH[1]}"; minor="${BASH_REMATCH[2]}"; patch="${BASH_REMATCH[3]}"
  [ "$major" -gt 3 ] || { [ "$major" -eq 3 ] && { [ "$minor" -gt 7 ] || { [ "$minor" -eq 7 ] && [ "$patch" -ge 6 ]; }; }; }
}

install_verified_sshfs() {
  command -v brew >/dev/null 2>&1 || die "--install-deps requires Homebrew; install it from https://brew.sh and retry"
  command -v curl >/dev/null 2>&1 || die "curl is required to install SSHFS"
  command -v shasum >/dev/null 2>&1 || die "shasum is required to verify SSHFS"
  brew list --cask macfuse >/dev/null 2>&1 || brew install --cask macfuse
  local formula
  for formula in glib meson ninja pkgconf; do
    brew list --formula "$formula" >/dev/null 2>&1 || brew install "$formula"
  done
  local tmp archive actual pkg_path
  tmp="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-sshfs.XXXXXX")"
  archive="$tmp/sshfs-$SSHFS_VERSION.tar.xz"
  trap 'rm -rf -- "$tmp"' RETURN
  curl -fL --proto '=https' --tlsv1.2 -o "$archive" "https://github.com/libfuse/sshfs/releases/download/sshfs-$SSHFS_VERSION/sshfs-$SSHFS_VERSION.tar.xz"
  actual="$(shasum -a 256 "$archive" | awk '{print $1}')"
  [ "$actual" = "$SSHFS_SHA256" ] || die "SSHFS archive checksum mismatch"
  tar -xJf "$archive" -C "$tmp"
  pkg_path="/usr/local/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  PKG_CONFIG_PATH="$pkg_path" meson setup "$tmp/build" "$tmp/sshfs-$SSHFS_VERSION" --prefix="$HOME/.local" --buildtype=release
  PKG_CONFIG_PATH="$pkg_path" meson compile -C "$tmp/build"
  mkdir -p "$HOME/.local/bin"
  install -m 0755 "$tmp/build/sshfs" "$HOME/.local/bin/sshfs"
  trap - RETURN
  rm -rf -- "$tmp"
  SSHFS_BIN="$HOME/.local/bin/sshfs"
  if [ ! -x "$SSHFS_BIN" ] || ! sshfs_version_ok "$SSHFS_BIN"; then
    die "verified SSHFS install did not produce a usable version >= $SSHFS_VERSION"
  fi
}

ensure_sshfs() {
  [ "$(uname -s)" = "Darwin" ] || die "mount requires macOS"
  if command -v sshfs >/dev/null 2>&1; then
    SSHFS_BIN="$(command -v sshfs)"
    if sshfs_version_ok "$SSHFS_BIN"; then return; fi
    [ "$INSTALL_DEPS" -eq 1 ] || die "SSHFS at $SSHFS_BIN is older than $SSHFS_VERSION or has an unparseable version; rerun mount with --install-deps"
  elif [ "$INSTALL_DEPS" -eq 0 ]; then
    die "SSHFS >= $SSHFS_VERSION is required; rerun mount with --install-deps"
  fi
  install_verified_sshfs
}

canonicalize_mount_dir() {
  local create="$1" parent base
  [ -n "$MOUNT_DIR" ] || MOUNT_DIR="$HOME/mnt/aws-ec2-vm/$NAME"
  case "$MOUNT_DIR" in /*) ;; *) MOUNT_DIR="$PWD/$MOUNT_DIR" ;; esac
  [ "$MOUNT_DIR" != "/" ] || die "refusing to use / as a mountpoint"
  [ ! -L "$MOUNT_DIR" ] || die "refusing symlinked mountpoint: $MOUNT_DIR"
  parent="$(dirname -- "$MOUNT_DIR")"
  base="$(basename -- "$MOUNT_DIR")"
  if [ "$create" -eq 1 ]; then
    mkdir -p -- "$parent"
  else
    [ -d "$parent" ] || die "mountpoint parent does not exist: $parent"
  fi
  parent="$(cd -- "$parent" && pwd -P)"
  MOUNT_DIR="$parent/$base"
  if [ "$create" -eq 1 ]; then
    if [ -e "$MOUNT_DIR" ]; then
      [ -d "$MOUNT_DIR" ] || die "mountpoint is not a directory: $MOUNT_DIR"
    elif [ -n "$(mount_lines_for_target "$MOUNT_DIR")" ]; then
      :
    else
      mkdir -- "$MOUNT_DIR" 2>/dev/null || {
        [ -d "$MOUNT_DIR" ] || [ -n "$(mount_lines_for_target "$MOUNT_DIR")" ] ||
          die "could not create mountpoint directory: $MOUNT_DIR"
      }
    fi
  fi
}

ensure_mount_config_dir() {
  local dir="$STATE_DIR/mounts"
  [ ! -L "$STATE_DIR" ] || die "refusing symlinked state directory: $STATE_DIR"
  [ ! -e "$STATE_DIR" ] || [ -d "$STATE_DIR" ] || die "state path is not a directory: $STATE_DIR"
  mkdir -p -- "$STATE_DIR"
  [ -O "$STATE_DIR" ] || die "state directory is not owned by the current user: $STATE_DIR"
  chmod 700 "$STATE_DIR"
  [ ! -L "$dir" ] || die "refusing symlinked mount-config directory: $dir"
  [ ! -e "$dir" ] || [ -d "$dir" ] || die "mount-config path is not a directory: $dir"
  mkdir -p -- "$dir"
  [ -O "$dir" ] || die "mount-config directory is not owned by the current user: $dir"
  chmod 700 "$dir"
  dir="$(cd -- "$dir" && pwd -P)"
  MOUNT_CONFIG="$dir/$NAME.conf"
}

acquire_mount_path_lock() {
  [ -x /usr/bin/shasum ] || die "/usr/bin/shasum is required to lock canonical mountpoints safely"
  local uid username home_record real_home runtime root claim_root digest_output digest lock stored permissions tmp
  uid="$(id -u)"
  case "$uid" in ''|*[!0-9]*) die "could not determine numeric local UID for mount locking" ;; esac
  [ "$(uname -s)" = "Darwin" ] && [ -x /usr/bin/getconf ] || die "canonical mountpoint locking requires macOS getconf"
  runtime="$(/usr/bin/getconf DARWIN_USER_TEMP_DIR)" || die "could not resolve the Darwin per-user runtime directory"
  runtime="${runtime%/}"
  [ ! -L "$runtime" ] && [ -d "$runtime" ] && [ -O "$runtime" ] || die "Darwin per-user runtime directory is insecure: $runtime"
  [ "$(stat -f '%u %Lp' "$runtime" 2>/dev/null || true)" = "$uid 700" ] || die "Darwin per-user runtime directory must be owner-only: $runtime"
  root="$runtime/aws-ec2-vm-mount-locks"
  [ -x /usr/bin/dscl ] || die "/usr/bin/dscl is required to resolve the trusted local home directory"
  username="$(/usr/bin/id -un)" || die "could not resolve the local account name"
  home_record="$(/usr/bin/dscl . -read "/Users/$username" NFSHomeDirectory 2>/dev/null)" || die "could not resolve the trusted home directory for $username"
  case "$home_record" in "NFSHomeDirectory: "*) ;; *) die "directory services returned an invalid home record for $username" ;; esac
  real_home="${home_record#NFSHomeDirectory: }"
  case "$real_home" in /*) ;; *) die "directory services returned a non-absolute home path" ;; esac
  case "$real_home" in *[[:cntrl:]]*) die "directory services returned a home path with control characters" ;; esac
  [ ! -L "$real_home" ] && [ -d "$real_home" ] && [ -O "$real_home" ] || die "trusted home path is insecure: $real_home"
  [ "$(stat -f '%u' "$real_home" 2>/dev/null || true)" = "$uid" ] || die "trusted home path is not owned by UID $uid: $real_home"
  claim_root="$real_home/.aws-ec2-vm-mount-claims"
  [ ! -L "$claim_root" ] || die "refusing symlinked persistent mount-claim directory: $claim_root"
  [ ! -e "$claim_root" ] || [ -d "$claim_root" ] || die "persistent mount-claim path is not a directory: $claim_root"
  mkdir -p -- "$claim_root"
  [ -O "$claim_root" ] || die "persistent mount-claim directory is not owned by the current user: $claim_root"
  chmod 700 "$claim_root"
  [ "$(stat -f '%u %Lp' "$claim_root" 2>/dev/null || true)" = "$uid 700" ] || die "persistent mount-claim directory must be owner-only: $claim_root"
  [ ! -L "$root" ] || die "refusing symlinked mount-lock directory: $root"
  [ ! -e "$root" ] || [ -d "$root" ] || die "mount-lock path is not a directory: $root"
  mkdir -p -- "$root"
  [ -O "$root" ] || die "mount-lock directory is not owned by the current user: $root"
  chmod 700 "$root"
  permissions="$(stat -f '%Lp' "$root" 2>/dev/null || stat -c '%a' "$root" 2>/dev/null || true)"
  [ "$permissions" = "700" ] || die "mount-lock directory must have mode 0700: $root"
  digest_output="$(printf '%s' "$MOUNT_DIR" | /usr/bin/shasum -a 256)" || die "could not hash canonical mountpoint"
  digest="${digest_output%% *}"
  [[ "$digest" =~ ^[0-9a-f]{64}$ ]] || die "/usr/bin/shasum returned an invalid SHA-256 digest"
  lock="$root/$digest.lock"
  MOUNT_CLAIM_FILE="$claim_root/$digest.claim"
  [ ! -L "$lock" ] || die "refusing symlinked canonical mountpoint lock: $lock"
  if ! mkdir "$lock" 2>/dev/null; then
    reclaim_stale_lock "$lock" "canonical mountpoint $MOUNT_DIR" "$MOUNT_DIR"
    mkdir "$lock" 2>/dev/null || die "another operation acquired canonical mountpoint $MOUNT_DIR; retry"
  fi
  MOUNT_PATH_LOCK_DIR="$lock"
  chmod 700 "$lock"
  write_lock_owner "$lock" || die "could not record canonical mountpoint lock ownership"
  tmp="$lock/path.tmp.$$"
  umask 077
  printf '%s\n' "$MOUNT_DIR" > "$tmp"
  chmod 600 "$tmp"
  mv -f -- "$tmp" "$lock/path"
  stored="$(< "$lock/path")"
  [ "$stored" = "$MOUNT_DIR" ] || die "could not verify canonical mountpoint lock path"
}

load_mount_claim() {
  [ ! -L "$MOUNT_CLAIM_FILE" ] && [ -f "$MOUNT_CLAIM_FILE" ] && [ -O "$MOUNT_CLAIM_FILE" ] || die "canonical mountpoint claim is missing or insecure: $MOUNT_CLAIM_FILE"
  local permissions links key value claim_name="" claim_path="" claim_config="" name_count=0 path_count=0 config_count=0
  read -r permissions links <<< "$(stat -f '%Lp %l' "$MOUNT_CLAIM_FILE" 2>/dev/null || true)"
  [ "$permissions" = "600" ] && [ "$links" = "1" ] || die "canonical mountpoint claim must be a private, single-link file"
  while IFS='=' read -r key value; do
    case "$key" in NAME) claim_name="$value"; name_count=$((name_count + 1)) ;; MOUNT_DIR) claim_path="$value"; path_count=$((path_count + 1)) ;; MOUNT_CONFIG) claim_config="$value"; config_count=$((config_count + 1)) ;; *) die "canonical mountpoint claim has unknown metadata" ;; esac
  done < "$MOUNT_CLAIM_FILE"
  [ "$name_count" -eq 1 ] && [ "$path_count" -eq 1 ] && [ "$config_count" -eq 1 ] || die "canonical mountpoint claim has duplicate or missing metadata"
  [ "$claim_name" = "$NAME" ] && [ "$claim_path" = "$MOUNT_DIR" ] && [ "$claim_config" = "$MOUNT_CONFIG" ] ||
    die "canonical mountpoint $MOUNT_DIR is durably claimed by another VM state"
}

save_mount_claim() {
  local tmp="$MOUNT_CLAIM_FILE.tmp.$$"
  umask 077
  printf 'NAME=%s\nMOUNT_DIR=%s\nMOUNT_CONFIG=%s\n' "$NAME" "$MOUNT_DIR" "$MOUNT_CONFIG" > "$tmp" || return 1
  chmod 600 "$tmp" || return 1
  mv -f -- "$tmp" "$MOUNT_CLAIM_FILE" || return 1
}

remove_mount_claim() {
  load_mount_claim
  rm -f -- "$MOUNT_CLAIM_FILE"
}

recover_missing_mount_claim() {
  local allow_force_recovery="$1" lines
  load_mount_config
  [ "$CONFIG_MOUNT_DIR" = "$MOUNT_DIR" ] || die "cannot recover mount claim: config mountpoint differs from $MOUNT_DIR"
  lines="$(mount_lines_for_target "$MOUNT_DIR")"
  if [ -n "$lines" ]; then
    managed_mount_line "$CONFIG_SOURCE" "$MOUNT_DIR" || die "cannot recover missing claim because $MOUNT_DIR has a different source"
    if mount_health_ok "$MOUNT_DIR" "$CONFIG_NAME" "$CONFIG_INSTANCE_ID" "$CONFIG_VOLUME_ID" "$CONFIG_UUID"; then
      :
    elif [ "$allow_force_recovery" -eq 1 ] && [ "$FORCE" -eq 1 ]; then
      warn "Recovering missing persistent claim for an exact but unhealthy managed source before explicit force-unmount"
    else
      die "cannot recover missing persistent claim without an exact healthy marker; use explicit --force only for stale managed-mount recovery"
    fi
  fi
  save_mount_claim || die "could not reconstruct missing persistent mountpoint claim: $MOUNT_CLAIM_FILE"
  info "Reconstructed persistent canonical mountpoint claim from secure config: $MOUNT_DIR"
}

CONFIG_NAME=""
CONFIG_INSTANCE_ID=""
CONFIG_VOLUME_ID=""
CONFIG_UUID=""
CONFIG_SOURCE=""
CONFIG_MOUNT_DIR=""
CONFIG_SSH_CONFIG=""

load_mount_config() {
  [ ! -L "$MOUNT_CONFIG" ] && [ -f "$MOUNT_CONFIG" ] && [ -O "$MOUNT_CONFIG" ] || die "managed mount config is missing or insecure: $MOUNT_CONFIG"
  local key value permissions
  permissions="$(stat -f '%Lp' "$MOUNT_CONFIG" 2>/dev/null || stat -c '%a' "$MOUNT_CONFIG" 2>/dev/null || true)"
  [ "$permissions" = "600" ] || die "managed mount config must have mode 0600: $MOUNT_CONFIG"
  CONFIG_NAME=""; CONFIG_INSTANCE_ID=""; CONFIG_VOLUME_ID=""; CONFIG_UUID=""; CONFIG_SOURCE=""; CONFIG_MOUNT_DIR=""; CONFIG_SSH_CONFIG=""
  while IFS='=' read -r key value; do
    case "$key" in
      NAME) CONFIG_NAME="$value" ;;
      INSTANCE_ID) CONFIG_INSTANCE_ID="$value" ;;
      VOLUME_ID) CONFIG_VOLUME_ID="$value" ;;
      UUID) CONFIG_UUID="$value" ;;
      SOURCE) CONFIG_SOURCE="$value" ;;
      MOUNT_DIR) CONFIG_MOUNT_DIR="$value" ;;
      SSH_CONFIG) CONFIG_SSH_CONFIG="$value" ;;
      *) die "unknown field in mount config: $key" ;;
    esac
  done < "$MOUNT_CONFIG"
  [ "$CONFIG_NAME" = "$NAME" ] || die "mount config belongs to another VM"
  case "$CONFIG_INSTANCE_ID" in i-[a-zA-Z0-9]*) ;; *) die "invalid instance ID in mount config" ;; esac
  case "$CONFIG_VOLUME_ID" in vol-[0-9a-f]*) ;; *) die "invalid volume ID in mount config" ;; esac
  [ -n "$CONFIG_UUID" ] && [ -n "$CONFIG_SOURCE" ] && [ -n "$CONFIG_MOUNT_DIR" ] || die "incomplete mount config"
  [ "$CONFIG_SOURCE" = "aws-ec2-vm-$NAME-$CONFIG_INSTANCE_ID:/data" ] || die "mount config has an unexpected source"
  [ "$CONFIG_SSH_CONFIG" = "$STATE_DIR/sshfs/$NAME-$CONFIG_INSTANCE_ID.conf" ] || die "mount config references an unexpected SSH config"
}

save_mount_config() {
  local source="$1" ssh_config="$2" tmp
  umask 077
  tmp="$MOUNT_CONFIG.tmp.$$"
  : > "$tmp" || return 1
  printf 'NAME=%s\nINSTANCE_ID=%s\nVOLUME_ID=%s\nUUID=%s\nSOURCE=%s\nMOUNT_DIR=%s\nSSH_CONFIG=%s\n' \
    "$NAME" "$INSTANCE_ID" "$VOLUME_ID" "$STORAGE_UUID" "$source" "$MOUNT_DIR" "$ssh_config" > "$tmp" || return 1
  chmod 600 "$tmp" || return 1
  mv -f -- "$tmp" "$MOUNT_CONFIG" || return 1
}

mount_lines_for_target() {
  local target="$1" line prefix
  prefix=" on $target ("
  /sbin/mount | while IFS= read -r line; do
    case "$line" in *"$prefix"*) printf '%s\n' "$line" ;; esac
  done
}

managed_mount_line() {
  local source="$1" target="$2" line count=0 match=""
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    count=$((count + 1))
    case "$line" in
      "$source on $target (macfuse)"|"$source on $target (macfuse,"*) match="$line" ;;
      *) return 1 ;;
    esac
  done < <(mount_lines_for_target "$target")
  [ "$count" -eq 1 ] && [ -n "$match" ]
}

mount_health_ok() {
  local mountpoint="$1" name="$2" instance="$3" volume="$4" uuid="$5"
  /usr/bin/perl -e '
    $SIG{ALRM} = sub { exit 124 }; alarm 5;
    open(my $fh, "<", $ARGV[0]) or exit 1;
    my $expected = "NAME=$ARGV[1]\nINSTANCE_ID=$ARGV[2]\nVOLUME_ID=$ARGV[3]\nUUID=$ARGV[4]\n";
    my $limit = length($expected) + 1;
    my $actual = "";
    my $eof = 0;
    while (length($actual) < $limit) {
      my $read = sysread($fh, my $chunk, $limit - length($actual));
      defined($read) or exit 1;
      if ($read == 0) { $eof = 1; last; }
      $actual .= $chunk;
    }
    exit($eof && $actual eq $expected ? 0 : 1);
  ' "$mountpoint/$DATA_MARKER" "$name" "$instance" "$volume" "$uuid"
}

ssh_config_quote() {
  local value="$1"
  value="${value//\\/\\\\}"
  value="${value//\"/\\\"}"
  printf '"%s"' "$value"
}

write_sshfs_config() {
  local dir="$STATE_DIR/sshfs" config="$STATE_DIR/sshfs/$NAME-$INSTANCE_ID.conf" tmp alias
  [ ! -L "$dir" ] || die "refusing symlinked SSHFS config directory: $dir"
  [ ! -e "$dir" ] || [ -d "$dir" ] || die "SSHFS config path is not a directory: $dir"
  mkdir -p -- "$dir"
  [ -O "$dir" ] || die "SSHFS config directory is not owned by the current user: $dir"
  chmod 700 "$dir"
  alias="aws-ec2-vm-$NAME-$INSTANCE_ID"
  tmp="$config.tmp.$$"
  umask 077
  {
    printf 'Host %s\n' "$alias"
    printf '  HostName %s\n  User ec2-user\n' "$PUBLIC_IP"
    printf '  HostKeyAlias %s\n' "$PUBLIC_IP"
    printf '  IdentityFile %s\n' "$(ssh_config_quote "$KEY_PATH")"
    printf '  UserKnownHostsFile %s\n' "$(ssh_config_quote "$SSH_KNOWN_HOSTS")"
    printf '  GlobalKnownHostsFile /dev/null\n  StrictHostKeyChecking yes\n  KnownHostsCommand none\n  UpdateHostKeys no\n  IdentitiesOnly yes\n'
    printf '  BatchMode yes\n  ConnectTimeout 10\n  ServerAliveInterval 15\n  ServerAliveCountMax 3\n'
  } > "$tmp"
  chmod 600 "$tmp"
  mv -f -- "$tmp" "$config"
  printf '%s\n' "$config"
}

assert_mountpoint_not_claimed() {
  local config key value other_name="" other_path="" permissions
  shopt -s nullglob
  for config in "$STATE_DIR"/mounts/*.conf; do
    [ "$config" = "$MOUNT_CONFIG" ] && continue
    [ ! -L "$config" ] && [ -f "$config" ] && [ -O "$config" ] || die "insecure mount config exists: $config"
    permissions="$(stat -f '%Lp' "$config" 2>/dev/null || stat -c '%a' "$config" 2>/dev/null || true)"
    [ "$permissions" = "600" ] || die "mount config must have mode 0600: $config"
    other_name=""; other_path=""
    while IFS='=' read -r key value; do
      case "$key" in NAME) other_name="$value" ;; MOUNT_DIR) other_path="$value" ;; esac
    done < "$config"
    [ "$other_path" != "$MOUNT_DIR" ] || die "mountpoint $MOUNT_DIR is already assigned to VM $other_name"
  done
}

mount_storage() {
  [ "$(uname -s)" = "Darwin" ] || die "mount requires macOS"
  canonicalize_mount_dir 1
  ensure_mount_config_dir
  acquire_mount_path_lock
  if [ -e "$MOUNT_CONFIG" ] || [ -L "$MOUNT_CONFIG" ]; then
    if [ -e "$MOUNT_CLAIM_FILE" ] || [ -L "$MOUNT_CLAIM_FILE" ]; then
      load_mount_claim
    else
      recover_missing_mount_claim 0
    fi
  elif [ -e "$MOUNT_CLAIM_FILE" ] || [ -L "$MOUNT_CLAIM_FILE" ]; then
    load_mount_claim
    [ -z "$(mount_lines_for_target "$MOUNT_DIR")" ] || die "persistent claim exists without config while $MOUNT_DIR is mounted; refusing adoption"
    remove_mount_claim
  fi
  assert_mountpoint_not_claimed
  prepare_storage
  ensure_sshfs
  local alias source ssh_config lines sshfs_log sshfs_pid attempt mounted=0
  alias="aws-ec2-vm-$NAME-$INSTANCE_ID"
  source="$alias:/data"
  if [ -e "$MOUNT_CONFIG" ] || [ -L "$MOUNT_CONFIG" ]; then
    load_mount_config
    if [ "$CONFIG_INSTANCE_ID" = "$INSTANCE_ID" ] && [ "$CONFIG_VOLUME_ID" = "$VOLUME_ID" ] &&
       [ "$CONFIG_UUID" = "$STORAGE_UUID" ] && [ "$CONFIG_SOURCE" = "$source" ] && [ "$CONFIG_MOUNT_DIR" = "$MOUNT_DIR" ]; then
      if managed_mount_line "$source" "$MOUNT_DIR"; then
        if mount_health_ok "$MOUNT_DIR" "$NAME" "$INSTANCE_ID" "$VOLUME_ID" "$STORAGE_UUID"; then
          info "SSHFS mount is healthy: name=$NAME mountpoint=$MOUNT_DIR"
          printf 'Name: %s\nMountpoint: %s\n' "$NAME" "$MOUNT_DIR"
          return
        elif [ "$RECOVER_STALE_MOUNT" -eq 1 ]; then
          warn "Force-unmounting the exact unhealthy managed SSHFS mount before remounting; active handles will error and in-flight writes may be lost."
          /sbin/umount -f "$MOUNT_DIR"
          [ -z "$(mount_lines_for_target "$MOUNT_DIR")" ] || die "mount is still present after stale-mount recovery: $MOUNT_DIR"
        fi
      fi
    fi
  fi
  lines="$(mount_lines_for_target "$MOUNT_DIR")"
  [ -z "$lines" ] || die "$MOUNT_DIR is already mounted but is not the exact healthy mount for $NAME; use unmount --force only if its marker read is unresponsive"
  ssh_config="$(write_sshfs_config)"
  sshfs_log="$STATE_DIR/sshfs/$NAME-$INSTANCE_ID.log"
  umask 077
  : > "$sshfs_log"
  chmod 600 "$sshfs_log"
  nohup "$SSHFS_BIN" -f -F "$ssh_config" "$source" "$MOUNT_DIR" -o reconnect -o ServerAliveInterval=15 -o ServerAliveCountMax=3 \
    -o ConnectTimeout=10 -o BatchMode=yes -o StrictHostKeyChecking=yes -o contain_symlinks -o nodev -o nosuid \
    > "$sshfs_log" 2>&1 < /dev/null &
  sshfs_pid=$!
  for attempt in $(seq 1 20); do
    if managed_mount_line "$source" "$MOUNT_DIR" && mount_health_ok "$MOUNT_DIR" "$NAME" "$INSTANCE_ID" "$VOLUME_ID" "$STORAGE_UUID"; then
      mounted=1
      break
    fi
    kill -0 "$sshfs_pid" 2>/dev/null || break
    sleep 1
  done
  if [ "$mounted" -ne 1 ]; then
    kill "$sshfs_pid" 2>/dev/null || true
    wait "$sshfs_pid" 2>/dev/null || true
    if managed_mount_line "$source" "$MOUNT_DIR"; then
      /sbin/umount "$MOUNT_DIR" >/dev/null 2>&1 || true
    fi
    die "SSHFS did not produce a healthy mount; inspect $sshfs_log. If macFUSE was just installed, approve it in System Settings > Privacy & Security, restart your Mac, and retry"
  fi
  if ! save_mount_config "$source" "$ssh_config"; then
    warn "Could not save durable mount ownership metadata; attempting normal unmount"
    /sbin/umount "$MOUNT_DIR" >/dev/null 2>&1 || warn "Automatic cleanup failed; inspect $MOUNT_DIR before retrying"
    die "could not save secure mount configuration: $MOUNT_CONFIG"
  fi
  if ! save_mount_claim; then
    warn "Could not save durable state-independent mountpoint ownership; attempting normal unmount"
    /sbin/umount "$MOUNT_DIR" >/dev/null 2>&1 || warn "Automatic cleanup failed; inspect $MOUNT_DIR before retrying"
    rm -f -- "$MOUNT_CONFIG"
    die "could not save canonical mountpoint claim: $MOUNT_CLAIM_FILE"
  fi
  info "Mounted persistent data: name=$NAME volume=$VOLUME_ID uuid=$STORAGE_UUID"
  printf 'Name: %s\nMountpoint: %s\n' "$NAME" "$MOUNT_DIR"
}

unmount_storage() {
  canonicalize_mount_dir 0
  ensure_mount_config_dir
  acquire_mount_path_lock
  if [ -e "$MOUNT_CONFIG" ]; then
    if [ -e "$MOUNT_CLAIM_FILE" ] || [ -L "$MOUNT_CLAIM_FILE" ]; then
      load_mount_claim
    else
      recover_missing_mount_claim 1
    fi
  elif [ -e "$MOUNT_CLAIM_FILE" ] || [ -L "$MOUNT_CLAIM_FILE" ]; then
    load_mount_claim
    [ -z "$(mount_lines_for_target "$MOUNT_DIR")" ] || die "canonical claim exists without secure config while $MOUNT_DIR is mounted; refusing to unmount"
    remove_mount_claim
  fi
  [ -e "$MOUNT_CONFIG" ] || {
    [ -z "$(mount_lines_for_target "$MOUNT_DIR")" ] || die "$MOUNT_DIR is mounted without this VM's secure ownership config; refusing to unmount"
    info "No managed mount exists for name=$NAME mountpoint=$MOUNT_DIR"
    return
  }
  load_mount_config
  [ "$CONFIG_MOUNT_DIR" = "$MOUNT_DIR" ] || die "requested mountpoint does not match $NAME's managed mount: $CONFIG_MOUNT_DIR"
  local lines
  lines="$(mount_lines_for_target "$MOUNT_DIR")"
  if [ -n "$lines" ]; then
    managed_mount_line "$CONFIG_SOURCE" "$MOUNT_DIR" || die "$MOUNT_DIR is not the exact managed macFUSE source; refusing to unmount"
    if mount_health_ok "$MOUNT_DIR" "$CONFIG_NAME" "$CONFIG_INSTANCE_ID" "$CONFIG_VOLUME_ID" "$CONFIG_UUID"; then
      /sbin/umount "$MOUNT_DIR"
    elif [ "$FORCE" -eq 1 ]; then
      warn "Force-unmounting an unhealthy SSHFS mount; active handles will error and in-flight writes may be lost."
      /sbin/umount -f "$MOUNT_DIR"
    else
      die "managed mount marker is unhealthy or unresponsive; inspect it, then rerun unmount with --force only for stale-mount recovery"
    fi
  fi
  [ -z "$(mount_lines_for_target "$MOUNT_DIR")" ] || die "mount is still present after unmount: $MOUNT_DIR"
  rm -f -- "$MOUNT_CONFIG"
  [ ! -e "$MOUNT_CLAIM_FILE" ] || remove_mount_claim
  info "Unmounted persistent data: name=$NAME mountpoint=$MOUNT_DIR"
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
  PUBLIC_DNS=""
  INSTANCE_READY="0"
  OLLAMA_READY="0"
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
  [ -z "$SSH_CONTROL_COMMAND" ] || fast_ssh_control
  STATE_FILE="$STATE_DIR/$NAME.state"
  case "$COMMAND" in setup) ;; *) acquire_lock ;; esac
  case "$COMMAND" in
    setup) setup ;;
    create) create_vm ;;
    status) status_vm ;;
    ssh) ssh_vm ;;
    init-storage) init_storage ;;
    prepare) prepare_storage ;;
    mount) mount_storage ;;
    unmount) unmount_storage ;;
    start) start_vm ;;
    restart) restart_vm ;;
    stop) stop_vm ;;
    terminate) terminate_vm ;;
    expose-port) expose_port ;;
    close-port) close_port ;;
    destroy-storage) destroy_storage ;;
  esac
}

main "$@"
