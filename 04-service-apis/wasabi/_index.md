---
title: Wasabi Overview
tags: [cloud, wasabi, s3]
type: index
status: stable
created: 2026-04-25
---

# Wasabi

รวม knowledge base เกี่ยวกับ Wasabi S3-compatible cloud storage

## Documents

### Getting Started
- [[wasabi_guideline]] — แหล่งอ้างอิงและ tools สำหรับเริ่มต้นใช้งาน Wasabi

### Connection
- [[wasabi_connect_nodejs]] — เชื่อมต่อ Wasabi ผ่าน AWS SDK (Node.js, Java, Python)

### Storage Operations
- [[wasabi_upload_put]] — Upload file ด้วย PutObjectCommand (SDK v2 & v3)
- [[wasabi_presigner_guide]] — สร้าง Signed URL ด้วย s3-request-presigner
- [[wasabi_presigner_response]] — ตัวอย่าง response จาก presigner workflow

### Policy
- [[wasabi_policy]] — Bucket policy สำหรับ IAM user และ public access

### Reference
- [[wasabi_placeholder_standard]] — มาตรฐาน placeholder สำหรับ sensitive & dynamic values

### Troubleshooting
- [[ts_connect_endpoint]] — แก้ปัญหา EndpointError และ InvalidAccessKeyId