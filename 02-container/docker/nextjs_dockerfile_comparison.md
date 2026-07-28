---
title: "Dockerfile Comparison: prod vs example"
tags: [container, docker, nextjs]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[nextjs_dockerfile_prod]]"
  - "[[nextjs_dockerfile_example]]"
---

# Dockerfile Comparison: prod vs example

## Key Differences

| Aspect | dockerfile.prod | dockerfile.example |
|--------|----------------|-------------------|
| Base Image | `node:18-alpine` + lock amd64 | `node:18-alpine` ไม่ lock architecture |
| Package Manager | pnpm เท่านั้น | รองรับ yarn / npm / pnpm อัตโนมัติ |
| Build Process | pnpm build ตรงๆ | Output file tracing (image เล็กกว่า) |
| User Permissions | `nextjs` user (non-root) | `nextjs` user + set permission `.next` folder |
| Production Run | `pnpm start` | `node server.js` |
| Port / Hostname | ไม่ระบุ | Expose 3000, hostname `0.0.0.0` |
| Telemetry Control | ไม่มี | ปิดได้ด้วย `NEXT_TELEMETRY_DISABLED` |
| Image Size | ปกติ | เล็กกว่า (output file tracing) |

## เลือกใช้แบบไหน

**ใช้ `dockerfile.prod`** → [[nextjs_dockerfile_prod]]
- project ใช้ pnpm และต้องการ setup เรียบง่าย
- deploy บน amd64 server (INET registry)

**ใช้ `dockerfile.example`** → [[nextjs_dockerfile_example]]
- project ใช้ package manager หลายแบบ
- ต้องการ image size เล็กที่สุด
- ต้องการควบคุม telemetry

## Build Commands

```bash
# dockerfile.prod
docker build -t nextjs-prod -f dockerfile.prod .
docker run -p 3000:3000 nextjs-prod

# dockerfile.example
docker build -t nextjs-example -f dockerfile.example .
docker run -p 3000:3000 nextjs-example
```