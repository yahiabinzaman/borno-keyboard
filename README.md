# বর্ণ (Borno) — Native Avro Phonetic Keyboard for macOS & Windows

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple&logoColor=white)](https://github.com/yahiabinzaman/borno-keyboard)
[![Windows](https://img.shields.io/badge/Windows-10%2F11-0078D6?logo=windows&logoColor=white)](https://github.com/yahiabinzaman/borno-keyboard)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Native-blue)](https://github.com/yahiabinzaman/borno-keyboard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Borno (বর্ণ)** is a clean, minimal, native Avro Phonetic Bengali keyboard for **macOS** and **Windows**. Designed for maximum typing speed, pure direct typing with zero floating popup disruption, and seamless compatibility across Adobe Illustrator, Photoshop, Figma, VS Code, MS Office, and all applications.

---

## ⚡️ Quick Install (1-Line Terminal Commands)

### 🍎 For macOS (Terminal):
Paste this into your macOS **Terminal** and press **Return**:
```bash
curl -fsSL https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main/scripts/install.sh | bash
```
> Or download the pre-packaged **[Borno.dmg](https://github.com/yahiabinzaman/borno-keyboard/releases/latest/download/Borno.dmg)**.

---

### 🪟 For Windows (PowerShell):
Open **PowerShell** or **Windows Terminal**, paste this command and press **Enter**:
```powershell
irm https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main/scripts/install.ps1 | iex
```
> Or download the standalone **[Borno-Setup-0.2.5.exe](https://github.com/yahiabinzaman/borno-keyboard/releases)** installer.

---

## 🖥️ First-Time Configuration

### 🍎 macOS:
1. Open **System Settings** → **Keyboard** → **Input Sources** (Click *Edit...*).
2. Click **`+`** (Add), search for **`Borno`**, and select it.
3. Use the **Globe (🌐)** key or **`Ctrl + Space`** to toggle between English and Borno.

### 🪟 Windows:
1. After installation, Borno automatically runs in the **System Tray** (near the taskbar clock).
2. Press **`F12`** anytime to toggle between **English ⇋ Bengali** mode.
3. Type in phonetic Avro (e.g. `ami` = `আমি`, `bangla` = `বাংলা`) in MS Word, Chrome, Notepad, etc.

---

## 🌟 Highlights

- **Pure Direct Typing**: Bengali characters stream directly into your active cursor without popup flicker.
- **Creative Cloud & Office Ready**: Perfectly tuned for Adobe Illustrator, Photoshop, InDesign, Figma & MS Office.
- **Native Performance**: Ultra-fast Rust engine core (`riti`) with native macOS Swift UI and Windows Win32 integration.
- **100% Offline & Private**: Zero network telemetry, fully open-source.
- **Full Avro Rules**: Supports all standard Avro phonetic mappings and complex Bengali conjuncts.

---

## 🛠️ Building from Source

### macOS:
```bash
git clone https://github.com/yahiabinzaman/borno-keyboard.git
cd borno-keyboard
make build
make install
```

### Windows:
```bash
git clone https://github.com/yahiabinzaman/borno-keyboard.git
cd borno-keyboard/windows
cargo build --release
```

---

## 👤 Credits & Author

- **Developer & Maintainer**: [Yahia Bin Zaman (ইয়াহিয়া বিন জামান)](https://github.com/yahiabinzaman)
- **License**: [MIT License](LICENSE)
