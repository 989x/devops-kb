---
title: INET Server Deploy
tags: [cloud, inet, docker, deploy]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[registry_docker]]"
---

# INET Server Deploy

คู่มือ Deploy และ Update service บน INET Server ด้วย Docker Compose
ใช้ได้กับทุก service: `backend`, `frontend`, `plugin`

## Prerequisites

- เชื่อมต่อ INET ผ่าน OpenVPN แล้ว
- มีสิทธิ์ SSH เข้า server
- Image พร้อมบน registry แล้ว → [[registry_docker]]

## Server Structure (UAT)

**Host:** `JongJong-APP-01-UAT` • **Base:** `/home/JongJong`

```
/home/JongJong
├─ deployment/
│  ├─ backend/
│  ├─ frontend/
│  └─ plugin/
│     └─ docker-compose.yaml
├─ devops-iac-script/
│  ├─ files/
│  │  ├─ grafana&prometheus/
│  │  ├─ jenkins-server/
│  │  ├─ keydb/
│  │  ├─ minio/
│  │  ├─ monitor/
│  │  ├─ nfs/
│  │  ├─ proxy/
│  │  ├─ rabbitmq/
│  │  ├─ rancher/
│  │  ├─ redis/
│  │  └─ sonarqube/
│  ├─ script/
│  │  ├─ actions/
│  │  ├─ CHANGELOG.md
│  │  ├─ get-docker.sh
│  │  ├─ main.sh
│  │  ├─ README.md
│  │  └─ setup.txt
│  └─ utils/
│     ├─ file-request.sh
│     ├─ logger.sh
│     ├─ random-password.sh
│     └─ README.md
└─ monitor-se/
   ├─ docker-compose.yml
   └─ prometheus/
      ├─ prometheus.yml
      └─ data/
```

แต่ละ service มี `docker-compose.yaml` ของตัวเองใน `deployment/<SERVICE>/`

---

## Deploy / Update Service

### Step 1: SSH เข้า Server

```bash
ssh <SERVER_USER>@<SERVER_IP>
```

### Step 2: Elevate Privileges

```bash
sudo su
```

### Step 3: ไปที่ directory ของ service

```bash
cd /home/<SERVER_USER>/deployment/<SERVICE>
# ตัวอย่าง: cd /home/<SERVER_USER>/deployment/frontend
```

### Step 4: Backup compose file ก่อนแก้ไข

```bash
cp docker-compose.yaml docker-compose.yaml.bak.$(date +%Y%m%d%H%M%S)
```

### Step 5: แก้ไข compose file (ถ้าต้องการ)

```bash
nano docker-compose.yaml
# บันทึก: Ctrl+O แล้ว Enter
# ออก:  Ctrl+X
```

สิ่งที่มักแก้ไขบ่อย

| Field | ตัวอย่าง |
|-------|--------|
| `image` tag | เปลี่ยน version เช่น `v0.0.6` → `v0.0.7` |
| `ports` | เปลี่ยน host port ถ้าชนกัน |
| `env_file` | เปิด comment ถ้าต้องใช้ `.env` |

### Step 6: Recreate Stack

```bash
docker compose down
docker compose up -d
```

### Step 7: ตรวจสอบ

```bash
docker compose ps        # ดูสถานะ container
docker compose logs -f   # ดู log realtime (Ctrl+C เพื่อออก)
```

---

## ตัวอย่าง docker-compose.yaml

```yaml
version: '3.8'

services:
  <SERVICE_NAME>:
    container_name: <CONTAINER_NAME>
    image: git.inet.co.th:5555/<GROUP>/<PROJECT>/<ENV>:<VERSION>
    ports:
      - '<HOST_PORT>:<CONTAINER_PORT>'
    restart: unless-stopped
    # env_file:
    #   - .env
    # volumes:
    #   - ./public:/app/public
```

---

## Docker Compose Commands ที่ใช้บ่อย

| Command | ความหมาย |
|---------|---------|
| `docker compose ps` | ดูสถานะ container ทั้งหมด |
| `docker compose up -d` | Start stack (background) |
| `docker compose down` | Stop และลบ container |
| `docker compose logs -f` | ดู log realtime |
| `docker compose pull` | Pull image ใหม่จาก registry |
| `docker compose restart` | Restart ทุก service |