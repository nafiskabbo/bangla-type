# BanglaType — Features

Detailed feature list. See [README](../readme.md) for install and quick start.

## Input & typing

- **Avro Phonetic** — Bangladeshi standard English-to-Bangla transliteration (OmicronLab-compatible).
- **7 fixed layouts** — Probhat, Munir Optima, Avro Easy, Bornona, National (Jatiya), Akkhor (see [Keyboard layouts](KEYBOARD_LAYOUTS.md)).
- **Bangladeshi dictionary** — word prediction and autocorrect (Bangladeshi spelling).
- **Automatic vowel forming**, **Reph (র্)** support, **Hasanta (্)**, **ZWNJ/ZWJ**, composing buffer with live preview.

## যুক্তাক্ষর (conjunct) deletion

- **Backspace** — one codepoint at a time.
- **⌥ Option + Backspace** — entire যুক্তাক্ষর cluster (e.g. `ক্ষ্ম` in one stroke).
- **⌘ Cmd + Backspace** — entire composing word.
- Engine follows Unicode UAX #29 grapheme clusters.

## Theme, layout switching, preferences

- **Theme:** System / Light / Dark; accent colors; candidate window styling.
- **Layout switching:** Menu bar, HUD (`⌃ Control + \`), per-app memory.
- **Preferences:** 8 tabs (General, Appearance, Shortcuts, Layouts, Phonetic, Dictionary, Advanced, About).

## Privacy & distribution

- No telemetry; works offline; dictionary is local.
- DMG via [Releases](https://github.com/nafiskabbo/bangla-type/releases); Homebrew: `brew install --cask banglatype`.
