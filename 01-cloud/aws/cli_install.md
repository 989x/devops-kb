---
title: AWS CLI Install
tags: [cloud, aws, cli]
type: guide
status: stable
created: 2026-04-25
---

# AWS CLI Install

คู่มือติดตั้งและถอนการติดตั้ง AWS CLI บนเครื่อง Mac/Linux

## Prerequisites

- Python และ pip ติดตั้งไว้แล้ว
- สิทธิ์ sudo บนเครื่อง

## Install

ติดตั้ง AWS CLI version ล่าสุดผ่าน pip

```bash
sudo pip install awscli --force-reinstall --upgrade
```

ตรวจสอบว่าติดตั้งสำเร็จ

```bash
aws --version
```

> ถ้าขึ้น `bash: aws: command not found` หลัง install ให้ลองรัน `source ~/.bashrc` หรือเปิด terminal ใหม่

## Uninstall

### Step 1: หา path ที่ติดตั้งไว้

```bash
which aws
# output: /usr/local/bin/aws

ls -l /usr/local/bin/aws
# output: ... /usr/local/bin/aws -> /usr/local/aws-cli/aws
```

### Step 2: ลบ symlinks

```bash
sudo rm /usr/local/bin/aws
sudo rm /usr/local/bin/aws_completer
```

### Step 3: ลบ installation folder

```bash
sudo rm -rf /usr/local/aws-cli
```

### Step 4: ลบ credentials (Optional)

> **ระวัง:** ไฟล์นี้ใช้ร่วมกับ AWS SDK ทุกตัว ถ้าลบแล้ว tool อื่นที่ใช้ AWS จะหยุดทำงาน

```bash
sudo rm -rf ~/.aws/
```

## References

- [AWS Docs: Uninstall AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/uninstall.html)
- [Stack Overflow: bash: aws: command not found](https://stackoverflow.com/questions/56449855/bash-aws-command-not-found)