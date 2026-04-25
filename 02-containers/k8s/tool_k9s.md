---
title: "Tool: k9s"
tags: [container, k8s, tool]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[tool_kube_hunter]]"
  - "[[tool_trivy]]"
---

# Tool: k9s

k9s เป็น terminal-based UI (TUI) สำหรับจัดการ Kubernetes cluster
ให้ real-time visibility และ control ผ่าน keyboard shortcuts โดยใช้ `kubectl` config ที่มีอยู่แล้ว

## Where to Install

ติดตั้งบน **เครื่อง admin เครื่องเดียวเท่านั้น** ไม่จำเป็นต้องติดตั้งบน worker nodes

ตัวอย่างที่เหมาะสม: admin laptop, bastion host, หรือ master/control-plane node

> Validated บน `k8s101-master-01` (Ubuntu) — cluster access ผ่าน `kubectl`

## Prerequisites

- Kubernetes cluster reachable
- `kubectl` ติดตั้งและ configure แล้ว
- `kubectl get nodes` ทำงานได้สำเร็จ

## Installation

```bash
# Install via Webinstall
curl -sS https://webinstall.dev/k9s | bash

# Load PATH (required หลัง install)
source ~/.config/envman/PATH.env

# Verify
k9s version
```

## Usage

```bash
k9s
```

k9s จะ load kubeconfig ปัจจุบัน เชื่อมต่อ cluster และแสดง live terminal UI อัตโนมัติ

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `:` | Switch resource view (pods, svc, deploy, nodes) |
| `/` | Search / filter |
| `l` | View logs |
| `d` | Delete selected resource |
| `s` | Describe resource |
| `q` | Quit / go back |
| `?` | Help |

## Security Notes

- Access จำกัดด้วย Kubernetes RBAC
- ใช้ read-only role สำหรับ non-admin users
- k9s ไม่ใช่ agent และไม่ได้รันบน cluster nodes
- ทุก action ต้อง trigger โดย user เอง ไม่มีการเปลี่ยนแปลง cluster อัตโนมัติ

## References

- [k9scli.io](https://k9scli.io)