#!/bin/bash
set -euo pipefail

APP_NAME="Borno"
INSTALL_DIR="$HOME/Library/Input Methods"
REPO_URL="https://github.com/yahiabinzaman/borno-keyboard"
RAW_URL="https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main"

echo "======================================================"
echo "    Installing Borno (বর্ণ) — Avro Keyboard for Mac    "
echo "======================================================"
echo ""

# Determine if running inside repo or via curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
LOCAL_APP=""

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../build/$APP_NAME.app" ]; then
    LOCAL_APP="$SCRIPT_DIR/../build/$APP_NAME.app"
elif [ -d "./build/$APP_NAME.app" ]; then
    LOCAL_APP="./build/$APP_NAME.app"
fi

TMP_WORK_DIR=$(mktemp -d /tmp/borno_install.XXXXXX)
trap 'rm -rf "$TMP_WORK_DIR"' EXIT

if [ -n "$LOCAL_APP" ] && [ -d "$LOCAL_APP" ]; then
    echo ">>> Installing from local build..."
    APP_SOURCE="$LOCAL_APP"
else
    echo ">>> Downloading latest Borno for macOS from GitHub..."
    DMG_DOWNLOAD_URL="https://raw.githubusercontent.com/yahiabinzaman/borno-keyboard/main/docs/Borno.dmg"
    curl -fSL --progress-bar "$DMG_DOWNLOAD_URL" -o "$TMP_WORK_DIR/Borno.dmg"

    echo ">>> Extracting installer package..."
    hdiutil attach "$TMP_WORK_DIR/Borno.dmg" -mountpoint "$TMP_WORK_DIR/mnt" -nobrowse -quiet
    
    if [ -f "$TMP_WORK_DIR/mnt/Install Borno.pkg" ]; then
        pkgutil --expand-full "$TMP_WORK_DIR/mnt/Install Borno.pkg" "$TMP_WORK_DIR/pkg_expanded" 2>/dev/null || true
        if [ -d "$TMP_WORK_DIR/pkg_expanded/Scripts/Borno.app" ]; then
            APP_SOURCE="$TMP_WORK_DIR/pkg_expanded/Scripts/Borno.app"
        elif [ -d "$TMP_WORK_DIR/pkg_expanded/Borno.app" ]; then
            APP_SOURCE="$TMP_WORK_DIR/pkg_expanded/Borno.app"
        fi
    fi
    
    if [ -z "${APP_SOURCE:-}" ]; then
        # Direct payload search
        APP_SOURCE=$(find "$TMP_WORK_DIR" -name "Borno.app" -type d | head -n 1)
    fi
fi

if [ -z "${APP_SOURCE:-}" ] || [ ! -d "$APP_SOURCE" ]; then
    echo "❌ Error: Could not locate Borno.app payload."
    exit 1
fi

echo ">>> Stopping any existing instances..."
killall "$APP_NAME" 2>/dev/null || true
killall "AvroBangla" 2>/dev/null || true
sleep 1

mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true
rm -rf "$INSTALL_DIR/AvroBangla.app" 2>/dev/null || true

echo ">>> Copying $APP_NAME.app to $INSTALL_DIR/..."
cp -R "$APP_SOURCE" "$INSTALL_DIR/"

# Detach DMG if mounted
if [ -d "$TMP_WORK_DIR/mnt" ]; then
    hdiutil detach "$TMP_WORK_DIR/mnt" -quiet 2>/dev/null || true
fi

# Clear quarantine attributes
echo ">>> Clearing quarantine security attributes..."
xattr -cr "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

# Symlink to /Applications for Spotlight/Launchpad
rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true
ln -sf "$INSTALL_DIR/$APP_NAME.app" "/Applications/$APP_NAME.app" 2>/dev/null || true

# Launch IME service
echo ">>> Launching $APP_NAME..."
open "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

echo ""
echo "======================================================"
echo "      ✅ Borno (বর্ণ) successfully installed!         "
echo "======================================================"
echo ""
echo "Setup Instructions:"
echo " 1. Open System Settings -> Keyboard -> Input Sources (Click Edit...)"
echo " 2. Click '+' at the bottom left"
echo " 3. Search for 'Borno' in the language list and click 'Add'"
echo " 4. Switch anytime using Globe key or Ctrl + Space"
echo ""
echo "Developed & Maintained by Yahia Bin Zaman"
echo "GitHub: https://github.com/yahiabinzaman/borno-keyboard"
echo "======================================================"
