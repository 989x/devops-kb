# PNG to WEBP Converter

## Pillow (PIL Fork)

Pillow คือไลบรารีประมวลผลภาพของภาษา Python (fork ที่พัฒนาต่อจาก PIL - Python
Imaging Library ตัวเดิมที่เลิกดูแลไปแล้ว) รองรับการเปิด/แปลง/บันทึกไฟล์ภาพ
หลายสิบฟอร์แมต รวมถึง PNG, JPEG, WEBP, GIF, BMP, TIFF เป็นต้น

- เว็บไซต์โปรเจกต์: https://python-pillow.org
- Repository: https://github.com/python-pillow/Pillow
- ติดตั้งผ่าน pip: `pip install Pillow`
- Import ในโค้ด: `from PIL import Image`

## Conversion Code

```python
from PIL import Image

im = Image.open('source.png')
im.save('output.webp', 'WEBP', lossless=True, quality=100, method=6)
```

### Line by Line

| บรรทัด | หน้าที่ |
|---|---|
| `Image.open(...)` | เปิดไฟล์ภาพต้นฉบับ (PNG) เข้าสู่ object ของ Pillow |
| `lossless=True` | คีย์หลักที่ทำให้ไม่เสียคุณภาพ ถ้าไม่ใส่ Pillow จะ fallback เป็น lossy webp ทันทีแม้ตั้ง quality สูงสุด |
| `quality=100` | ในโหมด lossless ค่านี้คุมความหนักของการบีบอัด (compression effort) ไม่ใช่คุณภาพภาพ |
| `method=6` | 0-6, ยิ่งสูงยิ่งบีบอัดได้ดีขึ้นแต่ใช้เวลานานขึ้น (6 = บีบอัดดีที่สุด) |

## Why lossless=True Instead of quality=85

รอบแรกที่แปลงไฟล์ใช้ `im.convert('RGB').save(..., quality=85)` ซึ่งเป็นโหมด
lossy — แม้ตั้ง quality สูงแค่ไหนก็ยังบีบอัดผ่าน DCT (คล้าย JPEG) อยู่ดี
ทำให้ตัวหนังสือในภาพสกรีนช็อต terminal เบลอ อ่านยาก โดยเฉพาะตัวอักษร
ขนาดเล็กที่มีขอบคม

แก้ด้วยการเปลี่ยนไปใช้ `lossless=True` แทน ซึ่งบีบอัดแบบไม่สูญเสียข้อมูล
เลย (คล้าย PNG แต่ไฟล์เล็กกว่า) ตรวจสอบด้วย pixel diff แล้วพบว่าเหมือน
ต้นฉบับทุกพิกเซล (diff = 0)

ส่วน `.convert('RGB')` ที่เคยใช้ก็ตัดออกได้ เพราะ WEBP lossless รองรับทั้ง
RGB และ RGBA อยู่แล้ว ไม่จำเป็นต้องแปลงโหมดสีก่อน

## Why WEBP

- ขนาดไฟล์เล็กกว่า PNG ในคุณภาพเท่ากัน (บีบอัดได้ดีกว่า โดยเฉพาะภาพ
  สกรีนช็อตที่มีสีเรียบและตัวอักษรมาก)
- รองรับทั้ง lossy และ lossless — งานนี้ใช้ lossless เพราะต้นฉบับเป็น
  สกรีนช็อตที่มีตัวหนังสือ ต้องคมชัด 100%
- ใช้แทนที่ PNG ในเอกสาร Markdown ได้ตรงๆ เพราะ browser และตัวแสดงผล
  Markdown สมัยใหม่รองรับ WEBP อยู่แล้ว

## Runtime Environment

คำสั่งด้านบนถูกรันผ่าน `bash_tool` บนเครื่อง Linux (Ubuntu 24) ที่ Claude
มีสิทธิ์เข้าถึงในระหว่างการสนทนานี้ ไม่ใช่ third-party API หรือบริการ
แปลงไฟล์ออนไลน์ใดๆ