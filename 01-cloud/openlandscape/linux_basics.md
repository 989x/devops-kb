---
title: Linux Command Basics
tags: [linux, openlandscape, basics]
type: guide
status: stable
created: 2026-04-26
---

# Linux Command Basics

## Core Commands

```bash
pwd       # show current path
ls        # list files and folders
ls -l     # detailed list
ls -a     # show hidden files
cd NAME   # change directory
cd ..     # go up one level
clear     # clear the terminal screen
man ls    # open manual for 'ls'
ls --help # quick help for 'ls'
```

## Create a Folder

```bash
# Single folder
mkdir myfolder

# Nested folders in one command
mkdir -p projects/2025/demo
```

## Display Current Path

```bash
pwd
# Example output:
# /home/username/projects
```

## Write Text to a File

```bash
# Overwrite
echo "First line" > notes.txt

# Append
echo "Another line" >> notes.txt

# Type many lines (Ctrl+D to save and exit)
cat > notes.txt
```

## Edit a File

```bash
nano notes.txt
# Ctrl+O  save
# Enter   confirm filename
# Ctrl+X  exit
```

> ถ้าไม่มี `nano` ให้ใช้ `vim` แทน

## Copy a File

```bash
# Copy to new filename
cp source.txt backup.txt

# Copy into folder
cp notes.txt backup/notes.txt

# Copy folder and all contents
cp -r myfolder myfolder-backup
```

## Move a File

```bash
# Move into folder
mv notes.txt backup/

# Rename (same folder)
mv oldname.txt newname.txt

# Move and rename
mv notes.txt archive/notes-2025.txt
```

## Delete a File

```bash
# Delete single file
rm notes.txt

# Ask confirmation before delete
rm -i notes.txt

# Delete multiple files
rm file1.txt file2.txt
```

> ⚠️ `rm` ไม่มี recycle bin ระวังก่อนรัน

## Delete a Folder

```bash
# Delete empty folder
rmdir emptyfolder

# Delete folder and everything inside
rm -r myfolder

# Ask confirmation on each item
rm -ri myfolder
```

> ⚠️ `rm -r` อันตราย ตรวจสอบชื่อ folder ให้ดีก่อนรัน

## curl

```bash
# แสดง HTML ของ URL
curl https://example.com

# Download ด้วยชื่อไฟล์เดิม
curl -O https://example.com/file.zip

# Download ด้วยชื่อที่กำหนดเอง
curl -o myfile.zip https://example.com/file.zip
# Saves as: myfile.zip

# GET request
curl -X GET https://api.example.com/status

# POST request พร้อม JSON body
curl -X POST https://api.example.com/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user", "password": "secret"}'
```