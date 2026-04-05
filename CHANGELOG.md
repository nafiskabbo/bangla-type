# Changelog

All notable changes to BanglaType are documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Documented Gatekeeper/quarantine fix (“damaged” message) and clean reinstall steps in the readme.
- **Input modes:** seven separate entries in **System Settings → Keyboard → Input Sources** (Avro Phonetic, Probhat, Munir Optima, Avro Easy, Bornona, National Jatiya, Akkhor), via `ComponentInputModeDict` and localized names in `en.lproj/InfoPlist.strings`.
- `InputSourceModeCoordinator` (Carbon/TIS) to sync the active layout with the selected input mode and to switch TIS when picking a layout from the menu bar.

### Changed

- **`CFBundleDevelopmentRegion`** set to **`bn`**; each mode declares **`TISIntendedLanguage`** **`bn`** so sources list under **Bangla**.
- Menu bar layout changes call **`TISSelectInputSource`** when possible so Input Sources and the engine stay aligned.

### Fixed

- **Typing in normal apps:** the old “secure field” check used `selectedRange == NSNotFound`, which matches many non-password IMK clients (e.g. web views) and disabled all processing — replaced with a narrow secure-field check.
- Key handling: fall back to **`charactersIgnoringModifiers`** when **`characters`** is empty; explicitly request **keyDown** in **`recognizedEvents`**.
- **Phonetic preview + IMK:** Avro returns the *full* Bangla preview every keystroke; the controller was **appending** it each time (garbled / empty effect). It now **replaces** the composing buffer for phonetic, uses **`composedString`** + **`updateComposition`**, commits once on **`.commit`**, and resets the phonetic Latin buffer on **`commitComposition`** / deactivate.
- **Input Sources icons:** `AppIcon.icns` was used for every mode (huge in the picker). Modes now use **`BanglaTypeInputMethod.icns`** (16–64 px, `tools/gen_input_method_icon.swift`).

### Removed

- (List removals, if any.)

---

## [1.0.0] - 2026-03-17

### Added

- Initial release of BanglaType for macOS.
- Avro Phonetic input (Roman script → Bangladeshi Bangla).
- Seven fixed layouts: Probhat, Munir Optima, National (Jatiya), and others.
- Menu bar icon with layout switching and Preferences (⌃ Control + ,).
- Bangladeshi Bangla dictionary and autocorrect.
- Documentation: Features, Keyboard layouts, Shortcuts, Building from source.

[Unreleased]: https://github.com/nafiskabbo/bangla-type/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/nafiskabbo/bangla-type/releases/tag/v1.0.0
