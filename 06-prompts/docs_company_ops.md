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
| Body              | Sarabun     | 22   | Normal | `#333333` |
| H1                | Sarabun     | 30   | Bold   | `#111111` |
| H2                | Sarabun     | 24   | Bold   | `#444444` |
| H3                | Sarabun     | 22   | Bold   | `#333333` |
| Note              | Sarabun     | 22   | Normal | `#333333` |
| Code              | Lucida Sans | 22   | Normal | `#2E2E2E` |
| Image placeholder | Sarabun     | 20   | Normal | `#BBBBBB` |

- Code block background: `#F5F5F5`
- Image placeholder: centered, no background

#### Company (บริษัท — OpenLandscape)

| Element           | Font        | Size | Weight | Color     |
|-------------------|-------------|------|--------|-----------|
| Body              | Sarabun     | 22   | Normal | `#333333` |
| H1                | Sarabun     | 30   | Bold   | `#1E3A0A` |
| H2                | Sarabun     | 24   | Bold   | `#3A5E18` |
| H3                | Sarabun     | 22   | Bold   | `#2D4A1A` |
| Note              | Sarabun     | 22   | Normal | `#333333` |
| Code              | Lucida Sans | 18   | Normal | `#2E2E2E` |
| Image placeholder | Sarabun     | 20   | Normal | `#BBBBBB` |

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
- **Cell body text size:** 20 (10pt) — เท่ากับ header แต่ header เป็น bold
- **Total column width:** รวมกันควรได้ ~9026 DXA

---

## Document styles override (บังคับทุก Document)

> ⚠️ **ต้องใส่ทุกครั้ง** — ถ้าไม่มี Google Docs จะ reset สีและ font ของ heading เป็น default และ Document outline จะว่างเปล่า

```js
const doc = new Document({
  styles: {
    paragraphStyles: [
      {
        id: "Heading1", name: "Heading 1",
        basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: "Sarabun", size: 30, bold: true, color: "1E3A0A" },
        paragraph: { spacing: { before: 480, after: 160 }, outlineLevel: 0 }
      },
      {
        id: "Heading2", name: "Heading 2",
        basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: "Sarabun", size: 24, bold: true, color: "3A5E18" },
        paragraph: { spacing: { before: 320, after: 120 }, outlineLevel: 1 }
      },
      {
        id: "Heading3", name: "Heading 3",
        basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { font: "Sarabun", size: 22, bold: true, color: "2D4A1A" },
        paragraph: { spacing: { before: 240, after: 80 }, outlineLevel: 2 }
      },
    ]
  },
  sections: [{ ... }]
});
```

> สำหรับ Personal theme ให้เปลี่ยน color เป็น `111111`, `444444`, `333333` ตามลำดับ

---

## Functions Reference

### `h1(text)`
Heading 1 — ต้องใส่ `heading: HeadingLevel.HEADING_1` เสมอ เพื่อให้ Google Docs แสดง outline ได้

```js
function h1(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_1,
    spacing: { before: 480, after: 160 },
    children: [new TextRun({ text, ...C.h1 })]
  });
}
```

### `h2(text)`
Heading 2 — ต้องใส่ `heading: HeadingLevel.HEADING_2` เสมอ

```js
function h2(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_2,
    spacing: { before: 320, after: 120 },
    children: [new TextRun({ text, ...C.h2 })]
  });
}
```

### `h3(text)`
Heading 3 — ต้องใส่ `heading: HeadingLevel.HEADING_3` เสมอ ขนาดเท่า body แต่ bold

```js
function h3(text) {
  return new Paragraph({
    heading: HeadingLevel.HEADING_3,
    spacing: { before: 240, after: 80 },
    children: [new TextRun({ text, ...C.h3 })]
  });
}
```

### `para(text)`
ข้อความ body ทั่วไป — font Sarabun สี `#333333` ทั้งสอง theme

### `note(text)`
ข้อความคำอธิบายเพิ่มเติม — ไม่มี prefix, ไม่มี label นำหน้า
font Sarabun สี `#333333` เหมือน body ใช้บอกข้อควรระวังหรือเงื่อนไขพิเศษ
ไม่ใช้ background color หรือ italic เพื่อให้ดู clean

### `bullet(text)`
Bullet list ใช้ dash `–` — font Sarabun สี `#333333` เหมือน body

### `step(num, text)`
Step ที่ hardcode ตัวเลขเอง เช่น `step("1.", "คลิกปุ่ม...")`
ตัวเลขและข้อความใช้ font Sarabun สี `#333333` เหมือน body ทั้งคู่ — ไม่ใช้สีเขียว
ใช้แทน `numbered()` เพื่อให้แทรกหรือลบขั้นตอนได้โดยไม่กระทบตัวเลขอื่น

### `codeBlock(lines[])`
- รับ **array of string** แต่ละ element คือ 1 บรรทัด
- font **Lucida Sans** size 18 (9pt)
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
แสดง `รูปภาพ - label` กึ่งกลาง สี `#BBBBBB` **ทั้งสอง theme**
ให้ผู้ใช้แทรกรูปภาพจริงเองหลังได้รับไฟล์
ใช้ plain Paragraph (ไม่ใช้ Table) เพื่อให้ลบและแทนที่ได้ง่าย

### `makeTable(headers[], rows[][], colWidths[])`
- `headers` — array ชื่อคอลัมน์
- `rows` — array of array ข้อมูลแต่ละแถว
- `colWidths` — array ความกว้างแต่ละคอลัมน์ (DXA) ผลรวมควรได้ ~9026
- Header bg ใช้สีตาม theme ที่เลือก — bold / size 20
- Body cell ใช้ font Sarabun size **20** (10pt) — เท่า header แต่ไม่ bold
- รองรับ `\n` ใน cell เพื่อแสดงหลายบรรทัดใน cell เดียว

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
| Heading แสดงเป็น "Normal text" ใน Google Docs | ไม่ได้ใส่ `heading: HeadingLevel` ใน Paragraph | เพิ่ม `heading: HeadingLevel.HEADING_1/2/3` ในทุก h1/h2/h3 |
| Document outline ว่างเปล่าใน Google Docs | ขาด `outlineLevel` ใน paragraphStyles | เพิ่ม `paragraphStyles` override ใน Document พร้อม `outlineLevel: 0/1/2` |
| note/warning มี emoji prefix | ใส่ 📌 หรือ ⚠️ นำหน้า text | ใช้ `note(text)` โดยไม่มี prefix — แค่ข้อความเปล่า |
| cell ใน table มีหลายบรรทัดแต่แสดงเป็น row แยก | ใส่ข้อมูล 2 แถวแทนที่จะเป็น cell เดียว | ใช้ `\n` ใน string เดียวกัน — makeTable รองรับ multiline cell แล้ว |

---

## ⚠️ Critical Rules — ห้ามทำผิดเด็ดขาด

### 1. Font Size — half-points เสมอ

size ใน docx-js คือ **half-points** ไม่ใช่ points

| ต้องการ | ใส่ใน code | ❌ ห้ามใส่ |
|---|---|---|
| 9pt (code) | `size: 18` | `size: 9` |
| 11pt (body) | `size: 22` | `size: 44` |
| 15pt (H1) | `size: 30` | `size: 60` |
| 12pt (H2) | `size: 24` | `size: 48` |
| 11pt (H3) | `size: 22` | `size: 44` |
| 28pt (title) | `size: 56` | `size: 112` |

ถ้าใส่ผิด: ตัวอักษรใหญ่ 2 เท่า, title ตัดกลางคำ, เอกสารดูผิดปกติทันที

### 2. HeadingLevel — ต้องใส่ทุก h1/h2/h3

```js
// ❌ ผิด — ไม่มี heading property
new Paragraph({ children: [new TextRun({ text, ...C.h1 })] })

// ✅ ถูก — ต้องมี heading: HeadingLevel.HEADING_N
new Paragraph({
  heading: HeadingLevel.HEADING_1,
  children: [new TextRun({ text, ...C.h1 })]
})
```

ถ้าไม่มี: Google Docs แสดง heading เป็น "Normal text" และ outline ว่างเปล่า

### 3. paragraphStyles override — ต้องมีใน Document ทุกฉบับ

ถ้าไม่มี: Google Docs reset สี font ของ heading เป็น default โดยอัตโนมัติ
ดูตัวอย่างโค้ดในส่วน **Document styles override** ด้านบน

### 4. โครงสร้างเอกสาร — ต้องมีครบทุกส่วน

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