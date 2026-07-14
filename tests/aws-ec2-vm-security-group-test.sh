#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT="$ROOT/aws-ec2-vm.sh"
TMP="$(mktemp -d "${TMPDIR:-/tmp}/aws-ec2-vm-sg-test.XXXXXX")"
trap 'rm -rf "$TMP"' EXIT

awk '/^main "\$@"$/ { found=1; exit } { print } END { if (!found) exit 1 }' "$SCRIPT" > "$TMP/aws-ec2-vm-functions.sh"
source "$TMP/aws-ec2-vm-functions.sh"

tests=0
failures=0
status=0
output=""
CASE_DIR=""
CASE_PORT=""
CASE_CIDR=""
CASE_PURPOSE=""
CASE_MODE=""
CASE_ATTACHED_OTHER=0
CASE_AUTO_AUTHORIZE=0
CASE_DESCRIBE_FAIL=0

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

assert_mutation_count() {
  local description="$1" expected="$2" pattern="$3" actual
  tests=$((tests + 1))
  actual="$(grep -Fc -- "$pattern" "$CASE_DIR/mutations" 2>/dev/null || true)"
  if [ "$actual" -eq "$expected" ]; then
    pass "$description"
  else
    fail "$description" "expected $expected mutations containing '$pattern', got $actual\n$(< "$CASE_DIR/mutations")"
  fi
}

assert_log_contains() {
  local description="$1" path="$2" expected="$3"
  tests=$((tests + 1))
  if grep -Fq -- "$expected" "$path"; then pass "$description"; else fail "$description" "expected '$expected' in $path\n$(< "$path")"; fi
}

assert_log_lacks() {
  local description="$1" path="$2" unexpected="$3"
  tests=$((tests + 1))
  if ! grep -Fq -- "$unexpected" "$path"; then pass "$description"; else fail "$description" "unexpected '$unexpected' in $path\n$(< "$path")"; fi
}

rule_row() {
  [ "$#" -eq 15 ] || return 99
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "$@"
}

tagged_row() {
  local id="$1" group="$2" port="$3" cidr="$4" purpose="$5"
  rule_row "$id" "$group" False tcp "$port" "$port" "$cidr" None None None \
    "aws-ec2-vm:v2:test:${purpose}:${port}" aws-ec2-vm test "$purpose" "$port"
}

legacy_row() {
  local id="$1" group="$2" port="$3" cidr="$4" description="$5"
  rule_row "$id" "$group" False tcp "$port" "$port" "$cidr" None None None "$description" None None None None
}

sg_case() (
  NAME=test
  SG_ID=sg-managed
  if [ "$CASE_ATTACHED_OTHER" -eq 1 ]; then INSTANCE_ID=i-test; else INSTANCE_ID=""; fi
  reconciliation_sleep() { :; }
  aws_text() {
    local id="" arg previous=""
    printf '%s\n' "$*" >> "$CASE_DIR/aws.log"
    case "$1:$2" in
      ec2:describe-instances)
        [ "$CASE_ATTACHED_OTHER" -eq 1 ] || return 97
        printf '%s\n' 'running sg-managed,sg-other'
        ;;
      ec2:describe-security-group-rules)
        if [ "$CASE_DESCRIBE_FAIL" -eq 1 ]; then
          printf '%s\n' 'injected describe failure' >&2
          return 70
        fi
        [ ! -s "$CASE_DIR/inventory" ] || printf '%s\n' "$(< "$CASE_DIR/inventory")"
        ;;
      ec2:authorize-security-group-ingress)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        if [ "$CASE_AUTO_AUTHORIZE" -eq 1 ]; then
          tagged_row sgr-authorized sg-managed "$CASE_PORT" "$CASE_CIDR" "$CASE_PURPOSE" >> "$CASE_DIR/inventory"
        fi
        ;;
      ec2:revoke-security-group-ingress)
        printf '%s\n' "$*" >> "$CASE_DIR/mutations"
        for arg in "$@"; do
          if [ "$previous" = --security-group-rule-ids ]; then id="$arg"; break; fi
          previous="$arg"
        done
        [ -n "$id" ] || return 96
        awk -F '\t' -v id="$id" '$1 != id' "$CASE_DIR/inventory" > "$CASE_DIR/inventory.next"
        mv "$CASE_DIR/inventory.next" "$CASE_DIR/inventory"
        ;;
      *) return 98 ;;
    esac
  }
  case "$CASE_MODE" in
    ensure) ensure_managed_ingress "$CASE_PORT" "$CASE_CIDR" "$CASE_PURPOSE" ;;
    ensure-twice)
      ensure_managed_ingress "$CASE_PORT" "$CASE_CIDR" "$CASE_PURPOSE"
      ensure_managed_ingress "$CASE_PORT" "$CASE_CIDR" "$CASE_PURPOSE"
      ;;
    close)
      close_managed_ingress "$CASE_PORT" "$CASE_PURPOSE"
      info "Closed managed TCP port $CASE_PORT"
      ;;
    *) return 95 ;;
  esac
)

run_sg_case() {
  local label="$1" port="$2" cidr="$3" purpose="$4" mode="$5" attached_other="$6" auto_authorize="$7" describe_fail="$8" inventory="$9"
  CASE_DIR="$TMP/$label"
  rm -rf "$CASE_DIR"
  mkdir -p "$CASE_DIR"
  : > "$CASE_DIR/aws.log"
  : > "$CASE_DIR/mutations"
  printf '%s' "$inventory" > "$CASE_DIR/inventory"
  CASE_PORT="$port"
  CASE_CIDR="$cidr"
  CASE_PURPOSE="$purpose"
  CASE_MODE="$mode"
  CASE_ATTACHED_OTHER="$attached_other"
  CASE_AUTO_AUTHORIZE="$auto_authorize"
  CASE_DESCRIBE_FAIL="$describe_fail"
  set +e
  output="$(sg_case 2>&1)"
  status=$?
  set -e
}

assert_conflict_case() {
  local label="$1" port="$2" cidr="$3" purpose="$4" attached="$5" inventory="$6" id="$7" source="$8"
  run_sg_case "$label" "$port" "$cidr" "$purpose" ensure "$attached" 0 0 "$inventory"
  assert_failure_contains "$label fails closed and identifies its rule" "$id"
  assert_failure_contains "$label reports the effective source kind" "$source"
  assert_mutation_count "$label authorizes no replacement rule" 0 'authorize-security-group-ingress'
  assert_mutation_count "$label revokes no unowned rule" 0 'revoke-security-group-ingress'
  assert_log_contains "$label preserves the conflicting rule" "$CASE_DIR/inventory" "$id"
}

row="$(rule_row sgr-ipv4range sg-managed False tcp 20 30 198.51.100.0/24 None None None unowned None None None None)"
assert_conflict_case 'IPv4 overlapping range on SSH' 22 203.0.113.7/32 ssh 0 "$row" sgr-ipv4range 'source=ipv4:'

row="$(rule_row sgr-ipv6 sg-managed False tcp 11434 11434 None 2001:db8::/64 None None unowned None None None None)"
assert_conflict_case 'IPv6 rule on Ollama' 11434 203.0.113.7/32 ollama 0 "$row" sgr-ipv6 'source=ipv6:'

row="$(rule_row sgr-prefix sg-managed False tcp 8080 8080 None None pl-1234 None unowned None None None None)"
assert_conflict_case 'prefix-list rule on custom port' 8080 203.0.113.7/32 tcp 0 "$row" sgr-prefix 'source=prefix-list:'

row="$(rule_row sgr-referenced sg-managed False tcp 22 22 None None None sg-source unowned None None None None)"
assert_conflict_case 'referenced-group rule on SSH' 22 203.0.113.7/32 ssh 0 "$row" sgr-referenced 'source=referenced-group:'

row="$(rule_row sgr-all sg-managed False -1 None None 0.0.0.0/0 None None None unowned None None None None)"
assert_conflict_case 'all-protocol rule on Ollama' 11434 203.0.113.7/32 ollama 0 "$row" sgr-all 'protocol=-1'

row="$(rule_row sgr-numeric6 sg-managed False 6 1 1 198.51.100.0/24 None None None unowned None None None None)"
assert_conflict_case 'numeric TCP protocol ignores port fields' 8080 203.0.113.7/32 tcp 0 "$row" sgr-numeric6 'protocol=6'

row="$(rule_row sgr-foreign sg-other False tcp 8080 8080 198.51.100.0/24 None None None unowned None None None None)"
assert_conflict_case 'effective rule in second attached group' 8080 203.0.113.7/32 tcp 1 "$row" sgr-foreign 'group=sg-other'
assert_log_contains 'second-group inspection queries every network interface attachment' "$CASE_DIR/aws.log" 'NetworkInterfaces[].Groups[].GroupId'
assert_log_contains 'second-group inventory includes both attached groups' "$CASE_DIR/aws.log" 'Name=group-id,Values=sg-managed,sg-other'

row="$(rule_row sgr-partial sg-managed False tcp 8080 8080 203.0.113.7/32 None None None aws-ec2-vm:v2:test:tcp:8080 aws-ec2-vm None None None)"
assert_conflict_case 'partially tagged v2-looking rule' 8080 203.0.113.7/32 tcp 0 "$row" sgr-partial 'source=ipv4:'

for spec in '22 ssh aws-ec2-vm' '11434 ollama aws-ec2-vm:test:ollama:11434' '8080 tcp aws-ec2-vm:test:tcp:8080'; do
  read -r port purpose legacy_description <<< "$spec"
  row="$(tagged_row "sgr-tagged${port}" sg-managed "$port" 203.0.113.7/32 "$purpose")"
  run_sg_case "tagged-$port" "$port" 203.0.113.7/32 "$purpose" ensure-twice 0 0 0 "$row"
  assert_success "exact tagged $purpose rule is idempotent across two reconciliations"
  assert_mutation_count "exact tagged $purpose rule needs no mutation" 0 'security-group-ingress'

  row="$(legacy_row "sgr-legacy${port}" sg-managed "$port" 203.0.113.7/32 "$legacy_description")"
  run_sg_case "legacy-$port" "$port" 203.0.113.7/32 "$purpose" ensure-twice 0 0 0 "$row"
  assert_success "complete legacy $purpose signature remains idempotent"
  assert_mutation_count "complete legacy $purpose signature needs no mutation" 0 'security-group-ingress'
done

desired="$(tagged_row sgr-desired sg-managed 8080 203.0.113.7/32 tcp)"
udp="$(rule_row sgr-udp sg-managed False udp 8080 8080 0.0.0.0/0 None None None unowned None None None None)"
adjacent="$(rule_row sgr-adjacent sg-managed False tcp 8079 8079 0.0.0.0/0 None None None unowned None None None None)"
run_sg_case unrelated 8080 203.0.113.7/32 tcp ensure-twice 0 0 0 "$desired
$udp
$adjacent"
assert_success 'same-port UDP and adjacent TCP rules do not create false conflicts'
assert_mutation_count 'unrelated rules remain untouched' 0 'security-group-ingress'
assert_log_contains 'same-port UDP rule is retained' "$CASE_DIR/inventory" sgr-udp
assert_log_contains 'adjacent TCP rule is retained' "$CASE_DIR/inventory" sgr-adjacent

run_sg_case authorize-once 8080 203.0.113.7/32 tcp ensure-twice 0 1 0 ''
assert_success 'empty ingress converges once and is idempotent on retry'
assert_mutation_count 'empty ingress authorizes exactly one rule' 1 'authorize-security-group-ingress'
assert_log_contains 'authorize targets only the managed group' "$CASE_DIR/mutations" '--group-id sg-managed'
assert_log_contains 'authorize uses the exact port and CIDR permission' "$CASE_DIR/mutations" 'IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges=[{CidrIp=203.0.113.7/32,Description=aws-ec2-vm:v2:test:tcp:8080}]'
assert_log_contains 'authorize applies complete rule ownership tags' "$CASE_DIR/mutations" 'ManagedBy,Value=aws-ec2-vm},{Key=aws-ec2-vm:Name,Value=test},{Key=aws-ec2-vm:Purpose,Value=tcp},{Key=aws-ec2-vm:Port,Value=8080}'

desired="$(tagged_row sgr-keep sg-managed 8080 203.0.113.7/32 tcp)"
stale="$(tagged_row sgr-stale sg-managed 8080 198.51.100.9/32 tcp)"
run_sg_case stale-owned 8080 203.0.113.7/32 tcp ensure 0 0 0 "$desired
$stale"
assert_success 'reconciliation removes only stale exact-owned ingress'
assert_mutation_count 'stale reconciliation does not authorize' 0 'authorize-security-group-ingress'
assert_mutation_count 'stale reconciliation revokes exactly one rule' 1 'revoke-security-group-ingress'
assert_log_contains 'stale reconciliation revokes by exact rule ID' "$CASE_DIR/mutations" '--security-group-rule-ids sgr-stale'
assert_log_contains 'desired owned rule remains after stale cleanup' "$CASE_DIR/inventory" sgr-keep
assert_log_lacks 'stale owned rule is absent after cleanup' "$CASE_DIR/inventory" sgr-stale

owned="$(tagged_row sgr-owned sg-managed 8080 203.0.113.7/32 tcp)"
conflict="$(rule_row sgr-residual sg-managed False tcp 8000 9000 0.0.0.0/0 None None None unowned None None None None)"
run_sg_case close-residual 8080 '' tcp close 0 0 0 "$owned
$conflict"
assert_failure_contains 'close-port fails when residual unowned access remains' 'still has effective ingress'
assert_mutation_count 'close-port revokes the exact owned rule once' 1 '--security-group-rule-ids sgr-owned'
assert_mutation_count 'close-port never revokes the unowned residual rule' 0 '--security-group-rule-ids sgr-residual'
assert_log_contains 'close-port preserves residual unowned ingress' "$CASE_DIR/inventory" sgr-residual
assert_output_lacks 'close-port omits success output when access remains' 'Closed managed TCP port'

canonical="$(tagged_row sgr-canonical sg-managed 22 203.0.113.0/24 ssh)"
run_sg_case canonical-cidr 22 203.0.113.99/24 ssh ensure-twice 0 0 0 "$canonical"
assert_success 'noncanonical explicit IPv4 CIDR reconciles to its AWS canonical network'
assert_mutation_count 'canonical CIDR equality avoids duplicate authorization' 0 'security-group-ingress'

run_sg_case describe-failure 8080 203.0.113.7/32 tcp ensure 0 0 1 ''
assert_failure_contains 'inventory errors fail closed instead of becoming empty ingress' 'cannot inventory ingress rules'
assert_mutation_count 'inventory failure performs zero mutations' 0 'security-group-ingress'

printf '1..%d\n' "$tests"
[ "$failures" -eq 0 ] || { printf '%d test(s) failed\n' "$failures" >&2; exit 1; }
