# linux-package-management.md

## Package Installation and Management

A **package manager** helps you install, update, and remove software.

Common package managers:

- **Ubuntu / Debian**: `apt`
- **CentOS / RHEL / Amazon Linux (old)**: `yum`
- **Fedora / newer RHEL-based**: `dnf`

You only use **one** of these, depending on your Linux distribution.

Check your distro:

```bash
cat /etc/os-release
# Example (short):
# NAME="Ubuntu"
# VERSION="22.04.5 LTS (Jammy Jellyfish)"
# ID=ubuntu
# VERSION_ID="22.04"
```

## Upgrade all packages on the system

### Ubuntu / Debian (apt)

```bash
# Update package list, then upgrade installed packages:
sudo apt update
sudo apt upgrade
# Optional: include dependency changes/removals:
sudo apt full-upgrade
```

### CentOS / RHEL / Fedora (yum / dnf)

```bash
# Older systems:
sudo yum update
# Newer systems:
sudo dnf upgrade
```

## Install nginx

### Ubuntu / Debian (apt)

```bash
# Install nginx (update list first is recommended):
sudo apt update
sudo apt install nginx
# Start and enable on boot:
sudo systemctl enable --now nginx
# Check status:
systemctl status nginx
```

### CentOS / RHEL / Fedora (yum / dnf)

```bash
# Install nginx:
sudo yum install nginx   # or: sudo dnf install nginx
# Start and enable on boot:
sudo systemctl enable --now nginx
# Check status:
systemctl status nginx
```

## Remove nginx

### Ubuntu / Debian (apt)

```bash
# Remove nginx (keep config files):
sudo apt remove nginx
# Remove nginx and its config files:
sudo apt purge nginx nginx-common
# Clean unused packages:
sudo apt autoremove
```

### CentOS / RHEL / Fedora (yum / dnf)

```bash
# Remove nginx:
sudo yum remove nginx    # or: sudo dnf remove nginx
```