---
title: INET MinIO Deployment
tags: [cloud, inet, minio, storage, infra]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[server_deploy]]"
---

# INET MinIO Deployment

คู่มือ Deploy MinIO บน INET Server ทั้งแบบ Single-Node และ Replica (Distributed)

## Prerequisites

- เชื่อมต่อ INET ผ่าน OpenVPN แล้ว
- Connect เข้า server ได้แล้ว → [[server_deploy]]
- **Single-node path:** `/home/JongJong/devops-iac-script/files/minio/single-node/docker-compose.yml`
- **Replica path:** `/home/JongJong/devops-iac-script/files/minio/replica/docker-compose.yml`

---

## Single-Node Setup

### docker-compose.yml

```yaml
services:
  minio:
    image: minio/minio:RELEASE.2025-04-22T22-12-26Z
    container_name: minio
    restart: unless-stopped
    ports:
      - 9000:9000
      - 9001:9001
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: <YOUR_PASSWORD>
      MINIO_SCANNER_SPEED: fastest
      MINIO_HTTP_TRACE: /tmp/minio.log
    volumes:
      - ./data:/data
    command: server /data --console-address ":9001"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
```

### Run / Update

```bash
cd /home/JongJong/devops-iac-script/files/minio/single-node
docker compose up -d
docker compose ps
docker compose logs -f minio
```

---

## Replica (Distributed) Setup

รัน **1 node ต่อ 1 host** แต่ละ node ชี้หา peer ผ่าน `extra_hosts`

### Template

```yaml
services:
  <HOSTNAME>:                          # เปลี่ยนต่อ node เช่น minio1
    hostname: <HOSTNAME>
    container_name: minio
    image: minio/minio:RELEASE.2025-04-22T22-12-26Z
    command: server --console-address ":9001" http://minio{1...3}/data
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    extra_hosts:
      - "minio1:<NODE_1_IP>"
      - "minio2:<NODE_2_IP>"
      - "minio3:<NODE_3_IP>"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: <YOUR_PASSWORD>
      MINIO_SCANNER_SPEED: fastest
    volumes:
      - ./data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
```

### ตัวอย่าง node `minio1`

> ทำซ้ำบน `minio2`, `minio3` โดยเปลี่ยน `hostname` และ service key ให้ตรงกับ node นั้น

```yaml
services:
  minio1:
    hostname: minio1
    container_name: minio
    image: minio/minio:RELEASE.2025-04-22T22-12-26Z
    command: server --console-address ":9001" http://minio{1...3}/data
    restart: unless-stopped
    ports:
      - "9000:9000"
      - "9001:9001"
    extra_hosts:
      - "minio1:<NODE_1_IP>"
      - "minio2:<NODE_2_IP>"
      - "minio3:<NODE_3_IP>"
    environment:
      MINIO_ROOT_USER: admin
      MINIO_ROOT_PASSWORD: <YOUR_PASSWORD>
      MINIO_SCANNER_SPEED: fastest
    volumes:
      - ./data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000/minio/health/live"]
      interval: 30s
      timeout: 20s
      retries: 3
```

### Start / Verify (ทำทุก node)

```bash
cd /home/JongJong/devops-iac-script/files/minio/replica
docker compose up -d
docker compose ps
docker compose logs -f
```

เมื่อทุก node ขึ้นแล้ว เข้าถึงได้ที่

| Service | URL |
|---------|-----|
| Console UI | `http://<NODE_IP>:9001` |
| S3 API | `http://<NODE_IP>:9000` |

---

## Tips & Notes

- `MINIO_ROOT_PASSWORD` ควรใช้ string ที่แข็งแรง หรือเก็บใน `.env` / secret manager
- ทุก node ใน Replica ต้องใช้ **image tag เดียวกัน**
- `./data` เป็น per-host ควรดูแล disk และทำ backup สม่ำเสมอ
- Healthcheck ช่วยให้ Compose restart container ที่ unhealthy อัตโนมัติ
- port `9000`/`9001` ต้องไม่ชนกับ service อื่นบน host เดียวกัน

## Troubleshooting

**`bash: cd: docker-compose.yml: Not a directory`**

`cd` เข้าไฟล์ไม่ได้ ให้เปิดด้วย editor แทน

```bash
nano docker-compose.yml
```