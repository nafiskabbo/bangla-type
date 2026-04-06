#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_BUNDLE="$PROJECT_ROOT/build/BanglaTypeIME.app"
PKG_DIR="$PROJECT_ROOT/build/pkg_staging"
DMG_DIR="$PROJECT_ROOT/build/dmg_staging"
VERSION="0.2.2"
PKG_OUTPUT="$PROJECT_ROOT/build/BanglaTypeIME.pkg"
DMG_OUTPUT="$PROJECT_ROOT/build/BanglaTypeIME-${VERSION}.dmg"
VOLUME_NAME="BanglaType IME"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run 'make build' first."
    exit 1
fi

echo "=== Creating Installer Package (BanglaType IME — separate bundle from main BanglaType) ==="

# Clean up
rm -rf "$PKG_DIR" "$DMG_DIR" "$PKG_OUTPUT"
rm -f "$DMG_OUTPUT"

mkdir -p "$PKG_DIR/scripts"
cp -R "$APP_BUNDLE" "$PKG_DIR/scripts/BanglaTypeIME.app"

cat > "$PKG_DIR/scripts/preinstall" << 'SCRIPT'
#!/bin/bash
REAL_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
REAL_HOME=$(eval echo "~$REAL_USER")

killall BanglaTypeIME 2>/dev/null || true
killall Lekho 2>/dev/null || true
killall AvroBangla 2>/dev/null || true
sleep 1

# Only remove this variant (do not touch BanglaType.app — main Xcode IME)
rm -rf "$REAL_HOME/Library/Input Methods/BanglaTypeIME.app" 2>/dev/null || true
rm -rf "$REAL_HOME/Library/Input Methods/Lekho.app" 2>/dev/null || true
rm -rf "$REAL_HOME/Library/Input Methods/AvroBangla.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/BanglaTypeIME.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/Lekho.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/AvroBangla.app" 2>/dev/null || true

exit 0
SCRIPT
chmod +x "$PKG_DIR/scripts/preinstall"

cat > "$PKG_DIR/scripts/postinstall" << 'SCRIPT'
#!/bin/bash
REAL_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
REAL_HOME=$(eval echo "~$REAL_USER")

INSTALL_DIR="$REAL_HOME/Library/Input Methods"
SCRIPT_DIR="$(dirname "$0")"

mkdir -p "$INSTALL_DIR"

cp -R "$SCRIPT_DIR/BanglaTypeIME.app" "$INSTALL_DIR/"
chown -R "$REAL_USER" "$INSTALL_DIR/BanglaTypeIME.app"
xattr -cr "$INSTALL_DIR/BanglaTypeIME.app" 2>/dev/null || true

rm -f "/Applications/BanglaTypeIME.app" 2>/dev/null || true
rm -rf "/Applications/BanglaTypeIME.app" 2>/dev/null || true
ln -sf "$INSTALL_DIR/BanglaTypeIME.app" "/Applications/BanglaTypeIME.app"

rm -f "/Applications/Lekho.app" 2>/dev/null || true
rm -rf "/Applications/Lekho.app" 2>/dev/null || true
rm -f "/Applications/AvroBangla.app" 2>/dev/null || true
rm -rf "/Applications/AvroBangla.app" 2>/dev/null || true

killall BanglaTypeIME 2>/dev/null || true
sleep 0.5

su "$REAL_USER" -c "open '$INSTALL_DIR/BanglaTypeIME.app'" 2>/dev/null || true

exit 0
SCRIPT
chmod +x "$PKG_DIR/scripts/postinstall"

echo ">>> Building package..."
pkgbuild \
    --nopayload \
    --scripts "$PKG_DIR/scripts" \
    --identifier "com.banglatype.inputmethod.BanglaTypeIME" \
    --version "0.2.2" \
    "$PKG_DIR/BanglaTypeIME-component.pkg"

cat > "$PKG_DIR/distribution.xml" << 'DISTXML'
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>BanglaType IME</title>
    <allowed-os-versions><os-version min="13.0"/></allowed-os-versions>
    <options hostArchitectures="arm64" customize="never" require-scripts="false"/>
    <welcome mime-type="text/plain"><![CDATA[
Welcome to BanglaType IME — Avro Phonetic Bengali Keyboard for macOS.

This build uses bundle ID com.banglatype.inputmethod.BanglaTypeIME so you can
install it alongside the main BanglaType app from Xcode (com.banglatype.inputmethod.BanglaType).

After installation:
  1. Open System Settings → Keyboard → Input Sources
  2. Click + → search "BanglaType IME" → select BanglaType IME → Add
  3. Use Globe key or Ctrl+Space to switch input methods

You may need to log out and log back in for the keyboard to appear.
    ]]></welcome>
    <choices-outline>
        <line choice="default">
            <line choice="com.banglatype.inputmethod.BanglaTypeIME"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="com.banglatype.inputmethod.BanglaTypeIME" visible="false">
        <pkg-ref id="com.banglatype.inputmethod.BanglaTypeIME"/>
    </choice>
    <pkg-ref id="com.banglatype.inputmethod.BanglaTypeIME"
             version="0.2.2"
             onConclusion="none">BanglaTypeIME-component.pkg</pkg-ref>
</installer-gui-script>
DISTXML

echo ">>> Building product package..."
productbuild \
    --distribution "$PKG_DIR/distribution.xml" \
    --package-path "$PKG_DIR" \
    "$PKG_OUTPUT"

echo ">>> Package created: $PKG_OUTPUT"

echo ""
echo "=== Creating DMG ==="

mkdir -p "$DMG_DIR"
cp "$PKG_OUTPUT" "$DMG_DIR/Install BanglaType IME.pkg"

hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

rm -rf "$PKG_DIR" "$DMG_DIR"

echo ""
echo "=== Done ==="
echo "DMG: $DMG_OUTPUT ($(du -h "$DMG_OUTPUT" | cut -f1))"
echo "PKG: $PKG_OUTPUT ($(du -h "$PKG_OUTPUT" | cut -f1))"
echo ""
echo "Users: open DMG → double-click 'Install BanglaType IME.pkg'"
