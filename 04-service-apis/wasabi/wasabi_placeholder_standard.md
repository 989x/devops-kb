---
title: "Wasabi Placeholder Standard"
tags: [wasabi, standard, placeholder, documentation]
type: reference
status: stable
created: 2026-04-25
related:
  - "[[wasabi_guideline]]"
  - "[[_index]]"
---

# Wasabi Placeholder Standard

มาตรฐานการแทนค่าใน KB เพื่อป้องกัน sensitive data และลด noise จากค่าที่ไม่มีความหมาย

---

## Placeholder Table

| Placeholder | ประเภท | ตัวอย่าง |
|-------------|--------|---------|
| `<BUCKET_NAME>` | config | `my-project-storage` |
| `<REGION>` | config | `ap-southeast-1` |
| `<WASABI_ENDPOINT>` | config | `https://s3.ap-southeast-1.wasabisys.com` |
| `<ACCESS_KEY>` | sensitive | `AKIAIOSFODNN7EXAMPLE` |
| `<SECRET_KEY>` | sensitive | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `<IMAGE_KEY>` | dynamic | `image-abc123def456.jpg` |
| `<SIGNATURE>` | dynamic | `b94d27b9934d3e08a52e52d7da7dabfac484efe04294e576b2b68e6b58e3c8d7` |
| `<ETAG>` | dynamic | `d41d8cd98f00b204e9800998ecf8427e` |
| `<REQUEST_ID>` | dynamic | `4B5C6D7E8F9A0B1C` |
| `<EXTENDED_REQUEST_ID>` | dynamic | `aBcDeFgHiJkLmNoPqRsTuVwXyZ012345abcdefghijklmnopqrstuvwxyz678901` |
| `<INVOCATION_ID>` | dynamic | `550e8400-e29b-41d4-a716-446655440000` |
| `<CONTENT_SHA256>` | dynamic | `9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08` |
| `<TIMESTAMP>` | dynamic | `20240315T083045Z` |
| `<DATE>` | dynamic | `20240315` |

### ประเภทของ Placeholder

| ประเภท | ความหมาย | ตัวอย่าง |
|--------|----------|---------|
| `sensitive` | ห้าม expose ทุกกรณี | credential, key, secret |
| `config` | เปลี่ยนตาม environment | endpoint, region, bucket |
| `dynamic` | regenerate ได้ทุก request | hash, signature, ID |

---

## เกณฑ์ว่าอะไรควรแทน

- **Sensitive** — credential ทุกชนิด: access key, secret key, token, password
- **Dynamic ที่ยาวเกิน 16 ตัวอักษร** — hash, signature, UUID, request ID
- **Config ที่ต่างกันตาม environment** — endpoint URL, region, bucket name

## เกณฑ์ว่าอะไรไม่ต้องแทน

- HTTP method: `GET`, `POST`, `PUT`
- Status code: `200`, `403`, `404`
- Port number: `443`, `80`
- Version string: `aws-sdk-js/3.370.0`, `nodejs#18.12.1`
- Header name: `x-amz-date`, `content-type`
