#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-create-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

# Load function definitions without invoking the script's command dispatcher.
sed '$d' "$SCRIPT" > "$TMP/aws-ec2-vm-functions.sh"
source "$TMP/aws-ec2-vm-functions.sh"

tests=0
failures=0
status=0
output=""

pass() { printf 'ok %d - %s\n' "$tests" "$1"; }
fail() {
  printf 'not ok %d - %s\n%s\n' "$tests" "$1" "$2"
  failures=$((failures + 1))
}

assert_success() {
  local description="$1"
  tests=$((tests + 1))
  if [ "$status" -eq 0 ]; then pass "$description"; else fail "$description" "status=$status\n$output"; fi
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

# An equal saved/live instance type is a successful no-op. In particular, the
# function must not inherit the failed comparison's status under `set -e`.
mock_equal_type_aws() { printf '%s\n' 't3.small'; }
save_calls=0
save_state() { save_calls=$((save_calls + 1)); }
AWS=(mock_equal_type_aws)
INSTANCE_ID="i-equaltype"
INSTANCE_TYPE="t3.small"
INSTANCE_TYPE_EXPLICIT=0
set +e
sync_live_instance_type running > "$TMP/equal-type.output" 2>&1
status=$?
set -e
output="$(< "$TMP/equal-type.output")"
assert_success 'equal saved and live instance types return success'
tests=$((tests + 1))
if [ "$save_calls" -eq 0 ]; then
  pass 'equal saved and live instance types do not rewrite state'
else
  fail 'equal saved and live instance types do not rewrite state' "save_state called $save_calls time(s)"
fi

# A failed AWS health waiter must not disappear as a bare `set -e` exit.
instance_state() { printf '%s\n' running; }
aws_text() {
  case "$1:$2:$*" in
    ec2:describe-volumes:*) printf '%s\n' "$INSTANCE_ID" ;;
    ec2:modify-instance-attribute:*) ;;
    ec2:describe-instances:*) printf '%s\n' false ;;
    *) printf 'Unexpected aws_text call: %s\n' "$*" >&2; return 97 ;;
  esac
}
mock_waiter_aws() {
  case "$*" in
    'ec2 wait instance-status-ok '*) return 255 ;;
    'ec2 wait '*) return 0 ;;
    *) printf 'Unexpected direct AWS call: %s\n' "$*" >&2; return 98 ;;
  esac
}
refresh_public_ip() { :; }
AWS=(mock_waiter_aws)
INSTANCE_ID="i-healthcheck"
VOLUME_ID="vol-healthcheck"
set +e
output="$(create_instance 2>&1)"
status=$?
set -e
assert_failure_contains 'health waiter failure reports the affected instance' 'EC2 health checks failed for instance i-healthcheck'

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
