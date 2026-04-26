---
title: "K8s Setup"
tags: [k8s, kubernetes, setup, haproxy, preflight]
type: index
status: stable
created: 2026-04-26
related:
---

# K8s Setup

รวมเอกสารการติดตั้งและเตรียมความพร้อม Kubernetes Cluster ตั้งแต่ Load Balancer, Control Plane จนถึง Tools สำหรับตรวจสอบก่อน deploy

## Documents

### Infrastructure
- [[infra_k8s_haproxy_lb]] — ติดตั้ง HAProxy เป็น Load Balancer สำหรับ Kubernetes API Server
- [[infra_k8s_control_plane]] — Initialize Kubernetes Control Plane พร้อม CNI, Metrics Server และ GUI
- [[infra_k8s_cleanup_kubeadm]] — Reset node ที่เคยรัน kubeadm init กลับสู่สถานะก่อน setup

### Tools
- [[tool_k8s_preflight_tools]] — Script ตรวจสอบ node readiness และ port conflicts ก่อน deploy
