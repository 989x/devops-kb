# Prompt: Server Log to Troubleshooting Note

## วิธีใช้

วาง log จาก server แล้วส่งให้ AI แปลงเป็นไฟล์ troubleshooting พร้อม frontmatter สำหรับ Obsidian

---

## Prompt

```
แปลง server log ด้านล่างนี้เป็นไฟล์ troubleshooting สำหรับ Obsidian knowledge base

โครงสร้างไฟล์ที่ต้องการ:

---
title: <ชื่อปัญหาสั้นๆ>
tags: [<service>, openlandscape, troubleshooting]
type: troubleshooting
status: stable
created: <วันที่วันนี้>
---

# <ชื่อปัญหา>

**Date:** <วันที่>
**Host:** <hostname ถ้ามีใน log>
**Package:** <package และ version ถ้ามีใน log>

---

## Background

<อธิบายบริบทสั้นๆ ว่าเกิดขึ้นตอนทำอะไร>

---

## Symptom

<อธิบายอาการสั้นๆ>

### Raw Log จาก Server

\`\`\`
<วาง log ตรงนี้ทั้งหมด ห้ามแก้ไข ให้เหมือน log จริงทุกตัวอักษร>
\`\`\`

> **หมายเหตุ:** <อธิบาย warning หรือ error ที่ไม่ใช่ปัญหาจริง ถ้ามี>

---

## Root Cause

<อธิบายสาเหตุของปัญหา>

---

## ตัวเลือกและคำอธิบาย (ถ้ามี)

| ตัวเลือก | คำอธิบาย | เหมาะกับสถานการณ์ |
|---|---|---|
| ... | ... | ... |

---

## Verification หลังแก้ไข

\`\`\`bash
# คำสั่งตรวจสอบ
\`\`\`

---

## Tags

`<tag1>` `<tag2>` `<service>` `<hostname>`

---

กฎ:
- Raw Log ต้องเหมือนต้นฉบับทุกตัวอักษร ห้ามแปล ห้ามแก้ไข
- ถ้าไม่มีข้อมูลในส่วนไหน ให้ข้ามส่วนนั้น
- ไม่ต้องบอกว่าเลือกตัวเลือกไหน แสดงแค่ตัวเลือกและคำอธิบาย
- เขียนภาษาไทยในส่วนคำอธิบาย

--- LOG START ---
<วาง log ที่นี่>
--- LOG END ---
```