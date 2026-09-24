#!/bin/bash
set -euo pipefail

APP_NAME="Borno"
INSTALL_DIR="$HOME/Library/Input Methods"
USER_DATA_DIR="$HOME/Library/Application Support/Borno"
PREFS_FILE="$HOME/Library/Preferences/com.lekho.inputmethod.Borno.plist"
SAVED_STATE_DIR="$HOME/Library/Saved Application State/com.lekho.inputmethod.Borno.savedState"

echo "=== Uninstalling $APP_NAME ==="

# Kill running instance & unload LaunchAgent
LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/com.borno.inputmethod.Borno.plist"
launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
rm -f "$LAUNCH_AGENT_PLIST" 2>/dev/null || true

killall "$APP_NAME" 2>/dev/null || true
killall "AvroBangla" 2>/dev/null || true  # old name
sleep 1

# Remove the app
if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo ">>> Removing $INSTALL_DIR/$APP_NAME.app"
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
else
    echo ">>> App not found in $INSTALL_DIR"
fi

# Remove old AvroBangla installation if present
rm -rf "$INSTALL_DIR/AvroBangla.app" 2>/dev/null || true
rm -f "/Applications/AvroBangla.app" 2>/dev/null || true
rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true

# Ask about user data
if [ -d "$USER_DATA_DIR" ] || [ -f "$PREFS_FILE" ] || [ -d "$SAVED_STATE_DIR" ]; then
    echo ""
    echo "User data found:"
    [ -d "$USER_DATA_DIR" ]   && echo "  - $USER_DATA_DIR (learned word selections)"
    [ -f "$PREFS_FILE" ]      && echo "  - $PREFS_FILE (settings)"
    [ -d "$SAVED_STATE_DIR" ] && echo "  - $SAVED_STATE_DIR (welcome window state)"
    echo ""
    read -p "Remove all user data? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$USER_DATA_DIR"   2>/dev/null || true
        rm -f  "$PREFS_FILE"      2>/dev/null || true
        rm -rf "$SAVED_STATE_DIR" 2>/dev/null || true
        echo ">>> User data removed."
    else
        echo ">>> User data preserved."
    fi
fi

echo ""
echo "=== Uninstall complete ==="
echo "Please log out and log back in to complete removal."
