# বর্ণ (Borno) — Native Avro Phonetic Keyboard for macOS

[![macOS](https://img.shields.io/badge/macOS-13.0%2B-black?logo=apple&logoColor=white)](https://github.com/yahiabinzaman/borno-keyboard)
[![Apple Silicon](https://img.shields.io/badge/Apple%20Silicon-Native-blue)](https://github.com/yahiabinzaman/borno-keyboard)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**Borno (বর্ণ)** is a clean, minimal, native Avro Phonetic Bengali keyboard for macOS. Designed for maximum typing speed, pure direct typing with zero floating popup disruption, and seamless compatibility across Adobe Illustrator, Photoshop, Figma, VS Code, and all macOS applications.

---

## ⚡️ Quick Install (1-Line Terminal Command)

Paste this into your macOS Terminal and press **Return**:

```bash
curl -fsSL https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main/scripts/install.sh | bash
```

Or download the pre-packaged **[Borno.dmg](https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main/docs/Borno.dmg)**.

---

## 🖥️ First-Time macOS Configuration

After installation:
1. Open **System Settings** → **Keyboard** → **Input Sources** (Click *Edit...*).
2. Click **`+`** (Add), search for **`Borno`**, and select it.
3. Use the **Globe (🌐)** key or **`Ctrl + Space`** to toggle between English and Borno.

---

## 🌟 Highlights

- **Pure Direct Typing**: Bengali characters stream directly into your active cursor without popup flicker.
- **Creative Cloud Ready**: Perfectly tuned for Adobe Illustrator, Photoshop, InDesign & Figma.
- **Apple Silicon Native**: High performance Rust core + native Swift UI.
- **100% Offline & Private**: Zero network telemetry.
- **Full Avro Rules**: Supports all standard Avro phonetic mappings and complex Bengali conjuncts.

---

## 🛠️ Building from Source

```bash
# Clone the repository
git clone https://github.com/yahiabinzaman/borno-keyboard.git
cd macbangla

# Build Apple Silicon release
make build

# Install to ~/Library/Input Methods/
make install

# Package DMG installer
bash scripts/create_dmg.sh
```

---

## 👤 Credits & Author

- **Developer & Maintainer**: [Yahia Bin Zaman (ইয়াহিয়া বিন জামান)](https://github.com/yahiabinzaman)
- **License**: [MIT License](LICENSE)
