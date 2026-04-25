---
title: "Troubleshooting — Wasabi Endpoint & Region Errors"
tags: [wasabi, s3, endpoint, region, troubleshooting]
type: troubleshooting
status: stable
created: 2025-04-25
related:
  - "[[wasabi_connect_nodejs]]"
  - "[[wasabi_guideline]]"
---

# Troubleshooting — Wasabi Endpoint & Region Errors

## EndpointError

```
Failed to upload to Wasabi: EndpointError: Invalid region: region was not a valid DNS name.
```

**สาเหตุ:** ใส่ endpoint URL ลงใน `region` field แทนที่จะใส่ region code

**วิธีแก้:** เปลี่ยน `region` ให้เป็น region code เท่านั้น

```ts
// ❌ ผิด
region: "s3.us-east-1.wasabisys.com"

// ✅ ถูก
region: "us-east-1"
```

> Source: [S3 regions regression (fails with DNS error) #306](https://github.com/aws/aws-sdk-js/issues/306)

---

## InvalidAccessKeyId

```
Failed to upload to Wasabi: InvalidAccessKeyId: The AWS Access Key Id you provided does not exist in our records.
```

**สาเหตุ:** `endpoint_url` ไม่ตรงกับ region ของ bucket

**วิธีแก้:** ระบุ region ใน `endpoint_url` ให้ตรงกับ bucket

```ts
// ❌ ผิด
endpoint_url: "https://s3.wasabisys.com"

// ✅ ถูก
endpoint_url: "https://s3.<REGION>.wasabisys.com"
```

> Source: [The AWS Access Key Id you provided does not exist in our records](https://stackoverflow.com/questions/68415772/the-aws-access-key-id-you-provided-does-not-exist-in-our-records-aws)