#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-auto-init-storage-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

REMOTE="$TMP/remote-storage.sh"
REMOTE_FUNCTIONS="$TMP/remote-storage-functions.sh"
CREATE="$TMP/create-vm.sh"
ENSURE_OLLAMA="$TMP/ensure-ollama.sh"
INITIALIZE_STORAGE="$TMP/initialize-storage.sh"

awk '
  /<<'"'"'REMOTE_STORAGE'"'"'/ { in_block=1; next }
  in_block && /^REMOTE_STORAGE$/ { found_end=1; exit }
  in_block { print }
  END { if (!in_block || !found_end) exit 1 }
' "$SCRIPT" > "$REMOTE"
sed -e '/^resolve_disk$/,$d' -e '/^    set [+-]e$/d' "$REMOTE" > "$REMOTE_FUNCTIONS"
awk '
  /^create_vm\(\) \{/ { in_function=1 }
  in_function { print }
  in_function && /^}$/ { found_end=1; exit }
  END { if (!in_function || !found_end) exit 1 }
' "$SCRIPT" > "$CREATE"
awk '
  /^ensure_ollama\(\) \{/ { in_function=1 }
  in_function { print }
  in_function && /^}$/ { found_end=1; exit }
  END { if (!in_function || !found_end) exit 1 }
' "$SCRIPT" > "$ENSURE_OLLAMA"
awk '
  /^initialize_storage\(\) \{/ { in_function=1 }
  in_function { print }
  in_function && /^}$/ { exit }
' "$SCRIPT" > "$INITIALIZE_STORAGE"

# Source only the remote definitions. Tests replace device-inspection commands;
# no AWS calls, SSH connections, mounts, or block devices are used.
# shellcheck source=/dev/null
source "$REMOTE_FUNCTIONS" auto test-vm i-12345678 vol-12345678 init-command ''

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

assert_contains() {
  local description="$1" path="$2" pattern="$3"
  tests=$((tests + 1))
  if grep -Eq -- "$pattern" "$path"; then
    pass "$description"
  else
    fail "$description" "expected $path to match: $pattern"
  fi
}

assert_order() {
  local description="$1" path="$2" first_pattern="$3" second_pattern="$4" first_line second_line
  tests=$((tests + 1))
  first_line="$(awk -v pattern="$first_pattern" '$0 ~ pattern { print NR; exit }' "$path")"
  second_line="$(awk -v pattern="$second_pattern" '$0 ~ pattern { print NR; exit }' "$path")"
  if [ -n "$first_line" ] && [ -n "$second_line" ] && [ "$first_line" -lt "$second_line" ]; then
    pass "$description"
  else
    fail "$description" "expected '$first_pattern' before '$second_pattern' (lines ${first_line:-missing}, ${second_line:-missing})"
  fi
}

assert_order_after() {
  local description="$1" path="$2" first_pattern="$3" second_pattern="$4" lines
  tests=$((tests + 1))
  lines="$(awk -v first="$first_pattern" -v second="$second_pattern" '
    !first_line && $0 ~ first { first_line=NR; next }
    first_line && $0 ~ second { print first_line " " NR; exit }
  ' "$path")"
  if [ -n "$lines" ]; then
    pass "$description"
  else
    fail "$description" "expected '$second_pattern' after '$first_pattern'"
  fi
}

assert_sequence() {
  local description="$1" path="$2" first_pattern="$3" second_pattern="$4" third_pattern="$5"
  tests=$((tests + 1))
  if awk -v first="$first_pattern" -v second="$second_pattern" -v third="$third_pattern" '
    stage == 0 && $0 ~ first { stage=1; next }
    stage == 1 && $0 ~ second { stage=2; next }
    stage == 2 && $0 ~ third { found=1; exit }
    END { exit !found }
  ' "$path"; then
    pass "$description"
  else
    fail "$description" "expected ordered sequence '$first_pattern', '$second_pattern', '$third_pattern'"
  fi
}

TEST_SIGNATURE=""
TEST_TYPE=""
# Consumed by the sourced remote functions.
# shellcheck disable=SC2034
disk=/dev/nvme-test

lsblk() {
  case "$*" in
    '-nrpo NAME,TYPE -- /dev/nvme-test') printf '%s\n' '/dev/nvme-test disk' ;;
    *) printf 'unexpected lsblk call: %s\n' "$*" >&2; return 97 ;;
  esac
}

readlink() {
  local arg last=""
  for arg in "$@"; do last="$arg"; done
  printf '%s\n' "$last"
}

blkid() {
  case "$*" in
    *'-s TYPE -o value -- /dev/nvme-test')
      [ -n "$TEST_TYPE" ] || return 2
      printf '%s\n' "$TEST_TYPE"
      ;;
    *'-s UUID -o value -- /dev/nvme-test') printf '%s\n' '11111111-2222-3333-4444-555555555555' ;;
    *'-t UUID=11111111-2222-3333-4444-555555555555 -o device') printf '%s\n' '/dev/nvme-test' ;;
    *) printf 'unexpected blkid call: %s\n' "$*" >&2; return 98 ;;
  esac
}

wipefs() {
  printf '%s' "$TEST_SIGNATURE"
}

# macOS ships Bash 3.2; provide the small mapfile subset used by these remote
# Linux functions so the mocked test remains portable.
mapfile() {
  local flag="$1" target="$2" line
  [ "$flag" = -t ] || return 99
  case "$target" in
    nodes)
      nodes=()
      while IFS= read -r line; do nodes+=("$line"); done
      ;;
    uuid_nodes)
      uuid_nodes=()
      while IFS= read -r line; do uuid_nodes+=("$line"); done
      ;;
    *) return 99 ;;
  esac
}

TEST_TYPE=ext4
classification=""
fs_node=""
fs_uuid=""
if classify_disk > "$TMP/ext4.output" 2>&1; then status=0; else status=$?; fi
output="$(< "$TMP/ext4.output")"
assert_success 'an existing ext4 filesystem is accepted for reuse'
tests=$((tests + 1))
if [ "$classification" = ready ] && [ "$fs_node" = /dev/nvme-test ] && [ "$fs_uuid" = 11111111-2222-3333-4444-555555555555 ]; then
  pass 'ext4 reuse preserves the verified filesystem identity'
else
  fail 'ext4 reuse preserves the verified filesystem identity' "classification=$classification node=$fs_node uuid=$fs_uuid"
fi

TEST_TYPE=xfs
if output="$(classify_disk 2>&1)"; then status=0; else status=$?; fi
assert_failure_contains 'an unsupported filesystem is refused' 'unsupported xfs signature'

TEST_TYPE=""
classification=""
if classify_disk > "$TMP/blank.output" 2>&1; then status=0; else status=$?; fi
output="$(< "$TMP/blank.output")"
assert_success 'a signature-free disk can be safely classified'
tests=$((tests + 1))
if [ "$classification" = blank ]; then pass 'a signature-free disk is classified as blank'; else fail 'a signature-free disk is classified as blank' "classification=$classification"; fi

TEST_SIGNATURE='gpt'
if output="$(prove_blank 2>&1)"; then status=0; else status=$?; fi
assert_failure_contains 'a nonblank signature is refused before formatting' 'candidate disk contains a signature'

TEST_SIGNATURE=""
if output="$(prove_blank 2>&1)"; then status=0; else status=$?; fi
assert_success 'a whole disk with no signatures passes the blank proof'

# These are regular expressions for source text.
# shellcheck disable=SC2016
assert_contains 'remote initialization formats only after blank classification' "$REMOTE" \
  'if \[ "\$classification" = "blank" \]; then'
assert_contains 'remote initialization uses the existing blank proof' "$REMOTE" \
  '^[[:space:]]+prove_blank$'
# shellcheck disable=SC2016
assert_contains 'remote initialization formats a proven blank disk as ext4' "$REMOTE" \
  '^[[:space:]]+mkfs\.ext4 .*"\$disk"'
# shellcheck disable=SC2016
assert_contains 'host orchestration requests automatic storage initialization' "$SCRIPT" \
  'run_remote_storage init "FORMAT \$VOLUME_ID"'
assert_contains 'automatic initialization revalidates the managed volume identity' "$INITIALIZE_STORAGE" \
  '^[[:space:]]*resolve_existing_volume$'
assert_order_after 'the instance and volume attachment exist before automatic storage setup' "$CREATE" \
  '^[[:space:]]*create_instance$' 'initialize_storage'
assert_sequence 'automatic storage setup completes before new-instance Ollama setup' "$CREATE" \
  '^[[:space:]]*create_instance$' 'initialize_storage' 'ensure_ollama'
assert_sequence 'Ollama resume initializes storage before provisioning continues' "$CREATE" \
  'Resuming Ollama setup' 'initialize_storage' 'ensure_ollama'
assert_order 'persistent storage is mounted and prepared before Ollama remote provisioning' "$ENSURE_OLLAMA" \
  'prepare_storage' 'ensure_ollama_remote'

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
