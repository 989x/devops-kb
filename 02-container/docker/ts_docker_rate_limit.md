---
tags: [docker, troubleshooting, registry, rate-limit]
date: 2025-05-02
status: resolved
---

# Troubleshooting: Docker Pull Rate Limit

## ปัญหา

```
Failed to pull image "nginx:latest": initializing source docker://nginx:latest:
reading manifest latest in docker.io/library/nginx:
toomanyrequests: You have reached your unauthenticated pull rate limit.
```

## สาเหตุ

- Docker Hub จำกัด **unauthenticated pull: 100 pulls / 6 ชั่วโมง** ต่อ IP
- ใน shared network / CI environment หลายคนใช้ IP เดียวกัน → หมดเร็วมาก
- Free account ได้ **200 pulls / 6 ชั่วโมง**

---

## Solutions

### 1. Use Public ECR (Fastest — no login required)

```yaml
# replace
image: nginx:latest

# with
image: public.ecr.aws/nginx/nginx:latest
```

```bash
docker pull public.ecr.aws/nginx/nginx:latest
```

> Amazon Public ECR has no rate limit and syncs from the official image

---

### 2. Use a Mirror Registry

```yaml
# Google Mirror
image: mirror.gcr.io/library/nginx:latest

# Quay.io
image: quay.io/jitesoft/nginx:latest
```

---

### 3. Login to Docker Hub (Permanent Fix)

```bash
docker login -u <your-username>
docker pull nginx:latest
```

---

### 4. Set Registry Mirror in Docker Daemon

แก้ไฟล์ `/etc/docker/daemon.json`:

```json
{
  "registry-mirrors": [
    "https://mirror.gcr.io",
    "https://public.ecr.aws"
  ]
}
```

```bash
sudo systemctl restart docker
```

---

## Alternative Registries

| Registry | URL | Rate Limit |
|----------|-----|------------|
| Amazon Public ECR | `public.ecr.aws/nginx/nginx` | ไม่มี |
| Google Mirror | `mirror.gcr.io/library/nginx` | ไม่มี |
| GitHub GHCR | `ghcr.io/nginxinc/nginx-unprivileged` | ไม่มี |
| Quay.io | `quay.io/jitesoft/nginx` | ไม่มี |
| Docker Hub (anonymous) | `nginx:latest` | 100/6h ต่อ IP |
| Docker Hub (free login) | `nginx:latest` | 200/6h |

---

## Related

- [[nextjs_dockerfile_prod]]
- [[nextjs_dockerfile_example]]
- [[ts_pnpm_next_ci]]