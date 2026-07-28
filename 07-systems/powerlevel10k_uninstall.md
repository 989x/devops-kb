# Uninstall Powerlevel10k

อ้างอิง: https://github.com/romkatv/powerlevel10k

> **สำคัญ:** บน macOS ต้องใช้ `sed -i ''` (มีช่องว่างตามด้วย `''`) เพราะ BSD sed
> ต้องการ argument ต่อท้าย `-i` เสมอ ถ้าใช้ `sed -i.bak` หรือ `sed -i` เฉยๆ
> จะพัง (`invalid command code` หรือไฟล์ backup เพี้ยน) คำสั่งด้านล่างปรับให้ปลอดภัยแล้ว

## 0. เช็คก่อนว่าติดตั้งผ่านทางไหน

```bash
grep -n "p10k\|powerlevel10k" ~/.zshrc
brew list --formula 2>/dev/null | grep -i powerlevel10k
```

- ถ้าเจอบรรทัด `source .../powerlevel10k.zsh-theme` ตรงๆ → ติดตั้งผ่าน **brew tap** (ไม่ใช่ Oh My Zsh theme) ให้ใช้ **วิธีที่ 2**
- ถ้าเจอ `ZSH_THEME="powerlevel10k/powerlevel10k"` → ติดตั้งผ่าน **Oh My Zsh** ให้ใช้ **วิธีที่ 1**
- ถ้า `brew list` เจอชื่อ formula → ใช้ชื่อนั้นตอน uninstall (เช่น `romkatv/powerlevel10k/powerlevel10k`)

## วิธีลบออกถาวร

### 1. ถ้าใช้ Oh My Zsh (theme แบบ `ZSH_THEME=`)

```bash
rm -rf ~/.oh-my-zsh/custom/themes/powerlevel10k
sed -i '' 's/ZSH_THEME="powerlevel10k\/powerlevel10k"/ZSH_THEME="robbyrussell"/' ~/.zshrc
sed -i '' -e '/p10k-instant-prompt/d' -e '/p10k.zsh/d' ~/.zshrc
rm -f ~/.p10k.zsh ~/.cache/p10k-instant-prompt-*.zsh
source ~/.zshrc
```

### 2. ถ้าใช้ Homebrew (macOS) — source ตรงจาก `powerlevel10k.zsh-theme`

ก่อนรัน ให้เอาชื่อ formula จากขั้นตอน 0 มาแทนใน `brew uninstall`:

```bash
brew uninstall romkatv/powerlevel10k/powerlevel10k
sed -i '' -e '/p10k-instant-prompt/d' -e '/powerlevel10k.zsh-theme/d' ~/.zshrc
rm -f ~/.p10k.zsh ~/.cache/p10k-instant-prompt-*.zsh
source ~/.zshrc
```

### 3. ถ้าใช้ Antigen / Zinit / plugin manager อื่น

```bash
sed -i '' -e '/romkatv\/powerlevel10k/d' -e '/p10k-instant-prompt/d' -e '/p10k.zsh/d' ~/.zshrc
rm -f ~/.p10k.zsh ~/.cache/p10k-instant-prompt-*.zsh
source ~/.zshrc
```

> วิธีนี้ลบบรรทัดที่อ้างถึง `romkatv/powerlevel10k` และ `p10k.zsh` ออกจาก `.zshrc`
> ถ้า plugin manager เก็บ config ไว้อีกไฟล์ (เช่น `.zshrc.local` หรือ `plugins.txt`) ให้ตรวจสอบไฟล์นั้นเพิ่ม

---

**หมายเหตุ:** ถ้าอยากมี backup ก่อนแก้ ให้ก็อปไฟล์ก่อนรัน:

```bash
cp ~/.zshrc ~/.zshrc.bak
```

กู้คืนได้ด้วย:

```bash
mv ~/.zshrc.bak ~/.zshrc
```