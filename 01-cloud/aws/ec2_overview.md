---
title: EC2 Overview
tags: [cloud, aws, ec2]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[ec2-running-node]]"
  - "[[cli-install]]"
---

# EC2 Overview

ภาพรวม Amazon EC2 รวม pattern ที่ใช้งานบ่อยในองค์กร ได้แก่ การ connect ผ่าน SSH และการ deploy ด้วย Docker

## Prerequisites

- มี AWS account และสิทธิ์เข้าถึง EC2
- มีไฟล์ `.pem` key pair สำหรับ instance ที่จะ connect
- ติดตั้ง AWS CLI แล้ว → [[cli-install]]

## Connect to EC2 via SSH

### Mac / Linux

```bash
# ปรับ permission ไฟล์ key ก่อนใช้งาน (ทำครั้งเดียว)
chmod 400 myec2key.pem

# Connect
ssh -i myec2key.pem ec2-user@<PUBLIC_IP>
```

### Windows

ใช้ PuTTY แทน terminal และแปลง `.pem` เป็น `.ppk` ผ่าน PuTTYgen ก่อน

## Setup EC2 Instance (Ubuntu)

คำสั่งพื้นฐานหลัง connect เข้า instance ครั้งแรก

```bash
# อัปเดต packages
sudo apt update && sudo apt upgrade -y

# โหลด bashrc
source ~/.bashrc

# ติดตั้ง Node.js ผ่าน NVM (LTS)
nvm install --lts

# Redirect port 80 → 3000 (ถ้าไม่ได้ใช้ Load Balancer)
sudo iptables -A PREROUTING -t nat -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 3000
```

## Deploy Docker บน EC2

### แบบ Single Instance

deploy container โดยตรงบน EC2 instance เดียว เหมาะกับ environment dev/staging

```bash
# ติดตั้ง Docker
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker

# Pull และ run image
sudo docker pull <IMAGE_NAME>
sudo docker run -d -p 3000:3000 <IMAGE_NAME>
```

### แบบ ECS (Production)

สำหรับ production แนะนำใช้ AWS ECS แทน เพื่อรองรับ auto-scaling และ rolling deploy
ดูเพิ่มเติมได้ที่ AWS ECS documentation

## References

- [AWS Docs: Connect to EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstances.html)
- [AWS Docs: Docker on EC2](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html)