---
title: Droplets Setup Environment File
tags: [cloud, digitalocean, env, config]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[droplets_setup_server]]"
---

# Droplets Setup Environment File

วิธีสร้างและจัดการไฟล์ `.env` บน server แต่ละ project ต้องมี `.env` เป็นของตัวเอง ไม่ใช้ร่วมกัน

## Prerequisites

- Connect เข้า Droplet ได้แล้ว → [[droplets_ssh_access]]
- รู้ path ของ project บน server

## สร้างและแก้ไข .env

```bash
nano <PROJECT_DIR>/.env
# บันทึก: Ctrl+O แล้ว Enter
# ออก:  Ctrl+X
```

ตัวอย่าง path จริง

```bash
nano /root/my-api/.env
nano /var/www/my-frontend/.env
```

## ตัวอย่างเนื้อหาใน .env

```env
# App
NODE_ENV=production
PORT=3000

# Database
DATABASE_URL=mongodb://admin:<PASSWORD>@localhost:27017/mydb?authSource=admin

# Secrets
JWT_SECRET=<RANDOM_STRING>
```

## Best Practices

| หัวข้อ | แนวทาง |
|-------|-------|
| ไม่ commit ขึ้น Git | เพิ่ม `.env` ใน `.gitignore` เสมอ |
| ไม่ใช้ไฟล์เดียวกันข้าม project | แต่ละ project มี `.env` ของตัวเอง |
| Password และ Secret | ใช้ random string ความยาว 32+ ตัวอักษร |
| Backup | เก็บ `.env` ไว้ใน password manager หรือ secret vault ขององค์กร |

## ตรวจสอบว่า .env โหลดถูกต้อง

```bash
# ดูค่าที่ app โหลดมา (Node.js)
node -e "require('dotenv').config(); console.log(process.env.NODE_ENV)"
```