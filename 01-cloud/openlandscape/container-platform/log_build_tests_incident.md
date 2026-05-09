# Build Incident Log

---

## blog-django-py — Build #1

- Repo: https://github.com/openshift-katacoda/blog-django-py
- Commit: 476de217
- Date: 2026-05-06 06:03 UTC
- Base image: centos/python-35-centos7:latest
- Status: Failed

```log
STEP 8/11: RUN /tmp/scripts/assemble
Collecting powershift-cli[image]
  Downloading powershift-cli-1.3.1.tar.gz
Collecting click (from powershift-cli[image])
  Downloading click-8.3.3-py3-none-any.whl (110kB)
Exception:
Traceback (most recent call last):
  ...
  File "<environment marker>", line 1, in <module>
NameError: name 'platform_system' is not defined
You are using pip version 7.1.2, however version 26.1.1 is available.
error: build error: building at STEP "RUN /tmp/scripts/assemble": while running runtime: exit status 2
```

### What happened

Build แรก ยังไม่มีการปรับอะไร พอ assemble script เริ่ม install `powershift-cli[image]` pip 7.1.2 ไม่รู้จัก environment marker `platform_system` ใน metadata ทำให้ล้มเหลวก่อนที่จะ install อะไรได้เลย

### Guidelines

- เปลี่ยน base image เป็น Python 3.8+ เช่น `openshift/python:3.11`
- หรือเพิ่ม `pip install --upgrade pip` ก่อน install ใน `assemble` script

---

## blog-django-py — Build #2

- Repo: https://github.com/openshift-katacoda/blog-django-py
- Commit: 476de217
- Date: 2026-05-06 06:09 UTC
- Base image: openshift/python (Python 3.11)
- Status: Failed

```log
STEP 9/10: RUN /tmp/scripts/assemble
Collecting powershift-cli[image]
  Downloading powershift-cli-1.3.1.tar.gz (7.6 kB)
  Installing build dependencies: finished with status 'done'
  Preparing metadata (pyproject.toml): finished with status 'done'
Collecting powershift-image>=1.0.3 (from powershift-cli[image])
  Downloading powershift-image-1.4.2.tar.gz (11 kB)
Building wheels for collected packages: powershift-image, powershift-cli
  Building wheel for powershift-image (pyproject.toml): finished with status 'done'
  Building wheel for powershift-cli (pyproject.toml): finished with status 'done'
Successfully installed click-8.3.3 powershift-cli-1.3.1 powershift-image-1.4.2

Usage: powershift [OPTIONS] COMMAND [ARGS]...
Try 'powershift --help' for help.

Error: No such command 'image'.
error: build error: building at STEP "RUN /tmp/scripts/assemble": while running runtime: exit status 2
```

### What happened

เปลี่ยน base image เป็น Python 3.11 โดยไม่แก้ `assemble` script — install ทุกอย่างสำเร็จ ทั้ง `powershift-cli 1.3.1`, `powershift-image 1.4.2`, และ `click 8.3.3` แต่พอ script เรียก `powershift image` ตอน runtime กลับได้ error เพราะ subcommand `image` ไม่ได้รวมอยู่ใน package จริงๆ แม้จะระบุ `[image]` extra ไว้แล้ว

### Guidelines

- ตรวจสอบว่า version ไหนของ `powershift-cli` ที่มี subcommand `image` รวมอยู่จริง
- หรือแก้ `assemble` script ให้ไม่พึ่ง `powershift image`

---

## demo-commerce — Build #1

- Repo: https://github.com/989x/demo-commerce
- Commit: 62b97da4
- Date: 2026-05-07 02:59 UTC
- Base image: node:20-alpine
- Status: Failed

```log
time="2026-05-07T02:59:55Z" level=warning msg="missing \"SHOPIFY_REVALIDATION_SECRET\" build argument."
time="2026-05-07T02:59:55Z" level=warning msg="missing \"SHOPIFY_STOREFRONT_ACCESS_TOKEN\" build argument."
time="2026-05-07T02:59:55Z" level=warning msg="missing \"SHOPIFY_STORE_DOMAIN\" build argument."

[1/2] STEP 3/16: RUN npm install -g pnpm
added 1 package in 7s

[1/2] STEP 5/16: RUN pnpm install --frozen-lockfile
Lockfile is up to date, resolution step is skipped
Progress: resolved 76, reused 0, downloaded 0, added 0
...
 WARN  Tarball download average speed 17 KiB/s (size 4150 KiB) is below 50 KiB/s: https://registry.npmjs.org/typescript/-/typescript-5.8.2.tgz
Progress: resolved 76, reused 0, downloaded 72, added 53
Progress: resolved 76, reused 0, downloaded 73, added 72
container exited on killed
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": while running runtime: exit status 1
```

### What happened

Build แรก ใช้ Dockerfile ที่แก้ล่าสุด (pnpm, HOSTNAME=0.0.0.0, secrets เป็น build args) — มี warning ว่าขาด Shopify build args ทั้ง 3 ตัว จากนั้น `pnpm install` เริ่มโหลดได้ถึง 72/76 packages แต่ network ช้ามาก (~17 KiB/s) ทำให้ container ถูก kill กะทันหันเพราะ OOM

### Guidelines

- เพิ่ม `node-linker=hoisted` ใน `.npmrc` เพื่อลด memory ที่ใช้ตอน install
- เพิ่ม memory limit ให้ build pod
- ระบุ Shopify build args ให้ครบ

---

## demo-commerce — Build #2

- Repo: https://github.com/989x/demo-commerce
- Commit: 62b97da4
- Date: 2026-05-07 03:22 UTC
- Base image: node:20-alpine
- Status: Failed

```log
[1/2] STEP 4/17: RUN echo "node-linker=hoisted" >> .npmrc

[1/2] STEP 6/17: RUN pnpm install --frozen-lockfile
Progress: resolved 0, reused 0, downloaded 76, added 76, done
╭ Warning ──────────────────────────────────────────────────────╮
│  Ignored build scripts: sharp@0.34.5.                         │
╰───────────────────────────────────────────────────────────────╯
Done in 40.3s using pnpm v10.33.4

[1/2] STEP 17/17: RUN NODE_OPTIONS="--max-old-space-size=1536" pnpm build
 ✓ Compiled successfully in 36.7s
 ✓ Generating static pages (11/11) in 3.7s

[2/2] STEP 6/14: COPY --from=builder /app/public ./public
error: build error: building at STEP "COPY --from=builder /app/public ./public":
copier: stat: "/app/public": no such file or directory
```

### What happened

เพิ่ม `node-linker=hoisted` ใน `.npmrc` — `pnpm install` ผ่านครบ 76/76 packages ใน 40.3s และ `next build` compile สำเร็จใน 36.7s แต่พอขึ้น runner stage สะดุดทันทีที่ `COPY --from=builder /app/public ./public` เพราะ repo ไม่มีโฟลเดอร์ `public/` อยู่จริง

### Guidelines

```dockerfile
# วิธีที่ 1: สร้างโฟลเดอร์ก่อน build
RUN mkdir -p /app/public

# วิธีที่ 2: ใช้ wildcard ป้องกัน error เมื่อไม่มี folder
COPY --from=builder /app/public* ./public/
```

---

## vercel/commerce — Build #1

- Repo: https://github.com/vercel/commerce
- Commit: 1df2cf6f
- Date: 2026-05-06 06:55 UTC
- Base image: openshift/nodejs (S2I builder)
- Status: Failed

```log
STEP 8/9: RUN /usr/libexec/s2i/assemble
---> Installing application source ...
---> Installing all dependencies
npm error code ERESOLVE
npm error ERESOLVE unable to resolve dependency tree
npm error
npm error While resolving: undefined@undefined
npm error Found: next@15.6.0-canary.60
npm error Could not resolve dependency:
npm error peer next@">=13.2.0" from geist@1.7.0
npm error
npm error Fix the upstream dependency conflict, or retry
npm error this command with --force or --legacy-peer-deps
error: build error: building at STEP "RUN /usr/libexec/s2i/assemble": while running runtime: exit status 1
```

### What happened

Build แรก ใช้ S2I builder ตรงๆ — npm strict semver ตีความว่า `next@15.6.0-canary.60` ไม่ตรงกับ range `>=13.2.0` ที่ `geist@1.7.0` กำหนด ทำให้ resolve dependency tree ล้มเหลวทันทีโดยไม่ได้โหลด package ใดเลย

### Guidelines

- เพิ่ม `--legacy-peer-deps` ใน npm install
- หรือ upgrade `geist` เป็น version ที่รองรับ next canary
- หรือเปลี่ยนมาใช้ `pnpm` ซึ่งจัดการ peer deps ได้ยืดหยุ่นกว่า
- หรือเปลี่ยนจาก S2I builder มาใช้ custom Dockerfile

---

## vercel/commerce — Build #2

- Repo: https://github.com/vercel/commerce
- Commit: 1df2cf6f
- Date: 2026-05-06 07:01 UTC
- Base image: openshift/nodejs (S2I builder)
- Status: Failed

```log
STEP 8/9: RUN /usr/libexec/s2i/assemble
---> Installing application source ...
---> Installing all dependencies
npm error code ERESOLVE
npm error ERESOLVE unable to resolve dependency tree
npm error
npm error While resolving: undefined@undefined
npm error Found: next@15.6.0-canary.60
npm error Could not resolve dependency:
npm error peer next@">=13.2.0" from geist@1.7.0
npm error
npm error Fix the upstream dependency conflict, or retry
npm error this command with --force or --legacy-peer-deps
error: build error: building at STEP "RUN /usr/libexec/s2i/assemble": while running runtime: exit status 1
```

### What happened

เปลี่ยนแค่ชื่อ build เป็น `commerce-2` ไม่ได้แก้อะไร — error เดิมทุกประการกับ Build #1

### Guidelines

ดู Build #1 — ต้องแก้ที่ Dockerfile หรือ dependency จึงจะผ่านได้