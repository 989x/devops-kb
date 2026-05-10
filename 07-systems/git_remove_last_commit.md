# การลบ Commit ล่าสุดที่ Push ไปแล้ว

- หมวดหมู่: Git / Version Control  
- ระดับ: Developer ทุกระดับ  
- อัปเดตล่าสุด: 2025

เมื่อ commit ถูก push ขึ้น remote repository ไปแล้ว การลบหรือย้อนกลับมีผลกระทบต่อสมาชิกในทีมทุกคน  
จึงต้องเลือกวิธีให้เหมาะกับสถานการณ์ก่อนดำเนินการเสมอ

> **กฎสำคัญ:** ห้าม force push บน `main` / `master` หรือ branch ที่ทีมใช้ร่วมกัน โดยไม่ได้รับอนุญาตจาก Lead / Repository Owner

```
commit ที่ต้องการลบอยู่บน branch ไหน?
│
├── main / master / branch ที่คนอื่นใช้ร่วม
│   └── ✅ ใช้ git revert (วิธีที่ 1)
│
└── feature branch / branch ส่วนตัว
    ├── ต้องการเก็บไฟล์ที่แก้ไขไว้   → git reset --soft (วิธีที่ 2a)
    └── ต้องการลบทิ้งทุกอย่าง      → git reset --hard (วิธีที่ 2b)
```

---

## วิธีที่ 1 — `git revert` (แนะนำสำหรับ shared branch)

สร้าง commit ใหม่ที่ทำหน้าที่ "ย้อนกลับ" การเปลี่ยนแปลงของ commit เดิม  
ประวัติ (history) ยังคงครบถ้วน ไม่กระทบการทำงานของสมาชิกคนอื่น

```bash
# 1. ตรวจสอบว่าอยู่บน branch ที่ถูกต้อง
git branch

# 2. ดู commit ล่าสุดเพื่อยืนยัน
git log --oneline -5

# 3. ย้อนกลับ commit ล่าสุด
git revert HEAD

# 4. บันทึก commit message (editor จะเปิดขึ้น — กด :wq เพื่อบันทึกใน vim)

# 5. push ขึ้น remote
git push
```

### ผลลัพธ์
- Remote repository จะมี commit ใหม่เพิ่มขึ้น 1 อัน
- โค้ดกลับสู่สถานะก่อน commit ที่ต้องการลบ
- ประวัติสมบูรณ์ — สามารถ audit ได้ในภายหลัง

---

## วิธีที่ 2 — `git reset` + Force Push (สำหรับ branch ส่วนตัวเท่านั้น)

> ⚠️ **คำเตือน:** วิธีนี้จะเขียนทับประวัติบน remote ห้ามใช้บน branch ที่มีสมาชิกคนอื่น pull หรือทำงานอยู่

### 2a — เก็บไฟล์ที่แก้ไขไว้ (Soft Reset)

ใช้เมื่อ: ต้องการยกเลิก commit แต่ยังต้องการไฟล์ที่แก้ไขไว้เพื่อแก้ต่อ

```bash
# 1. ย้อนกลับ 1 commit — ไฟล์ยังอยู่ใน staging area
git reset --soft HEAD~1

# 2. ตรวจสอบสถานะ
git status

# 3. force push
git push --force
```

### 2b — ลบทิ้งทุกอย่าง (Hard Reset)

ใช้เมื่อ: ต้องการลบ commit และการเปลี่ยนแปลงทั้งหมดออกอย่างถาวร

```bash
# 1. ย้อนกลับ 1 commit — ไฟล์ที่แก้ไขจะหายไปทั้งหมด
git reset --hard HEAD~1

# 2. force push
git push --force
```

> 💡 **แนะนำ:** ใช้ `git push --force-with-lease` แทน `--force` เพื่อป้องกันการเขียนทับ commit ของคนอื่นที่อาจ push มาในระหว่างนั้น
>
> ```bash
> git push --force-with-lease
> ```

---

## สรุปเปรียบเทียบ

```mermaid
flowchart TD
    A([ต้องการลบ commit?]) --> B{branch ที่คนอื่นใช้ร่วม?}

    B -->|Yes| C[git revert]
    B -->|No| D{ต้องการเก็บไฟล์\nที่แก้ไขไว้?}

    D -->|Yes| E[git reset --soft]
    D -->|No| F[git reset --hard]

    C --> G["push ปกติ\nประวัติยังครบ"]
    E --> H["force push\nไฟล์ยังอยู่ใน staging"]
    F --> I["force push\nลบทุกอย่างถาวร"]

    style C fill:#2d6a4f,color:#fff
    style E fill:#f4a261,color:#fff
    style F fill:#c1121f,color:#fff
```

---

## กรณีพิเศษ

### ลบมากกว่า 1 commit

```bash
# ย้อนกลับ 3 commit ล่าสุด (เปลี่ยน 3 เป็นจำนวนที่ต้องการ)
git reset --soft HEAD~3
git push --force-with-lease
```

### branch ถูก protect ไม่ให้ force push

กรณีนี้ใช้ได้เฉพาะ `git revert` เท่านั้น  
หากต้องการยกเว้นเป็นกรณีพิเศษ ให้ติดต่อ Repository Owner เพื่อปลด protection ชั่วคราว

### สมาชิกในทีม pull ไปแล้วหลังจากที่ force push

สมาชิกที่ได้รับผลกระทบต้องรัน:

```bash
git fetch origin
git reset --hard origin/<branch-name>
```

---

## Checklist ก่อนดำเนินการ

- [ ] ยืนยันชื่อ branch ที่กำลังทำงานอยู่ด้วย `git branch`
- [ ] ดู commit ที่ต้องการลบด้วย `git log --oneline -5`
- [ ] ตรวจสอบว่ามีสมาชิกคนอื่นกำลังทำงานบน branch นี้หรือไม่
- [ ] หาก force push — แจ้งทีมล่วงหน้าก่อนเสมอ

---

## อ้างอิง

- [Git Documentation — git-revert](https://git-scm.com/docs/git-revert)
- [Git Documentation — git-reset](https://git-scm.com/docs/git-reset)