# DaemonSet — Node Agent บน OpenLandscape Cloud

> **Platform:** OpenLandscape (OKD)
> **Namespace:** `cust-demo`
> **Team:** xops
> **Version:** 1.0 · เมษายน 2569

---

## 1. DaemonSet คืออะไร

DaemonSet คือ workload ที่สั่งให้ Kubernetes deploy **1 pod ต่อ 1 node** อัตโนมัติ เมื่อเพิ่ม node ใหม่ pod จะถูกสร้างทันที เมื่อลบ node pod จะหายไปเองโดยไม่ต้องสั่ง

```mermaid
graph TB
    subgraph Deployment
        DP[replicas: 3]
        DP --> PA[pod-aaa]
        DP --> PB[pod-bbb]
        DP --> PC[pod-ccc]
        PA --> NA[node ใดก็ได้]
        PB --> NA
        PC --> NA
    end

    subgraph DaemonSet
        DS[ไม่มี replicas]
        DS --> N1[node-1] & N2[node-2] & N3[node-3]
        N1 --> P1[1 pod]
        N2 --> P2[1 pod]
        N3 --> P3[1 pod]
    end
```

---

## 2. Use Case

| Use Case | ตัวอย่าง |
|---|---|
| Log collector | Fluentd, Filebeat |
| Monitoring agent | Prometheus Node Exporter |
| Network plugin | Calico, Cilium |
| Security scanner | Falco |
| Demo / ทดสอบ | nginx จำลอง agent |

---

## 3. Architecture Overview

```mermaid
graph TB
    subgraph Cluster
        subgraph NS["namespace: cust-demo"]
            DS["DaemonSet: xops-ds-node-agent"]
        end

        DS --> W1["worker-node-1\nxops-ds-node-agent-aaaaa"]
        DS --> W2["worker-node-2\nxops-ds-node-agent-bbbbb"]
        DS --> W3["worker-node-3\nxops-ds-node-agent-ccccc"]
    end

    NewNode["worker-node-4 (ใหม่)"] -->|เพิ่ม node| DS
    DS -->|auto deploy| W4["worker-node-4\nxops-ds-node-agent-ddddd"]
```

---

## 4. ลำดับการสร้าง

```mermaid
sequenceDiagram
    participant User
    participant Console as OKD Console
    participant K8s as Kubernetes API

    User->>Console: Workloads → DaemonSets → Create DaemonSet
    Console->>User: เปิด YAML editor
    User->>Console: วาง YAML + Create
    Console->>K8s: POST /apis/apps/v1/daemonsets
    K8s->>K8s: นับจำนวน worker node
    K8s->>K8s: Schedule 1 pod ต่อ node
    K8s-->>Console: DaemonSet Ready
    Note over K8s: ไม่มี replicas field
```

---

## 5. YAML + คำอธิบาย

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: xops-ds-node-agent      # ชื่อ DaemonSet
  namespace: cust-demo
spec:
  selector:
    matchLabels:
      app: xops-node-agent       # ต้องตรงกับ template.labels
  template:
    metadata:
      labels:
        app: xops-node-agent
    spec:
      containers:
        - name: node-agent
          image: quay.io/jitesoft/nginx:latest   # image ที่ผ่านแล้ว
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: 50m            # ใช้ resource น้อย เพราะรันทุก node
              memory: 64Mi
            limits:
              cpu: 100m
              memory: 128Mi
```

> **หมายเหตุ:** ไม่มี `replicas` field — DaemonSet ควบคุมจำนวน pod เองตาม node

---

## 6. ตรวจสอบหลัง Deploy

| ไปดูที่ | สิ่งที่ควรเห็น |
|---|---|
| Workloads → DaemonSets | `xops-ds-node-agent` สถานะ Ready |
| Workloads → Pods | pod ชื่อ `xops-ds-node-agent-xxxxx` หลายตัว |
| คอลัมน์ Node ใน Pods list | แต่ละ pod อยู่คนละ node |
| จำนวน pod | ต้องเท่ากับจำนวน worker node |

---

## 7. ทดสอบ

```mermaid
flowchart TD
    A[Workloads → DaemonSets\nดู xops-ds-node-agent Ready] --> B[Workloads → Pods\nนับจำนวน pod]
    B --> C{จำนวน pod\n= จำนวน node?}
    C -->|ใช่| D[คลิกแต่ละ pod\nดูคอลัมน์ Node]
    C -->|ไม่ใช่| E[ดู Events\nหา error]
    D --> F{แต่ละ pod\nอยู่คนละ node?}
    F -->|ใช่| G[เข้า Terminal\npod ใดก็ได้]
    F -->|ไม่ใช่| E
    G --> H[curl localhost:80\nต้องได้ Welcome to nginx]
    H --> I[DaemonSet ทำงานสมบูรณ์]
```

**คำสั่งทดสอบใน Terminal**

```bash
# ตรวจว่า process ทำงาน
ps aux

# ทดสอบ port
curl localhost:80
```

---

## 8. Resource Summary

| Resource | ชื่อ | หมายเหตุ |
|---|---|---|
| DaemonSet | `xops-ds-node-agent` | 1 pod ต่อ worker node |
| Pod | `xops-ds-node-agent-xxxxx` | ชื่อ random ต่อ node |
| Service | ไม่จำเป็น | ขึ้นอยู่กับ use case |
| PVC | ไม่มี | agent ไม่ต้องการ persistent storage |

---

## เปรียบเทียบ 3 Workload Types

```mermaid
graph LR
    subgraph Deployment
        D["Stateless App\nWeb / API\nreplicas กำหนดเอง"]
    end

    subgraph StatefulSet
        S["Stateful App\nDatabase / Queue\nชื่อ pod คงที่ + PVC"]
    end

    subgraph DaemonSet
        DS["Node Agent\nLog / Monitor\n1 pod ต่อ node"]
    end
```