#!/usr/bin/env bash
set -Eeuo pipefail

AUTH_MODE="agent"
CLONE_SLUG=""
CLONE_DIR=""
PROFILE=""
REGION=""
VM_NAME=""

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
github-vm-setup.sh - prepare an EC2 development VM for GitHub

USAGE
  github-vm-setup.sh VM_NAME [OPTIONS]

OPTIONS
  --profile PROFILE       Select an AWS CLI profile
  --region REGION         Select an AWS region
  --auth MODE             GitHub auth: agent (default), device, or public
  --clone OWNER/REPO      Clone a repository after setup
  --clone-dir REMOTE_PATH Clone destination (default: ~/src/REPO)
  -h, --help              Show help

AUTH MODES
  agent  Forward a loaded local SSH agent. No GitHub credential is stored.
  device Install GitHub CLI and complete its interactive browser/device login.
  public Use HTTPS without credentials; only public repositories can be cloned.

EXAMPLES
  ./github-vm-setup.sh mlbox --clone octocat/Hello-World
  ./github-vm-setup.sh mlbox --auth device --clone OWNER/private-repo
  ./github-vm-setup.sh mlbox --auth public --clone-dir projects/demo --clone OWNER/REPO

Device mode stores the GitHub CLI token on the VM's disposable root disk. Agent
forwarding lets the VM use the local agent only while SSH is connected; use it
only with a VM you trust. This helper never copies private keys or tokens.
EOF
}

need_value() { [ "$#" -ge 2 ] || die "$1 requires a value"; }

valid_slug() {
  [[ "$1" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*$ ]] || return 1
  local owner="${1%%/*}" repo="${1#*/}"
  [ "${#owner}" -le 39 ] && [ "${#repo}" -le 100 ] &&
    [ "$owner" != "." ] && [ "$owner" != ".." ] && [ "$repo" != "." ] && [ "$repo" != ".." ]
}

parse_args() {
  [ "$#" -gt 0 ] || { usage >&2; exit 2; }
  case "$1" in -h|--help) usage; exit 0 ;; -*) die "VM_NAME must be the first argument" ;; esac
  VM_NAME="$1"
  shift
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --profile) need_value "$@"; PROFILE="$2"; shift 2 ;;
      --region) need_value "$@"; REGION="$2"; shift 2 ;;
      --auth) need_value "$@"; AUTH_MODE="$2"; shift 2 ;;
      --clone) need_value "$@"; CLONE_SLUG="$2"; shift 2 ;;
      --clone-dir) need_value "$@"; CLONE_DIR="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
  done
}

validate_args() {
  case "$VM_NAME" in ''|*[!a-zA-Z0-9._-]*) die "VM_NAME may contain only letters, digits, dot, underscore, and hyphen" ;; esac
  [ "${#VM_NAME}" -le 48 ] || die "VM_NAME must be at most 48 characters"
  case "$AUTH_MODE" in agent|device|public) ;; *) die "--auth must be agent, device, or public" ;; esac
  [ -z "$PROFILE" ] || case "$PROFILE" in *[!a-zA-Z0-9_+=,.@-]*) die "invalid profile name" ;; esac
  [ -z "$REGION" ] || case "$REGION" in *[!a-z0-9-]*) die "invalid region: $REGION" ;; esac
  [ -z "$CLONE_SLUG" ] || valid_slug "$CLONE_SLUG" || die "--clone must be exactly OWNER/REPO using letters, digits, dot, underscore, or hyphen"
  [ -z "$CLONE_DIR" ] || [ -n "$CLONE_SLUG" ] || die "--clone-dir requires --clone"
  if [ -n "$CLONE_DIR" ]; then
    [ "${#CLONE_DIR}" -le 4096 ] || die "--clone-dir is too long"
    case "$CLONE_DIR" in -*) die "invalid --clone-dir" ;; esac
    [[ "$CLONE_DIR" != *[[:cntrl:]]* ]] || die "--clone-dir must not contain control characters"
  fi
  if [ "$AUTH_MODE" = "agent" ]; then
    [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ] || die "agent mode requires a working SSH_AUTH_SOCK"
    command -v ssh-add >/dev/null 2>&1 || die "agent mode requires ssh-add"
    ssh-add -L >/dev/null 2>&1 || die "agent mode requires at least one key loaded in the local SSH agent"
  fi
}

run_vm() {
  local args=("$VM_TOOL" ssh "$VM_NAME")
  [ -z "$PROFILE" ] || args+=(--profile "$PROFILE")
  [ -z "$REGION" ] || args+=(--region "$REGION")
  [ "$AUTH_MODE" != "agent" ] || args+=(--forward-agent)
  "${args[@]}" "$@"
}

main() {
  parse_args "$@"
  validate_args

  local script_dir
  script_dir="$(cd "$(dirname "$0")" && pwd)"
  readonly VM_TOOL="$script_dir/aws-ec2-vm.sh"
  [ -x "$VM_TOOL" ] || die "VM helper is not executable: $VM_TOOL"

  run_vm -- bash -s -- "$AUTH_MODE" <<'REMOTE_BOOTSTRAP'
set -Eeuo pipefail
auth_mode="$1"
. /etc/os-release
[ "${ID:-}" = "amzn" ] && [[ "${VERSION_ID:-}" = 2023* ]] || {
  printf 'Error: this helper supports Amazon Linux 2023 only\n' >&2
  exit 1
}
sudo dnf install -y git jq openssh-clients
if ! command -v curl >/dev/null 2>&1; then
  sudo dnf install -y curl-minimal
fi
command -v curl >/dev/null 2>&1 || {
  printf 'Error: curl is unavailable after installation\n' >&2
  exit 1
}
if [ "$auth_mode" = "device" ]; then
  sudo dnf install -y 'dnf-command(config-manager)'
  sudo dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo
  sudo dnf install -y gh
fi
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
curl -fsSL --proto '=https' --tlsv1.2 https://api.github.com/meta |
  jq -er 'if (.ssh_keys | length) > 0 then .ssh_keys[] | "github.com " + . else error("no SSH keys") end' > "$tmp"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/known_hosts"
chmod 600 "$HOME/.ssh/known_hosts"
ssh-keygen -R github.com -f "$HOME/.ssh/known_hosts" >/dev/null 2>&1 || true
cat "$tmp" >> "$HOME/.ssh/known_hosts"
if [ "$auth_mode" = "agent" ]; then
  [ -n "${SSH_AUTH_SOCK:-}" ] && [ -S "$SSH_AUTH_SOCK" ] || {
    printf 'Error: the SSH agent was not forwarded\n' >&2
    exit 1
  }
  ssh-add -L >/dev/null 2>&1 || {
    printf 'Error: the forwarded SSH agent has no available keys\n' >&2
    exit 1
  }
fi
REMOTE_BOOTSTRAP

  if [ "$AUTH_MODE" = "device" ]; then
    run_vm --tty -- bash -c 'gh auth status --hostname github.com >/dev/null 2>&1 || gh auth login --hostname github.com --git-protocol https --web; gh auth setup-git'
  fi

  if [ -n "$CLONE_SLUG" ]; then
    run_vm -- bash -s -- "$AUTH_MODE" "$CLONE_SLUG" "$CLONE_DIR" <<'REMOTE_CLONE'
set -Eeuo pipefail
auth_mode="$1"
slug="$2"
dest="$3"
repo="${slug#*/}"
[ -n "$dest" ] || dest="$HOME/src/$repo"
[ ! -e "$dest" ] || { printf 'Error: clone destination already exists: %s\n' "$dest" >&2; exit 1; }
mkdir -p -- "$(dirname -- "$dest")"
case "$auth_mode" in
  agent)
    url="git@github.com:$slug.git"
    git clone -- "$url" "$dest"
    ;;
  device)
    url="https://github.com/$slug.git"
    git clone -- "$url" "$dest"
    ;;
  public)
    url="https://github.com/$slug.git"
    GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=/bin/false \
      git -c credential.helper= -c credential.interactive=never -c core.askPass=/bin/false clone -- "$url" "$dest"
    ;;
  *) printf 'Error: invalid auth mode\n' >&2; exit 1 ;;
esac
REMOTE_CLONE
  fi

  printf 'GitHub setup complete for VM %s (%s mode).\n' "$VM_NAME" "$AUTH_MODE"
  if [ "$AUTH_MODE" = "device" ]; then
    local logout_args=("$VM_TOOL" ssh "$VM_NAME") arg
    [ -z "$PROFILE" ] || logout_args+=(--profile "$PROFILE")
    [ -z "$REGION" ] || logout_args+=(--region "$REGION")
    logout_args+=(--tty -- gh auth logout --hostname github.com)
    printf 'To remove the VM token later, run this command remotely through the helper:\n  '
    for arg in "${logout_args[@]}"; do printf '%q ' "$arg"; done
    printf '\n'
  fi
}

main "$@"
