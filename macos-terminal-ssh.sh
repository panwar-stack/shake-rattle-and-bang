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

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

usage() {
  cat <<'EOF'
macos-terminal-ssh.sh - open a macOS terminal connected to an EC2 VM

USAGE
  ./macos-terminal-ssh.sh [NAME] [OPTIONS]

OPTIONS
  --app APP          Terminal app: auto, iterm2, or terminal (default: auto)
  --profile PROFILE  AWS CLI profile passed to aws-ec2-vm.sh
  --region REGION    AWS region passed to aws-ec2-vm.sh
  -h, --help         Show help

EXAMPLES
  ./macos-terminal-ssh.sh
  ./macos-terminal-ssh.sh mlbox
  ./macos-terminal-ssh.sh mlbox --app iterm2
  ./macos-terminal-ssh.sh --app terminal --profile work --region us-west-2

The launcher runs the sibling aws-ec2-vm.sh ssh command in a new window. That
command looks up the VM's current public IP each time. No shell profile or SSH
configuration is modified.
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
  local script_dir vm_script state_dir
  local -a command

  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  vm_script="$script_dir/aws-ec2-vm.sh"
  [ -r "$vm_script" ] || die "sibling script is missing or unreadable: $vm_script"

  state_dir="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
  case "$state_dir" in
    /*) ;;
    *) state_dir="$PWD/$state_dir" ;;
  esac

  command=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" /bin/bash "$vm_script" ssh "$NAME")
  [ "$PROFILE_SET" -eq 0 ] || command+=(--profile "$PROFILE")
  [ "$REGION_SET" -eq 0 ] || command+=(--region "$REGION")

  osascript - "$APP" "${command[@]}" <<'APPLESCRIPT'
on run argv
  set appChoice to item 1 of argv
  set commandText to ""
  repeat with argumentIndex from 2 to count of argv
    if commandText is not "" then set commandText to commandText & " "
    set commandText to commandText & quoted form of (item argumentIndex of argv)
  end repeat

  if appChoice is "iterm2" then
    tell application "iTerm"
      set newWindow to create window with default profile
      tell current session of newWindow to write text commandText
      activate
    end tell
  else if appChoice is "terminal" then
    tell application "Terminal"
      do script commandText
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
  [ "$(uname -s)" = "Darwin" ] || die "this helper requires macOS"
  command -v osascript >/dev/null 2>&1 || die "osascript is required"
  select_app
  launch
}

main "$@"
