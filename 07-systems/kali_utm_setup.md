---
title: "Installing Kali Linux on UTM (Apple Silicon)"
tags:
  - kali_linux
  - utm
  - apple_silicon
  - virtualization
  - vm
type: guide
status: stable
created: 2026-04-22
updated: 2026-05-02
related:
  - "[[_index]]"
---
# Installing Kali Linux on UTM (Apple Silicon)

## Overview

```
[1. Create VM] → [2. Configure Hardware] → [3. Add Serial Device]
      ↓
[4. Boot & Install]
      ├── [4.1 Language & Locale]
      ├── [4.2 Keyboard]
      ├── [4.3 Network]
      ├── [4.4 Users & Passwords]
      ├── [4.5 Partition Disks]
      ├── [4.6 Software Selection]
      └── [4.7 Finish the Installation]
            ↓
      [5. First Login]
```

---

## Prerequisites

- Mac ที่ใช้ Apple Silicon (M1/M2/M3)
- ติดตั้ง [UTM](https://mac.getutm.app/) ไว้แล้ว
- ดาวน์โหลด `kali-linux-2026.1-installer-arm64.iso` เรียบร้อยแล้ว

---

## Step 1: Create a New VM in UTM

เปิด UTM แล้วคลิก **+** ที่ toolbar ด้านบนซ้าย

```
┌─────────────────────┐
│  ▶ Virtualize       │  ← เลือกอันนี้ (เร็วกว่า รองรับ ARM64 native)
│    Emulate          │
└─────────────────────┘
```

เลือก **Linux** เป็น operating system จากนั้น:

1. ปล่อย **Use Apple Virtualization** ไว้ไม่ติ๊ก (ใช้ QEMU ซึ่งแนะนำกว่า)
2. ตั้ง **Boot Image Type** → **Boot from ISO image**
3. คลิก **Browse…** แล้วเลือกไฟล์ `kali-linux-2026.1-installer-arm64.iso`
4. คลิก **Continue**

---

## Step 2: Configure Hardware

```
Memory:    [————●————————]  4096  MiB
CPU Cores:                     4
```

|Field|Value|
|---|---|
|Memory|4096 MiB|
|CPU Cores|4|
|Enable display output|✅ ติ๊กไว้|
|Enable hardware OpenGL accel.|☐ ไม่ต้องติ๊ก|

> **หมายเหตุ:** ไม่ต้องเปิด OpenGL เพราะมี bug กับ Linux driver รุ่นใหม่ อาจทำให้หน้าจอดำหรือแสดงผลผิดพลาดได้

คลิก **Continue** → ตั้ง Storage เป็น **32 GiB** → คลิก **Continue**

ข้ามหน้า **Shared Directory** ได้เลย (คลิก **Continue**)

ที่หน้า **Summary**:

- ตั้งชื่อ Name: `Kali Linux`
- ติ๊ก **Open VM Settings**
- คลิก **Save**

---

## Step 3: Add Serial Device (Required)

ถ้าไม่เพิ่ม Serial Device VM จะค้างที่ข้อความนี้และไม่ boot ต่อ:

```
[ 0.016684] PCI: OF: of_root node is NULL, cannot create PCI host bridge node
```

ใน VM Settings ให้ไปที่ **Devices → New…** แล้วเลือก **Serial**

```
Connection
  Mode:    Built-in Terminal
  Target:  Automatic Serial Device (max 4)
```

คลิก **Save**

---

## Step 4: Boot & Install Kali

คลิกปุ่ม **▶ Play** เพื่อเริ่ม VM จะเห็นหน้าต่างเปิดขึ้น 2 หน้าต่าง:

```
┌─────────────────────────────────────────┐
│  Kali Linux          (Display window)   │  ← ใช้งานหน้าต่างนี้
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  Kali Linux (Terminal 1)                │  ← kernel messages เท่านั้น
└─────────────────────────────────────────┘
```

> **สำคัญ:** ให้ทำงานกับหน้าต่าง **Display** ตลอดการติดตั้ง — ใช้ mouse และ keyboard ได้เต็มรูปแบบ หน้าต่าง Terminal 1 แสดงแค่ kernel messages ไม่ใช่ตัว installer

คลิกที่หน้าต่าง **Display** แล้วจะเห็น GRUB menu ให้กด ↓ หนึ่งครั้งเพื่อเลื่อนไป **Graphical install**:

```
  Install
▶ Graphical install            ← เลือกอันนี้
  Advanced options ...
  Accessible dark contrast installer menu ...
  Install with speech synthesis
```

กด **Enter**

---

### 4.1 Language & Locale

เลือกภาษาที่ใช้ตลอดการติดตั้งและระบบ:

```
[!!] Select a language

  C        – No localization
▶ English  – English           ← เลือก
```

เลือก location เพื่อตั้ง timezone:

```
[!!] Select your location

▶ United States                ← เลือกอันนี้เสมอ
```

> **ทำไมต้องเลือก United States?**
> การเลือก Thailand จะทำให้ระบบ generate `th_TH` locale มาโดยอัตโนมัติ ส่งผลให้ system UI เช่น desktop และ terminal แสดงผลเป็นภาษาไทย การเลือก United States การันตีว่า locale จะเป็น `en_US.UTF-8` ตั้งแต่แรก — timezone เปลี่ยนทีหลังได้ง่ายกว่า
>
> **หมายเหตุ:** Firefox ที่แสดง Google เป็นภาษาไทยเป็นคนละเรื่องกับ locale — Google ดูจาก IP address ของ network ซึ่ง VM รับมาจาก Mac ที่อยู่ในไทย ไม่มีการตั้งค่าใน VM ที่แก้ได้ วิธีแก้คือตั้ง language preference ใน Google account หรือใช้ VPN

จากนั้นจะมีหน้าเลือก timezone ของ United States ขึ้นมา:

```
[!] Configure the clock — Select your time zone:

▶ Eastern                      ← เลือกอันนี้ (เปลี่ยนทีหลังได้)
  Central
  Mountain
  Pacific
  ...
```

---

### 4.2 Keyboard

เลือก keymap ที่ต้องการใช้:

**ค่าเริ่มต้น (แนะนำ):**

```
[!!] Configure the keyboard — Keymap to use:

▶ American English             ← เลือก (อยู่บนสุดของ list)
```

**ถ้าต้องการใช้ภาษาไทยด้วย:**

```
  ...
  Tamil
  Telugu
▶ Thai                         ← เลือก (หรือ keymap ของคุณ)
  Tibetan
  ...
```

จากนั้นเลือก key ที่ใช้สลับระหว่าง Thai กับ Latin:

```
[!] Configure the keyboard — Method for toggling:

  Caps Lock
  Right Alt (AltGr)
  ...
▶ Left Alt+Left Shift          ← เลือก
  Alt+Shift
  ...
```

---

### 4.3 Network

ตั้งชื่อเครื่องใน network:

```
[!] Configure the network — Hostname:

  [ kali_______________ ]      ← พิมพ์ hostname ที่ต้องการ เช่น kali
```

**Domain name:**

```
[!] Configure the network — Domain name:

  [ ___________________ ]      ← ปล่อยว่างไว้ได้เลย
```

> **Domain name คืออะไร?**
> Hostname คือชื่อของเครื่องนั้นๆ (เช่น `kali`) ส่วน Domain name คือชื่อกลุ่มของเครื่องหลายๆ ตัวในเครือข่ายเดียวกัน (เช่น `office.local`) ใช้ในองค์กรที่มีเครื่องหลายเครื่อง ถ้ารวมกันจะได้ชื่อเต็ม เช่น `kali.office.local`
> สำหรับ VM ส่วนตัว — **ปล่อยว่างไว้ได้เลย**

---

### 4.4 Users & Passwords

**Full name** คือชื่อแสดงผลใน UI และ login screen ใส่ได้อิสระ รวมถึงภาษาไทย ช่องว่าง หรือตัวพิมพ์ใหญ่

**Username** คือชื่อที่ใช้ login จริง ใช้ใน terminal และ `sudo` ต้องเป็นตัวพิมพ์เล็ก ไม่มีช่องว่าง

```
[!!] Set up users and passwords — Full name:

  [ John Doe___________ ]      ← ชื่อแสดงผล เช่น John Doe

[!!] Set up users and passwords — Username:

  [ johndoe____________ ]      ← ชื่อ login เช่น johndoe
```

กรอก password และยืนยัน password อีกครั้ง

---

### 4.5 Partition Disks

เลือกวิธีแบ่ง partition:

```
[!!] Partition disks — Partitioning method:

▶ Guided – use entire disk              ← เลือก (ง่ายที่สุด)
  Guided – use entire disk and set up LVM
  Guided – use entire disk and set up encrypted LVM
  Manual
```

เลือก virtual disk ที่จะติดตั้ง:

```
▶ Virtual disk 1 (vda) – 34.4 GB Virtio Block Device   ← เลือก
```

เลือกรูปแบบการแบ่ง partition:

```
▶ All files in one partition (recommended for new users)  ← เลือก
  Separate /home partition
  Separate /home, /var, and /tmp partitions
  ...
```

ตรวจสอบ layout แล้วเลือก finish:

```
  > #1   16.8 MB
  > #2    1.0 GB   f  ESP
  > #3   31.5 GB   f  ext4   /
  > #4    1.8 GB   f  swap   swap

▶ Finish partitioning and write changes to disk           ← เลือก
```

ยืนยันการเขียนข้อมูลลง disk:

```
Write the changes to disks?

▶ <Yes>        <No>                                       ← เลือก Yes
```

---

### 4.6 Software Selection

เลือก desktop environment และ tools ที่ต้องการติดตั้ง:

```
[!] Software selection — Choose software to install:

  [*] Desktop environment
  [*] ... Xfce (Kali's default desktop environment)      ← ค่า default
  [ ] ... GNOME
  [ ] ... KDE Plasma
  [*] Collection of tools
  [*] ... top10 — the 10 most popular tools              ← ค่า default
```

ใช้ค่า default ได้เลย แล้วคลิก **Continue** รอการติดตั้งสักครู่

---

### 4.7 Finish the Installation

เมื่อติดตั้งเสร็จสมบูรณ์ installer จะแจ้งให้ reboot:

```
[!!] Finish the installation

  Installation complete

  Installation is complete, so it is time to boot into
  your new system. Make sure to remove the installation
  media, so that you boot into the new system rather
  than restarting the installation.

  Please choose <Continue> to reboot.

  <Go Back>                          ▶ <Continue>   ← เลือก
```

**ก่อนกด Continue** ให้ถอด ISO ออกจาก UTM ก่อน มิฉะนั้น VM จะ boot กลับเข้า installer อีกครั้ง

ไปที่หน้าต่าง UTM หลัก → คลิก dropdown **CD/DVD** → เลือก **Clear**

```
  ┌─────────────────────────────┐
  │ CD/DVD                      │
  ├─────────────────────────────┤
  │   Browse...                 │
  │ ▶ Clear                     │  ← เลือก
  └─────────────────────────────┘
```

จากนั้นกลับไปที่หน้าต่าง Terminal แล้วกด **Continue** เพื่อ reboot

---

## Step 5: First Login

หลังติดตั้งเสร็จและ VM reboot หน้าจอ login ของ Kali จะปรากฏขึ้น:

```
  ┌──────────────────────┐
  │  [Kali logo]         │
  │                      │
  │  Username: johndoe   │
  │  Password: ••••••••  │
  │                      │
  │  [Cancel]  [Log In]  │
  └──────────────────────┘
```

กรอก username และ password แล้วคลิก **Log In**

---

## Troubleshooting

### VM ค้างหลัง boot ไม่ขึ้น installer

```
[ 0.016684] PCI: OF: of_root node is NULL, cannot create PCI host bridge node
```

**สาเหตุ:** ข้อความนี้เป็น kernel message ปกติใน Terminal 1 ไม่ใช่ error — GRUB menu และ installer จะขึ้นใน **Display window** ไม่ใช่ Terminal 1

**แก้ไข:** มองหาหน้าต่าง Display และคลิกที่หน้าต่างนั้น ถ้าไม่เห็น ให้ตรวจสอบว่าได้เพิ่ม Serial Device ตาม Step 3 แล้วหรือยัง

---

### หน้าจอดำหรือแสดงผลผิดพลาดหลัง boot

**สาเหตุ:** เปิด Hardware OpenGL Acceleration ไว้

**แก้ไข:** ไปที่ VM Settings → **Display** → ปิด **Hardware OpenGL Acceleration**

---

### VM boot กลับเข้า installer หลัง reboot

**สาเหตุ:** ยังไม่ได้ถอด ISO ออกก่อน reboot

**แก้ไข:** หยุด VM → ไปที่ **CD/DVD → Clear** → start VM ใหม่

---

## References

- [How to Install Kali Linux on UTM (Apple Silicon)](https://www.youtube.com/watch?v=bcaF1OSivYI) — ProgrammingKnowledge
- [UTM for Mac](https://mac.getutm.app/)