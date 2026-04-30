# Company Docs Operations

## Stack & Tools

- **Library:** Node.js + `docx` (ติดตั้งด้วย `npm install -g docx`)
- **คำสั่ง run:** `node generate-xxx.js`
- **คำสั่ง validate:** `python3 /mnt/skills/public/docx/scripts/office/validate.py <file>`
- **Output path:** `/mnt/user-data/outputs/`

---

## ⚠️ ก่อนสร้างไฟล์ทุกครั้ง

ถามผู้ใช้ก่อนเสมอว่า:

> **"เอกสารนี้เป็นส่วนตัว หรือบริษัท?"**
> - **ส่วนตัว** → ใช้ theme Personal (สีเทา)
> - **บริษัท** → ใช้ theme Company (สีเขียว OpenLandscape)

---

## Design System

### Typography

> ⚠️ **กฎสำคัญ:** สีเขียวใช้เฉพาะ **Heading (H1, H2, H3) เท่านั้น**
> Body, Note, Bullet, Step, Image placeholder ต้องเป็นสีเทาเข้มเสมอ ทั้งสอง theme

#### Personal (ส่วนตัว)

| Element           | Font        | Size | Weight | Color     |
|-------------------|-------------|------|--------|-----------|
| Body              | Arial       | 22   | Normal | `#333333` |
| H1                | Arial       | 30   | Bold   | `#111111` |
| H2                | Arial       | 24   | Bold   | `#444444` |
| H3                | Arial       | 22   | Bold   | `#333333` |
| Note              | Arial       | 22   | Normal | `#333333` |
| Code              | Courier New | 18   | Normal | `#2E2E2E` |
| Image placeholder | Arial       | 20   | Normal | `#BBBBBB` |

- Code block background: `#F5F5F5`
- Image placeholder: centered, no background

#### Company (บริษัท — OpenLandscape)

| Element           | Font        | Size | Weight | Color     |
|-------------------|-------------|------|--------|-----------|
| Body              | Arial       | 22   | Normal | `#333333` |
| H1                | Arial       | 30   | Bold   | `#1E3A0A` |
| H2                | Arial       | 24   | Bold   | `#3A5E18` |
| H3                | Arial       | 22   | Bold   | `#2D4A1A` |
| Note              | Arial       | 22   | Normal | `#333333` |
| Code              | Courier New | 18   | Normal | `#2E2E2E` |
| Image placeholder | Arial       | 20   | Normal | `#BBBBBB` |

- Code block background: `#F5F5F5`
- Image placeholder: centered, no background

### Spacing (DXA)

| Element       | Before | After |
|---------------|--------|-------|
| H1            | 480    | 160   |
| H2            | 320    | 120   |
| H3            | 240    | 80    |
| para / note   | 80     | 80    |
| bullet / step | 40     | 40    |
| codeBlock     | 120    | 120   |
| sp()          | 60     | 60    |

### Page

- **Size:** A4 — width 11906 / height 16838 (DXA)
- **Margin:** top / right / bottom / left = 1440

### Table

#### Personal

| Element     | Value                           |
|-------------|--------------------------------|
| Header bg   | `#333333`                       |
| Header text | white / bold / Arial 20         |
| Row odd     | `#FFFFFF`                       |
| Row even    | `#F9F9F9`                       |
| Border      | `SINGLE` size 1 color `#E0E0E0` |

#### Company

| Element     | Value                           |
|-------------|--------------------------------|
| Header bg   | `#78B52D`                       |
| Header text | white / bold / Arial 20         |
| Row odd     | `#FFFFFF`                       |
| Row even    | `#F4FAF0`                       |
| Border      | `SINGLE` size 1 color `#C5E0A0` |

- **Cell padding (ทั้งสอง theme):** top/bottom 80 / left/right 140
- **Total column width:** รวมกันควรได้ ~9026 DXA

---

## Functions Reference

### `h1(text)`
Heading 1 — ใช้เปิด section หลัก เช่น `"1. บทนำ"` หรือ `"2. ขั้นตอนการติดตั้ง"`

### `h2(text)`
Heading 2 — ใช้เปิด sub-section เช่น `"ขั้นตอนที่ 1 — สร้าง Deployment"`

### `h3(text)`
Heading 3 — ใช้ label ก่อน code block เช่น `"YAML — Deployment"`  
ขนาดเท่า body แต่ bold เพื่อไม่ให้หนักเกินไป

### `para(text)`
ข้อความ body ทั่วไป — สี `#333333` ทั้งสอง theme

### `note(text)`
ข้อความคำอธิบายเพิ่มเติม — ไม่มี prefix, ไม่มี label นำหน้า  
สี `#333333` เหมือน body ใช้บอกข้อควรระวังหรือเงื่อนไขพิเศษ  
ไม่ใช้ background color หรือ italic เพื่อให้ดู clean

### `bullet(text)`
Bullet list ใช้ dash `–` — สี `#333333` เหมือน body

### `step(num, text)`
Step ที่ hardcode ตัวเลขเอง เช่น `step("1.", "คลิกปุ่ม...")`  
ตัวเลขและข้อความใช้สี `#333333` เหมือน body ทั้งคู่ — ไม่ใช้สีเขียว  
ใช้แทน `numbered()` เพื่อให้แทรกหรือลบขั้นตอนได้โดยไม่กระทบตัวเลขอื่น

### `codeBlock(lines[])`
- รับ **array of string** แต่ละ element คือ 1 บรรทัด
- render เป็น block เดียว ด้วย `\n` break ระหว่างบรรทัด
- ความกว้างเต็มหน้า **ไม่มี indent** ซ้ายขวา
- background `#F5F5F5`

```js
codeBlock([
  "apiVersion: v1",
  "kind: Pod",
  "metadata:",
  "  name: example",
])
```

### `imagePlaceholder(label)`
แสดง `📷  label` กึ่งกลาง สี `#BBBBBB` **ทั้งสอง theme**  
ให้ผู้ใช้แทรกรูปภาพจริงเองหลังได้รับไฟล์  
ใช้ plain Paragraph (ไม่ใช้ Table) เพื่อให้ลบและแทนที่ได้ง่าย

### `makeTable(headers[], rows[][], colWidths[])`
- `headers` — array ชื่อคอลัมน์
- `rows` — array of array ข้อมูลแต่ละแถว
- `colWidths` — array ความกว้างแต่ละคอลัมน์ (DXA) ผลรวมควรได้ ~9026
- Header bg ใช้สีตาม theme ที่เลือก

```js
makeTable(
  ["ฟิลด์", "ค่า", "คำอธิบาย"],
  [
    ["Name", "example", "ชื่อ HPA"],
    ["Min replicas", "1", "จำนวน Pod ขั้นต่ำ"],
  ],
  [2400, 1800, 4826]
)
```

### `sp()`
Blank paragraph สำหรับเพิ่ม visual spacing ระหว่าง element  
ใช้ระหว่าง section ย่อยที่ไม่ต้องการ heading แต่ต้องการ breathing room

---

## Patterns

### เพิ่ม section ใหม่

```
h2("ขั้นตอนที่ N — ชื่อขั้นตอน")
para("อธิบายภาพรวม")
sp()
step("1.", "...")
step("2.", "...")
sp()
imagePlaceholder("คำอธิบายรูป")
sp()
h3("YAML — ชื่อ")
codeBlock([...])
note("ข้อควรระวัง")
sp()
```

### YAML หลายตัวที่ต่างกันแค่ `name`

แสดง YAML ตัวแรกอย่างเดียว แล้วอธิบายใน step ว่า:

> "ทำซ้ำโดยเปลี่ยน `name` เป็น `load-generator-2` ถึง `load-generator-N`"

ไม่ต้องแสดง YAML ซ้ำ ป้องกันเอกสารยาวโดยไม่จำเป็น

### แก้ตัวเลข step

เนื่องจากใช้ `step()` แบบ hardcode ให้แก้ตัวเลขในฟังก์ชันนั้นโดยตรง  
ไม่กระทบ step อื่นในหน้าเดียวกัน

### Title Page

ประกอบด้วย 4 ส่วนตามลำดับ:

1. ชื่อหลัก (size 56 bold)
2. ชื่อรอง (size 32)
3. คำอธิบาย / กลุ่มเป้าหมาย (size 24)
4. version · วันที่ · ทีม (size 20 สีอ่อน)

ตามด้วย `new Paragraph({ children: [new PageBreak()] })` ก่อนเริ่มเนื้อหา

---

## Known Issues & Solutions

| ปัญหา | สาเหตุ | วิธีแก้ |
|---|---|---|
| Docker Hub rate limit (ImagePullBackOff) | unauthenticated pull limit | ใช้ `quay.io` หรือ `registry.access.redhat.com` แทน |
| HPA "object has been modified" error | HPA อัปเดตตัวเองพอดีกับกด Save | Refresh หน้าแล้วแก้ใหม่ |
| imagePlaceholder ลบยาก | ใช้ Table ทำให้ซับซ้อน | ใช้ plain `Paragraph` แทน `Table` |
| numbered() กระทบทุก step เมื่อแทรก/ลบ | auto-increment ของ docx numbering | ใช้ `step()` hardcode แทน |
| code block มี indent ทำให้แคบ | มี `indent: { left, right }` ใน codeBlock | ลบ indent ออก ให้เต็มความกว้าง |
| load-generator สร้าง load ได้น้อย (~10% ต่อตัว) | curl loop เป็น sequential | ใช้อย่างน้อย 6 ตัวเพื่อให้ CPU รวมเกิน 50% |
| font size ใหญ่เกินไป ตัดบรรทัดกลางคำ | ใส่ size เป็น 2 เท่าของ design system (เช่น 44 แทน 22) | size ใน docx-js คือ half-points ใช้ตามตาราง design system ตรงๆ |
| สีเขียวเยอะเกินไปใน body/step/note/placeholder | ใช้ C.h2 หรือสีเขียวกับ element ที่ไม่ใช่ heading | body, note, bullet, step, imagePlaceholder ใช้ `#333333` และ `#BBBBBB` เสมอ |

---

## ⚠️ Critical Rules — ห้ามทำผิดเด็ดขาด

### 1. Font Size — half-points เสมอ

size ใน docx-js คือ **half-points** ไม่ใช่ points

| ต้องการ | ใส่ใน code | ❌ ห้ามใส่ |
|---|---|---|
| 11pt (body) | `size: 22` | `size: 44` |
| 15pt (H1) | `size: 30` | `size: 60` |
| 12pt (H2) | `size: 24` | `size: 48` |
| 9pt (code) | `size: 18` | `size: 36` |
| 28pt (title) | `size: 56` | `size: 112` |

ถ้าใส่ผิด: ตัวอักษรใหญ่ 2 เท่า, title ตัดกลางคำ, เอกสารดูผิดปกติทันที

### 2. โครงสร้างเอกสาร — ต้องมีครบทุกส่วน

เอกสารคู่มือทุกฉบับต้องมีโครงสร้างดังนี้:

```
1. บทนำ
   1.1 X คืออะไร
   1.2 ประโยชน์
   1.3 Prerequisites  ← ตาราง รายการ / รายละเอียด

2. ขั้นตอนการติดตั้งและทดสอบ
   ขั้นตอนที่ 1 — ...
   ขั้นตอนที่ 2 — ...
   ...

3. ลบ Resources หลังทดสอบ  ← ตารางลำดับการลบ ห้ามข้าม
```

**ห้ามข้าม:**
- sub-heading (1.1, 1.2, 1.3) — ถ้าไม่มีเอกสารดูไม่เป็นทางการ
- Prerequisites table — ผู้อ่านต้องรู้ก่อนเริ่มทำ
- Cleanup section — ลบตามลำดับป้องกัน HPA พยายาม scale ระหว่างลบ