---
title: "PicShare"
tags: [picshare, gofiber, upload, backend, index]
type: index
status: stable
created: 2026-04-26
---

# PicShare

Prototype reference สำหรับ image upload service สร้างด้วย Go + Fiber

เขียนขึ้นเพื่อเป็นแนวทางก่อนเริ่มโปรเจคจริง — ครอบคลุม architecture, environment setup, code logic, API design, และ known issues ในระดับที่อ่านแล้วนำไปสร้าง production service ได้เลย

---

## ที่มา

เดิม PicShare เป็น repo `picshare-gofiber-main` ที่เขียนขึ้นเพื่อทดสอบ concept — run ได้จริงแต่ยังมีข้อผิดพลาดหลายจุดที่ไม่เหมาะกับ production เช่น id_generator ที่ conversion ผิด intent, ไม่มี body size limit, และไฟล์ชื่อซ้ำทับกันได้โดยไม่มี error

จึงตัดสินใจไม่นำ repo ไปต่อยอดโดยตรง แต่ถอด logic ที่ถูกต้องออกมาเขียนเป็น KB แทน เพื่อให้ทีมมีแนวทางที่ชัดเจนและหลีกเลี่ยงข้อผิดพลาดเดิมเมื่อสร้างโปรเจคจริง

---

## สิ่งที่ Prototype นี้ครอบคลุม

| หัวข้อ | รายละเอียด |
|--------|-----------|
| Architecture | GoFiber + static file server, directory structure, request flow |
| Upload Logic | Multi-file, multi-key (`cover_image`, `body_image`), public_id per request |
| Configuration | Environment-driven via `.env`, placeholder-ready |
| API Design | 2 endpoints (`/contents`, `/businesses`), response format |
| Known Issues | id_generator edge case, permission errors, form key validation |

---

## สิ่งที่ต้องเพิ่มก่อน Production

- [ ] Validate file type (`Content-Type`)
- [ ] จำกัดขนาดไฟล์ (`BodyLimit`)
- [ ] Authentication middleware
- [ ] Integration กับ object storage (เช่น Wasabi, MinIO)

---

## Documents

### Setup & Integration
- [[connect_gofiber_upload]] — Architecture, environment setup, code logic, และ API reference

### Troubleshooting
- [[ts_gofiber_upload]] — Known issues และวิธีแก้ไข