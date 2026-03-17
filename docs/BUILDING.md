# Building BanglaType

## From source

```bash
git clone https://github.com/nafiskabbo/bangla-type.git
cd bangla-type
open banglatype.xcodeproj
```

**CLI build:**

```bash
xcodebuild -scheme banglatype -configuration Release -derivedDataPath build build
sudo cp -R build/Build/Products/Release/BanglaType.app "/Library/Input Methods/"
```

Then **log out and back in** so macOS loads the input method.

## Building the dictionary

Word suggestions and autocorrect use `banglatype/Resources/bd_bangla_words.db` and `autocorrect_bd.json`.

```bash
python3 tools/build_dictionary.py
```

Add words in `tools/wordlist_bd.txt` (format: `word\tfrequency` per line) or in `tools/bangla_words_data.py`, then run the script and rebuild the app.

## Creating a DMG

```bash
./tools/build_dmg.sh
```

Output: `build/BanglaType-<version>.dmg`. Optional: set `CERT_NAME`, `APPLE_ID`, `APPLE_TEAM_ID` for signing and notarization.

## Project structure

- `banglatype/` — App target (AppDelegate, InputController, Layouts, Dictionary, UI, Theme, Utils).
- `tools/` — `build_dictionary.py`, `build_dmg.sh`.
- `Casks/banglatype.rb` — Homebrew cask.
- `.github/workflows/` — CI and Release (tag `v*` → build DMG and upload to GitHub Releases).
