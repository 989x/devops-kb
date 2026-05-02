# OPNsense — Expand Disk After Resizing in Proxmox

## ปัญหา

```
$ df -h
Filesystem         Size   Used   Avail  Capacity  Mounted on
/dev/gpt/rootfs    40G    37G    -308M  101%      /
```

`/dev/gpt/rootfs` ขนาด 40G เท่าเดิม แม้เพิ่ม disk เป็น 100GB ใน Proxmox แล้ว  
ต้องขยาย partition + filesystem ภายใน OPNsense เองด้วยตนเอง

---

## ขยาย Disk ใน OPNsense (FreeBSD)

### วิธีพื้นฐาน (ถ้าไม่มี swap ขวาง)

```sh
gpart show
gpart resize -i 2 ada0
growfs /
df -h
# ควรเห็น ~100G
```

---

## DEBUG — da0 GPT \[CORRUPT\]

```
gpart: No such geom: ada0
```

### ตรวจสอบ disk

```sh
gpart show da0
```

ผลที่ได้:

```
1   efi
2   freebsd-boot
3   freebsd-ufs   (42G)
4   freebsd-swap  (8G)
```

ตอนนี้ disk 100G แต่ partition 3 ยัง 42G

### ลองขยาย

```sh
gpart resize -i 3 da0
growfs /
df -h
# ควรเห็น ~90G+
```

---

## DEBUG — `gpart: table 'da0' is corrupt: Operation not permitted`

**สาเหตุ:** GPT backup table ยังอยู่ตำแหน่งเดิม (ตอน 40GB)  
หลังจากขยาย disk เป็น 100GB เลยทำให้ GPT มองว่า "corrupt"

### แก้ไข

```sh
gpart recover da0
gpart show da0
gpart resize -i 3 da0
growfs /
df -h
```

---

## DEBUG — swap partition (#4) ขวาง UFS (#3)

```
3   freebsd-ufs   42G
4   freebsd-swap   8G
```

UFS ไม่ได้อยู่ท้าย disk → resize ไม่ได้

---

## วิธีแก้: ย้าย Swap ไปท้าย Disk

### 1. ลบ swap ออกก่อน

```sh
swapoff -a
gpart delete -i 4 da0
gpart show da0
# ตอนนี้ควรเหลือแค่ partition 1, 2, 3
```

### 2. ขยาย UFS ให้เต็ม disk

```sh
gpart resize -i 3 da0
growfs /
```

### 3. สร้าง swap ใหม่ท้าย disk

```sh
gpart add -t freebsd-swap -l swapfs da0
swapon /dev/gpt/swapfs
```

### 4. ตรวจสอบ

```sh
df -h
swapinfo -h
```