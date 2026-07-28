---
title: "Tool: kube-hunter"
tags: [container, k8s, tool, security]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[tool_trivy]]"
  - "[[tool_k9s]]"
---

# Tool: kube-hunter

kube-hunter เป็น open-source security scanner โดย Aqua Security
ทำ penetration-style scanning โดยจำลอง attacker perspective เพื่อหา exposed services และ misconfigurations

> Validated บน `k8s101-master-01` (Ubuntu) โดยใช้ container-based execution (Podman)

## Tested Topology

| Role | IP |
|------|----|
| Load Balancer | `<LB_IP>` |
| Master 1 | `<MASTER_1_IP>` |
| Master 2 | `<MASTER_2_IP>` |
| Master 3 | `<MASTER_3_IP>` |
| Worker 1 | `<WORKER_1_IP>` |
| Worker 2 | `<WORKER_2_IP>` |
| Worker 3 | `<WORKER_3_IP>` |

## Execution Model

### Container (Recommended)

ไม่ต้องติดตั้ง Python หรือ package ใดๆ บน host

```bash
sudo apt update && sudo apt install -y podman-docker
docker run -it --rm --network host docker.io/aquasec/kube-hunter:latest
```

### CLI (Not Used)

CLI ผ่าน pip/pipx มี dependency management ซับซ้อนบน modern Ubuntu (PEP 668)
ไม่มีความแตกต่างด้าน scanning capability จาก container

---

## Scan Modes

### 1. Remote Scanning (แนะนำสำหรับ production)

Scan specific IPs จาก external attacker perspective

```bash
# Interactive
docker run -it --rm --network host docker.io/aquasec/kube-hunter:latest
# เลือก: 1 → ใส่ <LB_IP>

# Non-interactive
docker run --rm --network host docker.io/aquasec/kube-hunter:latest \
  --remote <LB_IP>

# Scan ทุก node
docker run --rm --network host docker.io/aquasec/kube-hunter:latest \
  --remote <LB_IP>,<MASTER_1_IP>,<MASTER_2_IP>,<MASTER_3_IP>,<WORKER_1_IP>,<WORKER_2_IP>,<WORKER_3_IP>
```

**Typical Findings:** Kubernetes API Server (`6443`), Kubelet ports (`10250`), NodePort exposure

### 2. Interface Scanning

Scan subnets ของ host's network interfaces จำลอง attacker ที่อยู่ใน internal network แล้ว

```bash
# Interactive
docker run -it --rm --network host docker.io/aquasec/kube-hunter:latest
# เลือก: 2
```

> ⚠️ ใช้ด้วยความระมัดระวังใน production เพราะ scan กว้าง

### 3. CIDR Scanning

Scan subnet ที่กำหนดเอง เหมาะสำหรับ staging หรือ scheduled security audit

CIDR format ตัวอย่าง: `172.16.51.0/24` (ครอบคลุม .1–.254 ทั้ง subnet)

```bash
# Interactive
docker run -it --rm --network host docker.io/aquasec/kube-hunter:latest
# เลือก: 3 → ใส่ <SUBNET>.0/24

# Non-interactive
docker run --rm --network host docker.io/aquasec/kube-hunter:latest \
  --cidr <SUBNET>.0/24
```

> ⚠️ Noisy กว่า remote scan อาจ trigger IDS/monitoring

---

## Active Mode

```bash
--active
```

> ⛔ ห้ามใช้ใน production — active mode อาจเปลี่ยนแปลง cluster state

---

## Operational Recommendations

1. เริ่มด้วย **Remote scan กับ Load Balancer** ก่อนเสมอ
2. ขยายไป **node-by-node remote scan** ถ้าต้องการละเอียดขึ้น
3. ใช้ **Interface / CIDR scan เฉพาะ internal audit**
4. ใช้เป็น **security assessment tool** ไม่ใช่ compliance scanner
5. Validate findings ก่อน apply remediation เสมอ

## References

- [github.com/aquasecurity/kube-hunter](https://github.com/aquasecurity/kube-hunter)