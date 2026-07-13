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
LOCAL_SHELL=0
LOCAL_SHELL_CONTROL_DIR=""
LOCAL_SHELL_CONTROL_PATH=""
LOCAL_SHELL_CONTROL_LOG=""
LOCAL_SHELL_CLEANUP=()
LOCAL_SHELL_CHECK=()
LOCAL_SHELL_REMOTE_BASE=()

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
warn() { printf 'Warning: %s\n' "$*" >&2; }

cleanup_local_shell() {
  local status=$?
  trap - EXIT
  [ "${#LOCAL_SHELL_CLEANUP[@]}" -eq 0 ] || "${LOCAL_SHELL_CLEANUP[@]}" >/dev/null 2>&1 || true
  [ -z "$LOCAL_SHELL_CONTROL_PATH" ] || rm -f -- "$LOCAL_SHELL_CONTROL_PATH"
  [ -z "$LOCAL_SHELL_CONTROL_LOG" ] || rm -f -- "$LOCAL_SHELL_CONTROL_LOG"
  [ -z "$LOCAL_SHELL_CONTROL_DIR" ] || rmdir "$LOCAL_SHELL_CONTROL_DIR" 2>/dev/null || true
  return "$status"
}

ensure_local_shell_master() {
  [ "${#LOCAL_SHELL_CHECK[@]}" -gt 0 ] || return 1
  if "${LOCAL_SHELL_CHECK[@]}" >/dev/null 2>&1; then
    return 0
  fi
  rm -f -- "$LOCAL_SHELL_CONTROL_PATH"
  : > "$LOCAL_SHELL_CONTROL_LOG"
  if "${LOCAL_SHELL_REMOTE_BASE[@]}" -- /bin/true >/dev/null 2>"$LOCAL_SHELL_CONTROL_LOG"; then
    return 0
  fi
  /bin/cat -- "$LOCAL_SHELL_CONTROL_LOG" >&2
  return 1
}

usage() {
  cat <<'EOF'
macos-terminal-ssh.sh - open a macOS terminal for an EC2 VM

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
the VM's workspace at its name-scoped local mountpoint, then opens a local
command shell rooted at the mounted workspace in iTerm2. Commands entered there
run on EC2; cd keeps the local SSHFS directory and remote /data directory in
sync. If a
remote command is missing, the local shell can ask OC2 to diagnose and apply a
fix before you retry it. Terminal.app and --no-mount use a direct remote login
shell instead. The current public IP is looked up each time, and the local SSH
agent is forwarded by default. No local shell profile or global user SSH config
is modified. Prepare writes remote
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
      --local-shell)
        LOCAL_SHELL=1
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
  local -a command=(/usr/bin/env AWS_VM_SSH_QUIET=1 /bin/bash "$vm_script" "$action" "$NAME")

  if [ "$action" = "mount" ] || [ "$action" = "unmount" ]; then
    command+=(--mount-dir "$MOUNT_DIR")
    [ "$action" != "mount" ] || [ "$INSTALL_DEPS" -eq 0 ] || command+=(--install-deps)
    [ "$action" != "mount" ] || command+=(--recover-stale-mount)
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
  local vm_script="$1" launcher_script="$2" state_dir
  local -a command

  state_dir="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
  case "$state_dir" in
    /*) ;;
    *) state_dir="$PWD/$state_dir" ;;
  esac

  if [ "$APP" = "iterm2" ] && [ "$NO_MOUNT" -eq 0 ]; then
    command=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" /bin/bash "$launcher_script" --local-shell "$NAME" --mount-dir "$MOUNT_DIR")
    [ "$PROFILE_SET" -eq 0 ] || command+=(--profile "$PROFILE")
    [ "$REGION_SET" -eq 0 ] || command+=(--region "$REGION")
    if [ "$FORWARD_AGENT" -eq 1 ]; then command+=(--forward-agent); else command+=(--no-forward-agent); fi
  else
    command=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" /bin/bash "$vm_script" ssh "$NAME" --quiet)
    [ "$PROFILE_SET" -eq 0 ] || command+=(--profile "$PROFILE")
    [ "$REGION_SET" -eq 0 ] || command+=(--region "$REGION")
    [ "$FORWARD_AGENT" -eq 0 ] || command+=(--forward-agent)
    command+=(--tty -- /bin/bash -lc "cd -- /data/workspace && exec \"\${SHELL:-/bin/bash}\" -l")
  fi
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

missing_executable_recovery() {
  local command_text="$1" remote_cwd="$2" invocation="" quoted prompt
  shift 2

  printf '\nRemote command exited with status 127 (missing executable).\n' >&2
  if ! command -v oc2 >/dev/null 2>&1; then
    warn "local 'oc2' is unavailable; install or enable it, then retry the command"
    return
  fi
  for quoted in "$@"; do
    printf -v quoted '%q' "$quoted"
    invocation+="${invocation:+ }$quoted"
  done
  printf -v prompt '%s\n\nFailed command: %s\nRemote working directory: %s\nExact VM helper invocation: %s\n' \
    "Diagnose and apply the safest minimal fix for the missing executable on this EC2 VM. Use the exact helper invocation below to inspect or change that VM, retain default OC2 permissions, verify the fix, and do not change unrelated files or settings." \
    "$command_text" "$remote_cwd" "$invocation"
  printf 'Invoking local OC2 to diagnose and apply a fix on %s...\n' "$NAME" >&2
  if oc2 run --dir "$PWD" "$prompt"; then
    printf 'OC2 finished. Retry the command when ready.\n' >&2
  else
    warn "OC2 did not complete successfully; review its output before retrying"
  fi
}

local_shell() {
  local vm_script="$1" state_dir remote_cwd command_text status remote_path local_path
  local -a remote_command

  [ "$NO_MOUNT" -eq 0 ] || die "internal local shell requires a mounted workspace"
  [ -d "$MOUNT_DIR/workspace" ] || die "mounted workspace is unavailable: $MOUNT_DIR/workspace"
  cd -- "$MOUNT_DIR/workspace"
  remote_cwd="/data/workspace"
  state_dir="${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}"
  case "$state_dir" in /*) ;; *) state_dir="$PWD/$state_dir" ;; esac
  LOCAL_SHELL_CONTROL_DIR="$(mktemp -d /tmp/aws-vm-ssh.XXXXXX)" || die "could not create SSH control directory"
  chmod 700 "$LOCAL_SHELL_CONTROL_DIR"
  LOCAL_SHELL_CONTROL_PATH="$LOCAL_SHELL_CONTROL_DIR/m"
  LOCAL_SHELL_CONTROL_LOG="$LOCAL_SHELL_CONTROL_DIR/master.stderr"
  LOCAL_SHELL_REMOTE_BASE=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" "AWS_VM_SSH_CONTROL_PATH=$LOCAL_SHELL_CONTROL_PATH" /bin/bash "$vm_script" ssh "$NAME" --quiet)
  [ "$PROFILE_SET" -eq 0 ] || LOCAL_SHELL_REMOTE_BASE+=(--profile "$PROFILE")
  [ "$REGION_SET" -eq 0 ] || LOCAL_SHELL_REMOTE_BASE+=(--region "$REGION")
  [ "$FORWARD_AGENT" -eq 0 ] || LOCAL_SHELL_REMOTE_BASE+=(--forward-agent)
  LOCAL_SHELL_CHECK=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" "AWS_VM_SSH_CONTROL_PATH=$LOCAL_SHELL_CONTROL_PATH" "AWS_VM_SSH_CONTROL_COMMAND=check" /bin/bash "$vm_script" ssh "$NAME" --quiet)
  LOCAL_SHELL_CLEANUP=(/usr/bin/env "AWS_VM_STATE_DIR=$state_dir" "AWS_VM_SSH_CONTROL_PATH=$LOCAL_SHELL_CONTROL_PATH" "AWS_VM_SSH_CONTROL_COMMAND=exit" /bin/bash "$vm_script" ssh "$NAME" --quiet)
  if [ "$PROFILE_SET" -eq 1 ]; then LOCAL_SHELL_CHECK+=(--profile "$PROFILE"); LOCAL_SHELL_CLEANUP+=(--profile "$PROFILE"); fi
  if [ "$REGION_SET" -eq 1 ]; then LOCAL_SHELL_CHECK+=(--region "$REGION"); LOCAL_SHELL_CLEANUP+=(--region "$REGION"); fi
  if [ "$FORWARD_AGENT" -eq 1 ]; then LOCAL_SHELL_CHECK+=(--forward-agent); LOCAL_SHELL_CLEANUP+=(--forward-agent); fi

  trap cleanup_local_shell EXIT
  trap 'printf "\n"' INT
  ensure_local_shell_master || die "could not establish the shared SSH connection"
  printf 'Local workspace shell for EC2 VM %s. Commands run remotely; cd mirrors /data.\n' "$NAME"
  while true; do
    command_text=""
    if IFS= read -e -r -p "$NAME:${PWD#"$MOUNT_DIR"}\$ " command_text; then
      :
    else
      status=$?
      [ "$status" -le 128 ] && break
      continue
    fi
    [[ "$command_text" =~ [^[:space:]] ]] || continue
    if [[ "$command_text" =~ ^[[:space:]]*(exit|logout)[[:space:]]*$ ]]; then
      break
    fi

    if [[ "$command_text" =~ ^[[:space:]]*cd([[:space:]]|$) ]]; then
      ensure_local_shell_master || { warn "shared SSH connection is unavailable; command was not run"; continue; }
      # $1 and $2 intentionally expand in the remote Bash, not this launcher.
      # shellcheck disable=SC2016
      remote_command=("${LOCAL_SHELL_REMOTE_BASE[@]}" -- /bin/bash -lc 'cd -- "$1" && { eval "$2" >&2; } && pwd -P' local-shell "$remote_cwd" "$command_text")
      if remote_path="$("${remote_command[@]}")"; then
        case "$remote_path" in
          /data) local_path="$MOUNT_DIR" ;;
          /data/*) local_path="$MOUNT_DIR${remote_path#/data}" ;;
          *) warn "remote cd reached '$remote_path', which is outside mounted /data; staying in $remote_cwd"; continue ;;
        esac
        if [ -d "$local_path" ]; then
          cd -- "$local_path"
          remote_cwd="$remote_path"
        else
          warn "remote directory is not visible through SSHFS: $local_path"
        fi
      else
        status=$?
        [ "$status" -ne 127 ] || missing_executable_recovery "$command_text" "$remote_cwd" "${remote_command[@]}"
      fi
      continue
    fi

    ensure_local_shell_master || { warn "shared SSH connection is unavailable; command was not run"; continue; }
    # $1 and $2 intentionally expand in the remote Bash, not this launcher.
    # shellcheck disable=SC2016
    remote_command=("${LOCAL_SHELL_REMOTE_BASE[@]}" --tty -- /bin/bash -lc 'cd -- "$1" && eval "$2"' local-shell "$remote_cwd" "$command_text")
    if "${remote_command[@]}"; then
      status=0
    else
      status=$?
    fi
    [ "$status" -ne 127 ] || missing_executable_recovery "$command_text" "$remote_cwd" "${remote_command[@]}"
  done
  printf '\n'
  cleanup_local_shell
}

main() {
  parse_args "$@"
  validate_args
  local script_dir vm_script launcher_script
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  vm_script="$script_dir/aws-ec2-vm.sh"
  launcher_script="$script_dir/$(basename -- "${BASH_SOURCE[0]}")"
  [ -r "$vm_script" ] || die "sibling script is missing or unreadable: $vm_script"
  if [ "$LOCAL_SHELL" -eq 1 ]; then
    local_shell "$vm_script"
    exit 0
  fi
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
    MOUNT_DIR="$(cd -- "$MOUNT_DIR" && pwd -P)"
    printf 'VM: %s\nMountpoint: %s\n' "$NAME" "$MOUNT_DIR"
  fi
  command -v osascript >/dev/null 2>&1 || die "osascript is required"
  select_app
  [ "$FORWARD_AGENT" -eq 0 ] || warn "forwarding your local SSH agent to '$NAME'; use --no-forward-agent if the VM is not trusted"
  printf 'Opening VM %s in %s.\n' "$NAME" "$APP"
  launch "$vm_script" "$launcher_script"
}

main "$@"
