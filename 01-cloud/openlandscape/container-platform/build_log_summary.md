# Build Log Summary

> รวบรวม build errors ที่เคยเจอบน OpenShift  
> อัปเดตล่าสุด: 2026-05-09

---

## blog-django-py — Build #1 | Python 3.5 (pip เก่า)

**Repo:** https://github.com/openshift-katacoda/blog-django-py  
**Log:** `blog-django-py-20260506-build1.log`  
**Commit:** `476de217`  
**Build date:** 2026-05-06 06:03 UTC  
**Base image:** `centos/python-35-centos7:latest`  
**สถานะ:** ❌ Failed

**Error:**
```
NameError: name 'platform_system' is not defined
You are using pip version 7.1.2, however version 26.1.1 is available.
error: build error: building at STEP "RUN /tmp/scripts/assemble": while running runtime: exit status 2
```

**สาเหตุ:** `centos/python-35-centos7` มาพร้อม pip 7.1.2 ซึ่งเก่ามาก ไม่รู้จัก environment marker `platform_system` ที่ใช้ใน metadata ของ `powershift-cli` ทำให้ install ล้มเหลว

**แนวทางแก้ไข:**
- เปลี่ยน base image เป็น Python 3.8+ เช่น `openshift/python:3.11`
- หรือเพิ่ม `pip install --upgrade pip` ก่อน install ใน `assemble` script

---

## blog-django-py — Build #2 | Python 3.11 (powershift image missing)

**Repo:** https://github.com/openshift-katacoda/blog-django-py  
**Log:** `blog-django-py-20260506-build2.log`  
**Commit:** `476de217`  
**Build date:** 2026-05-06 06:09 UTC  
**Base image:** `openshift/python` (Python 3.11)  
**สถานะ:** ❌ Failed

**Error:**
```
Usage: powershift [OPTIONS] COMMAND [ARGS]...
Try 'powershift --help' for help.

Error: No such command 'image'.
error: build error: building at STEP "RUN /tmp/scripts/assemble": while running runtime: exit status 2
```

**สาเหตุ:** `powershift-cli==1.3.1` ถูก install สำเร็จ แต่ subcommand `image` ไม่ถูกรวมอยู่ใน package ที่ติดตั้งมา แม้จะระบุ `powershift-cli[image]` ก็ตาม

**แนวทางแก้ไข:**
- ตรวจสอบ version ของ `powershift-cli` ที่มี subcommand `image` รวมอยู่จริง
- หรือแก้ `assemble` script ให้ไม่พึ่ง `powershift image`

---

## demo-commerce — Build #1 | OOM / container killed

**Repo:** https://github.com/989x/demo-commerce  
**Log:** `demo-commerce-20260507-build1.log`  
**Commit:** `62b97da4`  
**Build date:** 2026-05-07 02:59 UTC  
**Base image:** `node:20-alpine`  
**สถานะ:** ❌ Failed

**Error:**
```
container exited on killed
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": while running runtime: exit status 1
```

**สาเหตุ:** Container ถูก kill กะทันหันขณะติดตั้ง packages (ดาวน์โหลดได้ 72/76) สาเหตุหลักคือ OOM (Out of Memory) ประกอบกับ download speed ต่ำมาก (~17 KiB/s) ทำให้ใช้เวลานานเกิน limit นอกจากนี้ยังมี warning ว่า Shopify build args ขาดหายไปทั้งหมด (`SHOPIFY_REVALIDATION_SECRET`, `SHOPIFY_STOREFRONT_ACCESS_TOKEN`, `SHOPIFY_STORE_DOMAIN`)

**แนวทางแก้ไข:**
- เพิ่ม memory limit ให้ build pod
- เพิ่ม `node-linker=hoisted` ใน `.npmrc` เพื่อลด memory ที่ใช้ตอน install
- ระบุ Shopify build args ให้ครบ

---

## demo-commerce — Build #2 | missing /app/public

**Repo:** https://github.com/989x/demo-commerce  
**Log:** `demo-commerce-20260507-build2.log`  
**Commit:** `62b97da4`  
**Build date:** 2026-05-07 03:22 UTC  
**Base image:** `node:20-alpine`  
**สถานะ:** ❌ Failed

**Error:**
```
error: build error: building at STEP "COPY --from=builder /app/public ./public":
checking on sources under "...": copier: stat: "/app/public": no such file or directory
```

**สาเหตุ:** Build ผ่านทั้ง `pnpm install` และ `next build` สำเร็จ (การเพิ่ม `node-linker=hoisted` แก้ OOM ได้แล้ว) แต่ตอน copy ไฟล์จาก builder stage ไป runner stage พบว่าโฟลเดอร์ `/app/public` ไม่มีอยู่ใน repo

**แนวทางแก้ไข:**
```dockerfile
# วิธีที่ 1: สร้างโฟลเดอร์ก่อน build
RUN mkdir -p /app/public

# วิธีที่ 2: ใช้ wildcard ป้องกัน error เมื่อไม่มี folder
COPY --from=builder /app/public* ./public/
```

---

## vercel/commerce — Build #1 | npm ERESOLVE

**Repo:** https://github.com/vercel/commerce  
**Log:** `vercel-commerce-20260506-build1.log`  
**Commit:** `1df2cf6f`  
**Build date:** 2026-05-06 06:55 UTC  
**Base image:** `openshift/nodejs` (S2I builder)  
**สถานะ:** ❌ Failed

**Error:**
```
npm error code ERESOLVE
npm error ERESOLVE unable to resolve dependency tree
npm error Found: next@15.6.0-canary.60
npm error Could not resolve dependency:
npm error peer next@">=13.2.0" from geist@1.7.0
error: build error: building at STEP "RUN /usr/libexec/s2i/assemble": while running runtime: exit status 1
```

**สาเหตุ:** `geist@1.7.0` ระบุ peer dependency ว่าต้องการ `next>=13.2.0` แต่ npm ของ S2I builder ตีความว่า canary version (`15.6.0-canary.60`) ไม่ตรงกับ semver range ทำให้ resolve dependency ล้มเหลว

**แนวทางแก้ไข:**
- เพิ่ม `--legacy-peer-deps` ใน npm install
- หรือ upgrade `geist` เป็น version ที่รองรับ next canary
- หรือเปลี่ยนไปใช้ `pnpm` ซึ่งจัดการ peer deps ได้ยืดหยุ่นกว่า
- หรือเปลี่ยนจาก S2I builder มาใช้ custom Dockerfile

---

## vercel/commerce — Build #2 | npm ERESOLVE (ซ้ำ)

**Repo:** https://github.com/vercel/commerce  
**Log:** `vercel-commerce-20260506-build2.log`  
**Commit:** `1df2cf6f`  
**Build date:** 2026-05-06 07:01 UTC  
**Base image:** `openshift/nodejs` (S2I builder)  
**สถานะ:** ❌ Failed

_(แค่เปลี่ยน build name เป็น `commerce-2` ไม่ได้แก้ต้นตอ — error เดิมทุกประการ)_

**Error:**
```
npm error code ERESOLVE
npm error ERESOLVE unable to resolve dependency tree
npm error Found: next@15.6.0-canary.60
npm error Could not resolve dependency:
npm error peer next@">=13.2.0" from geist@1.7.0
error: build error: building at STEP "RUN /usr/libexec/s2i/assemble": while running runtime: exit status 1
```

**แนวทางแก้ไข:** เหมือน Build #1 — ต้องแก้ที่ Dockerfile หรือ dependency

---

## Pattern ที่พบ

- **Builder image เก่า** → toolchain ไม่รองรับ package สมัยใหม่ (blog-django-py #1, #2)
- **Memory limit ต่ำ** → container ถูก kill ระหว่าง install (demo-commerce #1)
- **Dockerfile ไม่ครอบคลุม edge case** → COPY folder ที่ไม่มีอยู่ใน repo (demo-commerce #2)
- **S2I + npm strict mode** → ไม่รองรับ canary version ใน peer deps (vercel/commerce #1, #2)

> **บทเรียน:** การใช้ custom Dockerfile แทน S2I builder ช่วยควบคุม environment ได้ดีกว่า และสามารถกำหนด memory, node version, และ package manager ได้อย่างชัดเจน