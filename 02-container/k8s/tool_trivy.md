---
title: "Tool: Trivy"
tags: [container, k8s, tool, security]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[tool_kube_hunter]]"
  - "[[tool_k9s]]"
---

# Tool: Trivy

Trivy เป็น open-source vulnerability scanner โดย Aqua Security
ใช้ scan containers, filesystems, repositories, IaC และ Kubernetes clusters
สำหรับ vulnerabilities, misconfigurations, secrets และ compliance issues

## Supported Scan Targets

container images, filesystems, git repositories, Kubernetes clusters, Kubernetes manifests (YAML), IaC (Terraform/Helm), secrets, SBOM

## System Requirements

- Linux (Ubuntu/Debian)
- x86_64 architecture
- Internet access (สำหรับ vulnerability database updates)
- Docker หรือ Podman (optional สำหรับ image scanning)
- kubectl configure แล้ว (สำหรับ Kubernetes scanning)

## Installation

```bash
# Install prerequisites
sudo apt-get update
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

# Add GPG key และ repository
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | \
  sudo tee /etc/apt/sources.list.d/trivy.list

# Install
sudo apt-get update
sudo apt-get install -y trivy

# Verify
trivy --version
```

## Update Vulnerability Database

```bash
trivy db update
```

---

## Usage

### Scan Container Image

```bash
trivy image nginx:latest

# เฉพาะ HIGH และ CRITICAL
trivy image --severity HIGH,CRITICAL nginx:latest
```

### Scan Filesystem

```bash
trivy fs /path/to/directory

# รวม misconfigurations
trivy fs --scanners vuln,config /path/to/directory
```

### Scan Git Repository

```bash
trivy repo https://github.com/<OWNER>/<REPO>
```

### Scan Kubernetes Cluster

```bash
# Scan ทั้ง cluster
trivy k8s cluster

# Summary report
trivy k8s --report summary all

# Scan specific namespace
trivy k8s --namespace default all
```

### Scan Kubernetes Manifests

```bash
trivy config deployment.yaml

# Scan ทั้ง directory
trivy config ./manifests/
```

---

## Output Formats

```bash
# JSON (สำหรับ audit/compliance)
trivy image --format json --output result.json nginx:latest

# Table (default)
trivy image nginx:latest
```

## Common Options

| Option | ความหมาย |
|--------|---------|
| `--severity` | Filter ตาม severity (LOW/MEDIUM/HIGH/CRITICAL) |
| `--format` | Output format (table, json, template) |
| `--output` | เขียนผลลัพธ์ลงไฟล์ |
| `--ignore-unfixed` | ข้าม unfixed vulnerabilities |
| `--scanners` | เลือก scanner (vuln, config, secret, license) |

## Best Practices

- Update vulnerability database สม่ำเสมอ
- Scan container images ก่อน deploy เสมอ
- Scan Kubernetes manifests ใน CI/CD pipeline
- Focus ที่ HIGH และ CRITICAL findings
- ใช้ JSON report สำหรับ audit และ compliance
- ใช้ร่วมกับ [[tool_kube_hunter]] เพื่อ security coverage ที่ครบขึ้น

## Security Notes

- Trivy เป็น **read-only scanner** ไม่มีการ modify system state
- Kubernetes scanning ใช้ RBAC permissions ของ user ที่รัน

## References

- [aquasecurity.github.io/trivy](https://aquasecurity.github.io/trivy)