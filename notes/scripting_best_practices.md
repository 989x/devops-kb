# Bash Server Provisioning — Best Practices

## 0. ตัวอย่างอ้างอิง

### 0.1 Laravel DevOps — PHP Installer

https://github.com/rcravens/devops-laravel/blob/master/provision/installers/php_all.sh

ตัวอย่าง provisioning script จริงจาก Laravel DevOps project ดูวิธีจัดโครงสร้าง installer แยกเป็นไฟล์ย่อยต่อ package

### 0.2 Restic Backup Script

https://github.com/buildplan/restic-backup-script

ตัวอย่าง backup script ที่เขียนด้วย bash อย่างมีโครงสร้าง ดูวิธีจัดการ config, logging, และ error handling ในงาน scheduled task

## 1. File Header & Strict Mode

Shebang line บอก interpreter ที่ใช้รัน script และ strict mode ช่วย catch error ตั้งแต่แรก

```bash
#!/usr/bin/env bash
set -euo pipefail
# -e  : exit ทันทีเมื่อ command ใดก็ตามล้มเหลว
# -u  : error ถ้าใช้ตัวแปรที่ยังไม่ได้ set
# -o pipefail : catch errors ที่เกิดใน pipe commands
```

## 2. Logging & Color Output

Log levels ช่วยแยกแยะความสำคัญของ message และ color output ทำให้อ่านง่ายขึ้น ควรเขียน log ลงไฟล์พร้อม timestamp ทุกครั้งเพื่อ debug ภายหลัง

```bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/provision_$(date +%Y%m%d_%H%M%S).log"

log()   { echo -e "${GREEN}[INFO]${NC}  $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${YELLOW}[WARN]${NC}  $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}[ERROR]${NC} $*" | tee -a "$LOG_FILE"; }
step()  { echo -e "${BLUE}[STEP]${NC}  ===== $* =====" | tee -a "$LOG_FILE"; }
```

## 3. Error Handling & Trap

trap handler รันทุกครั้งที่ script จบ ไม่ว่าจะจบปกติหรือผิดพลาด ทำให้มั่นใจได้ว่า error จะถูก log และ cleanup เสมอ

```bash
cleanup() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    error "Script failed at line $LINENO with exit code $exit_code"
    error "Check log: $LOG_FILE"
  fi
}

trap cleanup EXIT
trap 'error "Interrupted"; exit 130' INT TERM
```

## 4. Idempotency

Script ที่ดีต้องรันซ้ำได้โดยไม่มี side effects ทุกครั้งที่รันต้องได้ผลลัพธ์เหมือนเดิม ควร check ก่อนทำเสมอ

check ก่อน append

```bash
if ! grep -qF "/opt/node/bin" ~/.bashrc; then
  echo "export PATH=/opt/node/bin:$PATH" >> ~/.bashrc
  log "Updated PATH in .bashrc"
else
  log "PATH already configured, skipping"
fi
```

check ก่อน install ด้วย install_if_missing function

```bash
install_if_missing() {
  local pkg="$1"
  if dpkg -l "$pkg" &>/dev/null; then
    log "$pkg already installed, skipping"
  else
    log "Installing $pkg..."
    apt-get install -y "$pkg"
  fi
}
```

## 5. Full Script Template

ตัวอย่างสมบูรณ์ที่รวมทุก section ข้างต้น

```bash
#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# provision-server.sh — Ubuntu 22.04 Web Server Setup
# Usage: sudo ./provision-server.sh
# ============================================================

APP_USER="${APP_USER:-deploy}"
NODE_VERSION="${NODE_VERSION:-20}"
TIMEZONE="${TIMEZONE:-Asia/Bangkok}"

LOG_FILE="/var/log/provision_$(date +%Y%m%d_%H%M%S).log"

log()   { echo -e "\033[32m[INFO]\033[0m  $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "\033[33m[WARN]\033[0m  $*" | tee -a "$LOG_FILE"; }
error() { echo -e "\033[31m[ERROR]\033[0m $*" | tee -a "$LOG_FILE"; exit 1; }
step()  { echo -e "\033[34m[STEP]\033[0m  ===== $* =====" | tee -a "$LOG_FILE"; }

cleanup() {
  [[ $? -ne 0 ]] && error "Provisioning FAILED. Check $LOG_FILE"
}
trap cleanup EXIT
trap 'error "Interrupted"; exit 130' INT TERM

[[ $EUID -eq 0 ]] || error "Please run as root: sudo $0"

install_if_missing() {
  local pkg="$1"
  if dpkg -l "$pkg" &>/dev/null; then
    log "$pkg already installed, skipping"
  else
    apt-get install -y "$pkg"
    log "$pkg installed"
  fi
}

step "System Update"
apt-get update -qq && apt-get upgrade -y -qq
log "System updated"

step "Set Timezone"
timedatectl set-timezone "$TIMEZONE"
log "Timezone set to $TIMEZONE"

step "Create Deploy User"
if id "$APP_USER" &>/dev/null; then
  log "User $APP_USER already exists, skipping"
else
  useradd -m -s /bin/bash "$APP_USER"
  usermod -aG sudo "$APP_USER"
  log "Created user: $APP_USER"
fi

step "Install Node.js $NODE_VERSION"
if command -v node &>/dev/null; then
  log "Node.js $(node -v) already installed"
else
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | bash -
  install_if_missing nodejs
fi

step "Done"
log "Provisioning complete!"
log "Full log: $LOG_FILE"
```