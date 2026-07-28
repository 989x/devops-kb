---
title: "Windows Remote Desktop Setup"
tags: [windows, rdp, remote-desktop, firewall]
type: guide
status: stable
created: 2026-05-03
related: []
---

# Windows Remote Desktop Setup

คู่มือการเปิดใช้งาน Remote Desktop บน Windows Server เพื่อให้สามารถ remote เข้าใช้งานได้จากภายนอก

## Prerequisites

- เข้าถึง Windows Server ได้โดยตรง (console หรือ KVM)
- มี user ที่มีสิทธิ์ Administrator
- รู้จัก IP ของ server

## Steps

### 1. ตรวจสอบ / เปลี่ยน Password

ดู password ปัจจุบัน

```cmd
net user <SERVER_USER> *
```

กำหนด password ใหม่

```cmd
net user <SERVER_USER> <YOUR_PASSWORD>
```

---

### 2. Enable Remote Desktop

เปิด **Server Manager → Local Server** แล้วคลิกที่ Remote Desktop เพื่อเปลี่ยนเป็น Enabled

![Server Manager Local Server Properties](assets/windowsserver/rdp/server_manager_local_server_properties.webp)

หรือเปิดผ่าน **Settings → System → Remote Desktop** แล้ว toggle เป็น On

![Windows Settings Remote Desktop Enable](assets/windowsserver/rdp/settings_remote_desktop_enable.webp)

---

### 3. Disable Windows Firewall

วิธีปิด Firewall ผ่าน PowerShell (run as Administrator)

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

> ⚠️ ใช้ `-Enabled` (ไม่ใช่ `-Enable`) — ดู Troubleshooting ด้านล่าง

ตรวจสอบผลลัพธ์ผ่าน **Windows Defender Firewall with Advanced Security**

![Firewall Advanced Security All Profiles Off](assets/windowsserver/rdp/firewall_advanced_security_all_profiles.webp)

---

### 4. เปลี่ยน RDP Port (ถ้าจำเป็น)

Port default ของ RDP คือ **3389** หากต้องการเปลี่ยนให้เปิด Registry Editor แล้วไปที่

```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp
```

> **Registry Path อธิบาย**
> - `SYSTEM\CurrentControlSet` — config ที่ Windows ใช้งานอยู่จริง
> - `Control\Terminal Server` — settings ของ Remote Desktop ทั้งหมด
> - `WinStations\RDP-Tcp` — listener หลักที่รับ RDP connection ผ่าน TCP
>
> ⚠️ Windows Server ไม่มี GUI สำหรับเปลี่ยน RDP port — ต้องแก้ผ่าน Registry เท่านั้น

แก้ค่า `PortNumber` เป็น port ที่ต้องการ (เช่น 18888)

![Registry RDP Port Number](assets/windowsserver/rdp/registry_rdp_port_number.webp)

จากนั้น restart service

```cmd
net stop TermService /y
net start TermService /y
```

---

## Troubleshooting

### `-Enable` parameter ambiguous error

**Error**

```
Set-NetFirewallProfile : Parameter cannot be processed because the parameter name 'Enable' is ambiguous.
Possible matches include: -Enabled -EnableStealthModeForIPsec.
At line:1 char:55
+ Set-NetFirewallProfile -Profile DOmain,Public,Private -Enable False
```

**สาเหตุ** — พิมพ์ `-Enable` แทน `-Enabled`

**แก้ไข** — ใช้ parameter ที่ถูกต้อง

```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
```

![PowerShell Firewall Disable Output](assets/windowsserver/rdp/powershell_firewall_disable_output.webp)

---

## References

- [How to Remote Desktop from Mac to Windows (YouTube)](https://www.youtube.com/watch?v=2be2bYJwxOw)
- [วิธีปิด Firewall บน Windows — hostatom.com](https://kb.hostatom.com/content/6384)
- [การเปลี่ยน Port สำหรับ Remote Desktop บน Windows Server — porar.com](https://www.porar.com/viewblog-32.html)