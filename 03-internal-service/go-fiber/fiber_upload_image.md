---
title: Fiber — Upload Image
tags: [go, fiber, upload, file, api]
type: note
status: stable
created: 2026-04-25
---

# Fiber — Upload Image

รับไฟล์รูปภาพผ่าน `multipart/form-data` แล้วบันทึกลง `./static/images/`

---

## Flow

```
POST /upload
  └── รับ form field "image"
  └── สร้างโฟลเดอร์ ./static/images/ (ถ้ายังไม่มี)
  └── บันทึกไฟล์
  └── ตอบกลับ path ของไฟล์
```

---

## Code

```go
package main

import (
    "log"
    "os"
    "path/filepath"
    "github.com/gofiber/fiber/v2"
)

// UploadHandler handles image upload to /static/images/
func UploadHandler(c *fiber.Ctx) error {
    file, err := c.FormFile("image")
    if err != nil {
        return fiber.NewError(fiber.StatusBadRequest, "Image is required")
    }

    dirPath := "./static/images"
    if err := os.MkdirAll(dirPath, os.ModePerm); err != nil {
        log.Println("Directory creation failed:", err)
        return fiber.NewError(fiber.StatusInternalServerError, "Failed to create directory")
    }

    dst := filepath.Join(dirPath, file.Filename)
    if err := c.SaveFile(file, dst); err != nil {
        log.Println("File save failed:", err)
        return fiber.NewError(fiber.StatusInternalServerError, "Failed to save image")
    }

    return c.JSON(fiber.Map{
        "message": "Image uploaded successfully",
        "path":    "/images/" + file.Filename,
    })
}

func main() {
    app := fiber.New()
    app.Post("/upload", UploadHandler)
    log.Println("Server is running on :8080")
    if err := app.Listen(":8080"); err != nil {
        log.Fatal("Failed to start server:", err)
    }
}
```

---

## Response

**Success `200`**
```json
{
  "message": "Image uploaded successfully",
  "path": "/images/photo.jpg"
}
```

**Error `400`** — ไม่มีไฟล์แนบมา
```json
{
  "message": "Image is required"
}
```

---

## ทดสอบด้วย curl

```bash
curl -X POST http://localhost:8080/upload \
  -F "image=@/path/to/photo.jpg"
```

---

## ข้อจำกัดที่ควรแก้ก่อน Production

> [!warning] ยังไม่พร้อม Production
> ไฟล์นี้เก็บ logic จากโปรเจคต้นแบบ ยังขาด hardening สำคัญ

| ปัญหา | ผลกระทบ | แนวทางแก้ |
|-------|---------|-----------|
| ไม่ validate ชนิดไฟล์ | อัปโหลดไฟล์อันตรายได้ | ตรวจ `file.Header.Get("Content-Type")` |
| ชื่อไฟล์ซ้ำ = ทับกัน | ข้อมูลหาย | ใช้ UUID หรือ timestamp นำหน้าชื่อ |
| ไม่จำกัดขนาดไฟล์ | อาจ OOM | ตั้ง `fiber.Config{BodyLimit: 5 * 1024 * 1024}` |
| ไม่มี Authentication | ใครก็อัปโหลดได้ | เพิ่ม middleware JWT หรือ API key |