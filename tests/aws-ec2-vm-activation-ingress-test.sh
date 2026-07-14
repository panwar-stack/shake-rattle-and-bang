#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-activation-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

awk '/^main "\$@"$/ { found=1; exit } { print } END { if (!found) exit 1 }' "$SCRIPT" > "$TMP/aws-ec2-vm-functions.sh"
source "$TMP/aws-ec2-vm-functions.sh"

tests=0
failures=0
status=0
output=""
CASE_DIR=""
CASE_MODE=""
CASE_STATE=""
CASE_SSH_CIDR=""
CASE_OLLAMA_MODE=0
CASE_OLLAMA_CIDR=""
CASE_POST_INVENTORY_AT=999

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

assert_output_lacks() {
  local description="$1" unexpected="$2"
  tests=$((tests + 1))
  if [[ "$output" != *"$unexpected"* ]]; then pass "$description"; else fail "$description" "unexpected output containing: $unexpected\n$output"; fi
}

assert_log_empty() {
  local description="$1" path="$2"
  tests=$((tests + 1))
  if [ ! -s "$path" ]; then pass "$description"; else fail "$description" "unexpected log contents:\n$(< "$path")"; fi
}

assert_mutation_count() {
  local description="$1" expected="$2" pattern="$3" actual
  tests=$((tests + 1))
  actual="$(grep -Fc -- "$pattern" "$CASE_DIR/mutations" 2>/dev/null || true)"
  if [ "$actual" -eq "$expected" ]; then pass "$description"; else fail "$description" "expected $expected '$pattern' mutations, got $actual\n$(< "$CASE_DIR/mutations")"; fi
}

rule_row() {
  [ "$#" -eq 15 ] || return 99
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@"
}

tagged_row() {
  local id="$1" port="$2" cidr="$3" purpose="$4"
  rule_row "$id" sg-managed False tcp "$port" "$port" "$cidr" None None None \
    "aws-ec2-vm:v2:test:${purpose}:${port}" aws-ec2-vm test "$purpose" "$port"
}

increment_inventory_read() {
  local count=0
  [ ! -f "$CASE_DIR/reads" ] || count="$(wc -l < "$CASE_DIR/reads" | tr -d ' ')"
  printf '%s\n' "$((count + 1))" >> "$CASE_DIR/reads"
  printf '%s\n' "$((count + 1))"
}

activation_case() (
  NAME=test
  INSTANCE_ID=i-test
  INSTANCE_TOKEN=token-test
  AMI_INSTANCE_TOKEN=token-test
  INSTANCE_READY=0
  VOLUME_ID=vol-test
  VPC_ID=vpc-test
  SUBNET_ID=subnet-test
  AZ=us-east-1a
  SG_ID=sg-managed
  KEY_NAME=aws-vm-test
  AMI_ID=ami-test
  AMI_INSTANCE_TYPE=t3.small
  INSTANCE_TYPE=t3.small
  SG_SKIP_INSTANCE_SCOPE=0
  SSH_CIDR="$CASE_SSH_CIDR"
  OLLAMA_MODE="$CASE_OLLAMA_MODE"
  OLLAMA_CIDR="$CASE_OLLAMA_CIDR"
  STATE_DIR="$CASE_DIR/state"
  STATE_FILE="$STATE_DIR/test.state"
  mkdir -p "$STATE_DIR"
  prepare_existing() { :; }
  instance_state() { printf '%s\n' "$CASE_STATE"; }
  inspect_security_group_id_once() { return 0; }
  reconciliation_sleep() { :; }
  refresh_public_ip() { :; }
  save_state() { :; }
  print_commands() { printf '%s\n' ACTIVATION_SUCCESS; }
  direct_aws() {
    printf '%s\n' "$*" >> "$CASE_DIR/mutations"
  }
  AWS=(direct_aws)
  aws_text() {
    local read_number
    printf '%s\n' "$*" >> "$CASE_DIR/aws.log"
    case "$1:$2" in
      ec2:describe-instances)
        if [[ "$*" == *InstanceType* || "$*" == *ClientToken* ]]; then
          printf '%s\n' "i-test t3.small ami-test subnet-test us-east-1a aws-vm-test token-test $CASE_STATE sg-managed test aws-ec2-vm"
        else
          printf '%s\n' "$CASE_STATE sg-managed"
        fi
        ;;
      ec2:describe-security-group-rules)
        read_number="$(increment_inventory_read)"
        if [ "$read_number" -ge "$CASE_POST_INVENTORY_AT" ]; then
          [ ! -s "$CASE_DIR/post.inventory" ] || printf '%s\n' "$(< "$CASE_DIR/post.inventory")"
        else
          [ ! -s "$CASE_DIR/inventory" ] || printf '%s\n' "$(< "$CASE_DIR/inventory")"
        fi
        ;;
      ec2:start-instances|ec2:reboot-instances|ec2:authorize-security-group-ingress|ec2:revoke-security-group-ingress|ec2:attach-volume|ec2:modify-instance-attribute)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        ;;
      *)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        return 97
        ;;
    esac
  }
  case "$CASE_MODE" in
    start) start_vm ;;
    restart) restart_vm ;;
    create-partial) create_instance ;;
    *) return 96 ;;
  esac
)

run_activation_case() {
  local label="$1" mode="$2" state="$3" ssh_cidr="$4" ollama_mode="$5" ollama_cidr="$6" post_at="$7" inventory="$8" post_inventory="$9"
  CASE_DIR="$TMP/$label"
  rm -rf "$CASE_DIR"
  mkdir -p "$CASE_DIR"
  : > "$CASE_DIR/aws.log"
  : > "$CASE_DIR/mutations"
  printf '%s' "$inventory" > "$CASE_DIR/inventory"
  printf '%s' "$post_inventory" > "$CASE_DIR/post.inventory"
  CASE_MODE="$mode"
  CASE_STATE="$state"
  CASE_SSH_CIDR="$ssh_cidr"
  CASE_OLLAMA_MODE="$ollama_mode"
  CASE_OLLAMA_CIDR="$ollama_cidr"
  CASE_POST_INVENTORY_AT="$post_at"
  set +e
  output="$(activation_case 2>&1)"
  status=$?
  set -e
}

mkdir -p "$TMP/bin" "$TMP/cli-state"
cat > "$TMP/bin/aws" <<'MOCK_AWS'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MOCK_AWS_LOG"
exit 97
MOCK_AWS
chmod +x "$TMP/bin/aws"

for command in start restart; do
  : > "$TMP/cli-aws.log"
  set +e
  output="$(PATH="$TMP/bin:$PATH" AWS_VM_STATE_DIR="$TMP/cli-state" MOCK_AWS_LOG="$TMP/cli-aws.log" \
    "$SCRIPT" "$command" test --region us-east-1 --ssh-cidr 203.0.113.7/32 2>&1)"
  status=$?
  set -e
  assert_failure_contains "$command rejects --ssh-cidr outside create" '--ssh-cidr is supported only by create'
  assert_log_empty "$command option rejection occurs before AWS access" "$TMP/cli-aws.log"
done

foreign_ssh="$(rule_row sgr-foreignssh sg-managed False tcp 22 22 0.0.0.0/0 None None None unowned None None None None)"
run_activation_case start-ssh-conflict start stopped '' 0 '' 999 "$foreign_ssh" ''
assert_failure_contains 'stopped start rejects foreign effective SSH ingress' sgr-foreignssh
assert_mutation_count 'SSH conflict blocks start-instances' 0 'start-instances'

run_activation_case restart-ssh-conflict restart running '' 0 '' 999 "$foreign_ssh" ''
assert_failure_contains 'restart rejects foreign effective SSH ingress' sgr-foreignssh
assert_mutation_count 'SSH conflict blocks reboot-instances' 0 'reboot-instances'

run_activation_case partial-create-conflict create-partial stopped '' 0 '' 999 "$foreign_ssh" ''
assert_failure_contains 'stopped partial create preflights foreign SSH ingress' sgr-foreignssh
assert_mutation_count 'partial-create conflict blocks start-instances' 0 'start-instances'

owned_ssh="$(tagged_row sgr-ssh 22 203.0.113.7/32 ssh)"
foreign_ollama="$(rule_row sgr-foreignollama sg-managed False tcp 11434 11434 0.0.0.0/0 None None None unowned None None None None)"
run_activation_case start-ollama-conflict start stopped '' 1 203.0.113.7/32 999 "$owned_ssh
$foreign_ollama" ''
assert_failure_contains 'stopped start rejects foreign effective Ollama ingress' sgr-foreignollama
assert_mutation_count 'Ollama conflict blocks start-instances' 0 'start-instances'

run_activation_case missing-ssh-reconstruction start stopped '' 0 '' 999 '' ''
assert_failure_contains 'activation refuses to invent SSH access when no owned rule exists' 'exactly one effective, exactly owned IPv4 rule'
assert_mutation_count 'missing SSH reconstruction blocks start-instances' 0 'start-instances'

second_ssh="$(tagged_row sgr-sshsecond 22 198.51.100.4/32 ssh)"
run_activation_case duplicate-ssh-reconstruction start stopped '' 0 '' 999 "$owned_ssh
$second_ssh" ''
assert_failure_contains 'activation refuses ambiguous multiple owned SSH CIDRs' 'exactly one effective, exactly owned IPv4 rule'
assert_mutation_count 'ambiguous SSH reconstruction blocks start-instances' 0 'start-instances'

run_activation_case missing-ollama-cidr start stopped '' 1 '' 999 "$owned_ssh" ''
assert_failure_contains 'Ollama activation requires a persisted ingress CIDR' 'no persisted ingress CIDR'
assert_mutation_count 'missing Ollama CIDR blocks start-instances' 0 'start-instances'

post_conflict="$(rule_row sgr-postconflict sg-managed False tcp 22 22 0.0.0.0/0 None None None appeared-late None None None None)"
for mode in start restart; do
  if [ "$mode" = start ]; then state=stopped; mutation=start-instances; else state=running; mutation=reboot-instances; fi
  run_activation_case "$mode-postcheck" "$mode" "$state" '' 0 '' 5 "$owned_ssh" "$owned_ssh
$post_conflict"
  assert_failure_contains "$mode postcheck rejects ingress appearing after activation mutation" sgr-postconflict
  assert_mutation_count "$mode performs its activation mutation exactly once" 1 "$mutation"
  assert_output_lacks "$mode postcheck failure suppresses success output" ACTIVATION_SUCCESS
  if [ "$mode" = restart ]; then
    assert_output_lacks 'restart postcheck failure suppresses restart success message' 'Restart requested'
  fi
done

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
