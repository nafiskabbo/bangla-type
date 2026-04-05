# Building BanglaType

BanglaType is a **macOS input method**. After installation you turn it on from the **menu bar input menu** or **System Settings → Keyboard → Input Sources**, then type Bangla in any app (TextEdit, browser, etc.)—not inside a separate BanglaType window.

---

## Full checklist (build → DMG or app → install → use)

Use this when you want everything in order.

### Part 1 — Get the code (once)

1. Open **Terminal**.
2. Go to your project folder (example):

   ```bash
   cd ~/development/XcodeProjects/banglatype
   ```

---

### Part 2 — Build the `.app` (choose one way)

**Option A — Command line (good for scripts and CI-style builds)**

1. Run:

   ```bash
   xcodebuild -scheme banglatype -configuration Release \
     -derivedDataPath build -destination 'platform=macOS' build \
     CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO
   ```

2. When it finishes with **BUILD SUCCEEDED**, the app is here:

   ```text
   build/Build/Products/Release/BanglaType.app
   ```

**Option B — Xcode (GUI)**

1. Double-click **`banglatype.xcodeproj`** to open Xcode.
2. Top bar: scheme **banglatype**, configuration **Release** (Product → Scheme → Edit Scheme → Run → Build Configuration → Release, or Archive flow).
3. **Product → Build** (⌘B).
4. **Product → Show Build Folder in Finder** (or Derived Data), then open **`Products/Release/BanglaType.app`**.  
   *Easiest repeatable path:* use **Option A** so the app always lands in `build/Build/Products/Release/`.

---

### Part 3 — Create a `.dmg` (optional)

Do this if you want a disk image to share or install from (like a release).

1. From the **same project root** as `banglatype.xcodeproj`:

   ```bash
   chmod +x tools/build_dmg.sh
   ./tools/build_dmg.sh
   ```

2. The script runs a **clean** Release build, then packs the app. Output:

   ```text
   build/BanglaType-<version>.dmg
   ```

   (`<version>` comes from the app’s **CFBundleShortVersionString**, e.g. `1.0`.)

3. **Signing / notarization (optional, for public downloads)**  
   If you have an Apple Developer **Developer ID Application** certificate:

   ```bash
   export CERT_NAME="Developer ID Application: Your Name (TEAMID)"
   export APPLE_ID="your@email.com"
   export APPLE_TEAM_ID="XXXXXXXXXX"
   ./tools/build_dmg.sh
   ```

   Notarization needs **`notarytool`** credentials in Keychain (Apple’s docs: [Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)).  
   *Without* this, local DMGs still work; downloaded copies may need the quarantine step in Part 4.

---

### Part 4 — Install BanglaType on your Mac

1. If **BanglaType** is already installed, remove it first:
   - **System Settings → Keyboard → Input Sources** → select **BanglaType** → **−**.
   - Terminal:

     ```bash
     killall BanglaType 2>/dev/null || true
     sudo rm -rf "/Library/Input Methods/BanglaType.app"
     ```

2. **Install the app** (must be the **system** Library, not your home folder):
   - **From a DMG:** open the DMG, drag **BanglaType.app** onto **“Install to Input Methods”** (shortcut to `/Library/Input Methods/`), or copy the app there yourself.
   - **From Terminal** (replace the path if yours differs):

     ```bash
     sudo cp -R "build/Build/Products/Release/BanglaType.app" "/Library/Input Methods/"
     ```

3. **Remove quarantine** (stops the false *“damaged”* / Gatekeeper message after download or some copies):

   ```bash
   sudo xattr -dr com.apple.quarantine "/Library/Input Methods/BanglaType.app"
   ```

4. **Log out** of your macOS account **and log back in** (or **restart**).  
   *Skipping this often means BanglaType never appears in Input Sources.*

5. **Add input modes:** **System Settings → Keyboard → Input Sources → Edit… → +** → **Bangla**.  
   Add each **BanglaType — …** mode you want (Avro Phonetic, Probhat, etc.). Remove any **old** single “BanglaType” entry from a previous install first.

6. **Use it:** Click the **input menu** in the menu bar (e.g. “A”, “ABC”, or a flag) and choose **BanglaType**. Type in any normal app.

---

### Part 5 — Dictionary data (only if you changed words)

Suggestions use bundled `bd_bangla_words.db` and `autocorrect_bd.json`. Rebuild only if you edit word lists:

```bash
python3 tools/build_dictionary.py
```

Then build the app again (Part 2).

---

## Short reference

| Goal | Command / location |
|------|---------------------|
| Build `.app` (unsigned, CLI) | `xcodebuild …` as in **Part 2, Option A** |
| `.app` output path | `build/Build/Products/Release/BanglaType.app` |
| Build `.dmg` | `./tools/build_dmg.sh` → `build/BanglaType-<version>.dmg` |
| Install location | `/Library/Input Methods/BanglaType.app` |
| Fix “damaged” / quarantine | `sudo xattr -dr com.apple.quarantine "/Library/Input Methods/BanglaType.app"` |

---

## Project structure

- `banglatype/` — App target (input method, UI, layouts, dictionary).
- `tools/` — `build_dictionary.py`, `build_dmg.sh`.
- `Casks/banglatype.rb` — Homebrew cask.
- `.github/workflows/` — CI; release workflow builds a DMG on tag `v*`.

More usage and shortcuts: [readme](../readme.md), [Shortcuts](SHORTCUTS.md).
