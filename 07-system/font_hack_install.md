# Installing Hack Font on macOS (for use in iTerm2)

## Goal

ติดตั้งฟอนต์ Hack (เวอร์ชันธรรมดา ไม่มีไอคอน Nerd Font) แล้วนำไปใช้เป็นฟอนต์หลักใน iTerm2
https://github.com/source-foundry/Hack

## Steps

### 1) Download and extract the file

```bash
curl -L -o ~/Downloads/Hack-v3.003-ttf.zip https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.zip
cd ~/Downloads
unzip Hack-v3.003-ttf.zip -d Hack-font
```

### 2) Install the font into the system

```bash
cp ~/Downloads/Hack-font/ttf/*.ttf ~/Library/Fonts/
```

macOS จะรู้จักฟอนต์ทันทีหลัง copy เข้า `~/Library/Fonts/` โดยไม่ต้องรีสตาร์ทเครื่อง หรือจะดับเบิลคลิกไฟล์ `.ttf` แต่ละไฟล์แล้วกด Install Font ผ่าน Font Book ก็ได้เช่นกัน

### 3) Configure in iTerm2

iTerm2 เลือก Hack จากรายการ → ตั้งขนาดตามชอบ (แนะนำ 12–14pt)

## Notes

- ไฟล์ `.ttf` ที่แตกออกมาจากขั้นตอนที่ 1 จะอยู่ใน subfolder ชื่อ `ttf` อีกชั้น คือ `Hack-font/ttf/*.ttf` ไม่ใช่ `Hack-font/*.ttf`
- ฟอนต์ Hack เวอร์ชันนี้ไม่มีไอคอน (Powerline glyphs / dev icons) ถ้าต้องการไอคอนสำหรับ theme อย่าง `powerlevel10k`, `oh-my-posh`, `starship` ต้องใช้เวอร์ชัน Hack Nerd Font แทน ดาวน์โหลดได้จาก https://github.com/ryanoasis/nerd-fonts/releases (เลือกไฟล์ `Hack.zip`)
- iTerm2 มีตัวเลือก "Use built-in Powerline glyphs" ในแท็บ Text ซึ่งช่วยแสดงสัญลักษณ์ Powerline พื้นฐานได้แม้ใช้ฟอนต์ธรรมดาที่ไม่มีไอคอน แต่จะไม่ครบเท่า Nerd Font เต็มรูปแบบ