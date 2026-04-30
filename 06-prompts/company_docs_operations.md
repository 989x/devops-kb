# Company Docs Operations

## Stack & Tools

- **Library:** Node.js + `docx` (ติดตั้งด้วย `npm install -g docx`)
- **คำสั่ง run:** `node generate-xxx.js`
- **คำสั่ง validate:** `python3 /mnt/skills/public/docx/scripts/office/validate.py <file>`
- **Output path:** `/mnt/user-data/outputs/`

---

## Design System

### Typography

| Element           | Font        | Size | Weight | Color   |
|-------------------|-------------|------|--------|---------|
| Body              | Arial       | 22   | Normal | #333333 |
| H1                | Arial       | 30   | Bold   | #111111 |
| H2                | Arial       | 24   | Bold   | #444444 |
| H3                | Arial       | 22   | Bold   | #333333 |
| Note              | Arial       | 22   | Normal | #333333 |
| Code              | Courier New | 18   | Normal | #2E2E2E |
| Image placeholder | Arial       | 20   | Normal | #BBBBBB |

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

- **Header:** bg `#333333` / text white / bold / Arial 20
- **Row odd:** `#FFFFFF` / **Row even:** `#F9F9F9`
- **Border:** `SINGLE` size 1 color `#E0E0E0`
- **Cell padding:** top/bottom 80 / left/right 140
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
ข้อความ body ทั่วไป — ใช้อธิบายภาพรวมของแต่ละ section ก่อนลงรายละเอียด

### `note(text)`
ข้อความหมายเหตุ — prefix ด้วย `"หมายเหตุ: "` อัตโนมัติ  
ใช้บอกข้อควรระวัง ข้อกำหนด หรือเงื่อนไขพิเศษ  
ไม่ใช้ background color หรือ italic เพื่อให้ดู clean

### `bullet(text)`
Bullet list ใช้ dash `–` — เหมาะกับรายการที่ไม่มีลำดับ เช่น ประโยชน์ หรือสิ่งที่ต้องสังเกต

### `step(num, text)`
Step ที่ hardcode ตัวเลขเอง เช่น `step("1.", "คลิกปุ่ม...")`  
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
แสดง `📷  label` กึ่งกลาง สี `#BBBBBB`  
ให้ผู้ใช้แทรกรูปภาพจริงเองหลังได้รับไฟล์  
ใช้ plain Paragraph (ไม่ใช้ Table) เพื่อให้ลบและแทนที่ได้ง่าย

### `makeTable(headers[], rows[][], colWidths[])`
- `headers` — array ชื่อคอลัมน์
- `rows` — array of array ข้อมูลแต่ละแถว
- `colWidths` — array ความกว้างแต่ละคอลัมน์ (DXA) ผลรวมควรได้ ~9026

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