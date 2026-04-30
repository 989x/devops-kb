---
title: "HAProxy VIP Load Balancer Setup (Docker)"
tags: [load-balance, haproxy, docker, vip, tcp]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_lb_web_servers_setup]]"
---

# HAProxy VIP Load Balancer Setup (Docker)

ติดตั้ง HAProxy บน Docker เป็น TCP Load Balancer รับ traffic จาก VIP บน port 3333 และกระจายไปยัง backend nodes

## Prerequisites

- Docker Engine ติดตั้งแล้วบน node (ดู Step 1)
- Backend nodes พร้อมและ listen บน port 8080 → [[infra_lb_web_servers_setup]]
- มีสิทธิ์ `sudo` บน node

## Steps

### Step 1: Install Docker Engine

```bash
sudo apt update
sudo apt install -y ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Step 2: Validate Docker Installation

```bash
sudo systemctl status docker

# ถ้ายังไม่ running
sudo systemctl start docker

sudo docker run hello-world
```

### Step 3: Pre-check Network and Backends

```bash
# ตรวจว่า node เข้าถึง VIP ได้
ping -c 3 <LB_IP>

# ทดสอบ backend แต่ละตัว
curl -sS http://<BACKEND_01_IP>:8080/ | head
curl -sS http://<BACKEND_02_IP>:8080/ | head
```

Expected output:

```html
<html><body><h1>It works!</h1></body></html>
```

### Step 4: Prepare HAProxy Configuration

```bash
mkdir -p ~/haproxy-vip
cd ~/haproxy-vip
nano haproxy.cfg
```

เนื้อหา `haproxy.cfg`:

```
global
    log stdout format raw local0
    maxconn 2000

defaults
    log     global
    mode    tcp
    option  tcplog
    timeout connect 5s
    timeout client  50s
    timeout server  50s

frontend api
    bind *:3333
    default_backend web-server

backend web-server
    balance roundrobin
    server server-01 <BACKEND_01_IP>:8080 check
    server server-02 <BACKEND_02_IP>:8080 check
```

### Step 5: Run HAProxy Container

```bash
sudo docker pull haproxy:latest

# ลบ container เดิม (ถ้ามี)
sudo docker rm -f haproxy-vip 2>/dev/null || true

sudo docker run -d --name haproxy-vip \
  -p 3333:3333 \
  -v ~/haproxy-vip/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
  --restart always \
  haproxy:latest
```

### Step 6: Check Logs

```bash
sudo docker logs -f haproxy-vip
```

Expected:

```
[NOTICE] (1) : Loading success.
```

### Step 7: Connectivity Tests

```bash
# Local TCP test
nc -vz 127.0.0.1 3333

# Remote VIP test
curl -v http://<LB_IP>:3333/
```

Expected TCP test:

```
Connection to 127.0.0.1 3333 port [tcp/*] succeeded!
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| Container ไม่ start | `haproxy.cfg` syntax ผิด | ตรวจ logs ด้วย `sudo docker logs haproxy-vip` |
| Port 3333 ไม่ตอบสนอง | Container ยังไม่ run | ตรวจ `sudo docker ps` ว่า container status เป็น Up |
| Backend unreachable | Backend node ไม่ได้ run web server | ทดสอบด้วย `curl http://<BACKEND_01_IP>:8080/` โดยตรง |

## References

- [HAProxy Docker Hub](https://hub.docker.com/_/haproxy)
- [Docker Engine Install (Ubuntu)](https://docs.docker.com/engine/install/ubuntu/)
