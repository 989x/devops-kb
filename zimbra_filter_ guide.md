# การทำ Filter ใน Zimbra

อ้างอิง: https://zimbra.in.th/blogdetail.php?id=47&cateSubId=26

---

## ขั้นตอนที่ 1 — หา Email Address ของผู้ส่ง

1. เปิดเมลที่ต้องการทำ filter
2. ดูที่ช่อง From: เพื่อหา email address ของผู้ส่ง

> ตัวอย่าง: `notification@olsxops.com`

---

## ขั้นตอนที่ 2 — สร้าง Folder สำหรับเก็บเมล

1. มองไปที่แถบซ้าย Mail Folders
2. คลิกขวาที่ folder ที่ต้องการสร้าง folder ย่อยภายใน เช่น `Container`
3. เลือก New Folder
4. ตั้งชื่อ folder เช่น `Grafana`
5. กด OK

> folder ใหม่จะปรากฏอยู่ภายใต้ folder ที่เลือก เช่น `Container > Grafana`

---

## ขั้นตอนที่ 3 — เข้าหน้าตั้งค่า Filters

1. คลิกที่เมนู Preferences แถบด้านบน
2. เลือก Filters ในเมนูซ้าย
3. คลิกแท็บ Incoming Message Filters

---

## ขั้นตอนที่ 4 — สร้าง Filter ใหม่

1. กดปุ่ม Create Filter
2. กรอก Filter Name เช่น `Grafana-Alert-Filter`
3. ตั้งเงื่อนไข (Conditions)
   - dropdown แรก: เปลี่ยนจาก `Subject` เป็น `From`
   - dropdown สอง: `contains`
   - ช่องข้อความ: กรอก email address เช่น `notification@olsxops.com`
4. ตั้ง Action
   - คลิก dropdown `Keep in Inbox` เปลี่ยนเป็น `Move Into Folder`
   - เลือก folder ปลายทาง เช่น `Container > Grafana`
5. กด OK แล้วกด Save มุมบนซ้าย

> ถ้ายังไม่มี folder ให้สร้าง folder ใหม่ก่อน โดยคลิกขวาที่ Mail Folders แล้วเลือก New Folder

---

## ขั้นตอนที่ 5 — Run Filter สำหรับเมลเก่า

> Filter ปกติจะจัดการเฉพาะเมลใหม่ที่เข้ามา
> ต้องใช้ Run Filter เพื่อย้อนกลับไปจัดการเมลเก่าที่มีอยู่แล้ว

1. กลับไปที่ Preferences แล้วเลือก Filters
2. คลิกเลือก filter ที่เพิ่งสร้าง เช่น `Grafana-Alert-Filter`
3. กดปุ่ม Run Filter
4. หน้าต่าง Choose Folder จะเปิดขึ้น
5. ติ๊ก checkbox หน้าชื่อ folder ที่ต้องการให้ scan เช่น `Grafana`

> ต้องคลิกที่กล่อง checkbox ด้านซ้ายของชื่อ folder เท่านั้น
> การคลิกชื่อให้ highlight ไม่เพียงพอ

6. กด OK เพื่อเริ่มรัน

---

## ผลลัพธ์ที่ได้

| รายการ | ผล |
|---|---|
| เมลใหม่จากผู้ส่งที่กำหนด | ถูกย้ายเข้า folder อัตโนมัติ |
| เมลเก่าที่มีอยู่แล้ว | ถูกย้ายหลังจาก Run Filter |
| Inbox | ไม่รกจากเมล alert อีกต่อไป |