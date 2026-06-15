---
title: "🌟Kubernetes Part 6— ClusterIP vs NodePort vs Loadbalancer vs External"
source: "https://aws.plainenglish.io/kubernetes-part-6-clusterip-vs-nodeport-vs-loadbalancer-vs-external-614d1911f162"
author:
  - "[[Sathvika B]]"
published: 2025-08-18
created: 2026-06-15
description: "🌟Kubernetes Part 6— ClusterIP vs NodePort vs Loadbalancer vs External In the previous part, we explored ReplicaSets, ReplicationControllers, and Deployments. We created a Deployment with 4 Pods …"
tags:
  - "clippings"
---

# Kubernetes Services — ClusterIP vs NodePort vs LoadBalancer vs ExternalName

---

## ทำไมต้องมี Service?

ก่อนหน้านี้เราสร้าง Deployment ที่รัน NGINX อยู่ 4 Pods แต่ Pods เหล่านี้เข้าถึงได้แค่จากภายในคลัสเตอร์เท่านั้น

ในระบบจริงเรามักมีหลายชั้น เช่น:
- Frontend → Nginx (อยู่ใน Pod)
- Backend → Node.js (อยู่ใน Pod)
- External Data Source → DB หรือ API ที่อยู่นอกคลัสเตอร์

สิ่งที่ต้องทำให้ได้คือ:
1. ผู้ใช้เข้าถึง frontend ได้
2. frontend คุยกับ backend ได้
3. backend คุยกับ external data source ได้

นี่คือหน้าที่ของ Service — มันทำให้:
- Pods ถูก expose ออกไปทั้งภายใน/ภายนอกคลัสเตอร์
- มี IP/Name ที่คงที่ (เพราะ Pod IP เปลี่ยนทุกครั้งที่ restart)
- ทำ load balancing ระหว่าง Pods หลายตัวที่อยู่หลัง Service เดียวกัน
- ทำให้ระบบ loosely coupled — Pod scale/restart ได้ โดย endpoint ของ Service ไม่เปลี่ยน

ภาพรวมจากบทความ:

![overview](https://miro.medium.com/v2/format:webp/1*Y1W5gkQgrEQtFFlyhJUeBw.png)

ภาพรีแคปจาก Part ก่อนหน้า: Deployment/ReplicaSet คุม Pods nginx (replicas=3 และ replicas=1) กระจายอยู่บน 2 Nodes โดยมี "user" พยายามเข้าถึงจากด้านนอก — ตอนนี้ยังไม่มี Service เชื่อมเลย

![layers](https://miro.medium.com/v2/format:webp/1*uW0F-gBwdqAxBFSvgnjVpA.png)

สถานะ "ก่อนมี Service": Pod ของ nginx (frontend), Pod Node.js อีก 2 ตัว (backend), database, และ Users วางแยกกันลอยๆ ยังไม่มีอะไรเชื่อมถึงกัน

![service connecting layers](https://miro.medium.com/v2/format:webp/1*1JlpLOJpQ1WLFwzVPY4HIQ.png)

สถานะ "หลังมี Service": ชุดเดียวกันแต่ตอนนี้มี service เป็นตัวเชื่อม — Users → service → nginx Pod, และ Node.js Pod → service → database

---

## Service มี 4 ประเภทหลัก

1. ClusterIP (default)
2. NodePort
3. LoadBalancer
4. ExternalName

---

## ภาพรวมทั้งระบบ: หนึ่งภาพที่มีครบทุก Service type

ก่อนลงรายละเอียดแต่ละ type ลองดูภาพนี้ก่อน เป็นภาพรวมที่มี Service ทุกแบบที่จะพูดถึงปรากฏอยู่ในที่เดียว (ภาพเดียวกันนี้จะกลับมาอีกครั้งใน section LoadBalancer ด้านล่าง)

![ภาพรวมทุก Service type](https://miro.medium.com/v2/format:webp/1*_RPNetx9uLv4D-i9KapgxA.png)

ลองไล่ตาม traffic ทีละจุด:

1. Users เปิด myapp.com หรือยิงไปที่ Node IP:30001 — ฝั่งนี้คือจุดที่ NodePort เข้ามาเกี่ยวข้อง ถ้าไม่มี LoadBalancer ก็ยิงตรงมาที่ Node IP + nodePort แบบนี้ได้เลย
2. traffic ไปถึง loadbalancer (LoadBalancer Service) — เป็น Service ตัวแรกที่ traffic จากนอกคลัสเตอร์เจอ คอยกระจายงานต่อ
3. loadbalancer ส่งต่อไปยัง frontend Pods (nginx) ที่กระจายอยู่บน NodeA/B/C
4. frontend Pod เรียก backend ผ่าน service: clusterip — นี่คือจุดที่ ClusterIP ทำงาน คือการสื่อสารกันภายในคลัสเตอร์ ไม่เกี่ยวกับโลกภายนอกเลย
5. backend (Node.js Pods) เชื่อมไปยัง db — ถ้า db อยู่ในคลัสเตอร์ก็ผ่าน ClusterIP อีกตัว แต่ถ้าเป็น managed database ภายนอก (เช่น RDS) จะผ่าน ExternalName Service แทน

สรุปคือภาพเดียวนี้มีทั้ง NodePort/LoadBalancer (ทางเข้าจากนอก), ClusterIP (การสื่อสารภายใน), และ ExternalName (ถ้ามี dependency ภายนอก) ครบ ส่วนที่เหลือของไฟล์นี้จะลงรายละเอียดของแต่ละจุดในภาพนี้ทีละ type

---

## 1. NodePort

วิธีที่ง่ายที่สุดในการ expose แอปออกไปนอกคลัสเตอร์ (สำหรับ dev/test)

แนวคิดของ port แต่ละตัว:
- targetPort → port ที่ Pod listen อยู่ (เช่น 80)
- port → port ของ service ที่ใช้คุยกันภายในคลัสเตอร์
- nodePort → port ที่เปิดให้เข้าถึงจากนอกคลัสเตอร์ ผ่านทุก Node ในช่วง `30000–32767`

จุดในภาพรวม: คือทางที่ Users ยิงมาที่ Node IP:30001 ตรงๆ (กรณีไม่มี LoadBalancer)

เปรียบเหมือน: ประตูหลังบ้านที่มีเลขห้องตายตัว (30000-32767) — คนนอกต้องรู้ทั้งที่อยู่บ้าน (Node IP) และเลขห้อง (nodePort) ถึงจะเข้าได้

ไดอะแกรม:

![nodeport diagram 1](https://miro.medium.com/v2/format:webp/1*2V3mqBJnfs-zuZwHLSe0FQ.png)

แผนภาพแสดงการ mapping ของ port: targetPort (ที่ Pod) → port (ของ Service) → nodePort (เปิดบน Node)

![nodeport diagram 2](https://miro.medium.com/v2/format:webp/1*DD8dfhTCxeq1LSAsqAOvWQ.png)

แผนภาพแสดงการเข้าถึง Service ผ่าน NodePort (port 30001) จากภายนอกคลัสเตอร์ โดย service กระจาย traffic ไปยัง Pod nginx ที่อยู่บน 2 Nodes คนละตัว (load balancing ข้าม Node)

### ตัวอย่าง `nodeport.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nodeport-svc
  labels:
    env: demo
spec:
  type: NodePort
  ports:
    - nodePort: 30001
      port: 80
      targetPort: 80
  selector:
     env: demo
```

### คำสั่งที่ใช้

```bash
kubectl apply -f nodeport.yaml
kubectl get svc
```

หลัง apply แล้วจะมี service `nodeport-svc` ขึ้นมา เปิด targetPort 80 และ NodePort 30001

ดูว่า Pod รันอยู่ที่ Node ไหน (เอา IP ของ Node มาใช้):

```bash
kubectl get nodes -o wide
kubectl describe pod <pod-name>
```

![pod node info](https://miro.medium.com/v2/format:webp/1*-7b4uk_jbK_M_8JLQVyLMA.png)

ตัวอย่าง output ของ `kubectl get nodes -o wide` และ `kubectl describe pod` เพื่อหา Node IP ที่ Pod รันอยู่

จากนั้นเข้าแอปได้ผ่าน:

```bash
curl <NodeIP>:30001
```

หรือเปิดเบราว์เซอร์ไปที่ `http://<NodeIP>:30001`

### ⚠️ ถ้าใช้ KIND cluster

KIND ไม่ได้ expose NodePort ออกมาให้อัตโนมัติ ต้องตั้ง `extraPortMappings` ใน config ของคลัสเตอร์ตอนสร้าง

`kind.yaml`:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30001
    hostPort: 30001
- role: worker
```

สร้างคลัสเตอร์:

```bash
kind create cluster --config kind.yaml --name cka-cluster-3
```

จากนั้นเข้าได้ผ่าน:

```bash
curl localhost:30001
```

![kind nodeport](https://miro.medium.com/v2/format:webp/1*5OT1lGoZuY_IMGOsOnyRxA.png)

ตัวอย่างผลลัพธ์การ `curl localhost:30001` บน KIND cluster หลังตั้งค่า extraPortMappings แล้ว

> สรุป: NodePort เหมาะกับการทดสอบ/เข้าถึงเร็วๆ แต่ไม่เหมาะกับ production scale ใหญ่

---

## 2. ClusterIP (default)

ใช้สำหรับการสื่อสาร ภายในคลัสเตอร์เท่านั้น เช่น frontend → backend → database

จุดเด่น:
- ได้ internal IP ที่คงที่
- Pod อื่นเข้าถึงผ่าน service name หรือ ClusterIP ได้
- เข้าจากนอกคลัสเตอร์ไม่ได้

ทำไมต้องมี: เพราะ Pod IP เป็นแบบ ephemeral (เปลี่ยนทุกครั้งที่ restart) ClusterIP จึงเป็น static endpoint ให้แทน

จุดในภาพรวม: คือเส้น frontend Pod → service: clusterip → backend Pod ในภาพ

เปรียบเหมือน: เบอร์ต่อภายในออฟฟิศ — คนในออฟฟิศโทรหากันด้วยเบอร์ต่อได้เลย แต่คนนอกองค์กรโทรเข้ามาที่เบอร์ต่อตรงๆไม่ได้ ต้องผ่านเบอร์กลางก่อน

![clusterip diagram](https://miro.medium.com/v2/format:webp/1*1X9QxiW7MPyTG69W1pGnZw.png)

แผนภาพแสดงการทำงานของ ClusterIP: traffic ภายในคลัสเตอร์ถูกส่งผ่าน ClusterIP ไปยัง Pods ที่ตรงกับ selector

### ตัวอย่าง `clusterip.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: cluster-svc
  labels:
    env: demo
spec:
  type: ClusterIP
  ports:
    - port: 80
  selector:
     env: demo
```

### คำสั่งที่ใช้

```bash
kubectl apply -f clusterip.yaml
kubectl get svc
kubectl describe svc cluster-svc
```

![clusterip result 1](https://miro.medium.com/v2/format:webp/1*TJo2tVc4MsF227bbub---g.png)

ตัวอย่าง output ของ `kubectl get svc` หลัง apply `clusterip.yaml` แสดง service `cluster-svc` ชนิด ClusterIP

![clusterip result 2](https://miro.medium.com/v2/format:webp/1*RxsO4xfTxpVbpNjnKS57_Q.png)

ตัวอย่าง output ของ `kubectl describe svc cluster-svc` แสดงรายละเอียด selector, port, และ endpoints ของ service

ดู endpoints ที่อัปเดตตาม Pod IP อัตโนมัติ:

```bash
kubectl get ep
```

![clusterip endpoints](https://miro.medium.com/v2/format:webp/1*znh6EjqaLf62054OZ-EtUg.png)

ตัวอย่าง output ของ `kubectl get ep` แสดง IP ของแต่ละ Pod ที่ Service จับคู่ไว้ผ่าน endpoints

> สรุป: เหมาะมากสำหรับการสื่อสารแบบ frontend ↔ backend ↔ database ภายในคลัสเตอร์

---

## 3. LoadBalancer

ใช้เมื่อต้องการ expose แอปออก internet โดยมี IP/DNS เดียวที่คงที่

- ทำงานร่วมกับ cloud provider (AWS, Azure, GCP)
- คลาวด์จะ provision external load balancer ให้
- กระจาย traffic ไปยัง Pods ที่อยู่หลัง service นี้

จุดในภาพรวม: คือ loadbalancer ที่อยู่บนสุดของภาพ รับ traffic จาก Users/myapp.com ก่อนกระจายไปยัง frontend Pods (ภาพเดียวกับที่เห็นในส่วนภาพรวมต้นไฟล์)

เปรียบเหมือน: พนักงาน reception ที่มีเบอร์กลางเบอร์เดียว คนนอกโทรเข้าที่เบอร์นี้ reception จะโยกสายไปยังพนักงาน (Pod) ที่ว่างให้เอง

![loadbalancer diagram](https://miro.medium.com/v2/format:webp/1*_RPNetx9uLv4D-i9KapgxA.png)

แผนภาพแสดงภาพรวมทั้งระบบ: traffic จาก internet (ผ่าน myapp.com หรือ Node IP:30001) เข้าทาง loadbalancer ก่อนกระจายไปยัง frontend Pods (nginx) บน NodeA/NodeB/NodeC จากนั้น frontend เรียก backend ผ่าน service: clusterip ไปยัง Pods Node.js และ db

### ตัวอย่าง `lb.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: lb-svc
  labels:
    env: demo
spec:
  type: LoadBalancer
  ports:
    - port: 80
  selector:
     env: demo
```

### คำสั่งที่ใช้

```bash
kubectl apply -f lb.yaml
kubectl get svc
```

![loadbalancer result](https://miro.medium.com/v2/format:webp/1*CN3JwYDcje2XKUhfhCI6CA.png)

ตัวอย่าง output ของ `kubectl get svc` หลัง apply `lb.yaml` แสดง service ชนิด LoadBalancer (บนคลาวด์จริงจะมี External IP ขึ้นมาในคอลัมน์ EXTERNAL-IP)

ถ้ารันบน cloud จริง จะได้ External IP มา เข้าได้ผ่าน `http://<ExternalIP>`

⚠️ บน KIND หรือ bare-metal จะไม่มี load balancer มาให้อัตโนมัติ ต้องใช้เครื่องมือเสริมเช่น cloud-provider-kind หรือ MetalLB เพื่อจำลอง

> สรุป: เหมาะกับ production บน cloud

---

## 4. ExternalName

ใช้เมื่อ Pods ในคลัสเตอร์ต้องเรียกใช้ service ภายนอก เช่น managed database หรือ external API

- map ชื่อ service ไปยัง external DNS name
- ไม่มีการจอง IP ภายในคลัสเตอร์

จุดในภาพรวม: คือเส้นจาก backend ไปยัง db ในกรณีที่ db เป็น managed database ภายนอกคลัสเตอร์

เปรียบเหมือน: เบอร์ลัด (speed dial) ในออฟฟิศที่กดแล้วต่อตรงไปยังบริษัทคู่ค้าภายนอกทันที โดยที่คนในออฟฟิศไม่ต้องรู้เบอร์จริงของอีกฝั่ง

### ตัวอย่าง `external.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: prod
spec:
  type: ExternalName
  externalName: my.api.example.com
```

จาก Pod ภายในคลัสเตอร์ เรียกใช้ผ่าน:

```bash
curl http://my-service.prod.svc.cluster.local
```

> สรุป: เหมาะกับการเชื่อมต่อ external API หรือ external database

---

## สรุปรวบ 4 ประเภท

| ประเภท | ใช้ทำอะไร |
|---|---|
| ClusterIP | สื่อสารภายในคลัสเตอร์ (default) |
| NodePort | expose service ออกนอกคลัสเตอร์ผ่าน Node IP + port |
| LoadBalancer | cloud load balancer พร้อม external IP/DNS |
| ExternalName | map service ไปยัง external DNS name |

Service ช่วยให้ระบบมี high availability, scalability และ loose coupling

---

## Tip: ตั้ง alias สำหรับ kubectl

เพิ่มลงใน `.bash_profile`:

```bash
cd
vi .bash_profile
alias k=kubectl
source ~/.bash_profile
```

จากนั้นใช้สั้นๆได้:

```bash
k get pods
k get svc
```

---

## ตัวอย่างการใช้งานจริงในระบบ Production (สมมุติแบบแอป e-commerce)

| Layer | Service Type ที่ใช้ | ตัวอย่าง |
|---|---|---|
| Frontend (public website) | Ingress / LoadBalancer | เว็บ UI (React/Angular + Nginx) |
| Backend APIs (internal) | ClusterIP | Product catalog, Cart, Order, User service |
| Database Layer | ClusterIP / ExternalName | DB ภายใน (Postgres/MySQL) หรือ managed DB (RDS/Azure SQL) |
| External APIs | ExternalName | Payment Gateway, Delivery Partner API, Weather/Location API |
| Dev/Test (non-prod) | NodePort | สำหรับทดสอบบน Minikube/KIND |

### Flow การทำงานแบบคร่าวๆ

1. ผู้ใช้เปิดเว็บ → เข้าทาง Ingress / LoadBalancer Service
2. Ingress route ไปยัง Frontend Pod
3. Frontend เรียก backend ผ่าน ClusterIP Services ต่างๆ (catalog, cart, order, user)
4. Backend ดึง/บันทึกข้อมูลผ่าน ClusterIP (internal DB) หรือ ExternalName (managed DB)
5. ตอน checkout เรียก ExternalName ไปยัง payment gateway / delivery API ภายนอก
6. ส่ง response กลับไปยัง frontend ให้ผู้ใช้เห็นผลลัพธ์

โดยสรุป: Ingress → Frontend → ClusterIP APIs → DB/External APIs แยก public / internal / external dependency ออกจากกันชัดเจน

---

## Cheat Sheet

| Layer | Service Type | ตัวอย่างการใช้งาน |
|---|---|---|
| Frontend (public) | LoadBalancer / Ingress | แอปที่ผู้ใช้เห็น (nginx, React, Angular) |
| Backend APIs | ClusterIP | microservices ภายใน (Node.js, Java, Python) |
| Database | ClusterIP / ExternalName | DB pod ภายใน หรือ managed DB ภายนอก |
| External APIs | ExternalName | Payment gateway, Weather API, SaaS อื่นๆ |
| Local / Dev | NodePort | Minikube, KIND, testing |

---

ต่อไปจะเป็นเรื่อง Kubernetes Namespaces (อ้างอิงจาก source บทความ)

Source: https://aws.plainenglish.io/kubernetes-part-6-clusterip-vs-nodeport-vs-loadbalancer-vs-external-614d1911f162