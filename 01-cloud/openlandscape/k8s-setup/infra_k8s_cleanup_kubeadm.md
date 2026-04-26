---
title: "K8s Node Cleanup (After kubeadm init)"
tags: [k8s, kubernetes, kubeadm, cleanup, reset]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_k8s_control_plane]]"
  - "[[tool_k8s_preflight_tools]]"
---

# K8s Node Cleanup (After kubeadm init)

Reset node ที่เคยรัน `kubeadm init` กลับสู่สถานะ node preparation เพื่อเริ่ม cluster creation ใหม่จากศูนย์

## Prerequisites

- ใช้กับ node ที่รัน `kubeadm init` หรือ `kubeadm init` ค้างไปกลางคัน **เท่านั้น**
- โดยปกติใช้กับ first control-plane node เช่น `<MASTER_01_HOSTNAME>`
- **ห้ามใช้กับทุก node โดยไม่ตรวจสอบก่อน**

## Steps

### Step 1: Reset kubeadm

Force reset ทุก state ที่ kubeadm จัดการ

```bash
sudo kubeadm reset -f
```

### Step 2: Remove Kubernetes Configuration and Data

ลบไฟล์และ directory ทั้งหมดที่เกี่ยวกับ cluster

```bash
sudo rm -rf /etc/kubernetes
sudo rm -rf /var/lib/etcd
sudo rm -rf ~/.kube
sudo rm -rf /home/ubuntu/.kube
```

### Step 3: Clear Kubelet Runtime State

ลบ pod และ volume state ที่ค้างอยู่

```bash
sudo rm -rf /var/lib/kubelet/*
```

### Step 4: Restart Required Services

หลัง cleanup ควรมีเฉพาะ container runtime และ kubelet เท่านั้นที่ running

```bash
sudo systemctl restart containerd
sudo systemctl restart kubelet
```

### Step 5: Verify No Control-Plane Ports In Use

ตรวจว่า port ทุกตัวของ control plane ว่างทั้งหมด

```bash
sudo ss -lntp | egrep '6443|2379|2380|10250|10257|10259' || true
```

Expected result:

- ไม่มี output — แปลว่าไม่มี port ใดถูก listen อยู่

## Notes

- **ห้าม** ใช้ `--ignore-preflight-errors` เป็น workaround
- ทำ cleanup node ให้ถูกต้องก่อนเสมอก่อนรัน `kubeadm init` ใหม่
- Procedure นี้ปลอดภัยและสอดคล้องกับ official kubeadm behavior

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `kubeadm reset` ติด error | มี process ค้างอยู่ | รัน `sudo systemctl stop kubelet` ก่อน แล้วค่อย reset |
| Port ยังถูก listen หลัง reset | Container ยังค้างอยู่ | รัน `sudo crictl rm --all --force` แล้ว restart containerd |
| `/var/lib/kubelet/*` ลบไม่ได้ | mount point ค้าง | รัน `sudo umount /var/lib/kubelet/pods/*/volumes/*/*` ก่อน |

## References

- [kubeadm reset](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-reset/)
