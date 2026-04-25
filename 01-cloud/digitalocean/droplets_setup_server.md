---
title: Droplets Server Setup
tags: [cloud, digitalocean, docker, nodejs, mongodb]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[droplets_ssh_access]]"
  - "[[droplets_setup_env]]"
---

# Droplets Server Setup

ขั้นตอนติดตั้ง stack หลักบน DigitalOcean Droplet (Ubuntu 20.04/22.04)
ประกอบด้วย Docker, Node.js + pnpm และ MongoDB

## Prerequisites

- Connect เข้า Droplet ได้แล้ว → [[droplets_ssh_access]]
- ใช้ Ubuntu 20.04 หรือ 22.04

---

## 1. Install Docker

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
newgrp docker
```

ตรวจสอบ

```bash
docker --version
docker run hello-world
```

---

## 2. Install Node.js LTS + pnpm (via Corepack)

```bash
# ติดตั้ง Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# เปิดใช้ Corepack และ pnpm v9 (system-wide)
sudo corepack enable
sudo corepack prepare pnpm@9 --activate

# เปิดใช้สำหรับ current user
corepack enable
corepack prepare pnpm@9 --activate
```

ตรวจสอบ

```bash
node -v
pnpm -v
```

### ทางเลือก: One-liner installer (ไม่ใช้ Corepack)

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
# เปิด terminal ใหม่ แล้วตรวจสอบ
pnpm -v
```

### Optional: ตั้งค่า pnpm global store

ช่วยให้ `node_modules` เบาลง เหมาะถ้า Droplet มี disk จำกัด

```bash
mkdir -p ~/.pnpm-store
pnpm config set store-dir ~/.pnpm-store
```

---

## 3. Install MongoDB (Docker)

> เปลี่ยน password จาก `secret123` ก่อน run จริงเสมอ

```bash
docker run -d --name mongo \
  -p 27017:27017 \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD='<YOUR_PASSWORD>' \
  -v mongo_data:/data/db \
  mongo:7.0 --bind_ip_all
```

ตรวจสอบ

```bash
docker logs -f mongo        # Ctrl+C เพื่อออก
docker exec -it mongo mongosh -u admin -p
```

Connection string สำหรับ app

```
mongodb://admin:<YOUR_PASSWORD>@<SERVER_IP>:27017/?authSource=admin
```

### Firewall (กรณี app อยู่คนละ server)

```bash
sudo ufw allow from <APP_SERVER_IP> to any port 27017 proto tcp
sudo ufw status
```

### MongoDB Commands ที่ใช้บ่อย

| Command | ความหมาย |
|---------|---------|
| `docker ps` | ดู container ที่รันอยู่ |
| `docker stop mongo` | หยุด MongoDB |
| `docker start mongo` | เริ่ม MongoDB |
| `docker logs -f mongo` | ดู log realtime |
| `docker exec -it mongo mongosh -u admin -p` | เข้า mongo shell |