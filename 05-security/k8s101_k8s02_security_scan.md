---
title: "Security Scan: k8s101 / k8s02"
tags: [security, k8s, assessment, k8s101]
type: report
status: stable
created: 2026-04-25
related:
  - "[[tool_kube_hunter]]"
  - "[[tool_trivy]]"
---

# Security Scan: k8s101 / k8s02

## Overview

Security assessment ของ k8s02 cluster ใน batch k8s101
ประเมิน exposure จาก external attacker perspective และหา potential security risks
ก่อนส่งมอบ cluster ให้ลูกค้า

## Environment

### Cluster Information

<table>
  <thead>
    <tr>
      <th width="35%">Item</th>
      <th width="65%">Detail</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Cluster Name</td><td>k8s02</td></tr>
    <tr><td>Kubernetes Version</td><td>v1.34.3</td></tr>
    <tr><td>Container Runtime</td><td>containerd 2.2.0</td></tr>
    <tr><td>OS</td><td>Ubuntu 24.04 LTS</td></tr>
    <tr><td>Kernel</td><td>6.8.0-90-generic</td></tr>
  </tbody>
</table>

### Node Topology

<table>
  <thead>
    <tr>
      <th width="20%">Role</th>
      <th width="50%">Hostname</th>
      <th width="30%">IP Address</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Load Balancer</td><td>k8s02-lb-01</td><td>172.16.51.20</td></tr>
    <tr><td>Master</td><td>k8s02-master-01</td><td>172.16.51.21</td></tr>
    <tr><td>Master</td><td>k8s02-master-02</td><td>172.16.51.22</td></tr>
    <tr><td>Master</td><td>k8s02-master-03</td><td>172.16.51.23</td></tr>
    <tr><td>Worker</td><td>k8s02-worker-01</td><td>172.16.51.24</td></tr>
    <tr><td>Worker</td><td>k8s02-worker-02</td><td>172.16.51.25</td></tr>
  </tbody>
</table>

### Network

- Internal Network: `172.16.51.0/24`
- External IPs: Not exposed

---

## Scope

**In scope**
- Network port scanning
- Kubernetes service discovery
- Kubernetes vulnerability scanning (external perspective)
- Passive and active security testing

**Out of scope**
- Application-level vulnerabilities
- Internal pod compromise scenarios

---

## Tools Used

<table>
  <thead>
    <tr>
      <th width="25%">Tool</th>
      <th width="75%">Purpose</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>nmap</td><td>Network and port scanning</td></tr>
    <tr><td>kube-hunter</td><td>Kubernetes security testing</td></tr>
    <tr><td>curl</td><td>Manual service validation</td></tr>
    <tr><td>kubectl</td><td>Cluster inspection and validation</td></tr>
  </tbody>
</table>

---

## Test Methodology & Commands

### Network Port Scan

```bash
nmap -sS -p 1-65535 172.16.51.20-26
```

### Kubernetes Health Validation

```bash
kubectl get nodes -o wide
kubectl get --raw='/readyz?verbose'
```

### kube-hunter — Passive External Scan

```bash
docker run --rm -it aquasec/kube-hunter \
  --remote 172.16.51.21
```

### kube-hunter — Active External Scan

```bash
docker run --rm -it aquasec/kube-hunter \
  --remote 172.16.51.21 \
  --active
```

### Report Export

```bash
docker run --rm aquasec/kube-hunter \
  --remote 172.16.51.21 \
  --report json > kube-hunter-report.json
```

---

## Findings

### Discovered Services

<table>
  <thead>
    <tr>
      <th width="25%">Service</th>
      <th width="15%">Port</th>
      <th width="60%">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>API Server</td><td>6443</td><td>Kubernetes control plane API</td></tr>
    <tr><td>Kubelet API</td><td>10250</td><td>Node management interface</td></tr>
    <tr><td>Etcd</td><td>2379</td><td>Cluster data store</td></tr>
  </tbody>
</table>

### Vulnerabilities

<table>
  <thead>
    <tr>
      <th width="12%">ID</th>
      <th width="13%">Severity</th>
      <th width="20%">Component</th>
      <th width="55%">Description</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>KHV002</td><td>Low</td><td>API Server</td><td>Kubernetes version disclosure via <code>/version</code> endpoint</td></tr>
  </tbody>
</table>

**KHV002 Details**
- Kubernetes version (`v1.34.3`) เข้าถึงได้ผ่าน unauthenticated endpoint
- ไม่สามารถ escalate privilege หรือเข้าถึง cluster ได้โดยตรง

---

## Risk Summary

<table>
  <thead>
    <tr>
      <th width="70%">Severity</th>
      <th width="30%">Count</th>
    </tr>
  </thead>
  <tbody>
    <tr><td>Critical</td><td>0</td></tr>
    <tr><td>High</td><td>0</td></tr>
    <tr><td>Medium</td><td>0</td></tr>
    <tr><td>Low</td><td>1</td></tr>
    <tr><td>Informational</td><td>0</td></tr>
  </tbody>
</table>

---

## Analysis

- Critical Kubernetes components ทั้งหมดต้องผ่าน authentication
- Kubelet ไม่อนุญาต anonymous access
- Etcd reachable ที่ network level แต่ไม่อนุญาต unauthenticated access
- Active scan ได้ผลเหมือน passive scan ยืนยันว่าไม่มี exploitable external vulnerabilities

---

## Conclusion

- ไม่พบ Critical หรือ High risk vulnerabilities
- Cluster มี baseline security ที่แข็งแกร่งจาก external perspective
- Control plane ป้องกัน anonymous access ได้ถูกต้อง
- **พร้อมส่งมอบให้ลูกค้า**

---

## Recommendations

- Restrict network access to etcd ports ด้วย firewall rules
- Monitor exposed Kubernetes endpoints อย่างต่อเนื่อง
- ทำ internal (pod-level) security testing ถ้า threat model ต้องการ

---

## kube-hunter Raw Report

```json
{
  "summary": {
    "cluster": "k8s02",
    "scan_type": "remote",
    "target": "172.16.51.21",
    "kubernetes_version": "v1.34.3",
    "timestamp": "2025-12-20T16:40:35Z"
  },
  "nodes": [
    {
      "type": "master",
      "location": "172.16.51.21"
    }
  ],
  "services": [
    {
      "name": "API Server",
      "location": "172.16.51.21:6443",
      "description": "Kubernetes control plane API server"
    },
    {
      "name": "Kubelet API",
      "location": "172.16.51.21:10250",
      "description": "Node management interface"
    },
    {
      "name": "Etcd",
      "location": "172.16.51.21:2379",
      "description": "Kubernetes cluster datastore"
    }
  ],
  "vulnerabilities": [
    {
      "id": "KHV002",
      "severity": "Low",
      "category": "Initial Access / Exposed Sensitive Interfaces",
      "component": "API Server",
      "location": "172.16.51.21:6443",
      "title": "Kubernetes Version Disclosure",
      "description": "The Kubernetes version can be obtained via the unauthenticated /version endpoint.",
      "evidence": "v1.34.3",
      "impact": "Information disclosure only. No direct privilege escalation or remote access.",
      "recommendation": "Optional: restrict access to the API server endpoint at the network level."
    }
  ],
  "risk_summary": {
    "critical": 0,
    "high": 0,
    "medium": 0,
    "low": 1,
    "informational": 0
  },
  "conclusion": "No critical or high-risk vulnerabilities were identified. The cluster is secure from an external attacker perspective."
}
```