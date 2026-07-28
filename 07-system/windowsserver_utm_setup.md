---
title: "Installing Windows Server on UTM (Apple Silicon)"
tags:
  - windows_server
  - utm
  - apple_silicon
  - virtualization
  - vm
type: guide
status: stable
created: 2026-04-23
related:
  - "[[_index]]"
  - "[[vm_kali_utm_setup]]"
---

# Installing Windows Server on UTM (Apple Silicon)

## Overview

```
[1. Download ISO] → [2. Create VM] → [3. Configure Hardware]
                                             ↓
                                    [4. Boot & Install]
                                      ├── [4.1 Keyboard Layout]
                                      ├── [4.2 Install Now]
                                      ├── [4.3 Select Edition]
                                      ├── [4.4 License & Partition]
                                      └── [4.5 Set Administrator Password]
                                             ↓
                                    [5. Install UTM Guest Tools]
                                             ↓
                                    [6. First Login]
```

---

## Prerequisites

- Mac ที่ใช้ Apple Silicon (M1/M2/M3/M4)
- ติดตั้ง [UTM](https://mac.getutm.app/) ไว้แล้ว
- ดาวน์โหลดไฟล์ ISO ของ Windows Server ARM64 เรียบร้อยแล้ว

---

## Step 1: Download ISO

ดาวน์โหลดไฟล์ ISO จากแหล่งใดแหล่งหนึ่งต่อไปนี้:

**แหล่งที่ 1 — Microsoft Evaluation Center (แนะนำ)**
- ไปที่ [microsoft.com/evalcenter](https://www.microsoft.com/evalcenter)
- เลือก **Windows Server 2022**
- เลือก **ISO** แล้วกรอกข้อมูลเพื่อดาวน์โหลด (ฟรี 180 วัน)

> ⚠️ ณ ปัจจุบัน Microsoft Evaluation Center ยังไม่มี ISO สำหรับ ARM64 โดยตรง ให้ใช้แหล่งที่ 2 แทน

**แหล่งที่ 2 — Pre-release ARM64 ISO (สำหรับทดสอบ)**
- ดาวน์โหลดได้จาก [Reddit - Windows Insiders](https://www.reddit.com/r/windowsinsiders/comments/1pk9ifs/windows_server_2025_or_2024_arm64_vhdxiso_for/)
- หรือจาก [Archive.org](https://archive.org/details/26404.5000.250426-1100.-ge-prerelease-serverstandard-oemret-a-64-fre-en-us)

> ⚠️ ไฟล์จากแหล่งที่ 2 เป็น **Pre-release build** ควรใช้เพื่อทดสอบใน VM เท่านั้น ไม่เหมาะกับงาน Production

---

## Step 2: Create a New VM in UTM

เปิด UTM แล้วคลิก **+** ที่ toolbar ด้านบนซ้าย

```
┌─────────────────────┐
│  ▶ Virtualize       │  ← เลือกอันนี้
│    Emulate          │
└─────────────────────┘
```

เลือก **Windows** จากนั้น:

1. ติ๊ก **Install Windows 10 or higher**
2. คลิก **Browse…** แล้วเลือกไฟล์ ISO ที่ดาวน์โหลดมา
3. ติ๊ก **Install drivers and SPICE tools**
4. คลิก **Continue**

> **หมายเหตุ:** การติ๊ก Install drivers and SPICE tools จะทำให้ resolution ปรับอัตโนมัติและใช้ copy-paste ระหว่าง Mac กับ VM ได้

---

## Step 3: Configure Hardware

```
Memory:    [————●————————]  4096  MiB   (แนะนำ 4096 ขึ้นไป)
CPU Cores:                     4
Storage:                      64  GiB
```

| Field | Value |
|---|---|
| Memory | 4096 MiB ขึ้นไป |
| CPU Cores | 4 |
| Storage | 64 GiB ขึ้นไป |

คลิก **Continue** → **Save**

**ตรวจสอบ NVMe Drive ก่อนรัน VM:**

1. คลิกขวาที่ VM → **Edit**
2. ไปที่ **Drives → NVMe Drive**
3. กด **Resize…** แล้วใส่ **64** GiB → กด **Resize**
4. **Save**

---

## Step 4: Boot & Install Windows Server

คลิกปุ่ม **▶ Play** เพื่อเริ่ม VM

> ⚠️ **สำคัญ:** คลิกที่หน้าจอ VM ทันที แล้วกดปุ่มใดก็ได้เมื่อเห็น:

```
Press any key to boot from CD or DVD......
```

---

### 4.1 Keyboard Layout

เลือก keyboard layout ที่ต้องการ:

```
▶ US                          ← แนะนำ (เพื่อพิมพ์ password ได้ง่าย)
  Thai Kedmanee
  Thai Pattachote
```

> ⚠️ แนะนำให้เลือก **US** ก่อน เพื่อหลีกเลี่ยงปัญหาพิมพ์ password ไม่ได้ในขั้นตอนถัดไป สามารถเพิ่มภาษาไทยได้ภายหลังใน Windows Settings

---

### 4.2 Install Now

```
┌──────────────────────────────┐
│  Windows Server Setup        │
│                              │
│  ▶ Install now               │
│    Repair your computer      │
└──────────────────────────────┘
```

คลิก **Install now**

---

### 4.3 Select Edition

เลือก edition ที่ต้องการ:

```
  Windows Server 2022 Standard
▶ Windows Server 2022 Standard (Desktop Experience)   ← แนะนำ (มี GUI)
  Windows Server 2022 Datacenter
  Windows Server 2022 Datacenter (Desktop Experience)
```

> เลือก **Desktop Experience** เพื่อให้มีหน้าจอ GUI ปกติ ไม่เลือกจะได้แค่ Command Line

---

### 4.4 License & Partition

1. ยอมรับ License → ติ๊ก **I accept** → **Next**
2. เลือก **Custom: Install Windows only (advanced)**
3. เลือก drive ที่แสดงขึ้นมา → **Next**
4. รอการติดตั้ง (~15–30 นาที) VM จะ reboot เองหลายครั้ง

---

### 4.5 Set Administrator Password

หลัง reboot จะให้ตั้ง password สำหรับ Administrator:

```
┌─────────────────────────────────┐
│  Customize settings             │
│                                 │
│  User name:  Administrator      │
│  Password:   ____________       │
│  Reenter:    ____________       │
└─────────────────────────────────┘
```

Password ต้องมีอย่างน้อย 3 ใน 4 ข้อนี้:

- ตัวพิมพ์ใหญ่ (A-Z)
- ตัวพิมพ์เล็ก (a-z)
- ตัวเลข (0-9)
- อักขระพิเศษ (!@#$)

ตัวอย่าง: `Admin@1234`

---

## Step 5: Install UTM Guest Tools

หลังเข้า Windows ได้แล้ว ให้ติดตั้ง Guest Tools เพื่อให้ resolution ปรับอัตโนมัติ:

1. เปิด **File Explorer**
2. ไปที่ **This PC** จะเห็น CD Drive ชื่อ **utm-guest-tools**
3. ดับเบิลคลิกเพื่อติดตั้ง
4. รีสตาร์ท VM

หลังติดตั้งเสร็จ ให้ถอด ISO ออก:

ไปที่ UTM → ดู VM info ด้านล่าง → คลิก dropdown **CD/DVD** → เลือก **Clear** ทั้ง 2 ตัว

---

## Step 6: First Login

กด **Ctrl+Alt+Delete** เพื่อ unlock หน้าจอ

ใน UTM บน Mac ให้ไปที่ **Menu bar → VM → Send Ctrl+Alt+Delete**

```
┌──────────────────────┐
│  Administrator       │
│  Password: ••••••••  │
│                      │
│  [→ Sign in]         │
└──────────────────────┘
```

กรอก password แล้วคลิก **Sign in**

---

## Troubleshooting

### พลาดกด "Press any key" แล้วหน้าจอหายไป

**สาเหตุ:** ไม่ได้กดปุ่มทันทีที่ขึ้น prompt ระบบข้าม ISO ไปบูตจาก drive แทน

**แก้ไข:** พิมพ์คำสั่งนี้ใน UEFI Shell ที่ปรากฏขึ้น:

```
FS0:\EFI\BOOT\BOOTAA64.EFI
```

---

### พิมพ์ password ไม่ได้ / ตัวอักษรผิด

**สาเหตุ:** เลือก keyboard layout เป็น Thai ในขั้นตอน 4.1

**แก้ไข:** ตั้ง password ใหม่หลังเข้าระบบได้แล้ว หรือ reinstall และเลือก **US** ใน Step 4.1

---

### Resolution ไม่ปรับอัตโนมัติ / หน้าจอเล็ก

**สาเหตุ:** ยังไม่ได้ติดตั้ง UTM Guest Tools

**แก้ไข:** ทำตาม Step 5 ให้ครบ แล้ว reboot VM

---

### VM reboot กลับเข้า installer ซ้ำ

**สาเหตุ:** ยังไม่ได้ Clear ISO หลังติดตั้งเสร็จ

**แก้ไข:** หยุด VM → ไปที่ **CD/DVD → Clear** ทั้ง 2 ตัว → start VM ใหม่

---

## References

- [Windows Server 2025/2024 ARM64 VHDX/ISO — Reddit r/windowsinsiders](https://www.reddit.com/r/windowsinsiders/comments/1pk9ifs/windows_server_2025_or_2024_arm64_vhdxiso_for/)
- [26404.5000.250426-1100 GE_PRERELEASE SERVERSTANDARD ARM64 — Archive.org](https://archive.org/details/26404.5000.250426-1100.-ge-prerelease-serverstandard-oemret-a-64-fre-en-us)
- [UTM Virtual Machines for Mac](https://mac.getutm.app/)
- [Microsoft Evaluation Center](https://www.microsoft.com/evalcenter)