---
title: "Dockerfile: prod"
tags: [container, docker, nextjs]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[nextjs_comparison]]"
  - "[[nextjs_dockerfile_example]]"
  - "[[ts_platform_mismatch]]"
---

# Dockerfile: prod

Dockerfile สำหรับ production ใช้ pnpm และ lock architecture เป็น amd64
เหมาะสำหรับ deploy บน INET registry

## Build & Run

```bash
docker build --provenance=false -t <IMAGE_NAME> -f dockerfile.prod .
docker run -d -p 3000:3000 <IMAGE_NAME>
```

Apple Silicon (M1/M2) → amd64 server

```bash
docker build --platform=linux/amd64 --provenance=false -t <IMAGE_NAME> -f dockerfile.prod .
```

## Dockerfile

```dockerfile
# Cr. https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile
# Stage 0 - Prepare base image
# Use the platform option to specify amd64 architecture
FROM --platform=linux/amd64 node:18-alpine AS base
RUN apk add --no-cache g++ make py3-pip libc6-compat

# Install pnpm
RUN npm install -g pnpm

# Stage 1 - build source code
FROM base AS builder
WORKDIR /app

# Install dependencies using pnpm
COPY package.json package*.json ./
RUN pnpm install

# Copy project and build
COPY . .
RUN pnpm run build

# Stage 2 - production image
FROM base AS runner
WORKDIR /app

# Define production env
ENV NODE_ENV=production
# Do not use root user to run app
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copy built static
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/next.config.js ./next.config.js

COPY --from=builder /app/public ./public

# Define image spec
USER nextjs

CMD pnpm start
```

## Stage Overview

| Stage | หน้าที่ |
|-------|--------|
| `base` | ติดตั้ง system deps + pnpm บน amd64 |
| `builder` | ติดตั้ง all dependencies และ build |
| `runner` | copy เฉพาะ compiled output รัน production |