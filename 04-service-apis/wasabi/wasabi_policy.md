---
title: "Wasabi S3 Bucket Policy"
tags: [wasabi, s3, policy, iam, bucket]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[wasabi_guideline]]"
  - "[[wasabi_connect_examples]]"
---

# Wasabi S3 Bucket Policy

รวม policy สำหรับ Wasabi bucket ทั้งแบบ IAM user access และ public access

---

## IAM User Policy

ใช้ [AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html) เพื่อสร้าง policy

### Past — Grant specific actions

```json
{
  "Id": "Policy1689247311207",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1689247247508",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/<IAM_USER>"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::<BUCKET_NAME>/*"
    },
    {
      "Sid": "Stmt1689247306635",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/<IAM_USER>"
      },
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::<BUCKET_NAME>"
    }
  ]
}
```

### Present — Full access (`s3:*`)

```json
{
  "Id": "Policy1689351325990",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1689351321124",
      "Action": "s3:*",
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::<BUCKET_NAME>/*",
      "Principal": {
        "AWS": [
          "arn:aws:iam::<ACCOUNT_ID>:user/<IAM_USER>"
        ]
      }
    }
  ]
}
```

---

## Public Access Policy

เปิด public read สำหรับ object ใน bucket — ใช้ร่วมกับ IAM policy ข้างบน

> ⚠️ Policy นี้ combine IAM user access + public read ไว้ใน statement เดียวกัน

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1689351321124",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:user/<IAM_USER>"
      },
      "Action": "s3:*",
      "Resource": "arn:aws:s3:::<BUCKET_NAME>/*"
    },
    {
      "Sid": "AllowPublicRead",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": ["s3:GetObject", "s3:GetObjectVersion"],
      "Resource": "arn:aws:s3:::<BUCKET_NAME>/*"
    }
  ]
}
```

---

## References

- [AWS Policy Generator](https://awspolicygen.s3.amazonaws.com/policygen.html)
- [Defining a Bucket Policy for Public Access — Wasabi Docs](https://docs.wasabi.com/docs/public-access-enabledisable)