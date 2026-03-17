#!/bin/bash
# Build signed, notarized DMG for BanglaType.
# Set CERT_NAME for code signing; notarytool uses keychain credentials.
set -e
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

xcodebuild -scheme banglatype -configuration Release -derivedDataPath build clean build
APP=build/Build/Products/Release/BanglaType.app
[ -d "$APP" ] || { echo "Build failed: $APP not found"; exit 1; }

VERSION="${VERSION:-$(plutil -extract CFBundleShortVersionString raw "$APP/Contents/Info.plist" 2>/dev/null || echo "1.0.0")}"
DMG_NAME="BanglaType-${VERSION}.dmg"
VOLUME_NAME="BanglaType ${VERSION}"

if [ -n "$CERT_NAME" ]; then
  codesign --force --deep --sign "$CERT_NAME" --options runtime "$APP"
fi

# DMG layout: 540×380 window, background optional
DMG_TMP="build/dmg_tmp"
DMG_IMG="build/BanglaType-${VERSION}.dmg"
rm -rf "$DMG_TMP" "$DMG_IMG"
mkdir -p "$DMG_TMP"
cp -R "$APP" "$DMG_TMP/"
ln -s /Library/Input\ Methods "$DMG_TMP/Install to Input Methods"

hdiutil create -volname "$VOLUME_NAME" -srcfolder "$DMG_TMP" -ov -format UDZO "$DMG_IMG"
rm -rf "$DMG_TMP"

if [ -n "$CERT_NAME" ]; then
  codesign --force --sign "$CERT_NAME" "$DMG_IMG"
fi

# Notarize (requires APPLE_ID, APPLE_TEAM_ID, notarytool keychain profile)
if [ -n "$APPLE_ID" ] && [ -n "$APPLE_TEAM_ID" ]; then
  xcrun notarytool submit "$DMG_IMG" --apple-id "$APPLE_ID" --team-id "$APPLE_TEAM_ID" --wait
  xcrun stapler staple "$DMG_IMG"
fi

echo "Created $DMG_IMG"
