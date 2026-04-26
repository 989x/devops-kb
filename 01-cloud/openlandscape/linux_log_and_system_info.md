---
title: Linux Log and System Information
tags: [linux, openlandscape, monitoring]
type: guide
status: stable
created: 2026-04-26
---

# Linux Log and System Information

## System Time

```bash
# ดู current time
date
# Example output:
# Mon Nov 10 22:15:42 +07 2025

# ดูรายละเอียด timezone และ NTP status
timedatectl

# ตั้ง timezone (Bangkok)
sudo timedatectl set-timezone Asia/Bangkok
```

## Resource Usage

### CPU

```bash
# ดู CPU load และ processes
top
# ใน top: P = sort by CPU, M = sort by memory

# ดู load averages
uptime
# Example output:
# 14:32:10 up 10 days,  2:15,  2 users,  load average: 0.35, 0.40, 0.25
```

### RAM

```bash
free -h
# Example output:
#               total        used        free      shared  buff/cache   available
# Mem:           15Gi       4.0Gi       2.0Gi       512Mi       9.0Gi        10Gi
# Swap:         2.0Gi       0.0Gi       2.0Gi
```

### Disk

```bash
# ดู mounted filesystems
df -h

# ดู root filesystem
df -h /

# ดู directory usage
sudo du -sh /var/*

# ดู block devices และ partitions
lsblk
```

## Processes & Ports

### ดู listening ports

```bash
sudo lsof -i -P -n | grep LISTEN
# Example output:
# docker-pr  49318  root  7u  IPv4  97971  0t0  TCP *:80 (LISTEN)
# docker-pr  49324  root  7u  IPv6  97972  0t0  TCP *:80 (LISTEN)
# docker-pr  49339  root  7u  IPv4  97132  0t0  TCP *:443 (LISTEN)
# docker-pr  49345  root  7u  IPv6  97133  0t0  TCP *:443 (LISTEN)
```

### Kill process by port

```bash
# ดู process ที่ใช้ port
sudo fuser -v 8888/tcp

# Kill process ที่ใช้ port
sudo fuser -k 8888/tcp
```

### Kill process by PID

```bash
# ดู processes ทั้งหมด
ps -a

# ค้นหาตามชื่อ
ps -a | grep "<process-name>"

# Kill
kill <PID>
sudo kill <PID>
```

## SSH Logs & Authentication

### Ubuntu / Debian

```bash
# Live view
sudo tail -f /var/log/auth.log

# Filter SSH
sudo grep sshd /var/log/auth.log
```

### CentOS / RHEL

```bash
# Live view
sudo tail -f /var/log/secure

# Filter SSH
sudo grep sshd /var/log/secure
```

### journalctl (systemd)

```bash
# ดู logs
sudo journalctl -u ssh
# หรือ
sudo journalctl -u sshd

# Follow real-time
sudo journalctl -u ssh -f
```

## VM Provider Detection

### วิธีที่แนะนำ (ต้องการ sudo)

```bash
sudo dmidecode -s system-manufacturer
sudo dmidecode -s system-product-name
```

| Output | Provider |
|--------|---------|
| `Amazon EC2` | ✅ AWS |
| `Google Compute Engine` | ✅ GCP |
| `Microsoft Corporation` / `Virtual Machine` | ✅ Azure |

### วิธีที่ไม่ต้องใช้ sudo

```bash
cat /sys/class/dmi/id/sys_vendor
cat /sys/class/dmi/id/product_name
```

| sys_vendor / product_name | Meaning |
|--------------------------|---------|
| `QEMU` / `Standard PC (i440FX + PIIX)` | KVM / On-prem / Private cloud |
| `Amazon EC2` | AWS |
| `Google` | GCP |
| `Microsoft Corporation` | Azure |

> On-premise มักแสดง hypervisor ตรงๆ เช่น QEMU/KVM ส่วน public cloud มักซ่อนไว้