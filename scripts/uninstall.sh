#!/bin/bash
set -euo pipefail

APP_NAME="BanglaTypeIME"
INSTALL_DIR="$HOME/Library/Input Methods"
USER_DATA_DIR="$HOME/Library/Application Support/BanglaTypeIME"

echo "=== Uninstalling $APP_NAME ==="

killall "$APP_NAME" 2>/dev/null || true
sleep 1

if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo ">>> Removing $INSTALL_DIR/$APP_NAME.app"
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
else
    echo ">>> App not found in $INSTALL_DIR"
fi

rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true
rm -rf "/Applications/$APP_NAME.app" 2>/dev/null || true

if [ -d "$USER_DATA_DIR" ]; then
    echo ""
    read -p "Remove user data ($USER_DATA_DIR)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$USER_DATA_DIR"
        echo ">>> User data removed."
    else
        echo ">>> User data preserved."
    fi
fi

echo ""
echo "=== Uninstall complete ==="
echo "Please log out and log back in to complete removal."
