# YouTube Transcript Extractor

ดึง transcript จากวิดีโอ YouTube พร้อม timestamp เป็นไฟล์ `transcript.txt`

## Setup (one-time)

เปิด Terminal แล้ว `cd` ไปที่โฟลเดอร์ที่จะเก็บสคริปต์ (ลากโฟลเดอร์จาก Finder มาวางบน Terminal เพื่อเอา path จริง) เช่น:

```bash
cd ~/Desktop/demo/youtube
```

จากนั้นรัน:

```bash
python3 -m venv yt-env
source yt-env/bin/activate
pip install youtube-transcript-api
```

## Script

สร้างไฟล์ `extract_transcript.py` ในโฟลเดอร์เดียวกัน ใส่โค้ดนี้:

```python
from youtube_transcript_api import YouTubeTranscriptApi

video_id = "FqnSAa2KmBI"   # แก้เป็น video id ที่ต้องการ
chunk_seconds = 60

api = YouTubeTranscriptApi()
transcript_list = api.list(video_id)

try:
    transcript_obj = transcript_list.find_transcript(["th", "en"])
except Exception:
    transcript_obj = next(iter(transcript_list))

transcript = transcript_obj.fetch()

output_file = f"transcript_{video_id}.txt"

chunks = {}
for entry in transcript:
    bucket = int(entry.start // chunk_seconds) * chunk_seconds
    chunks.setdefault(bucket, []).append(entry.text)

with open(output_file, "w", encoding="utf-8") as f:
    for bucket in sorted(chunks.keys()):
        minutes, seconds = divmod(bucket, 60)
        text = " ".join(chunks[bucket])
        f.write(f"[{minutes:02d}:{seconds:02d}] {text}\n\n")

print(f"Done. Saved to {output_file} (language: {transcript_obj.language})")
```

video_id เอามาจาก URL เช่น `youtube.com/watch?v=FqnSAa2KmBI` → `FqnSAa2KmBI`

## Run

```bash
cd ~/Desktop/demo/youtube
source yt-env/bin/activate
python3 extract_transcript.py
```

ไฟล์ transcript_(video_id).txt จะอยู่ในโฟลเดอร์เดียวกัน เปิดดูได้เลย

---

ครั้งต่อไปแค่รัน 3 บรรทัดในหัวข้อ "Run" ไม่ต้องติดตั้งใหม่