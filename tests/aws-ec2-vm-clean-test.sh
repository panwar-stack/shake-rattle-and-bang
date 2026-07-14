#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-clean-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/bin" "$TMP/home"
ssh-keygen -q -t ed25519 -N '' -C aws-vm-clean -f "$TMP/fixture-key"
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
shift 2 || true
args="$*"

exists() { [ -e "$MOCK_AWS_STATE/$1" ]; }
mutation() { printf '%s %s %s\n' "$service" "$operation" "$args" >> "$MOCK_AWS_MUTATIONS"; }
require_arg() {
  case " $args " in *" $1 $2 "*) ;; *) printf 'Unexpected %s ID: %s\n' "$operation" "$args" >&2; exit 98 ;; esac
}

case "$service:$operation" in
  sts:get-caller-identity)
    printf '%s\n' '123456789012'
    ;;
  ec2:describe-instances)
    if [[ " $args " == *' --filters '* ]]; then
      if exists instance; then printf '%s\n' 'i-clean t3.small ami-test'; else printf '%s\n' 'None'; fi
    elif ! exists instance; then
      printf '%s\n' 'An error occurred (InvalidInstanceID.NotFound) when calling the DescribeInstances operation:' >&2
      exit 255
    elif [[ "$args" == *Tags* ]]; then
      if exists bad-instance-owner; then printf '%s\n' 'other aws-ec2-vm'; else printf '%s\n' 'clean aws-ec2-vm'; fi
    elif [[ "$args" == *InstanceType* ]]; then
      printf '%s\n' 't3.small'
    elif exists terminated-instance; then
      printf '%s\n' 'terminated'
    else
      printf '%s\n' 'running'
    fi
    ;;
  ec2:describe-volumes)
    if exists wrong-volume-notfound; then
      printf '%s\n' 'An error occurred (InvalidGroup.NotFound) when calling the DescribeVolumes operation:' >&2
      exit 255
    elif ! exists volume; then
      printf '%s\n' 'An error occurred (InvalidVolume.NotFound) when calling the DescribeVolumes operation:' >&2
      exit 255
    elif [[ "$args" == *Tags* ]]; then
      if exists bad-volume-owner; then printf '%s\n' 'other-data aws-ec2-vm'; else printf '%s\n' 'clean-data aws-ec2-vm'; fi
    elif [[ "$args" == *Attachments* ]]; then
      if exists instance; then printf '%s\n' 'i-clean'; else printf '%s\n' 'None'; fi
    else
      printf '%s\n' 'available None'
    fi
    ;;
  ec2:describe-security-groups)
    if ! exists security-group; then
      printf '%s\n' 'An error occurred (InvalidGroup.NotFound) when calling the DescribeSecurityGroups operation:' >&2
      exit 255
    elif exists bad-security-group-owner; then
      printf '%s\n' 'aws-vm-other vpc-test aws-vm-other aws-ec2-vm'
    else
      printf '%s\n' 'aws-vm-clean vpc-test aws-vm-clean aws-ec2-vm'
    fi
    ;;
  ec2:describe-key-pairs)
    if ! exists key-pair; then
      printf '%s\n' 'An error occurred (InvalidKeyPair.NotFound) when calling the DescribeKeyPairs operation:' >&2
      exit 255
    fi
    if [[ "$args" == *'KeyPairs[].KeyName'* ]]; then
      printf '%s\n' 'aws-vm-clean'
    else
      printf 'aws-vm-clean\t%s\taws-vm-clean\taws-ec2-vm\n' "$(< "$MOCK_AWS_STATE/public-key")"
    fi
    ;;
  ec2:terminate-instances)
    mutation
    require_arg --instance-ids i-clean
    rm -f "$MOCK_AWS_STATE/instance"
    printf '%s\n' 'shutting-down'
    ;;
  ec2:wait)
    mutation
    ;;
  ec2:delete-volume)
    mutation
    require_arg --volume-id vol-deadbeef
    [ ! -e "$MOCK_AWS_STATE/fail-delete-volume" ] || { printf '%s\n' 'injected delete-volume failure' >&2; exit 70; }
    rm -f "$MOCK_AWS_STATE/volume"
    ;;
  ec2:delete-security-group)
    mutation
    require_arg --group-id sg-deadbeef
    [ ! -e "$MOCK_AWS_STATE/fail-delete-security-group" ] || { printf '%s\n' 'injected delete-security-group failure' >&2; exit 71; }
    rm -f "$MOCK_AWS_STATE/security-group"
    ;;
  ec2:delete-key-pair)
    mutation
    require_arg --key-name aws-vm-clean
    [ ! -e "$MOCK_AWS_STATE/fail-delete-key-pair" ] || { printf '%s\n' 'injected delete-key-pair failure' >&2; exit 72; }
    rm -f "$MOCK_AWS_STATE/key-pair"
    if exists inject-key-directory-on-delete; then
      rm -f "$MOCK_AWS_STATE/../state/keys/clean"
      mkdir "$MOCK_AWS_STATE/../state/keys/clean"
    fi
    ;;
  *)
    printf 'Unexpected mock AWS call: %s %s %s\n' "$service" "$operation" "$args" >&2
    exit 97
    ;;
esac
MOCK_AWS
chmod +x "$TMP/bin/aws"

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

assert_output_contains() {
  local description="$1" expected="$2"
  tests=$((tests + 1))
  if [[ "$output" == *"$expected"* ]]; then pass "$description"; else fail "$description" "expected output containing: $expected\n$output"; fi
}

assert_file_exists() {
  local description="$1" path="$2"
  tests=$((tests + 1))
  if [ -e "$path" ]; then pass "$description"; else fail "$description" "expected file to exist: $path"; fi
}

assert_file_missing() {
  local description="$1" path="$2"
  tests=$((tests + 1))
  if [ ! -e "$path" ]; then pass "$description"; else fail "$description" "expected file to be removed: $path"; fi
}

assert_file_contains() {
  local description="$1" path="$2" expected="$3"
  tests=$((tests + 1))
  if grep -Fqx -- "$expected" "$path"; then pass "$description"; else fail "$description" "expected $path to contain exact line: $expected"; fi
}

assert_mutations_empty() {
  local description="$1"
  tests=$((tests + 1))
  if [ ! -s "$TMP/aws.mutations" ]; then pass "$description"; else fail "$description" "unexpected mutations:\n$(< "$TMP/aws.mutations")"; fi
}

assert_mutation_count() {
  local description="$1" expected="$2" pattern="$3" actual
  tests=$((tests + 1))
  actual="$(grep -Fc -- "$pattern" "$TMP/aws.mutations" 2>/dev/null || true)"
  if [ "$actual" -eq "$expected" ]; then pass "$description"; else fail "$description" "expected $expected occurrences of '$pattern', got $actual\n$(< "$TMP/aws.mutations")"; fi
}

assert_log_lacks() {
  local description="$1" pattern="$2"
  tests=$((tests + 1))
  if ! grep -Fq -- "$pattern" "$TMP/aws.log"; then pass "$description"; else fail "$description" "unexpected AWS log entry containing: $pattern\n$(< "$TMP/aws.log")"; fi
}

assert_mutations_in_order() {
  local description="$1" pattern line matched=0
  shift
  tests=$((tests + 1))
  while IFS= read -r line; do
    [ "$#" -gt 0 ] || break
    pattern="$1"
    if [[ "$line" == *"$pattern"* ]]; then matched=$((matched + 1)); shift; fi
  done < "$TMP/aws.mutations"
  if [ "$#" -eq 0 ]; then
    pass "$description"
  else
    fail "$description" "missing or out-of-order mutation: $1\n$(< "$TMP/aws.mutations")"
  fi
}

write_state() {
  local state_dir="$1" key_path="$2"
  cat > "$state_dir/clean.state" <<EOF
PROFILE=default
REGION=us-east-1
ACCOUNT_ID=123456789012
INSTANCE_ID=i-clean
VOLUME_ID=vol-deadbeef
VPC_ID=vpc-test
SUBNET_ID=subnet-test
AZ=us-east-1a
SG_ID=sg-deadbeef
KEY_NAME=aws-vm-clean
KEY_PATH=$key_path
AMI_ID=ami-test
AMI_INSTANCE_TYPE=t3.small
AMI_GPU_CLASS=generic
AMI_INSTANCE_TOKEN=token-test
INSTANCE_TYPE=t3.small
VCPUS=2
MEMORY_GIB=4
DISK_GIB=50
PUBLIC_IP=203.0.113.10
VOLUME_TOKEN=volume-token
INSTANCE_TOKEN=token-test
INSTANCE_READY=1
MODEL=gemma3:4b
OLLAMA_MODE=0
OLLAMA_CIDR=
OLLAMA_READY=0
EOF
  chmod 600 "$state_dir/clean.state"
}

new_fixture() {
  local label="$1" state_dir aws_state
  state_dir="$TMP/$label/state"
  aws_state="$TMP/$label/aws"
  rm -rf "${TMP:?}/$label"
  mkdir -p "$state_dir/keys" "$state_dir/known_hosts" "$state_dir/sshfs" "$aws_state"
  chmod 700 "$state_dir" "$state_dir/keys" "$state_dir/known_hosts" "$state_dir/sshfs"
  write_state "$state_dir" "$state_dir/keys/clean"
  cp "$TMP/fixture-key" "$state_dir/keys/clean"
  cp "$TMP/fixture-key.pub" "$state_dir/keys/clean.pub"
  ssh-keygen -y -f "$state_dir/keys/clean" > "$aws_state/public-key"
  printf '%s\n' host > "$state_dir/known_hosts/i-clean"
  printf '%s\n' config > "$state_dir/sshfs/clean-i-clean.conf"
  printf '%s\n' log > "$state_dir/sshfs/clean-i-clean.log"
  chmod 600 "$state_dir/keys/clean" "$state_dir/known_hosts/i-clean" "$state_dir/sshfs/clean-i-clean.conf" "$state_dir/sshfs/clean-i-clean.log"
  printf '%s\n' unrelated > "$state_dir/keys/other"
  printf '%s\n' unrelated > "$state_dir/known_hosts/i-other"
  printf '%s\n' unrelated > "$state_dir/sshfs/other-i-other.conf"
  printf '%s\n' unrelated > "$state_dir/other.state"
  touch "$aws_state/instance" "$aws_state/volume" "$aws_state/security-group" "$aws_state/key-pair"
  printf '%s\n' "$state_dir"
}

run_vm() {
  local state_dir="$1" aws_state
  shift
  aws_state="$(dirname "$state_dir")/aws"
  : > "$TMP/aws.log"
  : > "$TMP/aws.mutations"
  set +e
  if [ "${RUN_INPUT_SET:-0}" -eq 1 ]; then
    output="$(printf '%s\n' "${RUN_INPUT:-}" | PATH="$TMP/bin:$PATH" HOME="$TMP/home" AWS_VM_STATE_DIR="$state_dir" \
      MOCK_AWS_STATE="$aws_state" MOCK_AWS_LOG="$TMP/aws.log" MOCK_AWS_MUTATIONS="$TMP/aws.mutations" "$SCRIPT" "$@" 2>&1)"
  else
    output="$(PATH="$TMP/bin:$PATH" HOME="$TMP/home" AWS_VM_STATE_DIR="$state_dir" \
      MOCK_AWS_STATE="$aws_state" MOCK_AWS_LOG="$TMP/aws.log" MOCK_AWS_MUTATIONS="$TMP/aws.mutations" "$SCRIPT" "$@" 2>&1)"
  fi
  status=$?
  set -e
}

# Parser and help surface the new destructive command without broadening its options.
state_dir="$(new_fixture help)"
run_vm "$state_dir" --help
assert_success 'help succeeds'
assert_output_contains 'help documents clean with an optional name' 'clean [NAME]'
run_vm "$state_dir" clean clean --force
assert_failure_contains 'clean rejects the unmount-only force option' '--force is supported only by unmount'
assert_mutations_empty 'parser rejection happens before AWS mutation'

# Clean accepts only a private, single-link state file as destructive authority.
state_dir="$(new_fixture state-mode)"
chmod 644 "$state_dir/clean.state"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'clean refuses non-private state permissions' 'mode 0600'
assert_mutations_empty 'insecure state permissions are rejected before AWS mutation'
state_dir="$(new_fixture state-links)"
ln "$state_dir/clean.state" "$TMP/linked-clean.state"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'clean refuses a hard-linked state file' 'one hard link'
assert_mutations_empty 'hard-linked state is rejected before AWS mutation'
rm -f "$TMP/linked-clean.state"

# Cancellation and non-interactive use are safe and require one explicit confirmation.
state_dir="$(new_fixture cancel)"
RUN_INPUT_SET=1 RUN_INPUT=wrong run_vm "$state_dir" clean clean
assert_failure_contains 'wrong clean confirmation cancels' 'cancelled'
assert_output_contains 'confirmation names the VM exactly' 'Type clean to continue'
assert_mutations_empty 'cancelled clean performs no AWS mutation'
RUN_INPUT_SET=0 run_vm "$state_dir" clean clean --non-interactive
assert_failure_contains 'non-interactive clean requires --yes' 'confirmation required'
assert_mutations_empty 'missing non-interactive confirmation performs no AWS mutation'

# Every recorded resource is ownership-checked before the first mutation.
state_dir="$(new_fixture ownership)"
touch "$(dirname "$state_dir")/aws/bad-volume-owner"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'an ownership mismatch refuses cleanup' 'volume'
assert_mutations_empty 'ownership refusal occurs before all AWS mutation'
assert_file_exists 'ownership refusal preserves state' "$state_dir/clean.state"

# The local key must be the exact managed path, not an arbitrary state-supplied file.
state_dir="$(new_fixture key-path)"
printf '%s\n' do-not-delete > "$TMP/external-key"
write_state "$state_dir" "$TMP/external-key"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'an external key path is refused' 'key'
assert_mutations_empty 'unsafe key path is rejected before AWS mutation'
assert_file_exists 'external key is never removed' "$TMP/external-key"

# A durable managed mount config requires an explicit unmount before clean.
state_dir="$(new_fixture mounted)"
mkdir -p "$state_dir/mounts" "$TMP/mnt"
chmod 700 "$state_dir/mounts"
cat > "$state_dir/mounts/clean.conf" <<EOF
NAME=clean
INSTANCE_ID=i-clean
VOLUME_ID=vol-deadbeef
UUID=uuid-test
SOURCE=aws-ec2-vm-clean-i-clean:/data
MOUNT_DIR=$TMP/mnt
SSH_CONFIG=$state_dir/sshfs/clean-i-clean.conf
EOF
chmod 600 "$state_dir/mounts/clean.conf"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'managed mount metadata refuses clean' 'unmount'
assert_mutations_empty 'mount refusal occurs before AWS mutation'
assert_file_exists 'mount refusal preserves its secure config' "$state_dir/mounts/clean.conf"

# A durable claim also blocks clean even if its state-local config is absent.
state_dir="$(new_fixture claimed)"
mkdir -p "$TMP/home/.aws-ec2-vm-mount-claims"
chmod 700 "$TMP/home/.aws-ec2-vm-mount-claims"
cat > "$TMP/home/.aws-ec2-vm-mount-claims/test.claim" <<EOF
NAME=clean
MOUNT_DIR=$TMP/claimed-mount
MOUNT_CONFIG=$state_dir/mounts/clean.conf
EOF
chmod 600 "$TMP/home/.aws-ec2-vm-mount-claims/test.claim"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'durable mount claim refuses clean' 'unmount'
assert_mutations_empty 'claim refusal occurs before AWS mutation'
assert_file_exists 'clean never deletes a durable mount claim' "$TMP/home/.aws-ec2-vm-mount-claims/test.claim"
rm -rf "$TMP/home/.aws-ec2-vm-mount-claims"

# Non-Darwin clean does not require the macOS mount binary.
cat > "$TMP/bin/uname" <<'MOCK_UNAME'
#!/usr/bin/env bash
printf '%s\n' Linux
MOCK_UNAME
cat > "$TMP/bin/mount" <<MOCK_MOUNT
#!/usr/bin/env bash
touch "$TMP/mount.called"
exit 99
MOCK_MOUNT
chmod +x "$TMP/bin/uname" "$TMP/bin/mount"
state_dir="$(new_fixture linux-mount-scan)"
RUN_INPUT_SET=1 RUN_INPUT=wrong run_vm "$state_dir" clean clean
assert_failure_contains 'Linux clean reaches confirmation without macFUSE inspection' 'cancelled'
assert_file_missing 'Linux clean does not invoke the macOS mount scan' "$TMP/mount.called"
rm -f "$TMP/bin/uname"
state_dir="$(new_fixture trusted-mount-bin)"
RUN_INPUT_SET=1 RUN_INPUT=wrong run_vm "$state_dir" clean clean
assert_failure_contains 'Darwin clean reaches confirmation using trusted mount output' 'cancelled'
assert_file_missing 'Darwin clean ignores a PATH-shadowing mount binary' "$TMP/mount.called"
rm -f "$TMP/bin/mount"

# A terminated but still discoverable instance must still pass tag ownership.
state_dir="$(new_fixture terminated-owner)"
touch "$(dirname "$state_dir")/aws/terminated-instance" "$(dirname "$state_dir")/aws/bad-instance-owner"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'terminated instance still requires ownership tags' 'instance'
assert_mutations_empty 'terminated ownership refusal precedes all AWS mutation'

# A NotFound code for another resource type is an error, not idempotent success.
state_dir="$(new_fixture wrong-notfound)"
touch "$(dirname "$state_dir")/aws/wrong-volume-notfound"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'volume inspection rejects a security-group NotFound code' 'volume'
assert_mutations_empty 'wrong resource NotFound code cannot authorize mutation'

# A full cleanup is ordered and removes only the named VM's exact artifacts.
state_dir="$(new_fixture full)"
mkdir -p "$TMP/home/mnt/aws-ec2-vm/clean"
printf '%s\n' user-data > "$TMP/home/mnt/aws-ec2-vm/clean/keep"
run_vm "$state_dir" clean clean --yes
assert_success 'full clean succeeds with --yes'
assert_mutations_in_order 'AWS resources are removed in safe dependency order' \
  'terminate-instances' 'wait instance-terminated' 'wait volume-available' 'delete-volume' 'delete-security-group' 'delete-key-pair'
assert_file_missing 'clean removes the managed private key' "$state_dir/keys/clean"
assert_file_missing 'clean removes the managed public key' "$state_dir/keys/clean.pub"
assert_file_missing 'clean removes the exact instance host-key cache' "$state_dir/known_hosts/i-clean"
assert_file_missing 'clean removes the exact SSHFS config' "$state_dir/sshfs/clean-i-clean.conf"
assert_file_missing 'clean removes the exact SSHFS log' "$state_dir/sshfs/clean-i-clean.log"
assert_file_missing 'clean removes state last after successful cleanup' "$state_dir/clean.state"
assert_file_exists 'clean preserves another VM private key' "$state_dir/keys/other"
assert_file_exists 'clean preserves another instance host-key cache' "$state_dir/known_hosts/i-other"
assert_file_exists 'clean preserves another VM SSHFS config' "$state_dir/sshfs/other-i-other.conf"
assert_file_exists 'clean preserves another VM state file' "$state_dir/other.state"
assert_file_exists 'clean preserves user data in the default mount directory' "$TMP/home/mnt/aws-ec2-vm/clean/keep"
assert_log_lacks 'clean never targets an unrelated instance' 'i-unrelated'
assert_log_lacks 'clean never targets an unrelated volume' 'vol-unrelated'
assert_log_lacks 'clean never targets an unrelated security group' 'sg-unrelated'
assert_log_lacks 'clean never targets an unrelated key pair' 'aws-vm-unrelated'

# Resources that disappeared before the retry are treated as already clean.
state_dir="$(new_fixture missing)"
rm -f "$(dirname "$state_dir")/aws/instance" "$(dirname "$state_dir")/aws/volume" \
  "$(dirname "$state_dir")/aws/security-group" "$(dirname "$state_dir")/aws/key-pair"
run_vm "$state_dir" clean clean --yes
assert_success 'clean is idempotent when all recorded AWS resources are already missing'
assert_mutations_empty 'already-missing resources do not trigger destructive calls'
assert_file_missing 'idempotent clean still removes completed local state' "$state_dir/clean.state"

# Successful stages are checkpointed so a retry resumes at the failed stage.
state_dir="$(new_fixture retry)"
touch "$(dirname "$state_dir")/aws/fail-delete-security-group"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'a later AWS deletion failure retains retry state' 'security group'
assert_mutation_count 'first attempt terminates the instance once' 1 'terminate-instances'
assert_mutation_count 'first attempt deletes the volume once' 1 'delete-volume'
assert_file_exists 'failed cleanup retains state for retry' "$state_dir/clean.state"
assert_file_exists 'failed cleanup retains local keys' "$state_dir/keys/clean"
rm -f "$(dirname "$state_dir")/aws/fail-delete-security-group"
cp "$TMP/aws.mutations" "$TMP/first.mutations"
run_vm "$state_dir" clean clean --yes
assert_success 'retry resumes and completes cleanup'
tests=$((tests + 1))
if ! grep -Fq 'terminate-instances' "$TMP/aws.mutations" && ! grep -Fq 'delete-volume' "$TMP/aws.mutations"; then
  pass 'retry skips checkpointed instance and volume stages'
else
  fail 'retry skips checkpointed instance and volume stages' "unexpected retry mutations:\n$(< "$TMP/aws.mutations")"
fi
assert_mutation_count 'retry deletes the remaining security group once' 1 'delete-security-group'
assert_mutation_count 'retry deletes the remaining key pair once' 1 'delete-key-pair'
assert_file_missing 'successful retry finally removes state' "$state_dir/clean.state"

# The key deletion is checkpointed before fallible local artifact cleanup.
state_dir="$(new_fixture key-checkpoint)"
touch "$(dirname "$state_dir")/aws/inject-key-directory-on-delete"
run_vm "$state_dir" clean clean --yes
assert_failure_contains 'unexpected local key directory fails after AWS cleanup' 'directory'
assert_file_contains 'key name is checkpointed empty after AWS deletion' "$state_dir/clean.state" 'KEY_NAME='
assert_file_contains 'key path is checkpointed empty after AWS deletion' "$state_dir/clean.state" 'KEY_PATH='
assert_file_exists 'local cleanup failure retains retry state' "$state_dir/clean.state"
rmdir "$state_dir/keys/clean"
run_vm "$state_dir" clean clean --yes
assert_success 'retry completes local cleanup after key checkpoint'
assert_file_missing 'key-checkpoint retry removes state last' "$state_dir/clean.state"

# Empty shared artifact directories are retained for other VM operations.
state_dir="$(new_fixture shared-dirs)"
rm -f "$state_dir/keys/other" "$state_dir/known_hosts/i-other" "$state_dir/sshfs/other-i-other.conf"
rm -f "$(dirname "$state_dir")/aws/instance" "$(dirname "$state_dir")/aws/volume" \
  "$(dirname "$state_dir")/aws/security-group" "$(dirname "$state_dir")/aws/key-pair"
run_vm "$state_dir" clean clean --yes
assert_success 'clean succeeds with otherwise empty shared artifact directories'
assert_file_exists 'clean preserves the shared keys directory' "$state_dir/keys"
assert_file_exists 'clean preserves the shared known-hosts directory' "$state_dir/known_hosts"
assert_file_exists 'clean preserves the shared SSHFS directory' "$state_dir/sshfs"

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
