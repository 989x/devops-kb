---
title: EC2 Running Node.js with PM2
tags: [cloud, aws, ec2, nodejs, pm2]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[ec2-overview]]"
---

# EC2 Running Node.js with PM2

วิธีรัน Node.js และ NestJS บน EC2 ให้ทำงานต่อเนื่องโดยใช้ PM2 เป็น process manager

## Prerequisites

- Connect เข้า EC2 instance ได้แล้ว → [[ec2-overview]]
- Node.js และ npm ติดตั้งไว้แล้ว
- มี project พร้อม deploy

## Install PM2

```bash
npm install pm2 -g
```

ตรวจสอบว่าติดตั้งสำเร็จ

```bash
pm2 --version
```

## Deploy Node.js App

### Step 1: Start app ด้วย PM2

```bash
pm2 start app.js
```

แทน `app.js` ด้วย entry file ของ project

### Step 2: ตั้งค่า Auto-restart เมื่อ server reboot

```bash
pm2 startup system
pm2 save
```

## Deploy NestJS App

### Step 1: Build project

```bash
npm run build
```

### Step 2: Start ด้วย PM2

```bash
pm2 start dist/main.js --name <APP_NAME>
```

ตั้ง `<APP_NAME>` ให้สื่อความหมาย เช่น `api-production` เพื่อให้จำได้ง่ายใน PM2 list

### Step 3: ตั้งค่า Auto-restart เมื่อ server reboot

```bash
pm2 startup system
pm2 save
```

## PM2 Commands ที่ใช้บ่อย

| Command | ความหมาย |
|---------|---------|
| `pm2 list` | ดู process ทั้งหมดที่รันอยู่ |
| `pm2 logs <APP_NAME>` | ดู log realtime |
| `pm2 restart <APP_NAME>` | restart app |
| `pm2 stop <APP_NAME>` | หยุด app |
| `pm2 delete <APP_NAME>` | ลบ app ออกจาก PM2 |

## Troubleshooting

**`sudo: npm: command not found`**

```bash
sudo apt-get install npm
```

**PM2 start แล้ว app crash ทันที**

ดู log เพื่อหา error

```bash
pm2 logs <APP_NAME> --lines 50
```

## References

- [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)
- [Stack Overflow: Keep Node.js running forever on EC2](https://stackoverflow.com/questions/26245942/how-do-i-leave-node-js-server-on-ec2-running-forever)