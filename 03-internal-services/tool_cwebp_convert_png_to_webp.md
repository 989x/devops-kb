# cwebp — Convert PNG to WebP

tags: #tool #image #cli

---

## Available Tools

| Tool | เจ้าของ | สถานะ |
|---|---|---|
| **cwebp** | Google | ✅ ใช้งานได้ (แนะนำ) |
| **Pillow** | Python OSS | ✅ สำรอง |
| **FFmpeg** | OSS Community | ✅ สำรอง |
| **ImageMagick** | OSS Community | ✅ สำรอง |

> ⚠️ cwebp เป็น official tool ของ Google หาก Google ยุติการพัฒนา ให้ใช้ Pillow หรือ FFmpeg แทน เพราะเป็น open-source ไม่มีผู้ควบคุมรายเดียว

---

## Method 1: cwebp (Google) — Recommended

### Installation

```bash
# Mac
brew install webp

# Linux (Ubuntu/Debian)
sudo apt install webp
```

### Convert Single File

```bash
cwebp -q 100 input.png -o output.webp
```

### Convert Entire Folder

```bash
for f in *.png; do cwebp -q 100 "$f" -o "${f%.png}.webp"; done
```

### Output to Separate Folder

```bash
mkdir webp_output
for f in *.png; do cwebp -q 100 "$f" -o "webp_output/${f%.png}.webp"; done
```

### Quality Options (-q)

| `-q` | ความหมาย |
|---|---|
| `-q 100` | คุณภาพสูงสุด (ไฟล์ใหญ่) |
| `-q 85` | แนะนำ — สมดุลดี |
| `-q 70` | ไฟล์เล็กลง คุณภาพพอใช้ |

---

## Method 2: Python Pillow — Fallback

```bash
pip install Pillow
```

```python
from PIL import Image
import os, glob

input_folder = "."
output_folder = "webp_output"
os.makedirs(output_folder, exist_ok=True)

for path in glob.glob(f"{input_folder}/*.png"):
    name = os.path.splitext(os.path.basename(path))[0]
    Image.open(path).save(f"{output_folder}/{name}.webp", "WEBP", quality=85)
```

---

## Method 3: FFmpeg — Fallback

```bash
# Installation
brew install ffmpeg        # Mac
sudo apt install ffmpeg    # Linux

# Convert Entire Folder
for f in *.png; do ffmpeg -i "$f" "${f%.png}.webp"; done
```

---

## Method 4: ImageMagick — Fallback

```bash
# Installation
brew install imagemagick        # Mac
sudo apt install imagemagick    # Linux

# Convert Entire Folder
mogrify -format webp -quality 85 *.png
```