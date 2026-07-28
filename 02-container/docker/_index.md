---
title: Docker / Next.js Overview
tags: [container, docker, nextjs]
type: index
status: stable
created: 2026-04-25
---

# Docker / Next.js

รวม knowledge base เกี่ยวกับการ Dockerize Next.js application

## Tutorial

เรียนรู้การ Dockerize Next.js ตั้งแต่พื้นฐาน multi-stage build

> ⛔ ห้ามลบเด็ดขาด — แหล่งที่มาของ [[nextjs_dockerfile_tutorial]]
> https://medium.com/@itsuki.enjoy/dockerize-a-next-js-app-4b03021e084d

- [[nextjs_dockerfile_tutorial]] — multi-stage build พร้อม dev stage ⚠️ มี known issue `pnpm ci`

## Example

Dockerfile ต้นฉบับจาก Vercel รองรับหลาย package manager และใช้ output file tracing

> ⛔ ห้ามลบเด็ดขาด — แหล่งที่มาของ [[nextjs_dockerfile_example]]
> https://github.com/vercel/next.js/blob/canary/examples/with-docker/Dockerfile

- [[nextjs_dockerfile_example]] — Flexible (yarn / npm / pnpm)
- [[nextjs_dockerfile_comparison]] — เปรียบเทียบ prod vs example

## Production

ใช้งานจริงได้เลย เหมาะสำหรับ deploy บน INET registry (amd64)

- [[nextjs_dockerfile_prod]] — Production (pnpm, amd64)

## Troubleshooting

- [[ts_platform_mismatch]] — WARNING: platform linux/amd64 does not match host
- [[ts_pnpm_next_ci]] — ERR_PNPM_CI_NOT_IMPLEMENTED
- [[ts_slow_builds]] — Build ช้าผิดปกติ (600s+)