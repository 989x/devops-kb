---
title: OpenSSH Upgrade — sshd_config Conflict
tags: [openssh, openlandscape, troubleshooting]
type: troubleshooting
status: stable
created: 2026-05-13
---

# OpenSSH Upgrade — sshd_config Conflict

**Date:** 2026-05-13
**Host:** DTAM-E-service-CHM-Proxy01
**Package:** `openssh-server 1:9.6p1-3ubuntu13.16`
**OS:** Ubuntu (linux-modules 6.8.0-11)

---

## Background

รับเครื่องมาจากทีม **Cloud INET** แล้วพบปัญหานี้ระหว่างทำ `apt upgrade`
เนื่องจากเครื่องมีการ custom `/etc/ssh/sshd_config` ไว้ก่อนหน้าแล้ว

---

## Symptom

ระหว่าง `apt upgrade` ระบบหยุดรอ interactive prompt จาก `debconf`
เพื่อถามวิธีจัดการไฟล์ `/etc/ssh/sshd_config` ที่ถูก modify ไว้ก่อนหน้า

### Raw Log จาก Server

```
Setting up linux-modules-6.8.0-11-generic (6.8.0-111.111) ...
Setting up linux-headers-6.8.0-11-generic (6.8.0-111.111) ...
Setting up openssh-sftp-server (1:9.6p1-3ubuntu13.16) ...
Setting up vim (2:9.1.0016-1ubuntu7.13) ...
Setting up openssh-server (1:9.6p1-3ubuntu13.16) ...
debconf: unable to initialize frontend: Dialog
debconf: (Dialog frontend requires a screen at least 13 lines tall and 31 columns wide.)
debconf: falling back to frontend: Readline
Configuring openssh-server
------------------------------

A new version (/tmp/tmp.oG15DEQ2B5) of configuration
[More]

file /etc/ssh/sshd_config is available, but the version
installed currently has been locally modified.

  1. install the package maintainer's version
[More]

  2. keep the local version currently installed
  3. show the differences between the versions
  4. show a side-by-side difference between the versions
  5. show a 3-way difference between available versions
[More]

  6. do a 3-way merge between available versions
  7. start a new shell to examine the situation

What do you want to do about modified configuration file sshd_config?

What do you want to do about modified configuration file sshd_config?
```

> **หมายเหตุ:** `debconf: unable to initialize frontend: Dialog` เป็น warning ปกติ
> terminal ขนาดเล็กเกินไปสำหรับ UI แบบ Dialog ระบบ fallback ไปใช้ Readline แทน ทำงานได้ปกติ

---

## Root Cause

`/etc/ssh/sshd_config` มีการแก้ไขจาก default ไว้ก่อนหน้า
เมื่อ package version ใหม่มี sshd_config ที่แตกต่างจาก local ระบบจึง prompt ให้เลือก

---

## ตัวเลือกและคำอธิบาย

| ตัวเลือก | คำอธิบาย | เหมาะกับสถานการณ์ |
|---|---|---|
| `1` install maintainer's version | ใช้ config ของ package ใหม่ ทับ local ทั้งหมด | เครื่องใหม่ / ยังไม่มี custom config |
| `2` keep local version | เก็บ config เดิมที่แก้ไขไว้ ไม่เปลี่ยนแปลง | เครื่องที่มี custom config อยู่แล้ว |
| `3` show differences | แสดง diff แบบ unified (บรรทัดต่อบรรทัด) | ต้องการดูว่า config ต่างกันตรงไหน |
| `4` side-by-side diff | แสดง diff แบบ 2 คอลัมน์เปรียบเทียบ | อ่าน diff ได้ง่ายกว่า option 3 |
| `5` 3-way diff | แสดงความต่างระหว่าง 3 เวอร์ชัน (old/local/new) | ต้องการเห็นภาพรวมทุก version |
| `6` 3-way merge | รวม config ทั้ง 3 เวอร์ชันเข้าหากัน | ต้องการเอา feature ใหม่ + เก็บ custom ไว้ด้วย |
| `7` new shell | เปิด shell ใหม่เพื่อตรวจสอบเองก่อนตัดสินใจ | ต้องการดูรายละเอียดเพิ่มเติมก่อน |

---

## Verification หลังเลือก

```bash
# ตรวจสอบ syntax ของ sshd_config
sudo sshd -t

# ดู config ที่ active อยู่
sudo sshd -T | grep -E "port|passwordauthentication|permitrootlogin"

# restart service ถ้าจำเป็น
sudo systemctl restart ssh
sudo systemctl status ssh
```

---

## Related Files

| File | Description |
|---|---|
| `/etc/ssh/sshd_config` | SSH server configuration |

---

## Tags

`openssh` `sshd_config` `apt-upgrade` `debconf` `config-conflict` `chm-proxy01` `cloud-inet`