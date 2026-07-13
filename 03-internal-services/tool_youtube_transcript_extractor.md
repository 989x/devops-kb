# YouTube Transcript Extractor

ดึงข้อความ transcript พร้อม timestamp จากวิดีโอ YouTube โดยไม่ต้อง scrape HTML ใช้ package `youtube-transcript-api`

## Table of Contents

- [Check Python](#check-python)
- [Installation](#installation)
- [Script](#script)
- [Usage](#usage)
- [Notes (ปัญหาที่เคยเจอ + วิธีแก้)](#notes-ปัญหาที่เคยเจอ--วิธีแก้)

## Check Python

```bash
python3 --version
```

## Installation

```bash
pip3 install youtube-transcript-api
```

## Script

รวม caption เป็นก้อนละ 60 วินาที (ค่า raw ที่ได้จาก YouTube จะถูกตัดทุก 2-5 วินาทีตามจังหวะพูด อ่านยาก) และเขียนผลลงไฟล์ `transcript.txt` แทนการ print ใน terminal

```python
from youtube_transcript_api import YouTubeTranscriptApi

video_id = "FqnSAa2KmBI"  # เอามาจากส่วน ?v= ใน URL
chunk_seconds = 60

api = YouTubeTranscriptApi()
transcript = api.fetch(video_id)

chunks = {}
for entry in transcript:
    bucket = int(entry.start // chunk_seconds) * chunk_seconds
    chunks.setdefault(bucket, []).append(entry.text)

with open("transcript.txt", "w", encoding="utf-8") as f:
    for bucket in sorted(chunks.keys()):
        minutes = bucket // 60
        seconds = bucket % 60
        text = " ".join(chunks[bucket])
        f.write(f"[{minutes:02d}:{seconds:02d}] {text}\n\n")

print("Done. Saved to transcript.txt")
```

## Usage

```bash
python3 transcript_fetch.py
```

## Notes (ปัญหาที่เคยเจอ + วิธีแก้)

**1. `zsh: command not found: pip`**
เครื่องไม่มี alias `pip` ให้ใช้ `pip3` แทน

**2. Output ดิบจาก YouTube กระจัดกระจายเกินไป (ตัดทุก 2-5 วินาที)**
เกิดจาก auto-generated caption ตัดตามจังหวะพูด ไม่ใช่ตามประโยค แก้ด้วยการรวมเป็นก้อนตาม `chunk_seconds` (สคริปต์ด้านบน)

**3. แก้สคริปต์แล้ว output ไม่เปลี่ยน**
มักเกิดจากไฟล์ยังไม่ save จริง หรือเปิดดู `transcript.txt` เวอร์ชันเก่าค้างอยู่ ให้เช็คด้วย:
```bash
cat transcript_fetch.py        # ยืนยันว่าไฟล์มีโค้ดที่แก้จริง
cat transcript.txt | head -20  # ยืนยันว่าไฟล์ output ถูกเขียนใหม่จริง
```
