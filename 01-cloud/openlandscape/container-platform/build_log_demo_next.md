# Build Log — demo-next

**Repo:** https://github.com/989x/demo-next.git  
**Platform:** OKD / OpenShift (Buildah)  
**Stack:** Next.js 16 · React 19 · pnpm · node:alpine

---

## Root Cause

**`pnpm-workspace.yaml` ที่มีอยู่ใน repo คือต้นเหตุของทุก build failure**

แค่การมีอยู่ของไฟล์นี้ทำให้ pnpm ตีความ repo เป็น monorepo workspace ทันที
ส่งผลให้ทุก pnpm command ต้องการ `packages` field ซึ่งไม่มีอยู่ใน repo นี้

```
pnpm-workspace.yaml มีอยู่
  → pnpm ถือว่าเป็น monorepo workspace
    → ทุก command ต้องการ packages field
      → error "packages field missing or empty"
```

build #1–#4 แก้ผิดจุดที่ Dockerfile และ package.json ซึ่งเป็แค่ symptom
build #5 แก้ถูก root cause โดยลบ `pnpm-workspace.yaml` ออก

---

## Timeline

### Build #1 — 2026-05-08 03:24 UTC
**Commit:** `1eb0ee1` — Update README.md  
**Config:** `node:20-alpine` + `pnpm@latest`

**Error:**
```
warn: This version of pnpm requires at least Node.js v22.13
warn: The current version of Node.js is v20.20.2

Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:sqlite
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": exit status 1
```

**Cause:** `corepack prepare pnpm@latest` ดึง pnpm@11.0.8 มา แต่ pnpm 11 ต้องการ Node.js >= 22.13  
**Fix:** เปลี่ยน `node:20-alpine` → `node:22-alpine` ทั้ง 3 stage

---

### Build #2 — 2026-05-08 03:33 UTC
**Commit:** `de8f8b1` — fix: upgrade node 20 to 22 for pnpm compatibility  
**Config:** `node:22-alpine` + `pnpm@latest`  
_(ลองซ้ำ 3 ครั้ง — 03:33, 03:38, 03:50 UTC — error เดิมทุกครั้ง)_

**Error:**
```
[ERR_PNPM_IGNORED_BUILDS] Ignored build scripts: sharp@0.34.5, unrs-resolver@1.11.1

Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": exit status 1
```

**Cause:** pnpm 11 เพิ่ม security policy บังคับ approve build scripts ก่อน install  
**Fix:** downgrade เป็น `pnpm@9` ซึ่งไม่มี rule นี้ (แก้ผิดจุด — ยังไม่ใช่ root cause)

---

### Build #3 — 2026-05-08 06:22 UTC
**Commit:** `???` — fix: pin pnpm@9 instead of latest  
**Config:** `node:22-alpine` + `pnpm@9` + `RUN pnpm build`

**Error:**
```
[2/3] STEP 7/7: RUN pnpm build
 ERROR  packages field missing or empty
error: build error: building at STEP "RUN pnpm build": exit status 1
```

**Cause:** `pnpm-workspace.yaml` ทำให้ pnpm ถือว่าเป็น workspace → ต้องการ `packages` field  
**Fix attempt:** เปลี่ยนเป็น `pnpm run build` (แก้ผิดจุด — ยังไม่ใช่ root cause)

---

### Build #4 — 2026-05-08 06:31 UTC
**Commit:** `93d8ecb` — fix: use pnpm run build instead of pnpm build  
**Config:** `node:22-alpine` + `pnpm@9` + `RUN pnpm run build`

**Error:**
```
[2/3] STEP 7/7: RUN pnpm run build
 ERROR  packages field missing or empty
error: build error: building at STEP "RUN pnpm run build": exit status 1
```

**Cause:** เหมือน build #3 ทุกประการ — `pnpm-workspace.yaml` ยังอยู่  
**Fix attempt:** เปลี่ยนเป็น `RUN ./node_modules/.bin/next build` (แก้ผิดจุด)

---

### Build #5 — 2026-05-08 (หลังลบ pnpm-workspace.yaml) ✅
**Commit:** `???` — fix: move ignoredBuiltDependencies to package.json, remove pnpm-workspace.yaml  
**Config:** `node:22-alpine` + `pnpm@9` + ไม่มี `pnpm-workspace.yaml`

**Result:**
```
Done in 45.8s using pnpm v9.15.9
[2/3] STEP 7/7: RUN pnpm run build
[3/3] Successfully pushed image to ImageStream
```

**Status:** Build สำเร็จ ✅

---

## Lessons Learned

**เมื่อเจอ "packages field missing or empty" ให้ตรวจสิ่งนี้ก่อนเสมอ:**

```bash
ls pnpm-workspace.yaml
```

ถ้ามีไฟล์นี้อยู่แต่ไม่ได้ใช้ monorepo จริง → ลบออกทันที อย่าแก้ Dockerfile หรือ package.json

**`pnpm-workspace.yaml` ใช้สำหรับ monorepo เท่านั้น**  
ต้องมี `packages` field จึงจะทำงานได้ถูกต้อง:

```yaml
# ถูก — monorepo
packages:
  - "packages/*"
  - "apps/*"
```

```yaml
# ผิด — ไม่มี packages field แต่ไฟล์ยังอยู่
ignoredBuiltDependencies:
  - sharp
  - unrs-resolver
```

Config สำหรับ ignored build scripts ต้องอยู่ใน `package.json`:

```json
"pnpm": {
  "ignoredBuiltDependencies": ["sharp", "unrs-resolver"]
}
```

**References:**  
- [pnpm Workspaces](https://pnpm.io/workspaces)  
- [pnpm-workspace.yaml](https://pnpm.io/pnpm-workspace_yaml)  
- [Issue #8968 — packages field missing](https://github.com/pnpm/pnpm/issues/8968)