---
title: Droplets SSH Access
tags: [cloud, digitalocean, ssh]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[droplets_setup_server]]"
---

# Droplets SSH Access

วิธีสร้าง SSH key และ connect เข้า DigitalOcean Droplet

## Prerequisites

- ติดตั้ง `ssh-keygen` ไว้แล้ว (มาพร้อม macOS และ Linux)
- มี Droplet และ Public IP พร้อมแล้ว

## Step 1: Generate SSH Key

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_digitalocean
# กด Enter เพื่อข้าม passphrase หรือตั้งได้ถ้าต้องการ
```

Key จะถูกสร้าง 2 ไฟล์

| ไฟล์ | ความหมาย |
|------|---------|
| `~/.ssh/id_ed25519_digitalocean` | Private key — ห้ามแชร์ |
| `~/.ssh/id_ed25519_digitalocean.pub` | Public key — ใช้ลงทะเบียนกับ server |

## Step 2: Copy Public Key

```bash
cat ~/.ssh/id_ed25519_digitalocean.pub
```

นำค่าที่ได้ไปวางใน DigitalOcean → Settings → Security → SSH Keys

## Step 3: Connect เข้า Droplet

```bash
ssh -i ~/.ssh/id_ed25519_digitalocean root@<DROPLET_IP>
```

แทน `<DROPLET_IP>` ด้วย Public IP ของ Droplet

## References

- [DigitalOcean Docs: SSH Keys](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/)