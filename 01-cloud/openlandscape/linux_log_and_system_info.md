# linux-log-and-system-info.md

## System Time

### Check the current system time

```bash
date
# Example output:
# Mon Nov 10 22:15:42 +07 2025
```

Show detailed time settings (timezone, NTP status):

```bash
timedatectl
```

Set timezone (example: Bangkok):

```bash
sudo timedatectl set-timezone Asia/Bangkok
```

## Resource Usage (CPU / RAM / Disk)

### CPU Usage

View current CPU load and processes:

```bash
top
# In top:
#   - Press P to sort by CPU
#   - Press M to sort by memory
```

Load averages:

```bash
uptime
# Example output:
# 14:32:10 up 10 days,  2:15,  2 users,  load average: 0.35, 0.40, 0.25
```

### RAM Usage

Quick summary:

```bash
free -h
# Example output:
#               total        used        free      shared  buff/cache   available
# Mem:           15Gi       4.0Gi       2.0Gi       512Mi       9.0Gi        10Gi
# Swap:         2.0Gi       0.0Gi       2.0Gi
```

### Disk Usage

View mounted filesystems:

```bash
df -h
```

Check root filesystem:

```bash
df -h /
```

Check directory usage (example: `/var`):

```bash
sudo du -sh /var/*
```

View block devices and partitions:

```bash
lsblk
```

## Processes & Ports

### Check listening network ports

Show all listening TCP/UDP ports + processes:

```bash
sudo lsof -i -P -n | grep LISTEN
# Example output:
# docker-pr  49318  root  7u  IPv4  97971  0t0  TCP *:80 (LISTEN)
# docker-pr  49324  root  7u  IPv6  97972  0t0  TCP *:80 (LISTEN)
# docker-pr  49339  root  7u  IPv4  97132  0t0  TCP *:443 (LISTEN)
# docker-pr  49345  root  7u  IPv6  97133  0t0  TCP *:443 (LISTEN)
```

### Terminate processes

#### Kill process by port using `fuser`

Terminate all processes using a port:

```bash
sudo fuser -k 8888/tcp
```

Check processes that use the port:

```bash
sudo fuser -v 8888/tcp
```

#### Kill a process by PID

List processes:

```bash
ps -a
```

Search by name:

```bash
ps -a | grep "<process-name>"
```

Kill:

```bash
kill <PID>
sudo kill <PID>
```

## SSH Logs & Authentication

### Ubuntu / Debian

Live view:

```bash
sudo tail -f /var/log/auth.log
```

Filter for SSH:

```bash
sudo grep sshd /var/log/auth.log
```

### CentOS / RHEL

Live view:

```bash
sudo tail -f /var/log/secure
```

Filter SSH:

```bash
sudo grep sshd /var/log/secure
```

### Using `journalctl` (systemd)

View logs:

```bash
sudo journalctl -u ssh
# or
sudo journalctl -u sshd
```

Follow real-time:

```bash
sudo journalctl -u ssh -f
```