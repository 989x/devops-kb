# YouTube Transcript Extractor

ดึง transcript จากวิดีโอ YouTube พร้อม timestamp บันทึกเป็น `transcript.txt`

รันบน Google Colab: https://colab.research.google.com/

## วิธีใช้

1. เปิด Colab → New notebook
2. วางโค้ดด้านล่างทั้งหมดลงเซลล์เดียว
3. แก้ `video_id` เป็นวิดีโอที่ต้องการ (เอามาจาก URL เช่น `youtube.com/watch?v=FqnSAa2KmBI` → `video_id = "FqnSAa2KmBI"`)
4. กด Run (▶ หรือ Shift+Enter)
5. รอจนเห็น `Done. Saved to transcript.txt`
6. ดาวน์โหลดไฟล์ — รันโค้ดนี้ต่อในเซลล์ใหม่:

```python
from google.colab import files
files.download("transcript.txt")
```

## Script

```python
!pip install -q youtube-transcript-api

from youtube_transcript_api import YouTubeTranscriptApi

video_id = "FqnSAa2KmBI"
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

ถ้าอยากให้ไฟล์เก็บถาวรไม่หายตอนปิด session ให้เมาต์ Google Drive ก่อนเขียนไฟล์:

```python
from google.colab import drive
drive.mount('/content/drive')
# แล้วเปลี่ยน path ตอน open() เป็น "/content/drive/MyDrive/transcript.txt"
```