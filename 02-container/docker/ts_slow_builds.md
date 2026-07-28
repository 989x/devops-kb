---
title: "TS: Slow Docker Build Times"
tags: [container, docker, troubleshooting]
type: troubleshooting
status: stable
created: 2026-04-25
related:
  - "[[nextjs_dockerfile_prod]]"
---

# TS: Slow Docker Build Times

Build ที่ปกติใช้ ~200s แต่กลับใช้เวลา 600s+ สาเหตุมักเกิดจาก `apk add` ช้าเพราะ network หรือ cache ไม่ทำงาน

## ระบุ Step ที่ช้า

ดู output ระหว่าง build ว่า step ไหนค้างนานที่สุด

```bash
❯ docker build -t ${REGISTRY_HOST}/${NAMESPACE}/${IMAGE}/${ENV}:${TAG} . --no-cache
[+] Building 620.5s (5/19)                                                           docker:desktop-linux
 => [internal] load build definition from Dockerfile                                                 0.0s
 => => transferring dockerfile: 1.12kB                                                               0.0s
 => [internal] load metadata for docker.io/library/node:18-alpine                                    1.8s
 => [internal] load .dockerignore                                                                    0.0s
 => => transferring context: 447B                                                                    0.0s
 => CACHED [base 1/3] FROM docker.io/library/node:18-alpine@sha256:02376a266c84acbf45bd19440e08e48b  0.0s
 => [internal] load build context                                                                    0.1s
 => => transferring context: 86.42kB                                                                 0.1s
 => [base 2/3] RUN apk add --no-cache g++ make py3-pip libc6-compat                                618.6s
 => => # (8/40) Installing isl26 (0.26-r1)
 => => # (9/40) Installing mpfr4 (4.2.1-r0)
 => => # (10/40) Installing mpc1 (1.3.1-r1)
 => => # (11/40) Installing gcc (13.2.1_git20240309-r0)
 => => # (12/40) Installing musl-dev (1.2.5-r0)
 => => # (13/40) Installing g++ (13.2.1_git20240309-r0)
```

`[base 2/3] RUN apk add` ค้างอยู่ที่ **618.6s** คือ bottleneck ตัวหลัก

## Solutions

### 1. ลอง build โดยไม่ใช้ `--no-cache`

ถ้า Dockerfile ไม่ได้เปลี่ยนบ่อย layer cache จะช่วยได้มาก

```bash
docker build -t <IMAGE_NAME> .
```

### 2. เปลี่ยน Alpine mirror

เพิ่ม `--repository` เพื่อใช้ mirror ที่เร็วกว่า

```dockerfile
RUN apk add --no-cache \
  --repository=http://dl-cdn.alpinelinux.org/alpine/v3.18/main \
  g++ make py3-pip libc6-compat
```

### 3. ใช้ BuildKit

BuildKit รองรับ parallel execution และ caching ที่ดีกว่า

```bash
DOCKER_BUILDKIT=1 docker build -t <IMAGE_NAME> .
```

### 4. ตรวจสอบ `.dockerignore`

ลด build context size โดยเพิ่มไฟล์ที่ไม่จำเป็น

```
node_modules
.git
*.log
.next
```

### 5. ใช้ Multi-stage build

แยก stage ที่ต้องการ native tools ออกจาก production image

```dockerfile
FROM node:18-alpine AS build
RUN apk add --no-cache g++ make py3-pip libc6-compat
# ติดตั้ง dependencies และ build

FROM node:18-alpine AS final
COPY --from=build /app /app
CMD ["node", "/app/index.js"]
```

## Checklist

ถ้ายังช้าอยู่หลังลองทุก solution ให้ตรวจสอบ

- [ ] Network / proxy ขององค์กรขัดขวาง package download ไหม
- [ ] Docker resource allocation (CPU/RAM) เพียงพอไหม
- [ ] Disk space เหลือพอไหม (`docker system df`)