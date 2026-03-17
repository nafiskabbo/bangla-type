# বাংলা কীবোর্ড — **BanglaType** for macOS

<p align="center">
  <img src="assets/logo.png" alt="App Logo" width="128"/>
</p>

<p align="center">
  <strong>A free, open-source, Unicode-compliant Bangladeshi Bangla input method for macOS</strong><br/>
  Built with Swift & SwiftUI · Powered by InputMethodKit · Made for Bangladesh 🇧🇩
</p>

<p align="center">
  <a href="https://github.com/your-org/BanglaType/releases"><img src="https://img.shields.io/github/v/release/your-org/BanglaType?style=flat-square" alt="Release"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"/></a>
  <a href="https://github.com/your-org/BanglaType/stargazers"><img src="https://img.shields.io/github/stars/your-org/BanglaType?style=flat-square" alt="Stars"/></a>
  <img src="https://img.shields.io/badge/macOS-13%2B-brightgreen?style=flat-square" alt="macOS 13+"/>
  <img src="https://img.shields.io/badge/Swift-5.9%2B-orange?style=flat-square" alt="Swift 5.9+"/>
  <img src="https://img.shields.io/badge/focus-Bangladesh%20🇧🇩-green?style=flat-square" alt="Bangladesh"/>
</p>

---

## ✨ Overview

**BanglaType** is the first fully open-source, native **Bangladeshi Bangla** input method for macOS, built entirely in Swift and SwiftUI on top of Apple's `InputMethodKit` framework.

This project is **focused exclusively on Bangladesh** — every layout, every dictionary word, every default, and every design decision is shaped around the needs of Bangladeshi users writing standard Bangladeshi Bangla (বাংলাদেশ প্রমিত বাংলা). It brings the complete experience that millions of Bangladeshis enjoy with Avro and OpenBangla on Windows/Linux — natively to the Mac — with dark/light theme support and modern macOS UX.

> This project stands on the shoulders of [Avro Keyboard](https://www.omicronlab.com/avro-keyboard.html) by **OmicronLab** (Dhaka), [OpenBangla Keyboard](https://github.com/OpenBangla/OpenBangla-Keyboard), and the generations of Bangladeshi engineers who built the digital Bangla ecosystem.

---

## 📋 Table of Contents

- [Features](#-features)
- [Keyboard Layouts](#-keyboard-layouts)
- [Keyboard Shortcuts](#-keyboard-shortcuts)
- [যুক্তাক্ষর (Conjunct) Deletion](#-যুক্তাক্ষর-conjunct-deletion)
- [Installation](#-installation)
- [Building from Source](#-building-from-source)
- [Architecture](#-architecture)
- [Contributing](#-contributing)
- [Roadmap](#-roadmap)
- [Credits & Licenses](#-credits--licenses)

---

## 🚀 Features

### 🔤 Input & Typing
- **Avro Phonetic** — The de-facto Bangladeshi standard English-to-Bangla phonetic transliteration, 100% compatible with OmicronLab's original Avro scheme
- **7 fixed keyboard layouts** — all created by Bangladeshi authors (see [Keyboard Layouts](#-keyboard-layouts))
- **Bangladeshi Bangla dictionary** — word prediction and autocorrect trained on Bangladeshi corpus, not West Bengali Bangla
- **Automatic vowel forming** — phonetic mode auto-produces the full vowel form (স্বরবর্ণ) without a link key
- **Old-style Reph (র্)** support — traditional reph placement
- **Traditional -কার joining** — correct vowel diacritic rendering on consonants
- **Automatic চন্দ্রবিন্দু (ঁ) position fixing** — correct Unicode codepoint ordering
- **Hasanta (্) key** for manual conjunct formation
- **Zero Width Non-Joiner (ZWNJ)** and **Zero Width Joiner (ZWJ)** support
- **Composing buffer with live preview** — see the composed text before committing

### ✂️ যুক্তাক্ষর (Conjunct) Smart Delete
- **Single Backspace** — deletes one Unicode codepoint at a time
- **⌥ Option + Backspace** — deletes an entire যুক্তাক্ষর cluster at once — e.g., `ক্ষ্ম` gone in one keystroke
- **⌘ Cmd + Backspace** — deletes the entire composing word/token
- Cluster-aware deletion engine based on Unicode grapheme cluster boundary rules (UAX #29)

### 🎨 Theme & Appearance
- **Automatic system theme sync** — follows macOS Light / Dark mode instantly
- **Manual override** — lock to Light or Dark regardless of system setting
- **Menu bar icon adapts** to theme (filled / outline variant)
- **Candidate window** uses native `NSVisualEffectView` for a frosted-glass macOS-native look
- **Custom accent colors** (configurable in Preferences)

### 🔀 Layout Switching
- **Global hotkey** cycles through all enabled layouts (default: `⌃ Control + Space`, customizable)
- **Per-app layout memory** — remembers which layout you used per application
- **Menu bar dropdown** for one-click layout switch
- **Layout indicator** in menu bar — e.g., `বাং·অভ্র`, `বাং·প্র`, `বাং·জাতীয়`
- **Quick-switch HUD** (`⌃ Control + \`) — floating panel showing all layouts

### ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `⌃ Control + Space` | Toggle Bangla ↔ English input |
| `⌃ Control + \` | Open layout switcher HUD |
| `⌃ Control + 1` | Switch to Avro Phonetic |
| `⌃ Control + 2` | Switch to Probhat |
| `⌃ Control + 3` | Switch to Munir Optima |
| `⌃ Control + 4` | Switch to National / Jatiya (BCC) |
| `⌃ Control + 5` | Switch to Avro Easy |
| `⌃ Control + 6` | Switch to Bornona |
| `⌃ Control + 7` | Switch to Akkhor |
| `⌥ Option + Backspace` | Delete entire যুক্তাক্ষর cluster |
| `⌘ Cmd + Backspace` | Delete current composing word |
| `Esc` | Cancel composing / revert to English |
| `⌃ Control + ,` | Open Preferences |
| `⌃ Control + K` | Open on-screen keyboard viewer |
| `⌃ Control + D` | Toggle dictionary/autocomplete suggestions |

> All shortcuts are fully customizable in **Preferences → Keyboard Shortcuts**.

### 📖 Dictionary & Autocomplete
- **Real-time word prediction** — suggestions from a Bangladeshi Bangla text corpus
- **Autocorrect substitutions** — common English loanwords converted to standard Bangladeshi spellings (e.g., `facebook` → `ফেসবুক`)
- **User dictionary** — add, edit, remove personal words
- **Suggestion list orientation** — horizontal or vertical, configurable

### 🖥️ On-Screen Keyboard Viewer
- Floating keyboard showing the current Bangladeshi layout's character map
- Hover over any key to see the Unicode codepoint
- Click-to-type support
- Auto-updates when layout switches

### 🔧 Preferences & Customization
- 8-tab Preferences window:
  - **General** — startup, menu bar, default language
  - **Appearance** — theme, accent color, candidate window style
  - **Shortcuts** — remap every global hotkey
  - **Layouts** — enable/disable/reorder the 7 bundled layouts
  - **Phonetic** — tune Avro Phonetic (vowel forming, Reph style)
  - **Dictionary** — autocorrect and prediction settings
  - **Advanced** — per-app layout memory, ZWNJ/ZWJ, debug logging
  - **About** — version, contributors, licenses

### 🔒 Privacy First
- **Zero telemetry** — no analytics or crash reports without explicit consent
- **No internet required** — fully local; dictionary is bundled
- **Sandboxed** — App Sandbox enabled; only accessibility permission needed for hotkeys

### 📦 Distribution
- `.dmg` via GitHub Releases (no App Store — InputMethodKit restriction)
- Homebrew: `brew install --cask BanglaType`
- Auto-update via Sparkle framework

---

## ⌨️ Keyboard Layouts

**BanglaType ships only layouts authored by Bangladeshi creators for Bangladeshi Bangla.** Indian layouts (Inscript, Disha, etc.) are intentionally out of scope — this keeps the project focused, the maintenance lean, and the product identity clear.

All layouts use **Avro Keyboard Layout format v5** (`.avrolayout` JSON) — interoperable and community-editable.

| # | Layout | বাংলা নাম | Type | Author / Origin | License |
|---|---|---|---|---|---|
| 1 | **Avro Phonetic** | অভ্র ফোনেটিক | Phonetic | OmicronLab, Dhaka 🇧🇩 | [MIT](https://github.com/OmicronLab/avro-phonetic-js) |
| 2 | **Probhat** | প্রভাত | Fixed | Bangladeshi Linux community 🇧🇩 | [GPL-2.0](https://www.nongnu.org/m17n/) |
| 3 | **Munir Optima** | মুনীর অপ্টিমা | Fixed | Munir Chowdhury, Bangladesh 🇧🇩 | [GPL-3.0](https://github.com/OpenBangla/OpenBangla-Keyboard) |
| 4 | **Avro Easy** | অভ্র ইজি | Fixed | OmicronLab, Dhaka 🇧🇩 | [MIT](https://github.com/OpenBangla/OpenBangla-Keyboard) |
| 5 | **Bornona** | বর্ণনা | Fixed | The Safeworks, Bangladesh 🇧🇩 | [GPL-3.0](https://github.com/OpenBangla/OpenBangla-Keyboard) |
| 6 | **National (Jatiya)** | জাতীয় | Fixed | Bangladesh Computer Council (BCC) 🇧🇩 | Public Domain |
| 7 | **Akkhor** | অক্ষর | Fixed | Khan Md. Anwarus Salam, Bangladesh 🇧🇩 | [GPL-3.0](https://github.com/OpenBangla/OpenBangla-Keyboard) |

> **Scope note:** Inscript (C-DAC, India) and Disha (Ankur Group, India) are excluded by design. This is not a limitation — it's a commitment to focus.

> **Custom layouts**: Drop any valid `.avrolayout` file into `~/Library/Application Support/BanglaType/Layouts/` and it appears automatically in the switcher.

---

## 🗑️ যুক্তাক্ষর (Conjunct) Deletion

One of the most frustrating problems in Bangla typing is deleting a **যুক্তাক্ষর**. A cluster like `ক্ষ্ম` is stored as multiple codepoints (`ক` + `্` + `ষ` + `্` + `ম`) but renders as one glyph. Standard Backspace leaves broken half-rendered glyphs.

**BanglaType solves this with a cluster-aware deletion engine:**

```
Regular Backspace    → deletes one Unicode scalar (codepoint) at a time
⌥ Option+Backspace  → deletes the entire যুক্তাক্ষর cluster at once
⌘ Cmd+Backspace     → deletes the entire composed word token
```

The engine walks backward from the cursor using Swift's `String.unicodeScalars` with Unicode UAX #29 grapheme cluster boundary rules:
1. Is the preceding scalar a **Hasanta (্, U+09CD)**? Include the consonant before it.
2. Repeat until the chain ends.
3. Also handles **Khanda Ta (ৎ)**, **Anusvar (ং)**, **Visarga (ঃ)**, **Chandrabindu (ঁ)**, and all Bengali combining marks.

Exposed via `IMKInputController.didCommandBySelector(_:client:)` intercepting `deleteBackward:`.

---

## 📥 Installation

### Option 1 — DMG (Recommended)
1. Download `BanglaType-x.x.x.dmg` from [**Releases**](https://github.com/your-org/BanglaType/releases)
2. Drag **BanglaType.app** to `/Library/Input Methods/`
3. Log out and back in (macOS requirement for new input methods)
4. **System Settings → Keyboard → Input Sources → +** → search "Bangla" → Add **BanglaType**
5. Activate from the menu bar

### Option 2 — Homebrew
```bash
brew install --cask BanglaType
```

### System Requirements
- macOS 13 Ventura or later · Apple Silicon or Intel · ~20 MB

---

## 🔨 Building from Source

```bash
git clone https://github.com/your-org/BanglaType.git
cd BanglaType
open BanglaType.xcodeproj

# CLI build
xcodebuild -scheme BanglaType -configuration Release \
  -derivedDataPath build/ build

sudo cp -R build/Build/Products/Release/BanglaType.app \
  "/Library/Input Methods/"
```

> **Bundle ID rule:** Must contain `.inputmethod.` — e.g., `com.your-org.inputmethod.BanglaType`. Hard requirement of Apple's InputMethodKit.

### Project Structure

```
BanglaType/
├── Sources/
│   ├── App/
│   │   ├── AppDelegate.swift            # IMKServer init (must be a global var)
│   │   └── main.swift
│   ├── InputController/
│   │   ├── BanglaInputController.swift  # IMKInputController subclass
│   │   ├── ComposingBuffer.swift
│   │   ├── ClusterDeletionEngine.swift  # যুক্তাক্ষর-aware backspace
│   │   └── CandidateController.swift
│   ├── Layouts/
│   │   ├── LayoutEngine.swift           # Protocol + LayoutManager
│   │   ├── PhoneticEngine.swift         # Avro Phonetic (Swift port)
│   │   ├── FixedLayoutEngine.swift
│   │   └── Bundled/                     # 7 Bangladeshi .avrolayout files
│   ├── Dictionary/
│   │   ├── BanglaDictionary.swift
│   │   ├── UserDictionary.swift
│   │   └── Resources/bd_bangla_words.db # Bangladeshi Bangla corpus
│   ├── UI/
│   │   ├── PreferencesWindow.swift
│   │   ├── LayoutSwitcherHUD.swift
│   │   ├── OnScreenKeyboard.swift
│   │   └── MenuBarController.swift
│   ├── Theme/
│   │   └── ThemeManager.swift
│   └── Utils/
│       ├── HotkeyManager.swift
│       └── PerAppLayoutMemory.swift
└── Tests/
    ├── PhoneticEngineTests.swift
    ├── ClusterDeletionTests.swift
    └── LayoutParserTests.swift
```

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────┐
│           macOS InputMethodKit            │
│         (IMKServer / IMKTextInput)        │
└─────────────────┬────────────────────────┘
                  │ keyboard events
                  ▼
┌──────────────────────────────────────────┐
│       BanglaInputController              │
│   (IMKInputController subclass)          │
└───┬─────────────────┬────────────────────┘
    ▼                 ▼
┌───────────┐   ┌────────────────────┐
│  Avro     │   │  Fixed Layout      │
│ Phonetic  │   │  Engine            │
│  Engine   │   │(.avrolayout parser)│
└─────┬─────┘   └────────┬───────────┘
      └────────┬──────────┘
               ▼
┌──────────────────────────────────────────┐
│         ComposingBuffer                  │
└─────────────────┬────────────────────────┘
        ┌─────────┴──────────┐
        ▼                    ▼
┌───────────────┐   ┌──────────────────────┐
│  Bangladeshi  │   │  Cluster Deletion    │
│  Dictionary   │   │  Engine (UAX #29)    │
└───────────────┘   └──────────────────────┘
```

---

## 🤝 Contributing

Please read [`CONTRIBUTING.md`](CONTRIBUTING.md) before submitting PRs.

**Scope policy:** Please do not submit Indian regional layouts or West Bengali–specific features. This project is Bangladesh-focused by design.

---

## 🗺️ Roadmap

| Version | Milestone |
|---|---|
| `v0.1.0` | Core IME + Avro Phonetic + composing buffer |
| `v0.2.0` | All 7 Bangladeshi layouts + layout switcher HUD |
| `v0.3.0` | Bangladeshi dictionary + autocomplete + user words |
| `v0.4.0` | Cluster deletion engine (যুক্তাক্ষর smart Backspace) |
| `v0.5.0` | Preferences UI (all 8 tabs) + global hotkeys |
| `v0.6.0` | On-screen keyboard viewer + click-to-type |
| `v0.7.0` | Per-app layout memory + Sparkle auto-update |
| `v0.8.0` | Custom `.avrolayout` loading from user directory |
| `v1.0.0` | Public release + Homebrew cask |
| `v1.1.0` | Voice typing (local Whisper, Bangladeshi accent) |

---

## 📜 Credits & Licenses

BanglaType is licensed under the **GNU General Public License v3.0**. See [`LICENSE`](LICENSE).

| Person / Project | Contribution |
|---|---|
| **Mehdi Hasan Khan** | Creator of Avro Keyboard & Avro Phonetic (OmicronLab, Dhaka) |
| **OpenBangla Keyboard** | Open-source Bangladeshi layout files — GPL-3.0 |
| **Rifat Nabi** | avro-phonetic-js — MIT |
| **Munir Chowdhury** | Munir Optima layout |
| **Bangladesh Computer Council (BCC)** | National (Jatiya) layout — Public Domain |
| **Khan Md. Anwarus Salam** | Akkhor layout |
| **The Safeworks** | Bornona layout |
| **ensan-hcl** | macOS IMKitSample — IMKit Swift bootstrapping reference |

---

<p align="center">
  বাংলাদেশের জন্য, বাংলাদেশিদের দ্বারা তৈরি ❤️ 🇧🇩
</p>