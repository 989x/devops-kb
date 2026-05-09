# Build Incident Log

```
วิธีใช้ไฟล์นี้
1. copy block "## Project — Build #N" ด้านล่างมาเพิ่มต่อท้ายไฟล์
2. วาง log จริงลงใน code block
3. ตัด log ตามหลักการด้านล่าง แล้วเขียน What happened และ Guidelines

หลักการย่อ log
- ตัดออก: Copying blob sha256, Writing manifest, Adding transient rw bind mount
- ตัดออก: Progress bar ทุกบรรทัด เก็บแค่บรรทัดที่ผิดปกติ เช่น WARN speed ต่ำ
- ตัดออก: STEP ที่ผ่านปกติโดยไม่มีอะไรน่าสังเกต
- เก็บไว้: warning ทุกอัน, STEP สุดท้ายก่อน error, error message ทั้งหมด
```

---

## [Project] — Build #[N]

- Repo: [url]
- Commit: [short hash]
- Date: [YYYY-MM-DD HH:MM UTC]
- Base image: [image:tag]
- Status: Failed

```log
[วาง log ที่ย่อแล้วตรงนี้]
```

### What happened

[อธิบาย context ที่ log บอกไม่ได้ เช่น เปลี่ยนอะไรจาก build ก่อน, ผ่านถึงไหน, สาเหตุที่แท้จริง]

### Guidelines

- [แนวทางแก้ไข]