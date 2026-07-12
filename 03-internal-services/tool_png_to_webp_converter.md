# โปรแกรมที่ใช้แปลง PNG เป็น WEBP

## Pillow (PIL Fork)

**Pillow** คือไลบรารีประมวลผลภาพของภาษา Python (เป็น fork ที่พัฒนาต่อจาก PIL - Python Imaging Library ตัวเดิมที่เลิกดูแลไปแล้ว) รองรับการเปิด/แปลง/บันทึกไฟล์ภาพหลายสิบฟอร์แมต รวมถึง PNG, JPEG, WEBP, GIF, BMP, TIFF เป็นต้น

- **เว็บไซต์โปรเจกต์:** https://python-pillow.org
- **Repository:** https://github.com/python-pillow/Pillow
- **ติดตั้งผ่าน pip:** `pip install Pillow`
- **Import ในโค้ด:** `from PIL import Image`

---

## โค้ดที่ใช้แปลงไฟล์

```python
from PIL import Image

im = Image.open('ภาพต้นฉบับ.png')
im.convert('RGB').save('ภาพปลายทาง.webp', 'webp', quality=85)
```

### อธิบายแต่ละบรรทัด

| บรรทัด | หน้าที่ |
|---|---|
| `Image.open(...)` | เปิดไฟล์ภาพต้นฉบับ (PNG) เข้าสู่ object ของ Pillow |
| `.convert('RGB')` | แปลงโหมดสีให้เป็น RGB ก่อนเซฟ เนื่องจาก PNG บางไฟล์อยู่ในโหมด RGBA (มี alpha channel) หรือ Palette ซึ่ง WEBP encoder ของ Pillow ต้องการโหมดสีที่รองรับก่อนจึงจะบันทึกได้ราบรื่น |
| `.save(..., 'webp', quality=85)` | บันทึกไฟล์ผลลัพธ์เป็นฟอร์แมต WEBP โดยกำหนดคุณภาพการบีบอัดที่ 85 (จาก 0-100) ซึ่งเป็นจุดสมดุลระหว่างขนาดไฟล์เล็กกับคุณภาพภาพที่ยังดูดี |

---

## ทำไมใช้ WEBP

- **ขนาดไฟล์เล็กกว่า PNG** ในคุณภาพที่ใกล้เคียงกัน (บีบอัดได้ดีกว่า โดยเฉพาะภาพสกรีนช็อตที่มีสีเรียบและตัวอักษรมาก)
- **รองรับทั้ง Lossy และ Lossless** — กรณีนี้ใช้แบบ lossy (`quality=85`) เพื่อลดขนาดไฟล์
- ใช้แทนที่ PNG ในเอกสาร Markdown ได้ตรงๆ เพราะ browser และตัวแสดงผล Markdown สมัยใหม่รองรับ WEBP อยู่แล้ว

## Environment ที่ใช้รันจริง

คำสั่งด้านบนถูกรันผ่าน `bash_tool` บนเครื่อง Linux (Ubuntu 24) ที่ Claude มีสิทธิ์เข้าถึงในระหว่างการสนทนานี้ — ไม่ใช่ third-party API หรือบริการแปลงไฟล์ออนไลน์ใดๆ