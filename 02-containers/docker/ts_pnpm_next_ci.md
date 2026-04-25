---
title: "TS: pnpm ci Not Implemented"
tags: [container, docker, troubleshooting, pnpm]
type: troubleshooting
status: stable
created: 2026-04-25
related:
  - "[[nextjs_dockerfile_tutorial]]"
  - "[[ts_platform_mismatch]]"
---

# TS: pnpm ci Not Implemented

`pnpm ci` ยังไม่ถูก implement ใน pnpm ใช้ `pnpm install --frozen-lockfile --prod` แทน

## Error Message

```
ERR_PNPM_CI_NOT_IMPLEMENTED  The ci command is not implemented yet
```

## Solution

แทนที่ `pnpm ci` ด้วย

```dockerfile
RUN pnpm install --frozen-lockfile --prod
```

| Flag | ความหมาย |
|------|---------|
| `--frozen-lockfile` | ใช้ version จาก `pnpm-lock.yaml` ตรงๆ ไม่แก้ไข |
| `--prod` | ติดตั้งเฉพาะ production dependencies ลด image size |

## Dockerfile ที่แก้แล้ว (Production Stage)

ใช้ Multi-Stage Build แบ่งเป็น 3 stage

| Stage | หน้าที่ |
|-------|--------|
| `base` | ติดตั้ง system dependencies และ pnpm |
| `builder` | ติดตั้ง all dependencies และ build project |
| `production` | copy เฉพาะ compiled output + prod dependencies เท่านั้น |

ประโยชน์คือ final image ไม่มี dev dependencies และ source code ดิบ ทำให้ image เล็กลงและปลอดภัยขึ้น

```dockerfile
FROM --platform=linux/amd64 node:18-alpine AS base
RUN apk add --no-cache g++ make py3-pip libc6-compat
RUN npm install -g pnpm

FROM base AS builder
WORKDIR /app
COPY . .
RUN pnpm install
RUN pnpm run build

FROM base AS production
WORKDIR /app
ENV NODE_ENV=production

# ✅ แทนที่ pnpm ci ด้วยบรรทัดนี้
RUN pnpm install --frozen-lockfile --prod

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs

COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

CMD pnpm start
```

## Build & Run

```bash
docker build -t <IMAGE_NAME>:latest . --no-cache
docker run --platform linux/amd64 -d -p 3000:3000 <IMAGE_NAME>:latest
```

## Troubleshooting เพิ่มเติม

**Port ชนกัน**

```bash
docker run -d -p 3001:3000 <IMAGE_NAME>:latest
```

**Platform mismatch บนเครื่อง Apple Silicon**

ดู → [[ts_platform_mismatch]]

## References

- [pnpm docs](https://pnpm.io)
- [Docker Docs: Multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build)