---
title: Linux Network Basics
tags: [linux, openlandscape, network]
type: guide
status: stable
created: 2026-04-26
---

# Linux Network Basics

## Check IP Address

```bash
# แสดง network interfaces และ IP ทั้งหมด
ip addr

# แสดงเฉพาะ IPv4
hostname -I
```

> ระบบเก่าอาจใช้ `ifconfig` แทน

## DNS & Host Configuration

### ดู DNS ที่ใช้งานอยู่

```bash
cat /etc/resolv.conf
# Example output:
# nameserver 127.0.0.53
# options edns0 trust-ad
```

### Map hosts (/etc/hosts)

```bash
sudo vi /etc/hosts
# Example entries:
# 127.0.1.1 lab-poc-nfs lab-poc-nfs
# 127.0.0.1 localhost
```

### ตั้ง hostname

```bash
# ดู hostname ปัจจุบัน
hostname
# Example output:
# lab-poc-nfs

# เปลี่ยน hostname
sudo hostnamectl set-hostname myserver
# อาจต้อง re-login หรือ reboot เพื่อให้มีผลทุกที่
```

## DNS & Network Diagnostics

### dig

```bash
dig example.com

# Short output
dig +short example.com

# MX record
dig MX example.com
```

### nslookup

```bash
nslookup example.com

# ระบุ DNS server
nslookup example.com 8.8.8.8
```

### host

```bash
host example.com

# เฉพาะ A record
host -t A example.com
```

### Traceroute

```bash
# ติดตั้ง (Ubuntu/Debian)
sudo apt install traceroute

# รัน
traceroute example.com

# ทางเลือกที่ไม่ต้องติดตั้ง
tracepath example.com
# Example output:
#  1?: [LOCALHOST]                      pmtu 1500
#  1:  _gateway                                              0.257ms
#  1:  _gateway                                              0.223ms
#  2:  103.138.176.254                                       0.802ms asymm  3
#  3:  203-154-129-169.inter.inet.co.th                      0.830ms asymm  4
#  4:  203-150-215-110.inter.net.th                          1.077ms asymm  5
```

## Change SSH Port

```bash
# แก้ไข SSH config
sudo vi /etc/ssh/sshd_config
# เปลี่ยนจาก:
#   #Port 22
# เป็น:
#   Port 2222

# Restart SSH
sudo systemctl restart sshd
# หรือ (Ubuntu/Debian)
sudo systemctl restart ssh

# เปิด firewall (UFW)
sudo ufw allow 2222/tcp

# Connect ด้วย port ใหม่
ssh -p 2222 user@<SERVER_IP>
```

## Test Port Connectivity (telnet)

```bash
# ติดตั้ง
sudo apt install telnet    # Ubuntu / Debian
sudo yum install telnet    # CentOS / RHEL

# ทดสอบ
telnet 103.138.176.223 80
# Example output:
# Trying 103.138.176.223...
# Connected to 103.138.176.223.
```

| Result | ความหมาย |
|--------|---------|
| Connected | Port เปิดอยู่ |
| Connection refused | Service ไม่ได้ listen |
| Timed out | Firewall หรือ routing issue |