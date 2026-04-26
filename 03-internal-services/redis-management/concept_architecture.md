---
title: "Concept: Fiber + Redis Architecture"
tags: [redis, go-fiber, architecture, pattern]
type: concept
status: stable
created: 2026-04-26
---

# Concept: Fiber + Redis Architecture

Pattern การ wire Go Fiber กับ Redis client — สามารถนำไปใช้กับ project อื่นที่ต้องการ Redis layer ได้

---

## Overview

```
Browser → Fiber Routes → Handlers → Redis Client → Redis DB
```

แต่ละ layer แยก responsibility ชัดเจน:

- **Routes** (`main.go`) — ลงทะเบียน endpoint และชี้ไปที่ handler
- **Handlers** (`handlers/`) — รับ HTTP request, เรียก Redis, ส่ง response
- **Redis Client** (`redis/client.go`) — เชื่อมต่อและ wrap Redis commands

---

## Route Registration

```go
app := fiber.New()

app.Get("/", handlers.DashboardHandler)
app.Post("/add", handlers.AddCacheHandler)
app.Delete("/delete/:key", handlers.DeleteCacheHandler)
```

pattern นี้เหมาะกับ resource-based API — แต่ละ HTTP method มีความหมายชัด (GET = ดู, POST = เพิ่ม, DELETE = ลบ)

---

## Redis Client Initialization

```go
func InitRedisClient() {
    Rdb = redis.NewClient(&redis.Options{
        Addr:     os.Getenv("REDIS_ADDR"),
        Password: os.Getenv("REDIS_PASSWORD"),
        DB:       0,
    })

    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()

    if _, err := Rdb.Ping(ctx).Result(); err != nil {
        log.Fatalf("Failed to connect to Redis: %v", err)
    }
}
```

จุดสำคัญ:
- ใช้ `context.WithTimeout` ตอน ping — ถ้า Redis ไม่ตอบใน 2 วิ ให้ fail fast แทนที่จะ hang
- config ทั้งหมดมาจาก env ไม่มี hardcode
- ถ้า connect ไม่ได้ให้ `log.Fatalf` หยุด server เลย ไม่ให้ app รันโดยไม่มี Redis

---

## HTML Template Rendering Pattern

project นี้ใช้ Go `html/template` แทน frontend framework เพราะ UI เรียบง่ายและไม่ต้องการ interactivity ซับซ้อน

```go
// 1. Build HTML string จาก data
var keyListHTML string
for key, count := range keyCounts {
    keyListHTML += fmt.Sprintf(`<li>%s (Items: %d)</li>`, key, count)
}

// 2. Inject เข้า template ผ่าน template.HTML (bypass escaping)
data := struct {
    Keys template.HTML
}{
    Keys: template.HTML(keyListHTML),
}

// 3. Render และส่ง response
var buf bytes.Buffer
tmpl.Execute(&buf, data)
c.Type("html")
return c.SendString(buf.String())
```

ข้อควรระวัง: `template.HTML` bypass HTML escaping — ใช้ได้ถ้า input มาจาก Redis key ที่ควบคุมเองได้ แต่ถ้า user input ต้องใช้ `template.HTMLEscapeString` ก่อน

---

## Project Structure

```
redis-management-system/
├── cmd/
│   └── main.go                # entry point, routes
├── internal/
│   ├── handlers/
│   │   ├── dashboard.go       # GET /, POST /add
│   │   └── delete.go          # DELETE /delete/:key
│   ├── redis/
│   │   └── client.go          # Redis init + commands
│   └── templates/
│       └── dashboard.html     # Go template
```

---

## Docker Note

HTML template ต้อง copy เข้า Docker image แยกต่างหาก เพราะ Go compile เฉพาะ `.go` files — static files ไม่ได้ถูก embed อัตโนมัติ

```dockerfile
COPY --from=builder /app/internal/templates /app/internal/templates
```

ถ้าต้องการ embed ไฟล์เข้าไปใน binary เลยไม่ต้อง copy แยก ใช้ `//go:embed` แทน:

```go
//go:embed internal/templates/dashboard.html
var templateFS embed.FS
```
