---
title: DEVOPS-KB
tags: [devops, knowledge-base, index]
type: readme
status: stable
created: 2026-04-25
---

# DEVOPS-KB

Knowledge base for DevOps and backend engineering — cloud infrastructure, containers, service integrations, security, and internal standards

---

## Structure

```
DEVOPS-KB/
├── 00-meta/           # Platform & KB documentation
├── 01-cloud/          # Cloud providers & infrastructure
├── 02-containers/     # Docker & Kubernetes
├── 04-service-apis/   # Third-party service integrations
├── 05-security/       # Security scanning & hardening
└── 06-prompts/        # Personal AI prompts & conventions
```

---

## 00-meta

- [[mnlab_overview]] — MNLAB platform overview, tech stack, and vision

---

## 01-cloud

### AWS
- [[aws/_index]] — AWS overview
- [[aws/cli_install]] — ติดตั้งและถอนการติดตั้ง AWS CLI
- [[aws/ec2_overview]] — ภาพรวม EC2 วิธี connect และ deploy
- [[aws/ec2_running_node]] — รัน Node.js / NestJS บน EC2 ด้วย PM2

### DigitalOcean
- [[digitalocean/_index]] — DigitalOcean overview
- [[digitalocean/droplets_setup_env]] — ตั้งค่า environment บน Droplet
- [[digitalocean/droplets_setup_server]] — ตั้งค่า server บน Droplet
- [[digitalocean/droplets_ssh_access]] — SSH เข้า Droplet

### Inet
- [[inet/_index]] — Inet overview
- [[inet/infra_minio]] — MinIO object storage
- [[inet/infra_prometheus]] — Prometheus monitoring
- [[inet/registry_docker]] — Docker registry
- [[inet/server_deploy]] — Deploy server

---

## 02-containers

### Docker
- [[docker/_index]] — Docker overview
- [[docker/nextjs_dockerfile_comparison]] — เปรียบเทียบ Dockerfile แบบต่าง ๆ สำหรับ Next.js
- [[docker/nextjs_dockerfile_example]] — ตัวอย่าง Dockerfile สำหรับ Next.js
- [[docker/nextjs_dockerfile_prod]] — Dockerfile สำหรับ production
- [[docker/nextjs_dockerfile_tutorial]] — Tutorial การสร้าง Dockerfile
- [[docker/ts_platform_mismatch]] — แก้ปัญหา platform mismatch ใน TypeScript
- [[docker/ts_pnpm_next_ci]] — แก้ปัญหา pnpm + Next.js ใน CI
- [[docker/ts_slow_builds]] — แก้ปัญหา build ช้า

### Kubernetes
- [[k8s/_index]] — Kubernetes overview
- [[k8s/tool_k9s]] — k9s CLI dashboard
- [[k8s/tool_kube_hunter]] — kube-hunter security scanner
- [[k8s/tool_trivy]] — Trivy vulnerability scanner

---

## 03-internal-services

---

## 04-service-apis

### Wasabi
- [[wasabi/_index]] — Wasabi overview
- [[wasabi/wasabi_guideline]] — Getting started & tools
- [[wasabi/wasabi_connect_nodejs]] — เชื่อมต่อผ่าน AWS SDK (Node.js, Java, Python)
- [[wasabi/wasabi_upload_put]] — Upload file ด้วย PutObjectCommand
- [[wasabi/wasabi_presigner_guide]] — สร้าง Signed URL
- [[wasabi/wasabi_presigner_response]] — ตัวอย่าง response จาก presigner
- [[wasabi/wasabi_policy]] — Bucket policy (IAM & public access)
- [[wasabi/wasabi_placeholder_standard]] — มาตรฐาน placeholder
- [[wasabi/ts_connect_endpoint]] — แก้ปัญหา EndpointError & InvalidAccessKeyId

### Google Maps
- [[google_maps_guide]] — Google Maps API guide

---

## 05-security

- [[k8s101_k8s02_security_scan]] — Security scanning สำหรับ Kubernetes

---

## 06-prompts

- [[personal_commit]] — Prompt สำหรับเขียน commit message
- [[personal_kb_restructure]] — Prompt สำหรับ restructure KB
- [[personal_nextjs]] — Prompt สำหรับ Next.js
