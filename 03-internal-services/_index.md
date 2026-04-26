---
title: "Internal Services"
tags: [internal-services, backend, frontend, index]
type: index
status: stable
created: 2026-04-26
---

# Internal Services

รวม knowledge ของ services, frameworks, และ tools ที่สร้างหรือใช้งานภายในองค์กร

---

## ทำไมถึงเป็น `03-internal-services`

folder นี้ตั้งใจให้ครอบคลุม **ทุก layer** ของ internal stack — ไม่ว่าจะเป็น backend service, frontend service, หรือ shared framework

เดิมเคยพิจารณาใช้ `03-backend-services` แต่ชื่อนั้นผูกกับ layer เดียว ถ้ามี frontend service เพิ่มในอนาคตจะต้องสร้าง folder ใหม่นอก prefix `03` ทำให้ KB ขยายได้ลำบากและไม่สมมาตร

`internal-services` จึงเหมาะกว่า เพราะแยกด้วย **ownership** (สร้างเอง vs third-party) แทนที่จะแยกด้วย layer

---

## ต่างจาก `04-service-apis` ยังไง

| | `03-internal-services` | `04-service-apis` |
|--|------------------------|-------------------|
| คืออะไร | Services ที่สร้างหรือดูแลเอง | Third-party APIs ที่ integrate |
| ตัวอย่าง | PicShare, Go Fiber | Wasabi, Google Maps |
| เมื่อ deprecated | ทีมตัดสินใจเอง | ขึ้นอยู่กับ vendor |

---

## Documents

### Frameworks
- [[go-fiber/_index]] — Go Fiber framework reference

### Services
- [[picshare/_index]] — Image upload service prototype