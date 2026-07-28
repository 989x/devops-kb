---
title: "Redis Management"
tags: [redis, go-fiber, internal-services, deprecated]
type: index
status: deprecated
created: 2026-04-26
---

# Redis Management

ระบบจัดการ Redis cache ผ่าน Web UI สร้างด้วย Go + Fiber — **deprecated แล้ว** เนื่องจาก Redis Insight ทำได้ครบกว่าและฟรี

---

## ทำไมถึง Deprecated

project นี้ออกแบบในปี **2024** ช่วงที่ยังไม่มี tool สำเร็จรูปที่ครอบคลุม feature เหล่านี้อย่างครบถ้วน การสร้าง Redis dashboard เองจึงมี value และสมเหตุสมผลในขณะนั้น

แต่ในปี **2026** [Redis Insight](https://redis.io/insight/) ได้พัฒนาจนครอบคลุมเกือบทุก feature ที่วางแผนไว้แล้ว และยังมีสิ่งที่ไม่ได้วางแผนไว้อีกมาก เช่น visual query builder, slow log, pub/sub monitor การ maintain codebase เองจึงไม่คุ้มค่าอีกต่อไป

| Feature | Redis Insight | redis-management |
|---------|:---:|:---:|
| Key Search & Filtering | ✅ | ❌ |
| Key Grouping | ✅ | ❌ |
| TTL Management | ✅ | ❌ |
| Usage Statistics | ✅ | ❌ |
| Multi-cluster | ✅ | ❌ |
| View/Delete Keys | ✅ | ✅ |

การ rebuild สิ่งที่ทำได้แล้วไม่คุ้มค่า จึงตัดสินใจ deprecate และเก็บไว้เฉพาะ concept ที่ reusable

---

## สิ่งที่เก็บไว้

- [[concept_architecture]] — pattern การ wire Fiber routes + Redis client
- [[concept_key_counting]] — logic นับ items แยกตาม Redis data type
- [[future_features]] — feature roadmap พร้อม annotation ว่าอันไหน Redis Insight ทำได้แล้ว