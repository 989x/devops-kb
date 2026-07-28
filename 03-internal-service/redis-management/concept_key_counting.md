---
title: "Concept: Redis Key Counting by Type"
tags: [redis, pattern, data-types]
type: concept
status: stable
created: 2026-04-26
---

# Concept: Redis Key Counting by Type

Logic นับจำนวน items ใน Redis key โดยแยกตาม data type — reusable สำหรับ feature ที่ต้องแสดง size ของแต่ละ key

---

## ปัญหา

Redis มีหลาย data type และแต่ละ type นับ "จำนวน items" ด้วย command ที่ต่างกัน ไม่มี single command ที่บอกได้ว่า key นี้มีกี่ items

---

## Solution

ดู type ก่อน แล้วเรียก command ที่เหมาะสม:

```go
func GetAllKeysWithCounts() (map[string]int, error) {
    keys, _ := Rdb.Keys(ctx, "*").Result()
    keyCounts := make(map[string]int)

    for _, key := range keys {
        keyType, _ := Rdb.Type(ctx, key).Result()

        switch keyType {
        case "string":
            keyCounts[key] = 1             // string มีค่าเดียวเสมอ
        case "list":
            length, _ := Rdb.LLen(ctx, key).Result()
            keyCounts[key] = int(length)
        case "set":
            size, _ := Rdb.SCard(ctx, key).Result()
            keyCounts[key] = int(size)
        case "hash":
            size, _ := Rdb.HLen(ctx, key).Result()
            keyCounts[key] = int(size)
        case "zset":
            size, _ := Rdb.ZCard(ctx, key).Result()
            keyCounts[key] = int(size)
        default:
            keyCounts[key] = 0             // unknown type
        }
    }

    return keyCounts, nil
}
```

---

## Command Reference

| Type | Count Command | หมายเหตุ |
|------|--------------|----------|
| string | — | นับเป็น 1 เสมอ |
| list | `LLEN key` | นับจำนวน elements |
| set | `SCARD key` | นับจำนวน members |
| hash | `HLEN key` | นับจำนวน fields |
| zset | `ZCARD key` | นับจำนวน members |
| stream | `XLEN key` | ไม่ได้ implement ใน project นี้ |

---

## ข้อควรระวัง

**`KEYS *` ไม่เหมาะกับ Production** — command นี้ block Redis จนกว่าจะ scan ครบทุก key ถ้ามีหลักล้าน key จะทำให้ Redis หยุดตอบ request อื่น

แนะนำให้ใช้ `SCAN` แทน:

```go
var cursor uint64
var keys []string

for {
    var batch []string
    var err error
    batch, cursor, err = Rdb.Scan(ctx, cursor, "*", 100).Result()
    if err != nil {
        return nil, err
    }
    keys = append(keys, batch...)
    if cursor == 0 {
        break
    }
}
```

`SCAN` วน scan ทีละ batch ไม่ block server และ safe ใน production
