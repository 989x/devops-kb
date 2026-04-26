---
title: Linux Package Management
tags: [linux, openlandscape, package]
type: guide
status: stable
created: 2026-04-26
---

# Linux Package Management

Package manager ช่วย install, update และ remove software

| Distro | Package Manager |
|--------|----------------|
| Ubuntu / Debian | `apt` |
| CentOS / RHEL / Amazon Linux (เก่า) | `yum` |
| Fedora / RHEL ใหม่ | `dnf` |

ตรวจสอบ distro ที่ใช้งาน

```bash
cat /etc/os-release
# Example output:
# NAME="Ubuntu"
# VERSION="22.04.5 LTS (Jammy Jellyfish)"
# ID=ubuntu
# VERSION_ID="22.04"
```

## Upgrade All Packages

### Ubuntu / Debian

```bash
sudo apt update
sudo apt upgrade

# รวม dependency changes/removals
sudo apt full-upgrade
```

### CentOS / RHEL / Fedora

```bash
# ระบบเก่า
sudo yum update

# ระบบใหม่
sudo dnf upgrade
```

## Install nginx

### Ubuntu / Debian

```bash
sudo apt update
sudo apt install nginx

# Start และ enable on boot
sudo systemctl enable --now nginx

# ตรวจสอบ status
systemctl status nginx
```

### CentOS / RHEL / Fedora

```bash
sudo yum install nginx   # หรือ: sudo dnf install nginx

# Start และ enable on boot
sudo systemctl enable --now nginx

# ตรวจสอบ status
systemctl status nginx
```

## Remove nginx

### Ubuntu / Debian

```bash
# ลบ nginx แต่เก็บ config ไว้
sudo apt remove nginx

# ลบ nginx พร้อม config
sudo apt purge nginx nginx-common

# ลบ unused packages
sudo apt autoremove
```

### CentOS / RHEL / Fedora

```bash
sudo yum remove nginx    # หรือ: sudo dnf remove nginx
```