---
title: "K8s Control Plane Setup"
tags: [k8s, kubernetes, control-plane, kubeadm, cilium, metrics-server, headlamp]
type: guide
status: stable
created: 2026-04-26
related:
  - "[[infra_k8s_haproxy_lb]]"
  - "[[infra_k8s_cleanup_kubeadm]]"
  - "[[tool_k8s_preflight_tools]]"
---

# K8s Control Plane Setup

Initialize Kubernetes Control Plane บน master node หลัก พร้อมติดตั้ง CNI (Cilium), Metrics Server และ Headlamp GUI

## Prerequisites

- HAProxy Load Balancer พร้อมใช้งานบน `<LB_IP>:6443` → [[infra_k8s_haproxy_lb]]
- Node ผ่าน preflight checks ครบแล้ว → [[tool_k8s_preflight_tools]]
- มีสิทธิ์ `sudo` บน master node
- Node มี internet access สำหรับ download Cilium CLI และ components

## Steps

### Step 1: Configure Kubelet Node IP

กำหนด IP ที่ kubelet จะ advertise ให้ตรงกับ interface จริงของ node

```bash
echo 'KUBELET_EXTRA_ARGS=--node-ip=<MASTER_01_IP>' | sudo tee /etc/default/kubelet
sudo systemctl daemon-reexec
sudo systemctl restart kubelet
```

### Step 2: Initialize Kubernetes Cluster

```bash
sudo kubeadm init \
  --control-plane-endpoint "<LB_IP>:6443" \
  --apiserver-advertise-address <MASTER_01_IP> \
  --upload-certs
```

> **หมายเหตุ:** Join commands สำหรับ master และ worker nodes จะถูก generate ให้อัตโนมัติหลัง init สำเร็จ — บันทึกไว้ก่อนดำเนินการต่อ

### Step 3: Configure kubectl

```bash
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Step 4: Verify Cluster State

```bash
kubectl get nodes
```

Expected result:

- Node แสดงสถานะ `NotReady` — ปกติ เพราะยังไม่ได้ติดตั้ง CNI

### Step 5: Install Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi

curl -L --fail --remote-name-all \
  https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum

sudo tar xzvf cilium-linux-${CLI_ARCH}.tar.gz -C /usr/local/bin
rm -f cilium-linux-${CLI_ARCH}.tar.gz*
```

### Step 6: Install Cilium (CNI)

```bash
cilium install
cilium status --wait
```

### Step 7: Verify System Pods and Nodes

```bash
kubectl get pods -n kube-system
kubectl get nodes
```

Expected result:

- Node สถานะเปลี่ยนเป็น `Ready` หลัง Cilium พร้อม

### Step 8: Install Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### Step 9: Patch Metrics Server (Enable Insecure TLS)

```bash
kubectl edit deployment metrics-server -n kube-system
```

เพิ่ม argument ใน container spec:

```yaml
- --kubelet-insecure-tls
```

### Step 10: Verify Metrics Server

```bash
kubectl get pods -n kube-system
kubectl top nodes
```

### Step 11: Deploy Headlamp

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/headlamp/main/kubernetes-headlamp.yaml
```

### Step 12: Expose Headlamp via NodePort

```bash
kubectl edit svc headlamp -n kube-system
```

เปลี่ยน service type:

```yaml
spec:
  type: NodePort
```

### Step 13: Verify Headlamp Service

```bash
kubectl get svc,node -n kube-system -o wide
```

### Step 14: Create Headlamp Admin Service Account

```bash
kubectl -n kube-system create serviceaccount headlamp-admin
```

### Step 15: Grant Cluster Admin Role

```bash
kubectl create clusterrolebinding headlamp-admin \
  --serviceaccount=kube-system:headlamp-admin \
  --clusterrole=cluster-admin
```

### Step 16: Generate Headlamp Login Token

```bash
kubectl create token headlamp-admin -n kube-system
```

### Step 17: Retrieve kubeconfig (สำหรับ GUI Tools)

```bash
cat /root/.kube/config
```

## Troubleshooting

| อาการ | สาเหตุ | วิธีแก้ |
|-------|--------|---------|
| `kubeadm init` fail — port in use | มี process ค้างจาก init ก่อนหน้า | ทำ cleanup ก่อน → [[infra_k8s_cleanup_kubeadm]] |
| Node stuck `NotReady` นานเกิน 5 นาที | Cilium ติดตั้งไม่สำเร็จ | รัน `cilium status` ตรวจ error |
| `kubectl top nodes` ไม่มีข้อมูล | Metrics Server ยังไม่ ready | รัน `kubectl get pods -n kube-system` ตรวจ pod status |
| Headlamp เข้าไม่ได้ | NodePort ยังไม่ถูก expose | ตรวจ `kubectl get svc headlamp -n kube-system` ว่า type เป็น NodePort |

## References

- [kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/)
- [Cilium Installation](https://docs.cilium.io/en/stable/gettingstarted/k8s-install-default/)
- [Metrics Server](https://github.com/kubernetes-sigs/metrics-server)
- [Headlamp](https://headlamp.dev/docs/latest/)
