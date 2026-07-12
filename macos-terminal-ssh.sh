#!/usr/bin/env bash
set -Eeuo pipefail

readonly DEFAULT_NAME="dev-vm"

NAME="$DEFAULT_NAME"
APP="auto"
PROFILE=""
REGION=""
PROFILE_SET=0
REGION_SET=0
NAME_SET=0
FORWARD_AGENT=1
MOUNT_DIR=""
INSTALL_DEPS=1
NO_MOUNT=0
UNMOUNT=0
FORCE=0
APP_SET=0
FORWARD_AGENT_SET=0

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
macos-terminal-ssh.sh - open a macOS terminal connected to an EC2 VM

USAGE
  ./macos-terminal-ssh.sh [NAME] [OPTIONS]

OPTIONS
  --app APP          Terminal app: auto, iterm2, or terminal (default: auto)
  --profile PROFILE  AWS CLI profile passed to aws-ec2-vm.sh
  --region REGION    AWS region passed to aws-ec2-vm.sh
  --forward-agent    Forward the local SSH agent (default)
  --no-forward-agent Do not forward the local SSH agent
  --mount-dir PATH   Local SSHFS mountpoint (default: ~/mnt/aws-ec2-vm/NAME)
  --install-deps     Install macFUSE and SSHFS if missing (default)
  --no-install-deps  Require macFUSE and SSHFS to already be installed
  --no-mount         Initialize/prepare the VM but do not mount it locally
  --unmount          Unmount this VM's local SSHFS mount and exit
  --force            Force an unresponsive mount to unmount (with --unmount)
  -h, --help         Show help

EXAMPLES
  ./macos-terminal-ssh.sh
  ./macos-terminal-ssh.sh mlbox
  ./macos-terminal-ssh.sh mlbox --app iterm2
  ./macos-terminal-ssh.sh --app terminal --profile work --region us-west-2
  ./macos-terminal-ssh.sh mlbox --no-forward-agent
  ./macos-terminal-ssh.sh mlbox --mount-dir "$HOME/mnt/mlbox"
  ./macos-terminal-ssh.sh mlbox --no-install-deps
  ./macos-terminal-ssh.sh mlbox --no-mount
  ./macos-terminal-ssh.sh mlbox --unmount

By default the launcher safely initializes a verified blank persistent volume
(after exact typed confirmation), installs missing mount dependencies, mounts
the VM's workspace at its name-scoped local mountpoint, then opens a login shell
in /data/workspace. --no-mount still initializes/prepares the persistent
workspace before connecting. The current public IP is looked up each time, and
the local SSH agent is forwarded by default. No local shell profile or global
user SSH config is modified. Prepare writes remote
/etc/profile.d/aws-ec2-vm-data.sh for persistent tool paths, and mount maintains
per-VM SSHFS config under the helper state directory.

SECURITY
  Agent forwarding lets the remote VM request signatures from your local keys.
  Use it only with a VM you trust, or pass --no-forward-agent.
EOF
}

need_value() {
  [ "$#" -ge 2 ] || die "$1 requires a value"
  [ -n "$2" ] || die "$1 requires a non-empty value"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --app)
        need_value "$@"
        APP="$2"
        APP_SET=1
        shift 2
        ;;
      --profile)
        need_value "$@"
        PROFILE="$2"
        PROFILE_SET=1
        shift 2
        ;;
      --region)
        need_value "$@"
        REGION="$2"
        REGION_SET=1
        shift 2
        ;;
      --forward-agent)
        FORWARD_AGENT=1
        FORWARD_AGENT_SET=1
        shift
        ;;
      --no-forward-agent)
        FORWARD_AGENT=0
        FORWARD_AGENT_SET=1
        shift
        ;;
      --mount-dir)
        need_value "$@"
        MOUNT_DIR="$2"
        shift 2
        ;;
      --install-deps)
        INSTALL_DEPS=1
        shift
        ;;
      --no-install-deps)
        INSTALL_DEPS=0
        shift
        ;;
      --no-mount)
        NO_MOUNT=1
        shift
        ;;
      --unmount)
        UNMOUNT=1
        shift
        ;;
      --force)
        FORCE=1
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      --)
        shift
        [ "$#" -le 1 ] || die "expected at most one NAME"
        if [ "$#" -eq 1 ]; then
          [ "$NAME_SET" -eq 0 ] || die "NAME was provided more than once"
          NAME="$1"
          NAME_SET=1
        fi
        break
        ;;
      -*) die "unknown option: $1 (run --help)" ;;
      *)
        [ "$NAME_SET" -eq 0 ] || die "expected at most one NAME"
        NAME="$1"
        NAME_SET=1
        shift
        ;;
    esac
  done
}

validate_args() {
  case "$NAME" in
    ''|*[!a-zA-Z0-9._-]*) die "NAME may contain only letters, digits, dot, underscore, and hyphen" ;;
  esac
  [ "${#NAME}" -le 48 ] || die "NAME must be at most 48 characters"
  [ -z "$MOUNT_DIR" ] || case "$MOUNT_DIR" in *$'\n'*|*$'\r'*) die "--mount-dir must not contain newlines" ;; esac
  [ "$NO_MOUNT" -eq 0 ] || [ "$UNMOUNT" -eq 0 ] || die "--no-mount conflicts with --unmount"
  [ "$NO_MOUNT" -eq 0 ] || [ -z "$MOUNT_DIR" ] || die "--mount-dir conflicts with --no-mount"
  [ "$UNMOUNT" -eq 1 ] || [ "$FORCE" -eq 0 ] || die "--force requires --unmount"
  if [ "$UNMOUNT" -eq 1 ]; then
    [ "$APP_SET" -eq 0 ] || die "--app conflicts with --unmount"
    [ "$FORWARD_AGENT_SET" -eq 0 ] || die "SSH agent options conflict with --unmount"
    [ "$PROFILE_SET" -eq 0 ] || die "--profile conflicts with fully local --unmount"
    [ "$REGION_SET" -eq 0 ] || die "--region conflicts with fully local --unmount"
  fi
  [ -n "$MOUNT_DIR" ] || MOUNT_DIR="$HOME/mnt/aws-ec2-vm/$NAME"
}

vm_command() {
  local action="$1" vm_script="$2"
  local -a command=(/bin/bash "$vm_script" "$action" "$NAME")

  if [ "$action" = "mount" ] || [ "$action" = "unmount" ]; then
    command+=(--mount-dir "$MOUNT_DIR")
    [ "$action" != "mount" ] || [ "$INSTALL_DEPS" -eq 0 ] || command+=(--install-deps)
    [ "$action" != "unmount" ] || [ "$FORCE" -eq 0 ] || command+=(--force)
  fi
  if [ "$action" != "unmount" ]; then
    [ "$PROFILE_SET" -eq 0 ] || command+=(--profile "$PROFILE")
    [ "$REGION_SET" -eq 0 ] || command+=(--region "$REGION")
  fi
  "${command[@]}"
}

select_app() {
  case "$APP" in
    auto)
      if open -Ra iTerm >/dev/null 2>&1; then
        APP="iterm2"
      else
        APP="terminal"
      fi
      ;;
    iterm2)
      open -Ra iTerm >/dev/null 2>&1 || die "iTerm2 is not installed"
      ;;
    terminal) ;;
    *) die "--app must be auto, iterm2, or terminal" ;;
  esac
}

launch() {
  local vm_script="$1" state_dir
  local -a command

  state_dir="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
  case "$state_dir" in
    /*) ;;
    *) state_dir="$PWD/$state_dir" ;;
  esac

  command=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" /bin/bash "$vm_script" ssh "$NAME")
  [ "$PROFILE_SET" -eq 0 ] || command+=(--profile "$PROFILE")
  [ "$REGION_SET" -eq 0 ] || command+=(--region "$REGION")
  [ "$FORWARD_AGENT" -eq 0 ] || command+=(--forward-agent)
  command+=(--tty -- /bin/bash -lc "cd -- /data/workspace && exec \"\${SHELL:-/bin/bash}\" -l")
  osascript - "$APP" "$NAME" "${command[@]}" <<'APPLESCRIPT'
on run argv
  set appChoice to item 1 of argv
  set windowTitle to "AWS VM: " & item 2 of argv
  set commandText to ""
  repeat with argumentIndex from 3 to count of argv
    if commandText is not "" then set commandText to commandText & " "
    set commandText to commandText & quoted form of (item argumentIndex of argv)
  end repeat

  if appChoice is "iterm2" then
    tell application "iTerm"
      set newWindow to create window with default profile
      tell current session of newWindow
        set name to windowTitle
        write text commandText
      end tell
      activate
    end tell
  else if appChoice is "terminal" then
    tell application "Terminal"
      set newTab to do script commandText
      set custom title of newTab to windowTitle
      activate
    end tell
  else
    error "Unsupported terminal application"
  end if
end run
APPLESCRIPT
}

main() {
  parse_args "$@"
  validate_args
  local script_dir vm_script
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  vm_script="$script_dir/aws-ec2-vm.sh"
  [ -r "$vm_script" ] || die "sibling script is missing or unreadable: $vm_script"
  if [ "$UNMOUNT" -eq 1 ]; then
    vm_command unmount "$vm_script"
    exit 0
  fi
  [ "$(uname -s)" = "Darwin" ] || die "this helper requires macOS"
  vm_command init-storage "$vm_script"
  if [ "$NO_MOUNT" -eq 1 ]; then
    printf 'Persistent storage initialized and prepared for %s.\n' "$NAME"
  else
    vm_command mount "$vm_script"
    printf 'VM: %s\nMountpoint: %s\n' "$NAME" "$MOUNT_DIR"
  fi
  command -v osascript >/dev/null 2>&1 || die "osascript is required"
  select_app
  [ "$FORWARD_AGENT" -eq 0 ] || warn "forwarding your local SSH agent to '$NAME'; use --no-forward-agent if the VM is not trusted"
  printf 'Opening VM %s in %s.\n' "$NAME" "$APP"
  launch "$vm_script"
}

main "$@"
