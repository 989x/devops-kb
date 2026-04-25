---
title: INET Docker Registry
tags: [cloud, inet, docker, registry]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[server_deploy]]"
---

# INET Docker Registry

คู่มือ Build, Push และ Pull Docker image กับ INET Private Registry (`git.inet.co.th:5555`)

## Prerequisites

- ติดตั้ง Docker บน workstation หรือ CI runner แล้ว
- มีสิทธิ์เข้าถึง INET Registry
- มี Personal Access Token (PAT) พร้อมแล้ว

> **TLS / Certificate:**
> ถ้า registry ใช้ custom CA ให้วางไฟล์ CA ที่
> `/etc/docker/certs.d/git.inet.co.th:5555/ca.crt` แล้ว restart Docker
>
> ถ้าเป็น HTTP หรือ non-public cert ให้เพิ่มใน `/etc/docker/daemon.json`
> ```json
> { "insecure-registries": ["git.inet.co.th:5555"] }
> ```
> แล้ว restart Docker

---

## 1. Login

ใช้ **Personal Access Token (PAT)** เท่านั้น ไม่ใช้ group/project token เพราะ permission ไม่สม่ำเสมอ
สร้าง PAT ที่ GitLab → Settings → Access Tokens โดยเปิด scope `read_registry` และ `write_registry`

```bash
docker login git.inet.co.th:5555
# Username: <GITLAB_USERNAME>
# Password: <PERSONAL_ACCESS_TOKEN>
```

---

## 2. Build & Tag

รันที่ root ของ project (ที่มี Dockerfile)

```bash
docker build --provenance=false \
  -t git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION> .
```

> `--provenance=false` ปิด BuildKit attestations เพื่อป้องกัน digest error กับ INET/Harbor

**Apple Silicon (M1/M2) → deploy บน x86_64 server**

```bash
docker build --platform=linux/amd64 --provenance=false \
  -t git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION> .
```

**Docker เวอร์ชันเก่าที่ไม่รองรับ `--provenance`**

```bash
DOCKER_BUILDKIT=0 docker build \
  -t git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION> .
```

---

## 3. Push

```bash
docker push git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
```

ตรวจสอบ image ที่ build ไว้

```bash
docker images
```

---

## 4. Pull & Run

```bash
docker pull git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>

docker run -d -p <HOST_PORT>:<CONTAINER_PORT> \
  git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
```

---

## Workflow สรุป

### A. Build → Push → Run

```bash
docker login git.inet.co.th:5555

docker build --provenance=false \
  -t git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION> .

docker push git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>

docker run -d -p <HOST_PORT>:<CONTAINER_PORT> \
  git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
```

### B. Pull → Run (บน server)

```bash
docker login git.inet.co.th:5555
docker pull git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
docker run -d -p <HOST_PORT>:<CONTAINER_PORT> \
  git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
```

---

## Troubleshooting

**`insufficient_scope` / `read_registry` / `write_registry` error**

group/project token ไม่มีสิทธิ์เพียงพอ ให้สร้าง PAT แทน

```bash
docker logout git.inet.co.th:5555
docker login git.inet.co.th:5555
# Username: <GITLAB_USERNAME>
# Password: <PERSONAL_ACCESS_TOKEN>
```

**`Invalid tag: missing manifest digest`**

เกิดจาก BuildKit provenance ให้ rebuild ด้วย `--provenance=false`

```bash
docker build --no-cache --provenance=false \
  -t git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION> . \
  && docker push git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
```