---
title: "Future Features (Archived)"
tags: [redis, roadmap, archived]
type: reference
status: archived
created: 2026-04-26
---

# Future Features (Archived)

Feature roadmap ที่วางแผนไว้ตอนพัฒนา redis-management — เก็บไว้เป็น reference

> **Context:** feature เหล่านี้ออกแบบไว้ในปี **2024** ช่วงที่ยังไม่มี tool สำเร็จรูปที่ทำได้ครบ ถึงปี **2026** [Redis Insight](https://redis.io/insight/) ได้พัฒนาจนครอบคลุมเกือบทุก feature ใน list นี้แล้ว

---

## Status Legend

- ✅ Redis Insight ทำได้แล้ว — ไม่ต้อง build
- ⚠️ Redis Insight ทำได้บางส่วน — อาจ build เองถ้าต้องการ custom
- ❌ Redis Insight ยังไม่มี — ถ้า need จริงค่อย build

---

## 1. Key Search and Filtering ✅

filter keys ด้วย pattern เช่น `user:*` หรือ `session:*`

Redis Insight มี built-in filter + pattern search พร้อม type filter และ TTL filter อยู่แล้ว

---

## 2. Key Grouping ✅

จัดกลุ่ม keys อัตโนมัติตาม prefix

Redis Insight grouping keys by `:` separator อยู่แล้ว เช่น `user:001` และ `user:002` จะถูกจัดอยู่ใต้กลุ่ม `user` โดยอัตโนมัติ

---

## 3. Alert System ❌

แจ้งเตือนเมื่อ key ใกล้ expire หรือ memory เกิน threshold — ส่งผ่าน Email, Slack, Line

Redis Insight ไม่มี built-in alert — ถ้าต้องการจริงให้ integrate กับ Prometheus + Alertmanager แทน

---

## 4. Backup and Restore ⚠️

export/import Redis data เป็นไฟล์

Redis Insight มี export บางส่วน แต่ไม่ครบ สำหรับ production backup ควรใช้ `BGSAVE` หรือ Redis replication โดยตรง

---

## 5. TTL Management ✅

ตั้ง TTL, ดู countdown, กรอง key ที่กำลังจะ expire

Redis Insight แสดง TTL ของแต่ละ key และแก้ไขได้ใน UI

---

## 6. Usage Statistics ✅

dashboard แสดง memory usage, hit/miss rate, request count, key count

Redis Insight มี built-in stats dashboard ครอบคลุมทุก metric ที่วางแผนไว้ และ integrate กับ Prometheus ได้ด้วย

---

## 7. User Management ⚠️

role-based access เช่น Admin / Read-only

Redis Insight มีใน Enterprise version — ถ้าต้องการใน open-source tier ต้อง build เอง

---

## 8. Access Control (ACL) ⚠️

กำหนดสิทธิ์ระดับ key สำหรับแต่ละ user

Redis Insight ช่วย configure Redis ACL ได้ แต่ ACL ที่ set จะ apply กับ Redis โดยตรง ไม่ใช่ระดับ application

---

## 9. Audit Log ❌

บันทึกทุก action (ADD, DELETE, VIEW) พร้อม timestamp และ user

Redis Insight ไม่มี — ถ้าต้องการสำหรับ compliance ต้อง implement เอง โดย log ทุก Redis command ผ่าน middleware

---

## 10. Multi-cluster Support ✅

จัดการหลาย Redis instance ใน UI เดียว

Redis Insight รองรับการเพิ่มหลาย connection ได้ใน sidebar