---
title: "Web Servers Setup for Backend Nodes (Apache / Nginx)"
tags: [load-balance, apache, nginx, docker, backend]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_lb_haproxy_vip]]"
---

# Web Servers Setup for Backend Nodes (Apache / Nginx)

ติดตั้ง Apache หรือ Nginx บน backend nodes ผ่าน Docker เพื่อรองรับ traffic จาก HAProxy

## Prerequisites

- Docker Engine ติดตั้งแล้วบนทุก backend node → [[infra_lb_haproxy_vip]] Step 1
- มีสิทธิ์ `sudo` บน node
- Backend nodes ต้อง reachable จาก HAProxy node

## Lab Topology

| Node                   | IP               | Gateway        | Subnet | Zone                        | หมายเหตุ                  |
| ---------------------- | ---------------- | -------------- | ------ | --------------------------- | ------------------------- |
| `<LB_HOSTNAME>`        | `<LB_IP>`        | `<GATEWAY_IP>` | /24    | VFW securezone2 (VLAN 2520) | Load Balancer (HAProxy)   |
| `<SERVER_01_HOSTNAME>` | `<SERVER_01_IP>` | `<GATEWAY_IP>` | /24    | VFW securezone2 (VLAN 2520) | Web Server (Apache/Nginx) |
| `<SERVER_02_HOSTNAME>` | `<SERVER_02_IP>` | `<GATEWAY_IP>` | /24    | VFW securezone2 (VLAN 2520) | Web Server (Apache/Nginx) |

Backend nodes จะ listen บน **port 8080** และ HAProxy จะ forward traffic มาที่ port นี้

## Steps

### Step 1: Basic Checks on Each Backend Node

รันบน **ทุก backend node**:

```bash
hostname -I
ip route
ping -c 3 <LB_IP>
```

### Step 2: Choose Web Server

---

#### Option A — Apache via Docker

##### 2A.1 Start Apache Container

```bash
docker pull httpd

docker run -dit --name my-apache-server -p 8080:80 httpd
```

##### 2A.2 Test Apache

```bash
curl -sS http://127.0.0.1:8080/ | head
```

Expected output:

```html
<html><body><h1>It works!</h1></body></html>
```

---

#### Option B — Nginx via Docker

##### 2B.1 Start Nginx Container

```bash
# ลบ container เดิม (ถ้ามี)
sudo docker rm -f web 2>/dev/null || true

sudo docker run -d --name web \
  --restart always \
  -p 8080:80 \
  nginx
```

##### 2B.2 Test Nginx

```bash
curl -sS http://127.0.0.1:8080/ | head
```

Expected: Nginx default page

---

### Step 3: Failover Test — Stop Backend Container

ใช้สำหรับทดสอบ HAProxy health check:

```bash
# หยุด container แต่ยังเก็บไว้
sudo docker stop web

# หรือลบออกเลย
sudo docker rm -f web
```

ตรวจว่า port 8080 ไม่มี listener แล้ว:

```bash
sudo ss -lntp | grep ':8080' || echo "no listener on :8080"
curl -v http://127.0.0.1:8080/ || true
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `curl` ไม่ตอบสนองบน 8080 | Container ไม่ได้ run | ตรวจ `sudo docker ps` |
| HAProxy ไม่ส่ง traffic มา | Backend IP ใน `haproxy.cfg` ผิด | ตรวจ config ใน [[infra_lb_haproxy_vip]] |
| Port 8080 ถูก process อื่น ใช้อยู่ | มี service อื่น bind port เดิม | รัน `sudo ss -lntp | grep 8080` เพื่อหา process |

## References

- [Apache httpd Docker Hub](https://hub.docker.com/_/httpd)
- [Nginx Docker Hub](https://hub.docker.com/_/nginx)
