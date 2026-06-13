# คู่มือการล้างเมลใน Zimbra เพื่อเพิ่มพื้นที่

คู่มือนี้ใช้สำหรับ Zimbra Collaboration Suite (ZCS) เหมาะสำหรับกรณีที่พื้นที่กล่องจดหมายเต็ม หรือมีเมลสะสมจำนวนมาก เช่น การแจ้งเตือนจากระบบหรือ Grafana Alerts

---

## 1. การลบโดยตรง

### 1.1 ลบ Folder ที่เป็น System Alert ทั้งหมด (เช่น Grafana)

1. คลิกขวา ที่ Folder Grafana (หรือ folder แจ้งเตือนอื่น ๆ)
2. เลือก "Empty Folder"
3. ยืนยันการลบ
4. จากนั้นกลับไป Empty Trash อีกครั้ง

วิธีนี้ลบได้ทีเดียวหลายร้อยถึงหลายพันฉบับ

### 1.2 ลบเมลจาก Sender คนเดียวกันทั้งหมด

1. คลิกขวา ที่เมลจาก Sender ที่ต้องการลบ
2. เลือก "Find Mail from Sender" หรือ "Find messages from..."
3. ระบบจะ Filter เมลทั้งหมดจากคนนั้น
4. กด Ctrl+A เพื่อเลือกทั้งหมด
5. กด Delete
6. Empty Trash หลังลบเสร็จ

---

## 2. การลบด้วยการค้นหา

พิมพ์คำสั่งใน Search Bar ด้านบน แล้วกด Enter จากนั้นกด Ctrl+A เพื่อเลือกทั้งหมด → กด Delete → Empty Trash

### 2.1 ค้นหาจาก Sender หรือหัวข้อ

```
# ค้นหาจาก Sender
from:noreply@example.com
from:grafana@yourdomain.com

# ค้นหาจากหัวข้อ
subject:alert
subject:notification
subject:warning
subject:"Grafana alert"

# ค้นหาแบบรวม Sender + Subject
from:grafana subject:alert
```

### 2.2 ค้นหาเมลที่มีไฟล์แนบขนาดใหญ่

```
# ไฟล์แนบใหญ่กว่า 5MB
has:attachment larger:5mb

# ไฟล์แนบใหญ่กว่า 10MB
has:attachment larger:10mb
```

### 2.3 ค้นหาเมลเก่าเกิน X วัน

```
# เมลเก่ากว่า 30 วัน
before:-30days

# เมลเก่ากว่า 90 วัน
before:-90days

# เมลเก่ากว่า 30 วัน ใน Folder Grafana
in:Grafana before:-30days

# เมลเก่ากว่า 1 ปี
before:2024/01/01
```

---

## 3. การลบระดับผู้ดูแลระบบ

### 3.1 ล้างผ่าน Admin Console

1. เข้า Zimbra Admin Console
2. ไปที่ Accounts → [ชื่อบัญชี] → Mailbox
3. คลิก Purge เพื่อล้างข้อมูลที่ถูกลบออกจากระบบ

---

## ⚠️ ข้อควรระวัง

- พื้นที่จะถูกคืนก็ต่อเมื่อ Empty Trash แล้วเท่านั้น
- ตรวจสอบเมลใน Inbox ก่อนลบว่าไม่มีเมลสำคัญปะปน
- ถ้าไม่แน่ใจ ให้ Archive เมลก่อนลบ โดยใช้ Zimlet Archive ในแถบด้านซ้าย
- การลบผ่าน Admin Console จะมีผลทันที และอาจกู้คืนไม่ได้