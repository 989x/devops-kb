---
title: "Extend Root Filesystem After VM Disk Resize"
tags: [proxmox, vm, disk, filesystem, ext4, growpart]
type: guide
status: stable
created: 2026-04-26
related:
---

# Extend Root Filesystem After VM Disk Resize

หลังจากขยาย VM disk size ใน Proxmox แล้ว `df -h /` อาจยังแสดงขนาดเดิม เพราะ disk โตขึ้นแต่ root partition และ filesystem ยังไม่ถูกขยาย

## Prerequisites

- Ubuntu VM บน Proxmox ที่เพิ่ง resize disk แล้ว
- Root filesystem เป็น `ext4` บน `/dev/sda1`
- มีสิทธิ์ `sudo` บน node

## Steps

### Step 1: Verify Current State

```bash
lsblk
df -h /
lsblk -f
```

### Step 2: Install growpart

```bash
sudo apt update
sudo apt install -y cloud-guest-utils
```

### Step 3: Expand Root Partition

```bash
sudo growpart /dev/sda 1
```

### Step 4: Expand ext4 Filesystem

```bash
sudo resize2fs /dev/sda1
```

### Step 5: Confirm Result

```bash
lsblk
df -h /
```

## Example Logs

### Example A: Disk เป็น 50G แต่ `/` ยังแสดง ~9G

```bash
ubuntu@<MASTER_01_HOSTNAME>:~$ df -h
Filesystem    Size    Used   Avail   Use%   Mounted on
tmpfs         392M    3.3M    389M     1%   /run
/dev/sda1     8.7G    5.1G    3.6G    59%   /
tmpfs         2.0G       0    2.0G     0%   /dev/shm
tmpfs         5.0M       0    5.0M     0%   /run/lock
/dev/sda16    881M    117M    703M    15%   /boot
/dev/sda15    105M    6.2M     99M     6%   /boot/efi
tmpfs         392M     12K    392M     1%   /run/user/1000
```

```bash
ubuntu@<MASTER_01_HOSTNAME>:~$ df -h /
Filesystem   Size  Used Avail Use% Mounted on
/dev/sda1    8.7G  5.1G  3.6G  59% /
```

### Example B: Root เป็น ext4 บน /dev/sda1

```bash
ubuntu@<LB_HOSTNAME>:~$ sudo su
root@<LB_HOSTNAME>:/home/ubuntu# lsblk -f
NAME      FSTYPE    FSVER   LABEL            UUID         FSAVAIL  FSUSE%  MOUNTPOINTS
sda
├─sda1    ext4      1.0     cloudimg-rootfs  123a-b123    5.4G      37%    /
├─sda14
├─sda15   vfat      FAT32   UEFI             456b-c456    98.2M      6%    /boot/efi
└─sda16   ext4      1.0     BOOT             789c-d789    702.4M    13%    /boot
sr0       iso9660           cidata           2026-01-19   -
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `growpart` ไม่สามารถขยาย `/dev/sda1` ได้ | partition table มีปัญหา | รัน `sudo fdisk -l /dev/sda` เพื่อตรวจ partition table ก่อน |
| `resize2fs` fail | filesystem ไม่ใช่ ext4 | ตรวจด้วย `lsblk -f` ว่า FSTYPE เป็นอะไร |

## References

- [cloud-guest-utils (growpart)](https://manpages.ubuntu.com/manpages/focal/man1/growpart.1.html)
- [resize2fs man page](https://manpages.ubuntu.com/manpages/focal/man8/resize2fs.8.html)
