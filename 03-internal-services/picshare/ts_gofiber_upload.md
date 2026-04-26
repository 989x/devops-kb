---
title: "PicShare Upload — Troubleshooting"
tags: [picshare, gofiber, upload, troubleshooting, backend]
type: troubleshooting
status: stable
created: 2026-04-26
related:
  - "[[connect_gofiber_upload]]"
---

# PicShare Upload — Troubleshooting

---

## id_generator — Character Conversion Edge Case

### ปัญหา

`GeneratePublicID()` ใช้ logic แปลง character ตำแหน่งที่ 4 และ 8 ดังนี้

```go
'a'+(hexID[3]-'0')%6
```

ตั้งใจให้ได้ตัวอักษร `a-f` แต่ถ้า `hexID[3]` เป็น hex letter (`a-f`) แทนที่จะเป็น digit (`0-9`) การคำนวณจะให้ผลที่ไม่ตรง intent เพราะ `'a' - '0'` = 49 ซึ่งเกิน range ของ `a-f`

### ตัวอย่าง

| hexID[3] | hexID[3]-'0' | %6 | ผลลัพธ์ |
|----------|-------------|-----|--------|
| `'3'` | 3 | 3 | `'d'` ✅ |
| `'9'` | 9 | 3 | `'d'` ✅ |
| `'a'` | 49 | 1 | `'b'` ⚠️ (ได้ผล แต่ไม่ตรง intent) |
| `'f'` | 54 | 0 | `'a'` ⚠️ (ได้ผล แต่ไม่ตรง intent) |

### ผลกระทบ

`public_id` ยังคง unique และใช้งานได้ปกติ เพราะ output ยังอยู่ใน printable ASCII range — แต่ format ไม่ตรงกับ pattern `xxyyxxyy` ที่ตั้งใจไว้

### โค้ดที่ถูกต้อง

ใช้ `hex.EncodeToString()` โดยตรง แทนการ convert ทีละ character — ทดสอบได้ที่ [Go Playground](https://go.dev/play/)

```go
package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

func GeneratePublicID() string {
	b := make([]byte, 4)
	rand.Read(b)
	return hex.EncodeToString(b)
}

func main() {
	for i := 0; i < 5; i++ {
		fmt.Println(GeneratePublicID())
	}
}
```

**ตัวอย่างผลลัพธ์**

```
3fa2b4cd
a1c09e2f
7d3b85e1
2f6a1c4d
b8e30a72
```

---

## Service Panic ตอน Start

### ปัญหา

Service หยุดทันทีหลัง start พร้อม panic message

```
panic: BASE_UPLOAD_DIR must be set in .env
panic: FILE_SERVING_URL must be set in .env
```

### สาเหตุ

ไม่พบไฟล์ `.env` หรือ env variable ที่ required ไม่ได้ตั้งค่าไว้

### วิธีแก้

```bash
# ตรวจสอบว่ามีไฟล์ .env
cat .env

# ถ้าไม่มี ให้สร้างใหม่
echo "BASE_UPLOAD_DIR=<BASE_UPLOAD_DIR>" > .env
echo "FILE_SERVING_URL=<FILE_SERVING_URL>" >> .env
```

---

## อัปโหลดไฟล์แล้วได้ Error 400 — No valid files uploaded

### ปัญหา

```json
{ "error": "No valid files uploaded" }
```

### สาเหตุ

ส่ง form มาโดยไม่มี key `cover_image` หรือ `body_image` เลย

### วิธีแก้

ต้องส่งอย่างน้อย 1 key ใน form — ตรวจสอบชื่อ key ให้ตรงตัว

```bash
# ถูก
curl -F "cover_image=@photo.jpg" http://<SERVER_IP>:8081/api/v1/upload/contents

# ผิด — key ชื่อไม่ตรง
curl -F "cover=@photo.jpg" ...
curl -F "image=@photo.jpg" ...
```

---

## อัปโหลดไฟล์แล้วได้ Error 500 — Failed to create directory

### ปัญหา

```json
{ "error": "Failed to create base directory" }
{ "error": "Failed to create directory for public_id" }
```

### สาเหตุ

Process ไม่มีสิทธิ์สร้าง directory ใน `BASE_UPLOAD_DIR`

### วิธีแก้

```bash
# ตรวจสอบสิทธิ์
ls -la <BASE_UPLOAD_DIR>

# แก้สิทธิ์
chmod 755 <BASE_UPLOAD_DIR>
chown <SERVER_USER>:<SERVER_USER> <BASE_UPLOAD_DIR>
```

---

## ไฟล์ชื่อเดียวกันใน Request เดียวกัน — File Collision

### ปัญหา

ถ้าอัปโหลดไฟล์ชื่อซ้ำกันใน request เดียวกัน เช่น

```bash
curl -X POST http://<SERVER_IP>:8081/api/v1/upload/contents \
  -F "cover_image=@photo.jpg" \
  -F "cover_image=@photo.jpg"
```

ไฟล์ที่ 2 จะทับไฟล์ที่ 1 เพราะ save ลง path เดียวกันคือ `<public_id>/photo.jpg` — response จะมี URL ซ้ำ 2 รายการแต่ชี้ไปที่ไฟล์เดียวกัน

### ผลกระทบ

ข้อมูลสูญหายโดยไม่มี error — service ไม่แจ้งเตือน

### แนวทางแก้ไข

เติม unique prefix ก่อน save เช่น timestamp หรือ random string

```go
uniqueName := fmt.Sprintf("%d_%s", time.Now().UnixNano(), file.Filename)
filePath := filepath.Join(publicDir, uniqueName)
```

---

## Upload ไฟล์ใหญ่ไม่ได้ — Body Size Limit

### ปัญหา

Fiber มี default `BodyLimit` ที่ **4MB** — ถ้าไม่ได้ตั้งค่าไว้และ upload ไฟล์เกิน 4MB จะได้ error โดยไม่รู้สาเหตุ

```json
{ "error": "Failed to parse multipart form" }
```

### สาเหตุ

`main.go` สร้าง Fiber app โดยไม่ได้กำหนด `BodyLimit`

```go
// ปัจจุบัน — ใช้ default 4MB
app := fiber.New()
```

### แนวทางแก้ไข

กำหนด `BodyLimit` ให้เหมาะกับ use case

```go
app := fiber.New(fiber.Config{
    BodyLimit: 20 * 1024 * 1024, // 20MB
})
```

---

## References

- [[connect_gofiber_upload]] — Setup & Integration Guide