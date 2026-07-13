#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-az-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin"
cat > "$TMP/bin/aws" <<'MOCK_AWS'
#!/usr/bin/env bash
set -eu
printf '%s\n' "$*" >> "$MOCK_AWS_LOG"

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-cli-pager) shift ;;
    --profile|--region) shift 2 ;;
    *) break ;;
  esac
done

service="${1:-}"
operation="${2:-}"
case "$service:$operation" in
  sts:get-caller-identity) printf '%s\n' '123456789012' ;;
  ec2:describe-volumes)
    case " $* " in
      *AvailabilityZone*) printf '%s available None\n' "${MOCK_VOLUME_AZ:-us-east-1a}" ;;
      *) printf '%s\n' 'None' ;;
    esac
    ;;
  ec2:delete-volume) ;;
  ec2:describe-vpcs) printf '%s\n' 'vpc-test' ;;
  ec2:describe-subnets)
    case " $* " in
      *' --subnet-ids '*) printf 'vpc-test %s available\n' "${MOCK_SUBNET_AZ:-us-east-1a}" ;;
      *'SubnetId,AvailabilityZone'*) printf 'subnet-test %s\n' "${MOCK_SUBNET_AZ:-us-east-1a}" ;;
      *) printf '%s\n' 'subnet-test' ;;
    esac
    ;;
  ec2:describe-route-tables) printf '%s\n' 'None' ;;
  *) printf 'Unexpected mock AWS call: %s\n' "$*" >&2; exit 97 ;;
esac
MOCK_AWS
chmod +x "$TMP/bin/aws"

tests=0
failures=0
status=0
output=""

run_vm() {
  local state_dir="$1"
  shift
  : > "$TMP/aws.log"
  set +e
  output="$(PATH="$TMP/bin:$PATH" AWS_VM_STATE_DIR="$state_dir" MOCK_AWS_LOG="$TMP/aws.log" \
    "$SCRIPT" "$@" 2>&1)"
  status=$?
  set -e
}

pass() { printf 'ok %d - %s\n' "$tests" "$1"; }

fail() {
  printf 'not ok %d - %s\n%s\n' "$tests" "$1" "$2"
  failures=$((failures + 1))
}

assert_failure_contains() {
  local description="$1" expected="$2"
  tests=$((tests + 1))
  if [ "$status" -ne 0 ] && [[ "$output" == *"$expected"* ]]; then
    pass "$description"
  else
    fail "$description" "status=$status, expected output containing: $expected\n$output"
  fi
}

assert_log_contains() {
  local description="$1" expected="$2"
  tests=$((tests + 1))
  if grep -Fq -- "$expected" "$TMP/aws.log"; then
    pass "$description"
  else
    fail "$description" "expected AWS log containing: $expected\n$(< "$TMP/aws.log")"
  fi
}

assert_success() {
  local description="$1"
  tests=$((tests + 1))
  if [ "$status" -eq 0 ]; then
    pass "$description"
  else
    fail "$description" "status=$status\n$output"
  fi
}

new_state_dir() {
  local name="$1"
  rm -rf "${TMP:?}/$name"
  mkdir -p "$TMP/$name"
  printf '%s\n' "$TMP/$name"
}

# The option is create-only.
state_dir="$(new_state_dir create-only)"
run_vm "$state_dir" status zone-test --availability-zone us-east-1a
assert_failure_contains '--availability-zone is rejected outside create' 'supported only by create'

# An AZ is not a region override and must belong to the separately selected region.
state_dir="$(new_state_dir region-mismatch)"
run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-west-2a --ssh-cidr 203.0.113.1/32
assert_failure_contains 'availability zone must belong to selected region' 'us-east-1'

# A requested AZ selects the default subnet in that AZ while preserving --region.
state_dir="$(new_state_dir select-default)"
run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-east-1b --ssh-cidr 203.0.113.1/32
assert_failure_contains 'matching default subnet passes selection and reaches route validation' 'no active public route'
assert_log_contains 'default subnet lookup filters by requested AZ' 'Name=availability-zone,Values=us-east-1b'
assert_log_contains 'AWS region remains independent of requested AZ' '--region us-east-1 ec2 describe-subnets'

# An explicit subnet must agree with the requested AZ.
state_dir="$(new_state_dir subnet-mismatch)"
MOCK_SUBNET_AZ=us-east-1c run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-east-1b \
  --subnet-id subnet-explicit --ssh-cidr 203.0.113.1/32
assert_failure_contains 'explicit subnet in another AZ is rejected' 'subnet'
tests=$((tests + 1))
if [[ "$output" == *'us-east-1b'* && "$output" == *'us-east-1c'* ]]; then
  pass 'subnet mismatch identifies both availability zones'
else
  fail 'subnet mismatch identifies both availability zones' "$output"
fi

# A partial attempt persists the selected AZ for an idempotent retry.
state_dir="$(new_state_dir retry)"
run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-east-1b --ssh-cidr 203.0.113.1/32
assert_failure_contains 'first partial create persists state before resource creation' 'no active public route'
run_vm "$state_dir" create zone-test --ssh-cidr 203.0.113.1/32
assert_failure_contains 'retry reuses the saved availability zone' 'no active public route'
assert_log_contains 'retry subnet lookup uses saved AZ' 'Name=availability-zone,Values=us-east-1b'

# An explicit AZ cannot silently replace the AZ already persisted by a retry.
run_vm "$state_dir" create zone-test --availability-zone us-east-1c --ssh-cidr 203.0.113.1/32
assert_failure_contains 'conflicting explicit AZ on retry is rejected' 'us-east-1b'

# A retained EBS volume is authoritative and cannot be moved to a requested AZ.
state_dir="$(new_state_dir volume-mismatch)"
run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-east-1b --ssh-cidr 203.0.113.1/32
printf '%s\n' 'VOLUME_ID=vol-existing' >> "$state_dir/zone-test.state"
MOCK_VOLUME_AZ=us-east-1c run_vm "$state_dir" create zone-test --availability-zone us-east-1b --ssh-cidr 203.0.113.1/32
assert_failure_contains 'persisted EBS in another AZ is rejected' 'vol-existing'
tests=$((tests + 1))
if [[ "$output" == *'us-east-1b'* && "$output" == *'us-east-1c'* ]]; then
  pass 'volume mismatch identifies requested and EBS availability zones'
else
  fail 'volume mismatch identifies requested and EBS availability zones' "$output"
fi

# Explicitly deleting persistent storage releases its saved location for a fresh create.
state_dir="$(new_state_dir reset-after-destroy)"
run_vm "$state_dir" create zone-test --region us-east-1 --availability-zone us-east-1b --ssh-cidr 203.0.113.1/32
assert_failure_contains 'create before storage reset saves the original location' 'no active public route'
printf '%s\n' 'VOLUME_ID=vol-existing' >> "$state_dir/zone-test.state"
run_vm "$state_dir" destroy-storage zone-test --yes
assert_success 'destroy-storage succeeds for an unattached volume'
assert_log_contains 'destroy-storage deletes the persistent volume' 'ec2 delete-volume --volume-id vol-existing'
run_vm "$state_dir" create zone-test --availability-zone us-east-1c --ssh-cidr 203.0.113.1/32
assert_failure_contains 'recreate in a new AZ proceeds after storage destruction' 'no active public route'
assert_log_contains 'recreate selects a subnet in the new AZ' 'Name=availability-zone,Values=us-east-1c'

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
