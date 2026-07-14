#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-lifecycle-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

awk '/^main "\$@"$/ { found=1; exit } { print } END { if (!found) exit 1 }' "$SCRIPT" > "$TMP/aws-ec2-vm-functions.sh"
source "$TMP/aws-ec2-vm-functions.sh"
ssh-keygen -q -t ed25519 -N '' -C aws-vm-test -f "$TMP/fixture-key"
FIXTURE_PUBLIC="$(ssh-keygen -y -f "$TMP/fixture-key")"

tests=0
failures=0
status=0
output=""
CASE_DIR=""

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

assert_failure() {
  local description="$1"
  tests=$((tests + 1))
  if [ "$status" -ne 0 ]; then pass "$description"; else fail "$description" "expected failure, got status=0\n$output"; fi
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

assert_count() {
  local description="$1" expected="$2" path="$3" actual=0
  tests=$((tests + 1))
  if [ -f "$path" ]; then actual="$(wc -l < "$path" | tr -d ' ')"; fi
  if [ "$actual" -eq "$expected" ]; then pass "$description"; else fail "$description" "expected $expected lines in $path, got $actual"; fi
}

assert_log_count() {
  local description="$1" expected="$2" path="$3" pattern="$4" actual
  tests=$((tests + 1))
  actual="$(grep -Fc -- "$pattern" "$path" 2>/dev/null || true)"
  if [ "$actual" -eq "$expected" ]; then pass "$description"; else fail "$description" "expected $expected occurrences of '$pattern' in $path, got $actual"; fi
}

assert_empty() {
  local description="$1" path="$2"
  tests=$((tests + 1))
  if [ ! -s "$path" ]; then pass "$description"; else fail "$description" "unexpected contents:\n$(< "$path")"; fi
}

assert_file_contains() {
  local description="$1" path="$2" expected="$3"
  tests=$((tests + 1))
  if grep -Fqx -- "$expected" "$path"; then pass "$description"; else fail "$description" "expected exact line '$expected' in $path"; fi
}

assert_log_contains() {
  local description="$1" path="$2" expected="$3"
  tests=$((tests + 1))
  if grep -Fq -- "$expected" "$path"; then pass "$description"; else fail "$description" "expected '$expected' in $path\n$(< "$path")"; fi
}

assert_log_order() {
  local description="$1" path="$2" first="$3" second="$4" first_line second_line
  tests=$((tests + 1))
  first_line="$(grep -nF -- "$first" "$path" | awk -F: 'NR == 1 { print $1 }' || true)"
  second_line="$(grep -nF -- "$second" "$path" | awk -F: 'NR == 1 { print $1 }' || true)"
  if [ -n "$first_line" ] && [ -n "$second_line" ] && [ "$first_line" -lt "$second_line" ]; then
    pass "$description"
  else
    fail "$description" "expected '$first' before '$second' in $path\n$(< "$path")"
  fi
}

run_case() {
  local label="$1" function_name="$2"
  CASE_DIR="$TMP/$label"
  rm -rf "$CASE_DIR"
  mkdir -p "$CASE_DIR"
  set +e
  output="$($function_name 2>&1)"
  status=$?
  set -e
}

increment_file() {
  local path="$1" count=0
  [ ! -f "$path" ] || count="$(wc -l < "$path" | tr -d ' ')"
  printf '%s\n' "$((count + 1))" >> "$path"
  printf '%s\n' "$((count + 1))"
}

init_state() {
  STATE_DIR="$CASE_DIR/state"
  STATE_FILE="$STATE_DIR/test.state"
  mkdir -p "$STATE_DIR/keys"
  chmod 700 "$STATE_DIR" "$STATE_DIR/keys"
  : > "$CASE_DIR/mutations"
  NAME=test
  PROFILE=default
  REGION=us-east-1
  ACCOUNT_ID=123456789012
  INSTANCE_ID=""
  VOLUME_ID=""
  VPC_ID=vpc-test
  SUBNET_ID=subnet-test
  AZ=us-east-1a
  SG_ID=sg-managed
  SG_CREATE_PENDING=0
  SG_CREATE_PENDING_PRESENT=1
  KEY_NAME=aws-vm-test
  KEY_PATH="$STATE_DIR/keys/test"
  KEY_IMPORT_PENDING=0
  KEY_IMPORT_PENDING_PRESENT=1
  AMI_ID=ami-test
  AMI_INSTANCE_TYPE=t3.small
  AMI_GPU_CLASS=generic
  AMI_INSTANCE_TOKEN=token-test
  AMI_BINDINGS_PRESENT=1
  INSTANCE_TYPE=t3.small
  VCPUS=2
  MEMORY_GIB=4
  DISK_GIB=50
  PUBLIC_IP=""
  VOLUME_TOKEN=""
  INSTANCE_TOKEN=token-test
  INSTANCE_READY=0
  MODEL=gemma3:4b
  OLLAMA_MODE=0
  OLLAMA_CIDR=""
  OLLAMA_READY=0
  CLEAN_INSTANCE_ID=""
  reconciliation_sleep() { :; }
}

case_instance_eventual() (
  init_state
  save_state
  aws_text() {
    local attempt
    attempt="$(increment_file "$CASE_DIR/describes")"
    [ "$1:$2" = ec2:describe-instances ] || return 97
    if [ "$attempt" -lt 3 ]; then
      printf '%s\n' None
    else
      printf '%s\n' 'i-recovered t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
    fi
  }
  reconcile_instance_token
)

run_case instance-eventual case_instance_eventual
assert_success 'instance intent recovers on the third consistency read'
assert_count 'instance recovery performs exactly three token queries' 3 "$CASE_DIR/describes"
assert_file_contains 'instance recovery persists the resolved instance ID' "$CASE_DIR/state/test.state" 'INSTANCE_ID=i-recovered'
assert_empty 'instance recovery performs no mutating AWS call' "$CASE_DIR/mutations"

case_instance_clean_absent() (
  init_state
  save_state
  aws_text() {
    increment_file "$CASE_DIR/describes" >/dev/null
    [ "$1:$2" = ec2:describe-instances ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' None
  }
  clean_reconcile_instance_intent
)

run_case instance-clean-absent case_instance_clean_absent
assert_failure_contains 'clean fails closed after three absent instance-token reads' 'clean cannot prove whether launch was accepted'
assert_count 'failed clean performs exactly three instance-token reads' 3 "$CASE_DIR/describes"
assert_empty 'failed instance reconciliation performs zero mutations' "$CASE_DIR/mutations"
assert_file_contains 'failed clean retains the unresolved launch token' "$CASE_DIR/state/test.state" 'INSTANCE_TOKEN=token-test'

case_instance_ambiguous() (
  init_state
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-instances ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' \
      'i-one t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm' \
      'i-two t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
  }
  clean_reconcile_instance_intent
)

run_case instance-ambiguous case_instance_ambiguous
assert_failure_contains 'ambiguous instance-token recovery is refused' 'matched 2 instances'
assert_empty 'ambiguous instance recovery performs zero mutations' "$CASE_DIR/mutations"

case_volume_replay() (
  init_state
  VOLUME_TOKEN=volume-token
  save_state
  mock_direct_aws() { printf '%s\n' "$*" >> "$CASE_DIR/direct"; }
  AWS=(mock_direct_aws)
  aws_text() {
    case "$1:$2" in
      ec2:describe-volumes)
        increment_file "$CASE_DIR/describes" >/dev/null
        if [ -e "$CASE_DIR/volume-exists" ]; then
          printf '%s\n' 'vol-recovered us-east-1a 50 gp3 True False test-data aws-ec2-vm volume-token'
        else
          printf '%s\n' None
        fi
        ;;
      ec2:create-volume)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        touch "$CASE_DIR/volume-exists"
        printf '%s\n' vol-recovered
        ;;
      *) return 97 ;;
    esac
  }
  ensure_volume
  ensure_volume
)

run_case volume-replay case_volume_replay
assert_success 'volume recovery safely replays one create with the saved token'
assert_count 'volume replay issues exactly one create-volume request' 1 "$CASE_DIR/mutations"
assert_log_contains 'volume replay uses the exact persisted client token' "$CASE_DIR/mutations" '--client-token volume-token'
assert_log_contains 'volume replay tags immutable CreationToken identity' "$CASE_DIR/mutations" 'CreationToken,Value=volume-token'
assert_file_contains 'volume recovery persists the exact recovered ID' "$CASE_DIR/state/test.state" 'VOLUME_ID=vol-recovered'

case_volume_mismatch() (
  init_state
  VOLUME_TOKEN=volume-token
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-volumes ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' 'vol-wrong us-east-1a 50 gp3 True False test-data somebody-else volume-token'
  }
  clean_reconcile_volume_intent
)

run_case volume-mismatch case_volume_mismatch
assert_failure_contains 'clean refuses a token-matched volume with mismatched ownership' 'does not exactly match'
assert_empty 'mismatched volume ownership performs zero mutations' "$CASE_DIR/mutations"

case_exact_volume_empty() (
  init_state
  VOLUME_ID=vol-test
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-volumes ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' None
  }
  clean_preflight_volume
)

run_case exact-volume-empty case_exact_volume_empty
assert_failure_contains 'successful empty exact-volume lookup is malformed, not absence' 'empty result'
assert_empty 'empty exact-volume lookup authorizes zero mutations' "$CASE_DIR/mutations"
assert_file_contains 'empty exact-volume lookup retains the saved volume ID' "$CASE_DIR/state/test.state" 'VOLUME_ID=vol-test'

VOLUME_RESOLVE_ROW=""
case_resolve_saved_volume() (
  init_state
  VOLUME_ID=vol-test
  VOLUME_TOKEN=volume-token
  save_state
  direct_aws() { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; }
  AWS=(direct_aws)
  aws_text() {
    [ "$1:$2" = ec2:describe-volumes ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' "$VOLUME_RESOLVE_ROW"
  }
  resolve_existing_volume
)

for volume_case in \
  'wrong-name|us-east-1a available 50 gp3 True False None other-data aws-ec2-vm None' \
  'missing-name|us-east-1a available 50 gp3 True False None None aws-ec2-vm None' \
  'wrong-managed-by|us-east-1a available 50 gp3 True False None test-data somebody-else None' \
  'missing-managed-by|us-east-1a available 50 gp3 True False None test-data None None'; do
  label="${volume_case%%|*}"
  VOLUME_RESOLVE_ROW="${volume_case#*|}"
  run_case "saved-volume-$label" case_resolve_saved_volume
  assert_failure_contains "saved volume $label ownership is refused before create" 'not exactly owned'
  assert_empty "saved volume $label performs no attach, create, modify, or waiter" "$CASE_DIR/mutations"
  assert_file_contains "saved volume $label retains the recorded volume ID" "$CASE_DIR/state/test.state" 'VOLUME_ID=vol-test'
done

VOLUME_RESOLVE_ROW='us-east-1a available 50 gp3 True False None test-data aws-ec2-vm None'
run_case saved-volume-legacy-owned case_resolve_saved_volume
assert_success 'exact owned legacy saved volume remains valid without CreationToken'
assert_empty 'exact owned legacy volume resolution performs no mutation' "$CASE_DIR/mutations"

case_sg_eventual() (
  init_state
  SG_ID=""
  SG_CREATE_PENDING=1
  save_state
  aws_text() {
    local attempt
    [ "$1:$2" = ec2:describe-security-groups ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    attempt="$(increment_file "$CASE_DIR/describes")"
    if [ "$attempt" -lt 3 ]; then printf '%s\n' None; else printf '%s\n' 'sg-managed vpc-test aws-vm-test aws-vm-test aws-ec2-vm'; fi
  }
  reconcile_pending_security_group optional
)

run_case sg-eventual case_sg_eventual
assert_success 'pending security-group creation recovers on the third read'
assert_count 'security-group recovery performs exactly three name queries' 3 "$CASE_DIR/describes"
assert_file_contains 'security-group recovery persists the resolved ID' "$CASE_DIR/state/test.state" 'SG_ID=sg-managed'
assert_file_contains 'security-group recovery clears its pending marker' "$CASE_DIR/state/test.state" 'SG_CREATE_PENDING=0'
assert_empty 'security-group recovery does not create a duplicate group' "$CASE_DIR/mutations"

case_sg_clean_absent() (
  init_state
  SG_ID=""
  SG_CREATE_PENDING=1
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-security-groups ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    increment_file "$CASE_DIR/describes" >/dev/null
    printf '%s\n' None
  }
  reconcile_pending_security_group required
)

run_case sg-clean-absent case_sg_clean_absent
assert_failure_contains 'clean refuses an unresolved pending security-group create' 'remained absent after 3 reconciliation reads'
assert_count 'security-group clean refusal performs exactly three reads' 3 "$CASE_DIR/describes"
assert_file_contains 'security-group clean refusal retains the pending marker' "$CASE_DIR/state/test.state" 'SG_CREATE_PENDING=1'
assert_empty 'unresolved security-group clean performs zero mutations' "$CASE_DIR/mutations"

case_sg_mismatch() (
  init_state
  SG_ID=""
  SG_CREATE_PENDING=1
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-security-groups ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' 'sg-managed vpc-test aws-vm-test aws-vm-test somebody-else'
  }
  reconcile_pending_security_group required
)

run_case sg-mismatch case_sg_mismatch
assert_failure_contains 'pending security-group recovery requires exact ownership' 'exact VPC, name, and ownership identity'
assert_empty 'mismatched security-group recovery performs zero mutations' "$CASE_DIR/mutations"

case_exact_sg_empty() (
  init_state
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-security-groups ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' None
  }
  clean_preflight_security_group
)

run_case exact-sg-empty case_exact_sg_empty
assert_failure_contains 'successful empty exact-security-group lookup is malformed, not absence' 'empty result'
assert_empty 'empty exact-security-group lookup authorizes zero mutations' "$CASE_DIR/mutations"
assert_file_contains 'empty exact-security-group lookup retains the saved group ID' "$CASE_DIR/state/test.state" 'SG_ID=sg-managed'

case_key_eventual() (
  init_state
  cp "$TMP/fixture-key" "$KEY_PATH"
  cp "$TMP/fixture-key.pub" "$KEY_PATH.pub"
  chmod 600 "$KEY_PATH" "$KEY_PATH.pub"
  KEY_IMPORT_PENDING=1
  save_state
  aws_text() {
    local attempt
    [ "$1:$2" = ec2:describe-key-pairs ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    attempt="$(increment_file "$CASE_DIR/describes")"
    if [ "$attempt" -lt 3 ]; then
      printf '%s\n' 'An error occurred (InvalidKeyPair.NotFound) when calling the DescribeKeyPairs operation:' >&2
      return 255
    fi
    printf 'aws-vm-test\t%s\taws-vm-test\taws-ec2-vm\n' "$FIXTURE_PUBLIC"
  }
  reconcile_pending_key_import optional
)

run_case key-eventual case_key_eventual
assert_success 'pending key import recovers on the third read'
assert_count 'key import recovery performs exactly three identity reads' 3 "$CASE_DIR/describes"
assert_file_contains 'key import recovery clears its pending marker' "$CASE_DIR/state/test.state" 'KEY_IMPORT_PENDING=0'
assert_empty 'key import recovery does not import a duplicate key' "$CASE_DIR/mutations"

case_key_clean_absent() (
  init_state
  cp "$TMP/fixture-key" "$KEY_PATH"
  cp "$TMP/fixture-key.pub" "$KEY_PATH.pub"
  chmod 600 "$KEY_PATH" "$KEY_PATH.pub"
  KEY_IMPORT_PENDING=1
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-key-pairs ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    increment_file "$CASE_DIR/describes" >/dev/null
    printf '%s\n' 'An error occurred (InvalidKeyPair.NotFound) when calling the DescribeKeyPairs operation:' >&2
    return 255
  }
  reconcile_pending_key_import required
)

run_case key-clean-absent case_key_clean_absent
assert_failure_contains 'clean refuses an unresolved pending key import' 'remained absent after 3 reconciliation reads'
assert_count 'key clean refusal performs exactly three reads' 3 "$CASE_DIR/describes"
assert_file_contains 'key clean refusal retains the pending marker' "$CASE_DIR/state/test.state" 'KEY_IMPORT_PENDING=1'
assert_empty 'unresolved key clean performs zero mutations' "$CASE_DIR/mutations"

case_key_mismatch() (
  init_state
  cp "$TMP/fixture-key" "$KEY_PATH"
  cp "$TMP/fixture-key.pub" "$KEY_PATH.pub"
  chmod 600 "$KEY_PATH" "$KEY_PATH.pub"
  KEY_IMPORT_PENDING=1
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-key-pairs ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf 'aws-vm-test\t%s\taws-vm-test\tsomebody-else\n' "$FIXTURE_PUBLIC"
  }
  reconcile_pending_key_import required
)

run_case key-mismatch case_key_mismatch
assert_failure_contains 'pending key recovery requires exact ownership tags' 'exact aws-ec2-vm ownership tags'
assert_empty 'mismatched key ownership performs zero mutations' "$CASE_DIR/mutations"

case_nonpending_clean_missing_local_key() (
  init_state
  KEY_IMPORT_PENDING=0
  save_state
  aws_text() {
    if [ "$1:$2" = ec2:describe-key-pairs ]; then
      printf 'aws-vm-test\t%s\taws-vm-test\taws-ec2-vm\n' "$FIXTURE_PUBLIC"
    else
      printf '%s\n' "$*" >> "$CASE_DIR/mutations"
      return 97
    fi
  }
  clean_preflight_key
)

run_case nonpending-clean-missing-local-key case_nonpending_clean_missing_local_key
assert_failure_contains 'nonpending clean requires local key proof despite exact remote tags' 'local key files'
assert_empty 'missing local key proof authorizes zero AWS mutations' "$CASE_DIR/mutations"
assert_file_contains 'missing local key proof retains the recorded key name' "$CASE_DIR/state/test.state" 'KEY_NAME=aws-vm-test'
assert_file_contains 'missing local key proof retains the recorded key path' "$CASE_DIR/state/test.state" "KEY_PATH=$CASE_DIR/state/keys/test"

case_exact_key_empty() (
  init_state
  cp "$TMP/fixture-key" "$KEY_PATH"
  cp "$TMP/fixture-key.pub" "$KEY_PATH.pub"
  chmod 600 "$KEY_PATH" "$KEY_PATH.pub"
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-key-pairs ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' None
  }
  inspect_key_pair_once 0 0
)

run_case exact-key-empty case_exact_key_empty
assert_failure_contains 'successful empty exact-key lookup is malformed, not absence' 'empty result'
assert_empty 'empty exact-key lookup authorizes zero mutations' "$CASE_DIR/mutations"

case_require_key_absent_empty() (
  init_state
  save_state
  aws_text() {
    [ "$1:$2" = ec2:describe-key-pairs ] || { printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97; }
    printf '%s\n' None
  }
  require_key_name_absent
)

run_case require-key-absent-empty case_require_key_absent_empty
assert_failure_contains 'successful empty exact key-name absence check is malformed' 'empty result'
assert_empty 'malformed key-name absence check permits no import mutation' "$CASE_DIR/mutations"

case_sg_pending_absent_ensure() (
  init_state
  SG_ID=""
  SG_CREATE_PENDING=1
  save_state
  aws_text() {
    case "$1:$2" in
      ec2:describe-security-groups)
        increment_file "$CASE_DIR/describes" >/dev/null
        printf '%s\n' None
        ;;
      ec2:create-security-group)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        printf '%s\n' sg-new
        ;;
      *) printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97 ;;
    esac
  }
  ensure_security_group
)

run_case sg-pending-absent-ensure case_sg_pending_absent_ensure
assert_failure_contains 'create refuses to replay an unresolved pending security-group request' 'remained absent after 3 reconciliation reads'
assert_count 'pending security-group create stops after exactly three absent reads' 3 "$CASE_DIR/describes"
assert_empty 'pending security-group create performs zero duplicate-prone mutations' "$CASE_DIR/mutations"
assert_file_contains 'pending security-group create retains its write-ahead marker' "$CASE_DIR/state/test.state" 'SG_CREATE_PENDING=1'

case_key_pending_absent_ensure() (
  init_state
  cp "$TMP/fixture-key" "$KEY_PATH"
  cp "$TMP/fixture-key.pub" "$KEY_PATH.pub"
  chmod 600 "$KEY_PATH" "$KEY_PATH.pub"
  KEY_IMPORT_PENDING=1
  save_state
  aws_text() {
    case "$1:$2" in
      ec2:describe-key-pairs)
        increment_file "$CASE_DIR/describes" >/dev/null
        printf '%s\n' 'An error occurred (InvalidKeyPair.NotFound) when calling the DescribeKeyPairs operation:' >&2
        return 255
        ;;
      ec2:import-key-pair)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        printf '%s\n' key-new
        ;;
      *) printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97 ;;
    esac
  }
  ensure_key
)

run_case key-pending-absent-ensure case_key_pending_absent_ensure
assert_failure_contains 'create refuses to replay an unresolved pending key import' 'remained absent after 3 reconciliation reads'
assert_count 'pending key import stops after exactly three absent reads' 3 "$CASE_DIR/describes"
assert_empty 'pending key import performs zero duplicate-prone mutations' "$CASE_DIR/mutations"
assert_file_contains 'pending key import retains its write-ahead marker' "$CASE_DIR/state/test.state" 'KEY_IMPORT_PENDING=1'

case_partial_instance_id_mismatch() (
  init_state
  INSTANCE_ID=i-saved
  VOLUME_ID=vol-test
  save_state
  mock_direct_aws() {
    printf '%s\n' "$*" >> "$CASE_DIR/mutations"
    return 96
  }
  AWS=(mock_direct_aws)
  aws_text() {
    case "$1:$2:$*" in
      ec2:describe-instances:*' --instance-ids i-saved '*)
        printf '%s\n' 'An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation:' >&2
        return 255
        ;;
      ec2:describe-instances:*' --filters '*)
        printf '%s\n' 'i-different t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
        ;;
      ec2:describe-instances:*' --instance-ids i-different '*) printf '%s\n' pending ;;
      *) printf '%s\n' "$*" >> "$CASE_DIR/mutations"; return 97 ;;
    esac
  }
  create_instance
)

run_case partial-instance-id-mismatch case_partial_instance_id_mismatch
assert_failure_contains 'same-token recovery cannot replace a persisted partial instance ID' 'token token-test resolved to i-different'
assert_empty 'mismatched partial instance recovery stops before AWS waiters or mutations' "$CASE_DIR/mutations"
assert_file_contains 'mismatched partial recovery preserves the saved instance ID' "$CASE_DIR/state/test.state" 'INSTANCE_ID=i-saved'

LIVE_INSTANCE_ROW=""
LIVE_INSTANCE_STATE=""
LIVE_INSTANCE_READY=0
LIVE_OLLAMA_MODE=0
LIVE_OLLAMA_READY=0
LIVE_SAVED_INSTANCE_TOKEN=token-test
LIVE_SAVED_AMI_TOKEN=token-test
LIVE_SAVED_AMI_ID=ami-test
LIVE_SAVED_AMI_TYPE=t3.small
LIVE_SAVED_AMI_GPU=generic
LIVE_TOMBSTONE_ROW=""
case_create_live_instance_identity() (
  init_state
  INSTANCE_ID=i-live
  INSTANCE_TOKEN="$LIVE_SAVED_INSTANCE_TOKEN"
  AMI_INSTANCE_TOKEN="$LIVE_SAVED_AMI_TOKEN"
  AMI_ID="$LIVE_SAVED_AMI_ID"
  AMI_INSTANCE_TYPE="$LIVE_SAVED_AMI_TYPE"
  AMI_GPU_CLASS="$LIVE_SAVED_AMI_GPU"
  VOLUME_ID=vol-test
  SSH_CIDR=203.0.113.7/32
  INSTANCE_READY="$LIVE_INSTANCE_READY"
  OLLAMA_MODE="$LIVE_OLLAMA_MODE"
  OLLAMA_READY="$LIVE_OLLAMA_READY"
  save_state
  ensure_auth() { :; }
  apply_requested_availability_zone() { :; }
  sync_live_instance_type() { :; }
  save_state() { printf '%s\n' save-state >> "$CASE_DIR/mutations"; printf '%s\n' save-state >> "$CASE_DIR/events"; }
  pipeline_step() { printf '%s\n' "provision:$1" >> "$CASE_DIR/mutations"; printf '%s\n' "provision:$1" >> "$CASE_DIR/events"; }
  discover_ssh_cidr() { pipeline_step discover-ssh; }
  resolve_existing_volume() { pipeline_step resolve-volume; }
  resolve_subnet() { pipeline_step resolve-subnet; }
  verify_public_route() { pipeline_step verify-route; }
  resolve_instance_type() { pipeline_step resolve-type; }
  resolve_gpu_capability() { pipeline_step resolve-gpu; }
  verify_instance_offering() { pipeline_step verify-offering; }
  resolve_ami() { pipeline_step resolve-ami; }
  ensure_key() { pipeline_step ensure-key; }
  ensure_security_group() { pipeline_step ensure-sg; }
  ensure_volume() { pipeline_step ensure-volume; }
  create_instance() { pipeline_step "create-instance:id=${INSTANCE_ID}:token=${INSTANCE_TOKEN}"; }
  initialize_storage() { pipeline_step initialize-storage; }
  ensure_managed_ingress() { pipeline_step ensure-ingress; }
  ensure_ollama() { pipeline_step ensure-ollama; }
  print_commands() { :; }
  print_disk_instructions() { :; }
  direct_aws() { printf '%s\n' "direct:$*" >> "$CASE_DIR/mutations"; }
  AWS=(direct_aws)
  aws_text() {
    local args="$*"
    printf '%s\n' "$args" >> "$CASE_DIR/aws.log"
    printf '%s\n' "aws:$args" >> "$CASE_DIR/events"
    case "$1:$2" in
      sts:get-caller-identity) printf '%s\n' 123456789012 ;;
      ec2:describe-instances)
        if [[ "$args" == *InstanceType* || "$args" == *ClientToken* || "$args" == *'NetworkInterfaces[].Groups[].GroupId'* ]]; then
          printf '%s\n' "$LIVE_INSTANCE_ROW"
        elif [[ "$args" == *Tags* ]]; then
          printf '%s\n' "$LIVE_TOMBSTONE_ROW"
        elif [ "$LIVE_INSTANCE_STATE" = not-found ]; then
          printf '%s\n' 'An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation:' >&2
          return 255
        else
          printf '%s\n' "$LIVE_INSTANCE_STATE"
        fi
        ;;
      *) printf '%s\n' "aws:$args" >> "$CASE_DIR/mutations"; return 97 ;;
    esac
  }
  create_vm
)

for live_case in \
  'wrong-name|pending|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed other aws-ec2-vm' \
  'wrong-managed-by|running|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test running sg-managed test somebody-else' \
  'wrong-ami|stopped|i-live t3.small ami-other subnet-test us-east-1a aws-vm-test token-test stopped sg-managed test aws-ec2-vm' \
  'wrong-type|pending|i-live m7i.large ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm' \
  'wrong-subnet|running|i-live t3.small ami-test subnet-other us-east-1a aws-vm-test token-test running sg-managed test aws-ec2-vm' \
  'wrong-az|stopped|i-live t3.small ami-test subnet-test us-east-1b aws-vm-test token-test stopped sg-managed test aws-ec2-vm' \
  'wrong-key|pending|i-live t3.small ami-test subnet-test us-east-1a aws-vm-other token-test pending sg-managed test aws-ec2-vm' \
  'wrong-token|running|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-other running sg-managed test aws-ec2-vm' \
  'extra-sg|stopped|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test stopped sg-managed,sg-other test aws-ec2-vm' \
  'missing-managed-sg|pending|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-other test aws-ec2-vm' \
  'shutting-down-wrong-owner|shutting-down|i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test shutting-down sg-managed other aws-ec2-vm'; do
  label="${live_case%%|*}"
  remainder="${live_case#*|}"
  LIVE_INSTANCE_STATE="${remainder%%|*}"
  LIVE_INSTANCE_ROW="${remainder#*|}"
  LIVE_INSTANCE_READY=0
  LIVE_OLLAMA_MODE=0
  LIVE_OLLAMA_READY=0
  LIVE_SAVED_INSTANCE_TOKEN=token-test
  LIVE_SAVED_AMI_TOKEN=token-test
  LIVE_SAVED_AMI_ID=ami-test
  LIVE_SAVED_AMI_TYPE=t3.small
  LIVE_SAVED_AMI_GPU=generic
  run_case "live-instance-$label" case_create_live_instance_identity
  assert_failure "live saved instance $label identity mismatch is refused"
  assert_empty "live saved instance $label mismatch precedes state, provisioning, AWS mutation, and waiters" "$CASE_DIR/mutations"
  if [ "$label" = shutting-down-wrong-owner ]; then
    assert_failure_contains 'shutting-down ownership mismatch reports identity refusal before state rejection' 'does not exactly match saved launch identity and ownership'
    assert_log_count 'shutting-down ownership mismatch performs exactly one full identity query' 1 "$CASE_DIR/aws.log" InstanceType
  fi
done

LIVE_INSTANCE_STATE=pending
LIVE_INSTANCE_ROW='i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-live pending sg-managed test aws-ec2-vm'
LIVE_INSTANCE_READY=0
LIVE_OLLAMA_MODE=0
LIVE_OLLAMA_READY=0
LIVE_SAVED_INSTANCE_TOKEN=""
LIVE_SAVED_AMI_TOKEN=""
run_case live-instance-missing-saved-token case_create_live_instance_identity
assert_failure 'partial live instance without either saved token is refused'
assert_empty 'missing saved token fails before state, provisioning, AWS mutation, and waiters' "$CASE_DIR/mutations"

LIVE_INSTANCE_STATE=pending
LIVE_INSTANCE_ROW='i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
LIVE_SAVED_INSTANCE_TOKEN=""
LIVE_SAVED_AMI_TOKEN=token-test
run_case live-instance-missing-primary-token case_create_live_instance_identity
assert_failure 'partial live instance missing the primary saved token is refused'
assert_empty 'missing primary saved token fails before state, provisioning, AWS mutation, and waiters' "$CASE_DIR/mutations"

LIVE_SAVED_INSTANCE_TOKEN=token-test
LIVE_SAVED_AMI_TOKEN=token-other
run_case live-instance-conflicting-saved-tokens case_create_live_instance_identity
assert_failure 'partial live instance with conflicting saved token fields is refused'
assert_empty 'conflicting saved token fields fail before state, provisioning, AWS mutation, and waiters' "$CASE_DIR/mutations"

LIVE_SAVED_INSTANCE_TOKEN=token-test
LIVE_SAVED_AMI_TOKEN=""
run_case live-instance-primary-token-only case_create_live_instance_identity
assert_success 'legacy partial live instance with only the matching primary token may resume'
assert_log_contains 'primary-token-only legacy state reaches provisioning after validation' "$CASE_DIR/mutations" 'provision:discover-ssh'
assert_log_order 'primary-token-only resume initializes storage after instance attachment' "$CASE_DIR/events" 'provision:create-instance' 'provision:initialize-storage'

for transitional_state in stopping shutting-down; do
  LIVE_INSTANCE_STATE="$transitional_state"
  LIVE_INSTANCE_ROW="i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test $transitional_state sg-managed test aws-ec2-vm"
  LIVE_INSTANCE_READY=0
  LIVE_OLLAMA_MODE=0
  LIVE_OLLAMA_READY=0
  LIVE_SAVED_INSTANCE_TOKEN=token-test
  LIVE_SAVED_AMI_TOKEN=token-test
  LIVE_SAVED_AMI_ID=ami-test
  LIVE_SAVED_AMI_TYPE=t3.small
  LIVE_SAVED_AMI_GPU=generic
  run_case "live-instance-$transitional_state" case_create_live_instance_identity
  assert_failure "exact-owned $transitional_state partial instance is refused immediately"
  assert_empty "exact-owned $transitional_state state gate precedes save, provisioning, AWS mutation, and waiters" "$CASE_DIR/mutations"
  assert_log_count "exact-owned $transitional_state performs exactly one full identity query before state rejection" 1 "$CASE_DIR/aws.log" InstanceType
done

for tombstone_case in \
  'wrong-name|i-live terminated other aws-ec2-vm' \
  'wrong-managed-by|i-live terminated test somebody-else'; do
  label="${tombstone_case%%|*}"
  LIVE_INSTANCE_STATE=terminated
  LIVE_INSTANCE_ROW=""
  LIVE_TOMBSTONE_ROW="${tombstone_case#*|}"
  LIVE_INSTANCE_READY=0
  LIVE_OLLAMA_MODE=0
  LIVE_OLLAMA_READY=0
  LIVE_SAVED_INSTANCE_TOKEN=""
  LIVE_SAVED_AMI_TOKEN=""
  LIVE_SAVED_AMI_ID=""
  LIVE_SAVED_AMI_TYPE=""
  LIVE_SAVED_AMI_GPU=""
  run_case "terminated-tombstone-$label" case_create_live_instance_identity
  assert_failure_contains "terminated tombstone $label is refused by reduced ownership validation" 'does not have exact ownership'
  assert_log_count "terminated tombstone $label performs exactly one reduced ownership query" 1 "$CASE_DIR/aws.log" 'InstanceId,State.Name'
  assert_empty "terminated tombstone $label retains state before every mutation" "$CASE_DIR/mutations"
  assert_file_contains "terminated tombstone $label retains the saved instance ID" "$CASE_DIR/state/test.state" 'INSTANCE_ID=i-live'
done

LIVE_INSTANCE_STATE=terminated
LIVE_TOMBSTONE_ROW='i-live terminated test aws-ec2-vm'
run_case terminated-tombstone-exact case_create_live_instance_identity
assert_success 'exact-owned tokenless terminated tombstone checkpoints and proceeds to recreate'
assert_log_count 'exact terminated tombstone uses one reduced ownership query' 1 "$CASE_DIR/aws.log" 'InstanceId,State.Name'
assert_log_order 'terminated tombstone ownership validation precedes checkpoint clearing' "$CASE_DIR/events" 'InstanceId,State.Name' save-state
assert_log_contains 'terminated tombstone reaches recreate with old ID and token cleared' "$CASE_DIR/mutations" 'provision:create-instance:id=:token='

LIVE_INSTANCE_STATE=not-found
LIVE_TOMBSTONE_ROW=""
run_case not-found-tokenless-tombstone case_create_live_instance_identity
assert_success 'tokenless NotFound tombstone clears its saved ID and proceeds to recreate'
assert_log_contains 'tokenless NotFound reaches recreate with old ID and token cleared' "$CASE_DIR/mutations" 'provision:create-instance:id=:token='

LIVE_INSTANCE_STATE=pending
LIVE_INSTANCE_ROW='i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
LIVE_INSTANCE_READY=0
LIVE_OLLAMA_MODE=0
LIVE_OLLAMA_READY=0
LIVE_SAVED_INSTANCE_TOKEN=token-test
LIVE_SAVED_AMI_TOKEN=token-test
LIVE_SAVED_AMI_ID=ami-test
LIVE_SAVED_AMI_TYPE=t3.small
LIVE_SAVED_AMI_GPU=generic
run_case live-instance-exact case_create_live_instance_identity
assert_success 'exact matching live partial instance identity may resume create provisioning'
assert_log_contains 'live identity validation inspects immutable launch fields' "$CASE_DIR/aws.log" InstanceType
assert_log_contains 'live identity validation inspects full ENI security-group set' "$CASE_DIR/aws.log" 'NetworkInterfaces[].Groups[].GroupId'
assert_log_contains 'exact live identity reaches provisioning only after validation' "$CASE_DIR/mutations" 'provision:discover-ssh'

LIVE_INSTANCE_STATE=running
LIVE_INSTANCE_ROW='i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test running sg-managed other aws-ec2-vm'
LIVE_INSTANCE_READY=1
LIVE_OLLAMA_MODE=1
LIVE_OLLAMA_READY=0
run_case completed-ollama-live-mismatch case_create_live_instance_identity
assert_failure 'completed Ollama resume requires exact live instance identity'
assert_empty 'completed Ollama identity mismatch blocks remote provisioning and state mutation' "$CASE_DIR/mutations"

LIVE_INSTANCE_ROW='i-live t3.small ami-test subnet-test us-east-1a aws-vm-test token-test running sg-managed test aws-ec2-vm'
run_case completed-ollama-live-exact case_create_live_instance_identity
assert_success 'completed exact-owned live instance may resume Ollama provisioning'
assert_log_contains 'exact completed Ollama resume reaches remote provisioning after validation' "$CASE_DIR/mutations" 'provision:ensure-ollama'
assert_log_order 'completed Ollama resume initializes storage before remote provisioning' "$CASE_DIR/events" 'provision:initialize-storage' 'provision:ensure-ollama'

case_full_create_partial_instance_replay() (
  init_state
  INSTANCE_ID=i-saved
  VOLUME_ID=vol-test
  SSH_CIDR=203.0.113.7/32
  SG_SKIP_INSTANCE_SCOPE=0
  save_state
  ensure_auth() { :; }
  apply_requested_availability_zone() { :; }
  sync_live_instance_type() { :; }
  discover_ssh_cidr() { :; }
  resolve_existing_volume() { :; }
  resolve_subnet() { :; }
  verify_public_route() { :; }
  resolve_instance_type() { :; }
  resolve_gpu_capability() { :; }
  verify_instance_offering() { :; }
  resolve_ami() { :; }
  ensure_key() { :; }
  refresh_public_ip() { :; }
  initialize_storage() { printf '%s\n' initialize-storage >> "$CASE_DIR/events"; }
  print_commands() { :; }
  print_disk_instructions() { :; }
  save_state() { :; }
  reconciliation_sleep() { :; }
  direct_aws() { printf '%s\n' "$*" >> "$CASE_DIR/direct"; }
  AWS=(direct_aws)
  aws_text() {
    local args="$*"
    printf '%s\n' "$args" >> "$CASE_DIR/aws.log"
    case "$1:$2" in
      sts:get-caller-identity) printf '%s\n' 123456789012 ;;
      ec2:describe-instances)
        if [[ "$args" == *' --filters '* ]]; then
          increment_file "$CASE_DIR/token-describes" >/dev/null
          if [ -e "$CASE_DIR/launched" ]; then
            printf '%s\n' 'i-saved t3.small ami-test subnet-test us-east-1a aws-vm-test token-test pending sg-managed test aws-ec2-vm'
          else
            printf '%s\n' None
          fi
        elif [[ "$args" == *'NetworkInterfaces[].Groups[].GroupId'* ]]; then
          if [ ! -e "$CASE_DIR/launched" ]; then
            printf '%s\n' "$args" >> "$CASE_DIR/forbidden-instance-scope"
            printf '%s\n' 'An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation:' >&2
            return 255
          fi
          printf '%s\n' 'pending sg-managed'
        elif [[ "$args" == *BlockDeviceMappings* ]]; then
          printf '%s\n' False
        elif [ ! -e "$CASE_DIR/launched" ]; then
          printf '%s\n' 'An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation:' >&2
          return 255
        else
          printf '%s\n' pending
        fi
        ;;
      ec2:describe-security-groups) printf '%s\n' 'sg-managed vpc-test aws-vm-test aws-vm-test aws-ec2-vm' ;;
      ec2:describe-security-group-rules)
        printf 'sgr-ssh\tsg-managed\tFalse\ttcp\t22\t22\t203.0.113.7/32\tNone\tNone\tNone\taws-ec2-vm:v2:test:ssh:22\taws-ec2-vm\ttest\tssh\t22\n'
        ;;
      ec2:run-instances)
        printf '%s\n' "$args" >> "$CASE_DIR/mutations"
        printf '%s\n' create-instance >> "$CASE_DIR/events"
        touch "$CASE_DIR/launched"
        printf '%s\n' i-saved
        ;;
      ec2:describe-volumes) printf '%s\n' i-saved ;;
      ec2:modify-instance-attribute) printf '%s\n' "$args" >> "$CASE_DIR/mutations" ;;
      *) printf '%s\n' "$args" >> "$CASE_DIR/mutations"; return 97 ;;
    esac
  }
  create_vm
  printf '%s\n' "$INSTANCE_ID" > "$CASE_DIR/resolved-instance"
)

run_case full-create-partial-replay case_full_create_partial_instance_replay
assert_success 'full create replays a saved unresolved partial instance safely'
assert_count 'full create bounds both pre-replay token reconciliations and verifies the replay' 7 "$CASE_DIR/token-describes"
assert_empty 'pre-replay SG setup never re-describes the missing saved instance' "$CASE_DIR/forbidden-instance-scope"
assert_log_contains 'pre-replay SG inventory is scoped only to the saved managed group' "$CASE_DIR/aws.log" 'Name=group-id,Values=sg-managed'
assert_log_count 'full create issues exactly one same-token run request' 1 "$CASE_DIR/mutations" 'ec2 run-instances'
assert_log_contains 'full create replays the exact persisted instance token' "$CASE_DIR/mutations" '--client-token token-test'
assert_file_contains 'full create preserves the expected saved instance identity' "$CASE_DIR/resolved-instance" 'i-saved'
assert_log_order 'full replay initializes storage after the instance and volume are attached' "$CASE_DIR/events" create-instance initialize-storage

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
