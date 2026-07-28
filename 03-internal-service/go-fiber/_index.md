---
title: Go Fiber
tags: [go, fiber, backend, service-apis]
type: index
status: stable
created: 2026-04-25
---

# Go Fiber

Go web framework สำหรับสร้าง HTTP API — เน้น performance สูงและ syntax คล้าย Express.js

---

## ทำไมถึงใช้ Fiber

- เร็วกว่า `net/http` standard library เนื่องจากใช้ [fasthttp](https://github.com/valyala/fasthttp) เป็น base
- Middleware ecosystem ครบ เช่น logger, cors, rate limiter
- API คล้าย Express ทำให้ทีมที่มาจาก Node.js เรียนรู้ได้เร็ว

---

## Notes

- [[fiber_upload_image]] — รับและบันทึก image ผ่าน multipart form

---

## Requirements

| รายการ | Version |
|--------|---------|
| Go | 1.18+ |
| gofiber/fiber | v2 |

## Installation

```bash
go get github.com/gofiber/fiber/v2
```