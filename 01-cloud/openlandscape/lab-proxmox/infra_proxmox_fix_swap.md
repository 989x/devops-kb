---
title: "Fix / Restore Swap on VM"
tags: [proxmox, vm, swap, fstab]
type: guide
status: stable
created: 2026-04-26
related:
---

# Fix / Restore Swap on VM

ใช้เมื่อ swap ถูกปิดหรือลบออกไป เช่น หลังรัน `swapoff -a`, ลบ `/swap.img`, หรือแก้ไข `/etc/fstab`

## Prerequisites

- มีสิทธิ์ `sudo` บน node
- disk มีพื้นที่เพียงพอสำหรับ swap file ที่ต้องการสร้าง

## Steps

### Step 1: Verify Current Swap Status

```bash
free -h
```

### Step 2: Create New Swap File

ตัวอย่าง: สร้าง swap ขนาด 4GB

```bash
sudo fallocate -l 4G /swap.img
sudo chmod 600 /swap.img
sudo mkswap /swap.img
sudo swapon /swap.img
```

### Step 3: Verify Swap is Active

```bash
free -h
```

### Step 4: Make Swap Persistent After Reboot

เปิดไฟล์ `/etc/fstab`:

```bash
sudo vi /etc/fstab
```

เพิ่มบรรทัดนี้ที่ท้ายไฟล์:

```
/swap.img none swap sw 0 0
```

### Step 5: Validate fstab

```bash
sudo mount -a
free -h
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `fallocate` fail | disk เต็ม | ตรวจ `df -h` ก่อนสร้าง swap |
| swap หายหลัง reboot | ยังไม่ได้เพิ่มใน fstab | ตรวจ `/etc/fstab` ว่ามี `/swap.img` entry แล้วหรือยัง |
| `mount -a` error | syntax ใน fstab ผิด | ตรวจ whitespace และ format ของ entry ให้ถูกต้อง |

## References

- [Ubuntu swap management](https://help.ubuntu.com/community/SwapFaq)
