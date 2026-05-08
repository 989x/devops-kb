# Git: Rename Commit Message

## เมื่อไหร่ที่ใช้

- พิมพ์ชื่อ commit ผิด เช่น `Docs:` → `docs:`
- ต้องการแก้ให้ตรง commit convention ของทีม

---

## วิธีที่ 1: แก้ commit ล่าสุด (amend)

```bash
git commit --amend -m "docs: ชื่อใหม่ที่ต้องการ"
```

จากนั้น force push:

```bash
git push --force-with-lease origin main
```

---

## วิธีที่ 2: แก้ commit เก่า (interactive rebase)

### Step 1: เปิด rebase โดยระบุจำนวน commit ย้อนหลัง

```bash
git rebase -i HEAD~2
```

> เปลี่ยน `2` ให้ตรงกับจำนวน commit ที่ต้องการย้อนกลับไป

### Step 2: เปลี่ยน `pick` → `reword` หน้า commit ที่ต้องการแก้

```
reword daf210f # Docs: add testcase_deployment.txt   ← เปลี่ยนตรงนี้
pick 664cdaa # docs: add okd pros/cons...
```

### Step 3: บันทึกออกจาก editor แล้ว Vim จะเปิดขึ้นมาอีกรอบ

แก้ชื่อ commit ให้ถูกต้อง จากนั้นบันทึก

### Step 4: Force push

```bash
git push --force-with-lease origin main
```

---

## Vim Commands

| คำสั่ง | ความหมาย |
|--------|----------|
| `i` | เข้า Insert mode (แก้ไขได้) |
| `Esc` | ออกจาก Insert mode |
| `:wq` | บันทึกและออก |
| `:q!` | ออกโดยไม่บันทึก (ยกเลิก) |

---

## ข้อควรระวัง

- การแก้ commit เก่าจะทำให้ **commit hash เปลี่ยน**
- ต้อง `--force-with-lease` ทุกครั้งหลัง rebase
- ถ้ามีคนอื่น pull branch นี้ไปแล้ว **ควรแจ้งทีมก่อน** force push

---

## ตัวอย่างจริง

แก้ commit ที่พิมพ์ `Docs:` (D ตัวใหญ่) → `docs:` (d ตัวเล็ก)

```bash
# 1. เปิด rebase
git rebase -i HEAD~2

# 2. ใน editor เปลี่ยน
#    pick → reword สำหรับ commit ที่ต้องการแก้

# 3. Vim เปิดอีกครั้ง → แก้ชื่อ → :wq

# 4. Push
git push --force-with-lease origin main
```