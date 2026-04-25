---
title: "TS: Docker Platform Mismatch"
tags: [container, docker, troubleshooting]
type: troubleshooting
status: stable
created: 2026-04-25
related:
  - "[[nextjs_dockerfile_prod]]"
---

# TS: Docker Platform Mismatch

เกิดขึ้นเมื่อ build หรือ run image บนเครื่อง ARM (Apple M1/M2) แต่ image ถูก build สำหรับ AMD64

## Warning Message

```
WARNING: The requested image's platform (linux/amd64) does not match
the detected host platform (linux/arm64/v8) and no specific platform was requested
```

## Solutions

### 1. Run ด้วย `--platform` flag (เร็วสุด)

```bash
docker run --platform linux/amd64 -d -p 3000:3000 <IMAGE_NAME>
```

### 2. Build image ใหม่สำหรับ ARM64

ใช้เมื่อต้องการ run บนเครื่อง ARM โดยไม่ใช้ compatibility mode

```bash
docker build --platform linux/arm64 -t <IMAGE_NAME> .
docker push <IMAGE_NAME>
docker pull <IMAGE_NAME>
```

### 3. ตรวจสอบ platform ของ image

```bash
docker image inspect <IMAGE_NAME> --format '{{.Os}}/{{.Architecture}}'
```

## สรุป

| สถานการณ์ | วิธีแก้ |
|----------|--------|
| Run บนเครื่อง dev (M1/M2) | ใช้ `--platform linux/amd64` ตอน run |
| Deploy บน INET server (amd64) | Build ด้วย `--platform=linux/amd64` ตาม [[nextjs_dockerfile_prod]] |
| ต้องการ run native บน ARM | Build ใหม่ด้วย `--platform linux/arm64` |