---
title: INET Monitoring (Prometheus)
tags: [cloud, inet, prometheus, monitoring, infra]
type: guide
status: stable
created: 2026-04-25
related:
  - "[[server_deploy]]"
---

# INET Monitoring (Prometheus)

คู่มือ Deploy และจัดการ Prometheus สำหรับ monitoring บน INET Server

## Prerequisites

- เชื่อมต่อ INET ผ่าน OpenVPN แล้ว
- Connect เข้า server ได้แล้ว → [[server_deploy]]
- **Path:** `/home/JongJong/monitor-se`

## Files & Layout

```
/home/JongJong/monitor-se
├─ docker-compose.yml
└─ prometheus/
   ├─ prometheus.yml
   └─ data/
      ├─ chunks_head/
      ├─ lock
      ├─ queries.active
      └─ wal/
```

---

## docker-compose.yml

```yaml
version: "3.7"
services:
  prometheus:
    image: prom/prometheus
    user: root
    ports:
      - 8012:9090
    restart: always
    volumes:
      - ./prometheus/data:/prometheus
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
      - "--web.console.libraries=/usr/share/prometheus/console_libraries"
      - "--web.console.templates=/usr/share/prometheus/consoles"
      - "--web.route-prefix=/prom"
      - "--web.enable-lifecycle"
      - "--storage.tsdb.retention.time=1m"
      - "--web.enable-admin-api"
```

> ⚠️ **`retention.time=1m`** — ค่านี้สั้นมาก (1 นาที) เหมาะแค่สำหรับ dev/test
> production ควรตั้งเป็น `15d` หรือมากกว่า ขึ้นอยู่กับ disk ที่มี

---

## Run / Restart

```bash
cd /home/JongJong/monitor-se
docker compose down
docker compose up -d
```

## Verify

```bash
docker compose ps
docker compose logs -f prometheus
```

เข้า UI ที่ `http://<SERVER_IP>:8012/prom`