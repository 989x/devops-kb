# Build Log — demo-next

**Repo:** https://github.com/989x/demo-next.git  
**Platform:** OpenShift / Buildah

## Overview

1. ใช้ `node:20-alpine` + `pnpm@latest` → pnpm@11 ต้องการ Node.js v22+
2. อัปเป็น `node:22-alpine` + `pnpm@latest` → pnpm@11 บล็อก build scripts
3. downgrade เป็น `pnpm@9` → install ผ่าน แต่ `pnpm build` fail
4. เปลี่ยนเป็น `pnpm run build` → ยัง fail เหมือนเดิม
5. แก้ Dockerfile → build ผ่าน ✅

## 2026-05-08 03:24:00 UTC | node:20-alpine + pnpm@latest

**Commit:** `1eb0ee1` — Update README.md

**Error:**
```
warn: This version of pnpm requires at least Node.js v22.13
warn: The current version of Node.js is v20.20.2

Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:sqlite

error: build error: building at STEP "RUN pnpm install --frozen-lockfile": while running runtime: exit status 1
```

**Full Log:**
```bash
[1/3] STEP 5/5: RUN pnpm install --frozen-lockfile
warn: This version of pnpm requires at least Node.js v22.13
warn: The current version of Node.js is v20.20.2
warn: Visit https://r.pnpm.io/comp to see the list of past pnpm versions with respective Node.js version support.
node:internal/modules/cjs/loader:1031
      throw new ERR_UNKNOWN_BUILTIN_MODULE(request);
            ^

Error [ERR_UNKNOWN_BUILTIN_MODULE]: No such built-in module: node:sqlite
    at Module._load (node:internal/modules/cjs/loader:1031:13)
    at Module.require (node:internal/modules/cjs/loader:1289:19)
    at require (node:internal/modules/helpers:182:18)
    at ../store/index/lib/index.js (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:16044:25)
    at __init (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:15:56)
    at ../resolving/npm-resolver/lib/index.js (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:26743:5)
    at __init (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:15:56)
    at ../workspace/projects-graph/lib/index.js (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:26889:5)
    at __init (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:15:56)
    at ../workspace/projects-filter/lib/index.js (file:///root/.cache/node/corepack/v1/pnpm/11.0.8/dist/pnpm.mjs:42792:5) {
  code: 'ERR_UNKNOWN_BUILTIN_MODULE'
}

Node.js v20.20.2
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": while running runtime: exit status 1
```

## 2026-05-08 03:33:18 UTC | node:22-alpine + pnpm@latest

**Commit:** `de8f8b1` — fix: upgrade node 20 to 22 for pnpm compatibility  
**Commit:** `f6d6653` — fix: allow pnpm build scripts for sharp and unrs-resolver  
_(3 attempts — 03:33:18, 03:38:35, 03:50:08 UTC — error เดิมทุกครั้ง)_

**Error:**
```
[ERR_PNPM_IGNORED_BUILDS] Ignored build scripts: sharp@0.34.5, unrs-resolver@1.11.1

Run "pnpm approve-builds" to pick which dependencies should be allowed to run scripts.
error: build error: building at STEP "RUN pnpm install --frozen-lockfile": while running runtime: exit status 1
```

## 2026-05-08 06:22:04 UTC | node:22-alpine + pnpm@9 — `pnpm build`

_(ไม่มี clone section ใน log)_

**Error:**
```
[2/3] STEP 7/7: RUN pnpm build
 ERROR  packages field missing or empty
For help, run: pnpm help run
error: build error: building at STEP "RUN pnpm build": while running runtime: exit status 1
```

## 2026-05-08 06:31:14 UTC | node:22-alpine + pnpm@9 — `pnpm run build`

**Commit:** `93d8ecb` — fix: use pnpm run build instead of pnpm build

**Error:**
```
[2/3] STEP 7/7: RUN pnpm run build
 ERROR  packages field missing or empty
For help, run: pnpm help run
error: build error: building at STEP "RUN pnpm run build": while running runtime: exit status 1
```
