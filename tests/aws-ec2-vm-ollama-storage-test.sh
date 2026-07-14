#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-ollama-storage-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

REMOTE="$TMP/remote-ollama.sh"
ENSURE="$TMP/ensure-ollama.sh"
awk '
  /<<'"'"'REMOTE_OLLAMA'"'"'/ { in_block=1; next }
  in_block && /^REMOTE_OLLAMA$/ { found_end=1; exit }
  in_block { print }
  END { if (!in_block || !found_end) exit 1 }
' "$SCRIPT" > "$REMOTE"
awk '
  /^ensure_ollama\(\) \{/ { in_function=1 }
  in_function { print }
  in_function && /^}$/ { found_end=1; exit }
  END { if (!in_function || !found_end) exit 1 }
' "$SCRIPT" > "$ENSURE"

tests=0
failures=0

pass() { printf 'ok %d - %s\n' "$tests" "$1"; }
fail() {
  printf 'not ok %d - %s\n%s\n' "$tests" "$1" "$2"
  failures=$((failures + 1))
}

assert_contains() {
  local description="$1" pattern="$2"
  tests=$((tests + 1))
  if grep -Eq -- "$pattern" "$REMOTE"; then
    pass "$description"
  else
    fail "$description" "expected remote Ollama provisioning to match: $pattern"
  fi
}

assert_not_contains() {
  local description="$1" pattern="$2"
  tests=$((tests + 1))
  if grep -Eq -- "$pattern" "$REMOTE"; then
    fail "$description" "expected remote Ollama provisioning not to match: $pattern"
  else
    pass "$description"
  fi
}

assert_order() {
  local description="$1" first_pattern="$2" second_pattern="$3" path="${4:-$REMOTE}" first_line second_line
  tests=$((tests + 1))
  first_line="$(awk -v pattern="$first_pattern" '$0 ~ pattern { print NR; exit }' "$path")"
  second_line="$(awk -v pattern="$second_pattern" '$0 ~ pattern { print NR; exit }' "$path")"
  if [ -n "$first_line" ] && [ -n "$second_line" ] && [ "$first_line" -lt "$second_line" ]; then
    pass "$description"
  else
    fail "$description" "expected '$first_pattern' before '$second_pattern' (lines ${first_line:-missing}, ${second_line:-missing})"
  fi
}

assert_contains 'Ollama stores models on the persistent data disk' \
  '^Environment="OLLAMA_MODELS=/data/ollama/models"$'
assert_contains 'Ollama CLI writes pulls to the persistent model directory' \
  '^export OLLAMA_MODELS=/data/ollama/models$'
assert_contains 'Ollama service requires the data mount' \
  '^RequiresMountsFor=/data$'
assert_contains 'Ollama service starts only when data is a mountpoint' \
  '^ConditionPathIsMountPoint=/data$'
assert_contains 'persistent model directory is owned by the Ollama account' \
  '^install -d -o ollama -g ollama -m 0755 /data/ollama/models$'
assert_contains 'both persistent Ollama directory owners are inspected' \
  '^for path in /data/ollama /data/ollama/models; do$'
assert_contains 'persisted Ollama ownership is read numerically' \
  "stat -c ['\"]%u:%g:%a:%F"
assert_contains 'an absent models directory is allowed for parent-only persisted state' \
  '^  if \[ -e "[$]path" \]; then$'
assert_contains 'existing persistent Ollama paths must be real mode-0755 directories' \
  ':755:directory'
assert_contains 'persisted Ollama ownership must be non-root' \
  'persistent Ollama.*(non-root|UID/GID 0)|UID/GID 0.*persistent Ollama'
assert_contains 'persisted Ollama directories must have consistent owners' \
  'persistent Ollama.*(same|consistent|conflicting).*(owner|UID/GID)|(owner|UID/GID).*(same|consistent|conflicting).*persistent Ollama'
assert_contains 'persisted Ollama UID collision is checked' \
  'getent passwd .*persisted_ollama_uid'
assert_contains 'persisted Ollama GID collision is checked' \
  'getent group .*persisted_ollama_gid'
assert_contains 'an incompatible persisted UID collision is rejected' \
  'UID.*(belongs|used|collision).*ollama|ollama.*UID.*(belongs|used|collision)'
assert_contains 'an incompatible persisted GID collision is rejected' \
  'GID.*(belongs|used|collision).*ollama|ollama.*GID.*(belongs|used|collision)'
assert_contains 'new Ollama group reuses the persisted GID' \
  'groupadd .*--gid .*persisted_ollama_gid.*ollama'
assert_contains 'new Ollama user reuses the persisted UID' \
  'useradd .*--uid .*persisted_ollama_uid.*--gid .*ollama.*ollama'
assert_contains 'assigned Ollama UID is verified against persisted ownership' \
  'id -u ollama.*persisted_ollama_uid|persisted_ollama_uid.*id -u ollama'
assert_contains 'assigned Ollama GID is verified against persisted ownership' \
  'id -g ollama.*persisted_ollama_gid|persisted_ollama_gid.*id -g ollama'
assert_contains 'resolved Ollama service identity must be non-root' \
  '\[ "[$]ollama_uid" -gt 0 \].*\[ "[$]ollama_gid" -gt 0 \]'
assert_not_contains 'model data is never recursively reassigned' \
  'chown[[:space:]].*(-R|--recursive).*/data/ollama'

assert_order 'persistent storage preparation precedes Ollama remote provisioning' \
  'prepare_storage' 'ensure_ollama_remote' "$ENSURE"
assert_order 'data mount is verified before persisted owners are inspected' \
  'mountpoint -q /data' "stat -c ['\"]%u:%g:%a:%F"
assert_order 'persisted Ollama owners are inspected before group creation' \
  "stat -c ['\"]%u:%g:%a:%F" 'groupadd .*ollama'
assert_order 'persisted Ollama owners are inspected before user creation' \
  "stat -c ['\"]%u:%g:%a:%F" 'useradd .*ollama'
assert_order 'data mount is verified before the model directory is prepared' \
  'mountpoint -q /data' 'install -d -o ollama -g ollama -m 0755 /data/ollama/models'
assert_order 'persistent model directory is prepared before Ollama starts' \
  'install -d -o ollama -g ollama -m 0755 /data/ollama/models' 'systemctl restart ollama\.service'
assert_order 'persistent model directory is prepared before any model pull' \
  'install -d -o ollama -g ollama -m 0755 /data/ollama/models' 'ollama pull '
assert_order 'data mount verification precedes every model pull' \
  'mountpoint -q /data' 'ollama pull '
assert_order 'Ollama CLI model path is configured before every model pull' \
  'export OLLAMA_MODELS=/data/ollama/models' 'ollama pull '

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
