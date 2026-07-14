> [!IMPORTANT]
> Extended guides, proposals, specs, and current notes are available in the
> project wiki:
> **[Shake, Rattle, and Bang Wiki](https://github.com/panwar-stack/shake-rattle-and-bang/wiki)**

# Shell Scripts

This repository contains three shell scripts for creating and using an Amazon
Linux 2023 development VM. Run each script with `--help` for its complete option
list.

## `aws-ec2-vm.sh`

The main AWS CLI-based VM manager. It creates and controls a named EC2 instance,
its security group and SSH key, and a separate encrypted EBS data volume mounted
at `/data`. The root disk is disposable; the data volume is retained when the
instance is stopped or terminated. It can also manage SSH access, macOS SSHFS
mounts, ingress ports, and optional Ollama provisioning.

### Prerequisites

- Bash, OpenSSH, `curl`, an AWS account, and credentials with the required EC2,
  SSM, and STS permissions.
- AWS CLI v2. The `setup` action can install it on macOS or Linux and configure
  an existing credential, SSO, or standard AWS CLI profile.
- A public subnet with an active route through an internet gateway. The script
  selects a default subnet unless `--subnet-id` is supplied.
- macOS, Homebrew, macFUSE, and SSHFS 3.7.6 or newer only when using `mount`.

State and generated keys are stored under
`${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}`. The default VM name is `dev-vm`, the
default region falls back to `us-east-1`, and options can select another AWS
profile or region.

### Common Workflow

```sh
# Configure AWS access.
./aws-ec2-vm.sh setup --profile dev --region us-east-1

# Create a VM with a 100 GiB persistent data volume, prepared at /data.
./aws-ec2-vm.sh create devbox --vcpus 4 --memory 8 --disk 100

# Connect after creation completes.
./aws-ec2-vm.sh ssh devbox

# Inspect and control the instance.
./aws-ec2-vm.sh status devbox
./aws-ec2-vm.sh stop devbox
./aws-ec2-vm.sh start devbox
./aws-ec2-vm.sh terminate devbox
```

During `create`, a verified blank managed volume is formatted automatically,
mounted at `/data`, and prepared for use. A managed volume with one supported
ext4 filesystem is reused, mounted, and prepared without reformatting. Creation
refuses to format a volume with an unsupported filesystem or other nonblank
signature.

For manual recovery, `init-storage` verifies the managed volume before
formatting it and requires the exact interactive confirmation `FORMAT
<volume-id>`; `--yes` cannot bypass this check. Use `prepare` to verify and mount
an already initialized volume at `/data` without formatting it.

Other actions include:

- `restart`, `ssh`, `mount`, and `unmount` for VM and filesystem access.
- `expose-port` and `close-port` for script-owned security-group rules.
- `destroy-storage` to permanently delete a detached persistent volume.
- `clean` to remove every managed remote and local resource for a VM.
- `version` to print the script version.

Examples:

```sh
# Run one command remotely. Agent forwarding is opt-in.
./aws-ec2-vm.sh ssh devbox --forward-agent -- git status

# Mount /data locally on macOS; install missing mount dependencies.
./aws-ec2-vm.sh mount devbox --install-deps
./aws-ec2-vm.sh unmount devbox

# Allow one source address to reach an application port.
./aws-ec2-vm.sh expose-port devbox 8080 --cidr 203.0.113.10/32
./aws-ec2-vm.sh close-port devbox 8080

# Provision Ollama and restrict its endpoint to the stated network.
./aws-ec2-vm.sh create mlbox --model gemma3:4b \
  --instance-type g6.xlarge --cidr 203.0.113.0/24
```

Models requested with `--model` are stored on the persistent EBS volume under
`/data/ollama/models`. Before provisioning Ollama, `create` automatically
initializes a verified blank volume or reuses a volume with one supported ext4
filesystem, then mounts and prepares it at `/data`. It never reformats an
initialized volume and refuses unsupported filesystems or other nonblank
signatures instead of overwriting them.

```sh
# Inspect persistent-volume capacity and model storage usage.
./aws-ec2-vm.sh ssh mlbox -- df -h /data
./aws-ec2-vm.sh ssh mlbox -- sudo du -sh /data/ollama/models
```

> [!CAUTION]
> EC2 instances, EBS volumes, and public IPv4 addresses can incur charges.
> Unmount SSHFS before stopping or terminating a VM. Treat broad ingress CIDRs
> as public exposure; the provisioned Ollama endpoint has no application-level
> authentication.

### Clean Up a VM

```sh
./aws-ec2-vm.sh clean <name>
```

`clean` terminates the named EC2 instance and permanently deletes its managed
persistent EBS volume, security group, and EC2 key pair. It also deletes the
matching local state, private and public keys, known-host entries, and managed
SSHFS artifacts under `${AWS_VM_STATE_DIR:-$HOME/.aws-ec2-vm}`.

The command verifies resource ownership and refuses to proceed while a managed
mount is configured or active. It prompts for confirmation unless `--yes` is
supplied. Unlike `terminate`, which preserves the persistent volume for reuse,
`clean` permanently removes it.

## `macos-terminal-ssh.sh`

A macOS launcher for an existing, running VM managed by `aws-ec2-vm.sh`. It
prepares the VM's `/data` volume, optionally mounts it locally with SSHFS, and
opens iTerm2 or Terminal.app in either a local-style command shell or a normal
remote SSH session.

```sh
./macos-terminal-ssh.sh [name] [options]

# Mount /data and open the default VM in the preferred terminal.
./macos-terminal-ssh.sh

# Open a normal SSH session without mounting the volume.
./macos-terminal-ssh.sh devbox --remote-shell --no-mount

# Use a local-style shell without forwarding the local SSH agent.
./macos-terminal-ssh.sh devbox --local-shell --no-forward-agent

# Remove this script's managed local mount.
./macos-terminal-ssh.sh devbox --unmount
```

The default local mount is `~/mnt/aws-ec2-vm/<name>`. Automatic dependency
installation uses Homebrew and may install macFUSE, SSHFS, and build tools. The
script initializes or prepares storage whenever it launches a terminal, even
with `--no-mount`, so a verified blank volume can still trigger the
`FORMAT <volume-id>` confirmation. macOS may also request system-extension or
application-automation permission.

Agent forwarding is enabled by default for this launcher. Disable it with
`--no-forward-agent` unless the VM is trusted. Use `--force` with `--unmount`
only to recover an unresponsive managed mount because in-flight writes may be
lost.

## `github-vm-setup.sh`

Prepares an existing, running managed VM for GitHub access and can clone one
repository. It installs the required packages on Amazon Linux 2023, prepares the
existing `/data` volume without formatting it, and refreshes GitHub's SSH host
keys in the remote user's `known_hosts` file.

```sh
./github-vm-setup.sh <vm-name> [--profile <profile>] [--region <region>] \
  [--auth agent|device|public] [--clone <owner/repo>] \
  [--clone-dir <remote-path>]

# Use the default forwarded-agent authentication and clone into /data/workspace.
./github-vm-setup.sh devbox --clone octocat/Hello-World

# Authenticate interactively with GitHub CLI for a private repository.
./github-vm-setup.sh devbox --auth device --clone owner/private-repo

# Clone a public repository without credentials.
./github-vm-setup.sh devbox --auth public --clone owner/public-repo \
  --clone-dir /data/workspace/demo
```

Authentication modes:

- `agent` is the default. It forwards a loaded local SSH agent for the setup and
  clone without copying the private key to the VM.
- `device` installs GitHub CLI and starts its interactive browser/device login.
  The resulting token is stored on the VM's disposable root disk; run the
  printed logout command when it is no longer needed.
- `public` disables credentials and prompts, so it works only with public
  repositories.

Clone into `/data`, such as the default `/data/workspace/<repo>`, to retain the
checkout when the instance is terminated and recreated. Agent forwarding should
only be used with a trusted VM.
