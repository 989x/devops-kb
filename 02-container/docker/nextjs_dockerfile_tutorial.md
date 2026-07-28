---
title: "Dockerfile: tutorial"
tags: [container, docker, nextjs]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[nextjs_comparison]]"
  - "[[ts_pnpm_next_ci]]"
  - "[[ts_platform_mismatch]]"
---

# Dockerfile: tutorial

Dockerfile สำหรับเรียนรู้ multi-stage build มี dev stage เพิ่มมาด้วย
ใช้เป็น starting point ก่อนปรับเป็น dockerfile.prod

> ⚠️ **Known Issue:** มี `pnpm ci` ใน production stage ซึ่งยังไม่ถูก implement
> ต้องแก้เป็น `pnpm install --frozen-lockfile --prod` ก่อนใช้งานจริง → [[ts_pnpm_next_ci]]

## Dockerfile

```dockerfile
# FROM node:18-alpine as base
# Use the platform option to specify amd64 architecture
FROM --platform=linux/amd64 node:18-alpine as base
RUN apk add --no-cache g++ make py3-pip libc6-compat

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app
COPY package*.json ./
EXPOSE 3000

FROM base as builder
WORKDIR /app

COPY . .

# Install dependencies using pnpm
RUN pnpm install

RUN pnpm run build


FROM base as production
WORKDIR /app

ENV NODE_ENV=production
RUN pnpm ci  # ⚠️ แก้เป็น: pnpm install --frozen-lockfile --prod

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
USER nextjs


COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/public ./public

CMD pnpm start

FROM base as dev
ENV NODE_ENV=development
RUN pnpm install
COPY . .
CMD pnpm run dev
```

## Stage Overview

| Stage | หน้าที่ |
|-------|--------|
| `base` | ติดตั้ง system deps + pnpm บน amd64 |
| `builder` | ติดตั้ง all dependencies และ build |
| `production` | รัน production (⚠️ มี bug `pnpm ci`) |
| `dev` | รัน development mode |

## References

- [Dockerize a Next.js App](https://medium.com/@itsuki.enjoy/dockerize-a-next-js-app-4b03021e084d)