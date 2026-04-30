# StatefulSet — MySQL บน OpenLandscape Cloud

> **Platform:** OpenLandscape (OKD)
> **Namespace:** `cust-demo`
> **Team:** xops
> **Version:** 1.0 · เมษายน 2569

---

## ทำไมต้อง StatefulSet?

```mermaid
graph LR
    subgraph DEP["Deployment"]
        DA["pod-abc123"] -->|restart| DB["pod-xyz999"]
        DB -->|restart| DC["pod-qqq111"]
    end

    subgraph STS["StatefulSet"]
        SA["mysql-0"] -->|restart| SB["mysql-0"]
        SB -->|restart| SC["mysql-0"]
    end

    DEP --- NOTE1["ชื่อเปลี่ยนทุกครั้ง\nDNS ชี้ไม่ถูก"]
    STS --- NOTE2["ชื่อเดิมเสมอ\nDNS ชี้ถูกต้อง"]
```

**ความต่างหลัก**

| | Deployment | StatefulSet |
|---|---|---|
| ชื่อ Pod | random hash | ลำดับคงที่ เช่น `mysql-0` |
| Storage | ใช้ร่วมกันหรือไม่มี | PVC ของตัวเองต่อ pod |
| การ deploy | พร้อมกัน | ทีละตัว ตามลำดับ |
| ใช้กับ | Web, API | Database, Queue |

---

## Architecture Overview

```mermaid
graph TB
    Client["Client / Application"]
    SVC["Headless Service: xops-svc-mysql\nclusterIP: None"]
    POD["Pod: xops-sts-mysql-0"]
    PVC["PVC: xops-pvc-mysql-xops-sts-mysql-0"]
    PV["PersistentVolume"]

    NS["namespace: cust-demo"]:::label
    STS["StatefulSet: xops-sts-mysql"]:::label

    Client -->|"port 3306"| SVC
    SVC -->|"DNS"| POD
    POD -->|"/var/lib/mysql/data"| PVC
    PVC -->|"Bound"| PV

    NS -.-> SVC
    NS -.-> POD
    NS -.-> PVC
    NS -.-> PV
    STS -.-> POD

    classDef label fill:none,stroke:#888,stroke-dasharray:4,color:#aaa
```

---

## ลำดับการสร้าง Resource

```mermaid
sequenceDiagram
    participant User
    participant Console as OKD Console
    participant K8s as Kubernetes API
    participant Storage as Storage Provisioner

    User->>Console: 1. สร้าง Headless Service
    Console->>K8s: POST /api/v1/services (clusterIP: None)
    K8s-->>Console: Service xops-svc-mysql created

    User->>Console: 2. สร้าง StatefulSet
    Console->>K8s: POST /apis/apps/v1/statefulsets
    K8s->>Storage: Request PVC 1Gi
    Storage-->>K8s: PV provisioned + Bound
    K8s->>K8s: Schedule pod xops-sts-mysql-0
    K8s-->>Console: Pod Running

    Note over K8s: fsGroup: 27 chown /var/lib/mysql/data ให้ mysql user เขียนได้
```

---

## Logic การแก้ปัญหาที่เจอ

```mermaid
flowchart TD
    Start([Deploy StatefulSet]) --> Pull{Image Pull?}

    Pull -->|Fail: manifest unknown| IP[เปลี่ยน image\ncentos7 ถูกยกเลิกแล้ว]
    IP --> Use[ใช้ quay.io/sclorg/mysql-80-c9s]
    Use --> Pull2{Image Pull?}
    Pull2 -->|Success| Init{Initialize DB?}

    Pull -->|Success| Init

    Init -->|Error: case-insensitive FS| LC[เพิ่ม ENV\nMYSQL_LOWER_CASE_TABLE_NAMES=1]
    LC --> Init2{Initialize DB?}
    Init2 -->|Error: Permission denied| Perm[เพิ่ม securityContext\nfsGroup: 27]
    Perm --> Init3{Initialize DB?}
    Init3 -->|Success| Mount{Mount Volume?}

    Init -->|Success| Mount
    Mount -->|mountPath ผิด| MP[แก้เป็น /var/lib/mysql/data]
    MP --> Mount2{Mount Volume?}
    Mount2 -->|Success| Running([Pod Running])
    Mount -->|Success| Running
```

---

## YAML ที่ใช้งานได้จริง

### 1. Headless Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: xops-svc-mysql
  namespace: cust-demo
spec:
  clusterIP: None        # Headless — ไม่มี VIP, ใช้ DNS แทน
  selector:
    app: xops-mysql
  ports:
    - port: 3306
      targetPort: 3306
```

### 2. StatefulSet

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: xops-sts-mysql
  namespace: cust-demo
spec:
  serviceName: xops-svc-mysql
  replicas: 1
  selector:
    matchLabels:
      app: xops-mysql
  template:
    metadata:
      labels:
        app: xops-mysql
    spec:
      securityContext:
        fsGroup: 27                    # chown volume ให้ mysql user (UID/GID=27)
      containers:
        - name: mysql
          image: quay.io/sclorg/mysql-80-c9s:latest
          ports:
            - containerPort: 3306
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "xops1234"
            - name: MYSQL_USER
              value: "xopsuser"
            - name: MYSQL_PASSWORD
              value: "xops5678"
            - name: MYSQL_DATABASE
              value: "xopsdb"
            - name: MYSQL_LOWER_CASE_TABLE_NAMES
              value: "1"               # แก้ case-insensitive FS ของ cluster
          resources:
            requests:
              cpu: 100m
              memory: 256Mi
            limits:
              cpu: 200m
              memory: 512Mi
          volumeMounts:
            - name: xops-pvc-mysql
              mountPath: /var/lib/mysql/data   # sclorg ใช้ /data ไม่ใช่ /mysql
  volumeClaimTemplates:
    - metadata:
        name: xops-pvc-mysql
      spec:
        accessModes: ["ReadWriteOnce"]
        resources:
          requests:
            storage: 1Gi
```

---

## การทดสอบ

```mermaid
flowchart LR
    T1["เข้า Terminal"] --> T2["Login MySQL"]
    T2 --> T3["show databases"]
    T3 --> T4["CREATE + INSERT"]
    T4 --> T5["Delete Pod"]
    T5 --> T6["SELECT ตรวจ data"]
```

| ขั้นตอน | คำสั่ง |
|---|---|
| Login MySQL | `mysql -u xopsuser -pxops5678 xopsdb` |
| ตรวจ database | `show databases;` |
| สร้าง table | `CREATE TABLE test (id INT, name VARCHAR(50));` |
| Insert data | `INSERT INTO test VALUES (1, 'xops-test');` |
| ตรวจ data | `SELECT * FROM test;` |
| Delete Pod | Actions → Delete Pod → รอ Running |
| ตรวจหลัง restart | `SELECT * FROM test;` — data ต้องยังอยู่ |

---

## Resource Summary

| Resource | ชื่อ | หมายเหตุ |
|---|---|---|
| Headless Service | `xops-svc-mysql` | clusterIP: None |
| StatefulSet | `xops-sts-mysql` | replicas: 1 |
| Pod | `xops-sts-mysql-0` | ชื่อคงที่เสมอ |
| PVC | `xops-pvc-mysql-xops-sts-mysql-0` | auto-created โดย StatefulSet |