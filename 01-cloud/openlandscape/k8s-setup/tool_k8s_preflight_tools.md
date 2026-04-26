---
title: "K8s Preflight Tools"
tags: [k8s, kubernetes, preflight, tools, port-guard, bash]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_k8s_haproxy_lb]]"
  - "[[infra_k8s_control_plane]]"
---

# K8s Preflight Tools

Script สำหรับตรวจสอบความพร้อมของ node และ port conflicts ก่อนเริ่ม Kubernetes setup

## Prerequisites

- Bash 4.0 ขึ้นไป
- `k8s-preflight.sh` — ต้องมี `kubectl` และ kubeconfig พร้อม (ใช้หลัง cluster init)
- `preflight-port-guard.sh` — ต้องรันด้วยสิทธิ์ `root`

## Tools

### tool_k8s_preflight.sh — Node Readiness Check

ตรวจสอบ node ว่าผ่าน requirements ทั้งหมดก่อน deploy cluster

**สิ่งที่ตรวจ:**

| Check | รายละเอียด |
|-------|-----------|
| SWAP disabled | ต้องปิด swap ก่อน K8s ทำงาน |
| Kernel modules | `overlay`, `br_netfilter` ต้อง loaded |
| sysctl settings | `ip_forward`, `bridge-nf-call-iptables` ต้องเปิด |
| containerd | ต้อง active และ config `SystemdCgroup = true` |
| K8s binaries | `kubeadm`, `kubelet`, `kubectl` ต้องมีครบ |
| kubelet service | ต้อง active |
| Helper packages | `open-iscsi`, `nfs-common`, `net-tools` |
| Helm | ต้องมีและ execute ได้ |
| Cluster nodes | ตรวจ node status และ IP |

**วิธีรัน:**

```bash
chmod +x tool_k8s_preflight.sh
./tool_k8s_preflight.sh
```

**ตัวอย่าง output:**

```
[12:00:01] [INFO] SWAP is disabled: passed
[12:00:01] [INFO] kernel module 'overlay' is loaded: passed
[12:00:01] [WARNING] binary 'helm' is not installed
...
[12:00:02] [INFO] preflight summary: passed=12, failed=1
```

---

### tool_k8s_port_guard.sh — Port Conflict Check

ตรวจสอบ listening ports และ validate ว่าไม่มี port conflicts บน node

**สิ่งที่ตรวจ:**

| Port | Service |
|------|---------|
| 22 | SSH |
| 53 | DNS |
| 80 | HTTP |
| 443 | HTTPS |
| 6443 | Kubernetes API |

**วิธีรัน:**

```bash
chmod +x tool_k8s_port_guard.sh
sudo ./tool_k8s_port_guard.sh
```

> ต้องรันด้วย `sudo` เพราะอ่าน kernel socket state โดยตรง

**ตัวอย่าง output:**

```
PROTO  PORT    PID      PROCESS                NOTE
----------------------------------------------------------------------
tcp    22      1234     sshd                   SSH
tcp    6443    5678     haproxy                Kubernetes API
...
[12:00:01] [INFO] preflight summary: passed=5, failed=0
[12:00:01] [INFO] preflight PASSED - no runtime port conflicts detected
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `preflight FAILED` — SWAP enabled | ยังไม่ได้ปิด swap | `sudo swapoff -a` และ comment swap ใน `/etc/fstab` |
| `kernel module not loaded` | Module ยังไม่ได้ load | `sudo modprobe overlay && sudo modprobe br_netfilter` |
| `port_guard` — multiple listeners on 6443 | HAProxy + process อื่น bind port เดียวกัน | ตรวจด้วย `sudo ss -lntp | grep 6443` และ kill process ที่ไม่ต้องการ |
| Permission denied | รัน `port_guard` โดยไม่มี sudo | รันใหม่ด้วย `sudo ./tool_k8s_port_guard.sh` |

## References

- [Kubernetes Node Preparation](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
