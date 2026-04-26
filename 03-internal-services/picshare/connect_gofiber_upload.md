---
title: "PicShare Upload — Setup & Integration Guide"
tags: [picshare, gofiber, upload, api, infra, backend]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[ts_gofiber_upload]]"
---

# PicShare Upload — Setup & Integration Guide

PicShare เป็น internal image upload service สร้างด้วย Go + Fiber รับไฟล์รูปภาพผ่าน multipart form และจัดเก็บลง directory บน server พร้อม return URL สำหรับ serve ไฟล์

---

## Prerequisites

- Go 1.19+
- Fiber v2
- Nginx หรือ static file server สำหรับ serve ไฟล์ (ตั้งค่าแยก)
- Directory ที่มีสิทธิ์ write สำหรับ `BASE_UPLOAD_DIR`

---

## Architecture

```
Client
  │
  ▼
GoFiber App (port 8081)
  │
  ├── POST /api/v1/upload/contents
  └── POST /api/v1/upload/businesses
        │
        ▼
  image_controller
        │
        ├── Generate public_id
        ├── Create directory: <BASE_UPLOAD_DIR>/<type>/<public_id>/
        └── Save files → return URL
                            │
                            ▼
                   Static File Server (Nginx)
                   <FILE_SERVING_URL>/<type>/<public_id>/<filename>
```

---

## Directory Structure

```
<BASE_UPLOAD_DIR>/
├── contents/
│   └── <public_id>/
│       ├── cover1.jpg
│       └── body1.jpg
└── businesses/
    └── <public_id>/
        ├── cover1.jpg
        └── body1.jpg
```

แต่ละ request จะสร้าง subdirectory ใหม่ตาม `public_id` ที่ generate ขึ้นมา ทำให้ไฟล์ไม่ชนกัน

---

## Environment Variables

สร้างไฟล์ `.env` ที่ root ของ project

```env
BASE_UPLOAD_DIR=<BASE_UPLOAD_DIR>
FILE_SERVING_URL=<FILE_SERVING_URL>
```

| Variable | คำอธิบาย | ตัวอย่าง |
|----------|---------|---------|
| `BASE_UPLOAD_DIR` | path หลักสำหรับเก็บไฟล์ | `/var/www/uploads` |
| `FILE_SERVING_URL` | base URL ที่ใช้ serve ไฟล์ | `http://<SERVER_IP>:8081/images` |

> **หมายเหตุ:** ทั้ง 2 ตัวแปรนี้เป็น required — service จะ panic ถ้าไม่ได้ตั้งค่า

---

## Installation

```bash
# 1. Clone และติดตั้ง dependencies
go mod tidy

# 2. สร้าง .env
echo "BASE_UPLOAD_DIR=<BASE_UPLOAD_DIR>" > .env
echo "FILE_SERVING_URL=<FILE_SERVING_URL>" >> .env

# 3. สร้าง upload directory และให้สิทธิ์
mkdir -p <BASE_UPLOAD_DIR>
chmod 755 <BASE_UPLOAD_DIR>

# 4. Run
go run cmd/main.go
```

---

## Code Structure

```
picshare-gofiber/
├── cmd/
│   └── main.go              # Entry point
├── routes/
│   └── upload_routes.go     # Route definitions
├── controllers/
│   └── image_controller.go  # Upload logic
└── utils/
    └── id_generator.go      # public_id generator
```

---

## Layer Breakdown

### 1. Entry Point — `main.go`

สร้าง Fiber app พร้อม middleware และ register routes

```go
app := fiber.New()
app.Use(logger.New())
app.Use(cors.New())
routes.SetupUploadRoutes(app)
app.Listen("0.0.0.0:8081")
```

### 2. Routes — `upload_routes.go`

กำหนด 2 endpoints ภายใต้ prefix `/api/v1`

```go
api := app.Group("/api/v1")
api.Post("/upload/contents", func(c *fiber.Ctx) error {
    return controllers.HandleFileUpload(c, controllers.ContentBaseDir)
})
api.Post("/upload/businesses", func(c *fiber.Ctx) error {
    return controllers.HandleFileUpload(c, controllers.BusinessBaseDir)
})
```

| Endpoint | Base Directory |
|----------|---------------|
| `POST /api/v1/upload/contents` | `<BASE_UPLOAD_DIR>/contents/` |
| `POST /api/v1/upload/businesses` | `<BASE_UPLOAD_DIR>/businesses/` |

### 3. Controller — `image_controller.go`

Flow การทำงานหลักเมื่อได้รับ request:

```
1. ensureDir(baseDir)           — สร้าง directory ถ้ายังไม่มี
2. GeneratePublicID()           — สร้าง public_id แบบ random
3. ensureDir(baseDir/publicID)  — สร้าง subdirectory สำหรับ request นี้
4. MultipartForm()              — parse form data
5. loop keys [cover_image, body_image]
   └── loop files per key
       ├── SaveFile()           — บันทึกไฟล์
       └── build URL            — <FILE_SERVING_URL>/<type>/<public_id>/<filename>
6. return JSON response
```

### 4. ID Generator — `id_generator.go`

สร้าง `public_id` รูปแบบ 8 หลัก โดยใช้ `crypto/rand`

```go
// ตัวอย่างผลลัพธ์: "3fa2b4cd"
func GeneratePublicID() string {
    b := make([]byte, 4)
    rand.Read(b)
    ...
}
```

> **Note:** มี edge case ใน character conversion — ดูรายละเอียด [[ts_gofiber_upload]]

---

## API Reference

### Base URL

```
http://<SERVER_IP>:8081/api/v1
```

### POST /upload/contents

อัปโหลดรูปภาพสำหรับ content

**Headers**

```
Content-Type: multipart/form-data
```

**Form Keys**

| Key | Required | คำอธิบาย |
|-----|----------|---------|
| `cover_image` | ❌ optional | รูป cover (รับได้หลายไฟล์) |
| `body_image` | ❌ optional | รูป body (รับได้หลายไฟล์) |

> ต้องส่งอย่างน้อย 1 key มิฉะนั้นจะได้ error `No valid files uploaded`

**Response — Success**

```json
{
  "message": "Images uploaded successfully",
  "public_id": "3fa2b4cd",
  "cover_image": [
    "http://<SERVER_IP>:8081/images/contents/3fa2b4cd/cover1.jpg"
  ],
  "body_image": [
    "http://<SERVER_IP>:8081/images/contents/3fa2b4cd/body1.jpg"
  ]
}
```

**Response — Error**

| Status | Error | สาเหตุ |
|--------|-------|--------|
| 400 | `Failed to parse multipart form` | Content-Type ไม่ใช่ multipart |
| 400 | `No valid files uploaded` | ไม่มี key `cover_image` หรือ `body_image` |
| 500 | `Failed to create base directory` | ไม่มีสิทธิ์สร้าง directory |
| 500 | `Failed to save image` | เขียนไฟล์ไม่ได้ |

---

### POST /upload/businesses

อัปโหลดรูปภาพสำหรับ business — โครงสร้าง request/response เหมือน `/upload/contents` ทุกประการ ต่างแค่ path ที่เก็บไฟล์

```json
{
  "message": "Images uploaded successfully",
  "public_id": "7bc1d2ef",
  "cover_image": [
    "http://<SERVER_IP>:8081/images/businesses/7bc1d2ef/cover1.jpg"
  ]
}
```

---

## Testing with curl

### Upload contents

```bash
# single file per key
curl -X POST http://<SERVER_IP>:8081/api/v1/upload/contents \
  -F "cover_image=@cover.jpg" \
  -F "body_image=@body.jpg"

# multiple files per key
curl -X POST http://<SERVER_IP>:8081/api/v1/upload/contents \
  -F "cover_image=@cover1.jpg" \
  -F "cover_image=@cover2.jpg" \
  -F "body_image=@body1.jpg"
```

### Upload businesses

```bash
curl -X POST http://<SERVER_IP>:8081/api/v1/upload/businesses \
  -F "cover_image=@cover.jpg" \
  -F "body_image=@body.jpg"
```

---

## References

- [Fiber v2 — File Upload](https://docs.gofiber.io/api/ctx#saveFile)
- [Fiber v2 — MultipartForm](https://docs.gofiber.io/api/ctx#multipartform)