---
title: "HAProxy Load Balancer for K8s API"
tags: [k8s, kubernetes, haproxy, load-balancer, setup]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_k8s_control_plane]]"
---

# HAProxy Load Balancer for K8s API

ติดตั้งและ configure HAProxy ให้ทำหน้าที่เป็น Load Balancer สำหรับ Kubernetes API Server บน port 6443

## Prerequisites

- Node ที่จะใช้เป็น LB ต้องติดตั้ง Ubuntu และเข้าถึงได้ทาง SSH
- มีสิทธิ์ `sudo` บน node
- Master nodes ทุกตัวต้องพร้อมและ reachable ก่อน configure backend
- Port 6443 ต้องไม่มี process อื่น listen อยู่ (ตรวจสอบด้วย [[tool_k8s_preflight_tools]])

## Steps

### Step 1: Install HAProxy

```bash
sudo apt update
sudo apt install haproxy -y
sudo systemctl enable haproxy
```

### Step 2: Backup Default Configuration

```bash
sudo cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg-backup
```

### Step 3: Configure HAProxy

เปิดไฟล์ config:

```bash
sudo vi /etc/haproxy/haproxy.cfg
```

เพิ่ม configuration ต่อไปนี้ที่ท้ายไฟล์:

```cfg
frontend k8s-api-server
    bind *:6443
    mode tcp
    option tcplog
    default_backend k8s-api-server

backend k8s-api-server
    mode tcp
    balance source
    server <MASTER_01_HOSTNAME> <MASTER_01_IP>:6443 check
    server <MASTER_02_HOSTNAME> <MASTER_02_IP>:6443 check
```

### Step 4: Restart HAProxy

```bash
sudo systemctl restart haproxy
sudo systemctl status haproxy
```

### Step 5: Verify Listener

```bash
sudo ss -lntp | grep 6443
```

Expected result:

- HAProxy listening on `0.0.0.0:6443`

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `haproxy.service` failed to start | Config syntax ผิด | รัน `haproxy -c -f /etc/haproxy/haproxy.cfg` เพื่อตรวจ |
| Port 6443 ไม่ขึ้น | Backend IP ผิด หรือ haproxy ไม่ได้ restart | ตรวจ `haproxy.cfg` แล้ว restart ใหม่ |
| Backend server unreachable | Master node ยังไม่พร้อม | ใช้ `nc -zv <MASTER_01_IP> 6443` ตรวจการเชื่อมต่อ |

## References

- [HAProxy Documentation](https://www.haproxy.org/#docs)
- [kubeadm HA Topology](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/ha-topology/)
