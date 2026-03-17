# BanglaType — Cursor Development Plan

> **Stack**: Swift 5.9+ · SwiftUI · InputMethodKit · macOS 13+
> **IDE**: Xcode 15+ with Cursor AI
> **Focus**: Bangladesh 🇧🇩 — Bangladeshi Bangla only
> **Architecture**: IMKInputController-based macOS Input Method Extension
> **Target**: `/Library/Input Methods/BanglaType.app`

---

## 📐 Project Philosophy

- **Bangladesh-first**: Every layout, dictionary word, and default is shaped for Bangladeshi users writing standard Bangladeshi Bangla. Indian layouts are out of scope.
- Every piece of logic is **unit-testable** in isolation from InputMethodKit
- Layouts are **data-driven** (`.avrolayout` JSON) — zero code changes to add a layout
- The UI (Preferences + HUD) is a **separate SwiftUI process** communicating with the IME via UserDefaults/XPC
- The core IME process has **no SwiftUI dependency** — runs headlessly, creates only AppKit windows when needed

---

## 🗂️ Phase Overview

| Phase | Name | Deliverable | Est. Days |
|---|---|---|---|
| 0 | Project Scaffold | Buildable skeleton, CI | 2 |
| 1 | Core IME Engine | Text input working | 5 |
| 2 | Phonetic Engine | Avro Phonetic fully working | 5 |
| 3 | Fixed Layouts | All 7 Bangladeshi layouts working | 3 |
| 4 | Layout Switcher | HUD + hotkey switching | 3 |
| 5 | Cluster Deletion | Smart Backspace for যুক্তাক্ষর | 3 |
| 6 | Dictionary | Bangladeshi Bangla autocomplete + autocorrect | 5 |
| 7 | Preferences UI | Full SwiftUI prefs window | 5 |
| 8 | Theme Support | Dark / Light / System | 2 |
| 9 | On-Screen Keyboard | Visual keyboard + click-to-type | 3 |
| 10 | Per-App Memory | Layout memory per application | 2 |
| 11 | Packaging | DMG + Homebrew + Sparkle | 2 |
| 12 | Testing & Polish | Full test suite + edge cases | 5 |

---

## Phase 0 — Project Scaffold

### Goal
Buildable Xcode project that macOS recognises as a valid input method, with CI configured.

#### Task 0.1 — Create Xcode Project
```
Prompt Cursor:
"Create a new macOS app Xcode project named 'BanglaType' with bundle identifier
'com.your-org.inputmethod.BanglaType'. The target must install to
/Library/Input Methods/. Remove the default SwiftUI @main entry point and
ContentView. Set the minimum deployment target to macOS 13.0. Add the
InputMethodKit framework as a linked library."
```

**Critical `Info.plist` keys:**
```xml
<key>InputMethodConnectionName</key>
<string>com.your-org.inputmethod.BanglaType_Connection</string>
<key>InputMethodServerControllerClass</key>
<string>BanglaType.BanglaInputController</string>
<key>tsInputMethodIconName</key>
<string>BanglaTypeIcon</string>
<key>tsInputMethodCharacterSubset</key>
<array>
  <string>Bengali</string>
</array>
```

#### Task 0.2 — Stub Input Controller
```
Prompt Cursor:
"Create BanglaInputController.swift that subclasses IMKInputController.
Override inputText(_:client:) to log keystrokes and return false for now.
The class must be @objc annotated and match the class name string in Info.plist
exactly. Add a global IMKServer variable in AppDelegate.swift initialised with
the connection name from Info.plist. The IMKServer MUST be a global var — not
inside applicationDidFinishLaunching."
```

**Key pattern:**
```swift
// AppDelegate.swift — global, not inside any function
var server: IMKServer = IMKServer(
    name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String,
    bundleIdentifier: Bundle.main.bundleIdentifier
)

@objc(BanglaInputController)
class BanglaInputController: IMKInputController {
    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        return false
    }
}
```

#### Task 0.3 — GitHub Actions CI
```
Prompt Cursor:
"Write .github/workflows/ci.yml that:
1. Runs on push to main and all PRs
2. Builds with xcodebuild for arm64 and x86_64
3. Runs all unit tests
4. Uploads the built .app as a build artifact"
```

---

## Phase 1 — Core IME Engine

#### Task 1.1 — ComposingBuffer State Machine
```
Prompt Cursor:
"Create ComposingBuffer.swift:
- Maintains a String buffer of uncommitted text
- Methods: append(scalar: Unicode.Scalar), deleteLastScalar(),
  deleteLastCluster(), deleteAll(), commit() -> String
- Fires onBufferChanged(text: String) delegate callback on every change
  so BanglaInputController can call client.setMarkedText() to show the
  composing underline in the target text field"
```

#### Task 1.2 — IMKInputController Key Routing
```
Prompt Cursor:
"Expand BanglaInputController:
1. Override handle(_:client:) -> Bool for NSEvent keyboard events
2. Check modifier keys (Cmd, Option, Control) to route to shortcut handler
3. Route printable characters to the active layout engine
4. Override didCommandBySelector(_:client:) to intercept deleteBackward:,
   moveLeft:, moveRight: selectors
5. Call client.setMarkedText() with composing buffer content on each keystroke
6. Call client.insertText() when Enter or Space commits the composition"
```

#### Task 1.3 — LayoutEngine Protocol
```
Prompt Cursor:
"Define LayoutEngineProtocol in LayoutEngine.swift:
  func process(key: String, modifiers: NSEvent.ModifierFlags) -> LayoutOutput
  enum LayoutOutput {
    case commit(String)     // insert text immediately
    case compose(String)    // update composing buffer
    case passthrough        // let macOS handle
    case consumed           // key consumed, no output
  }
Create a PassthroughLayoutEngine stub."
```

#### Task 1.4 — Candidate Window
```
Prompt Cursor:
"Create CandidateController.swift wrapping IMKCandidates:
- Shows a list of String suggestions in a candidate window
- Handles candidateSelected(_:)
- Supports horizontal and vertical orientations (configurable)
- Lazy — only creates IMKCandidates on first use"
```

---

## Phase 2 — Avro Phonetic Engine

#### Task 2.1 — Port Avro Phonetic Table
```
Prompt Cursor:
"Create PhoneticEngine.swift — a Swift port of the Avro Phonetic algorithm
(avro-phonetic-js by OmicronLab, MIT licensed).
Include:
1. The complete suffix-replacement rule table as Swift structs:
   struct PhoneticRule { let find: String; let replace: String;
                         let rules: [SubRule] }
2. transliterate(_ input: String) -> String
3. Vowel auto-forming: when a কার/মাত্রা is typed after a vowel context,
   produce the full independent vowel form
4. The complete 'patterns' array from the original JS source
This implements the OmicronLab Avro Phonetic scheme exactly — the standard
used by Bangladeshi users."
```

#### Task 2.2 — Phonetic Word Parsing
```
Prompt Cursor:
"Implement phonetic word boundary parsing in PhoneticEngine:
- Maintain the current 'phonetic word' context as the user types
- On Space or punctuation: commit the current word and start fresh
- 'Preview' mode: show the Bangla candidate in real-time via
  client.setMarkedText() without committing"
```

#### Task 2.3 — Phonetic Unit Tests
```
Prompt Cursor:
"Write PhoneticEngineTests.swift:
- Basic vowels: a→আ, aa→আ, i→ই, ii→ঈ, u→উ, uu→ঊ
- Common consonants: k→ক, kh→খ, g→গ, gh→ঘ, ng→ঙ
- Conjuncts: kt→ক্ত, ndr→ন্দ্র, ksh→ক্ষ
- Hasanta: k``→ক্
- Reph: rk→র্ক
- Common Bangladeshi words: 'amar'→আমার, 'bangladesh'→বাংলাদেশ,
  'dhaka'→ঢাকা, 'protidin'→প্রতিদিন
- Edge cases: double consonants, word boundaries"
```

---

## Phase 3 — Fixed Layouts (Bangladeshi Only)

### Layouts included: Probhat, Munir Optima, Avro Easy, Bornona, National (Jatiya/BCC), Akkhor
### Layouts explicitly excluded: Inscript (C-DAC India), Disha (Ankur Group India)

#### Task 3.1 — Avrolayout v5 JSON Parser
```
Prompt Cursor:
"Create AvroLayoutParser.swift that parses Avro Keyboard Layout v5 JSON:
  { 'layout_name': String, 'layout_type': 'fixed'|'phonetic',
    'keys': { 'KEY_CODE': { 'normal': String, 'shift': String,
              'altgr': String, 'shift_altgr': String } } }
Parse into FixedLayout struct with keyMap: [String: KeyEntry].
Write a unit test loading probhat.avrolayout and verifying a→আ, b→ব."
```

#### Task 3.2 — FixedLayoutEngine
```
Prompt Cursor:
"Create FixedLayoutEngine: LayoutEngineProtocol:
1. Takes a FixedLayout on init
2. process(key:modifiers:) looks up character from keyMap:
   - No modifier → 'normal'
   - Shift → 'shift'
   - Option/AltGr → 'altgr'
   - Option+Shift → 'shift_altgr'
3. Returns .commit(character) for direct-commit fixed layouts
4. Handles Hasanta (্) — when followed by a consonant, uses .compose()
   to show conjunct forming in the composing buffer"
```

#### Task 3.3 — Bundle All 7 Bangladeshi Layout Files
```
Prompt Cursor:
"Create these 7 .avrolayout JSON files in Sources/Layouts/Bundled/.
Source the key mappings from the OpenBangla Keyboard GitHub repository (GPL-3.0).
All layouts must use correct Unicode codepoints from the Bengali block U+0980–U+09FF.

Files to create:
1. avro_phonetic.avrolayout    — OmicronLab, MIT
2. probhat.avrolayout          — Bangladeshi Linux community, GPL-2.0
3. munir_optima.avrolayout     — Munir Chowdhury, GPL-3.0
4. avro_easy.avrolayout        — OmicronLab, MIT
5. bornona.avrolayout          — The Safeworks BD, GPL-3.0
6. national_jatiya.avrolayout  — Bangladesh Computer Council, Public Domain
7. akkhor.avrolayout           — Khan Md. Anwarus Salam, GPL-3.0

DO NOT include Inscript or Disha — those are Indian layouts outside our scope."
```

#### Task 3.4 — LayoutManager
```
Prompt Cursor:
"Create LayoutManager.swift — a singleton that:
1. Loads all 7 bundled .avrolayout files at startup
2. Scans ~/Library/Application Support/BanglaType/Layouts/ for user-added layouts
3. Maintains an ordered array of LayoutDescriptor structs
4. Provides activeEngine: LayoutEngineProtocol
5. Persists active layout index to UserDefaults
6. Posts NSNotification 'BanglaTypeLayoutChanged' on layout switch
7. Exposes switchToNextLayout() and switchToLayout(index:)"
```

---

## Phase 4 — Layout Switcher

#### Task 4.1 — Global Hotkey Manager
```
Prompt Cursor:
"Create HotkeyManager.swift using CGEvent tap (NOT deprecated Carbon hotkeys):
1. Register a CGEventTap for keyDown at kCGSessionEventTap
2. Default hotkeys: ⌃Space = Bangla toggle, ⌃\ = layout HUD
3. All hotkeys configurable and stored in UserDefaults
4. Handle re-registration after screen lock or sleep (tap can be invalidated)"
```

#### Task 4.2 — Layout Switcher HUD (SwiftUI)
```
Prompt Cursor:
"Create LayoutSwitcherHUD.swift — an NSPanel with:
1. SwiftUI view showing all 7 Bangladeshi layouts as tap targets
2. Highlighted active layout
3. Keyboard navigation: arrow keys + Enter
4. Auto-dismiss after 2 seconds or on Escape
5. Centered on primary display
6. NSVisualEffectView with .hudWindow material
7. collectionBehavior = .auxiliary + .ignoresCycle
   (does not appear in Mission Control)"
```

#### Task 4.3 — Menu Bar Controller
```
Prompt Cursor:
"Create MenuBarController.swift:
1. NSStatusItem showing layout indicator text:
   'বাং·অভ্র' / 'বাং·প্র' / 'বাং·মু' / 'বাং·জাতীয়' / etc.
2. Clicking shows dropdown: all 7 layouts with checkmarks, separator,
   Preferences, Quit
3. Updates whenever active layout changes
4. Separate icon assets for Light and Dark mode (NSImage template)"
```

---

## Phase 5 — Cluster Deletion Engine

#### Task 5.1 — Unicode Grapheme Cluster Walker
```
Prompt Cursor:
"Create ClusterDeletionEngine.swift:
  func previousClusterRange(in text: String, before index: String.Index)
    -> Range<String.Index>

Walk backward from 'index' using String.unicodeScalars with these rules:
- A Bengali cluster = consonant + (Hasanta U+09CD + consonant)* + optional vowel diacritic
                      + optional anusvar/visarga/chandrabindu
- Stop at a non-combining character outside the cluster
- Handle: Khanda Ta (ৎ U+09CE), Anusvar (ং U+0982), Visarga (ঃ U+0983),
  Chandrabindu (ঁ U+0981), Nukta (় U+09BC)
Return the Range covering the full cluster."
```

#### Task 5.2 — Delete Selector Interception
```
Prompt Cursor:
"In BanglaInputController, override didCommandBySelector(_:client:) -> Bool:
1. 'deleteBackward:':
   - Option held → ClusterDeletionEngine.previousClusterRange() then
     client.insertText('', replacementRange: clusterRange)
   - Cmd held → delete entire composing word
   - Otherwise → single-codepoint delete
2. 'cancelOperation:' (Escape) → clear composing buffer
Return true if handled, false to let system handle."
```

#### Task 5.3 — Cluster Deletion Tests
```
Prompt Cursor:
"ClusterDeletionTests.swift:
1. 'ক্ষ্ম' — entire string is one cluster
2. 'বাংলাদেশ' — delete from end codepoint by codepoint
3. 'র্ক' — reph + consonant = one cluster
4. 'ক্' — consonant + hasanta = one cluster
5. Mixed Bangla-English: 'Hello বাংলা' — cluster walk stops at ASCII"
```

---

## Phase 6 — Bangladeshi Bangla Dictionary

#### Task 6.1 — Build Bangladeshi Corpus Database
```
Prompt Cursor:
"Create tools/build_dictionary.py:
1. Read word frequency list from Bangladeshi Bangla sources:
   - Bangla Wikipedia (Bangladesh-authored articles)
   - Prothom Alo corpus (if available)
   - bdnews24 word list
2. SQLite schema:
   CREATE TABLE words (word TEXT PRIMARY KEY, frequency INTEGER)
3. Output Resources/bd_bangla_words.db
4. Target: 50,000+ most common Bangladeshi Bangla words
   EXCLUDE: West Bengali vocabulary that differs from Bangladeshi standard"
```

#### Task 6.2 — BanglaDictionary Swift Wrapper
```
Prompt Cursor:
"Create BanglaDictionary.swift using system SQLite3:
1. suggestions(for prefix: String, limit: Int = 5) -> [String]
   — words starting with prefix, sorted by frequency
2. autocorrect(for romanized: String) -> String?
   — English loanword → standard Bangladeshi Bangla spelling
3. Lazy DB connection on first use
4. Background queue queries, main queue callbacks
5. NSCache for last 100 queries"
```

#### Task 6.3 — Bangladeshi Autocorrect Table
```
Prompt Cursor:
"Create autocorrect_bd.json with 500+ English→Bangladeshi Bangla substitutions.
Focus on terms common in Bangladesh: social media (facebook→ফেসবুক),
government terms (upazila→উপজেলা, pourashava→পৌরসভা), common loanwords,
Bangladeshi institution names, months/days in Bangladeshi standard spelling.
Prioritize Bangladeshi spelling conventions over West Bengali ones."
```

---

## Phase 7 — Preferences UI (SwiftUI)

#### Task 7.1 — PreferencesWindowController
```
Prompt Cursor:
"Create PreferencesWindowController.swift:
1. NSWindow hosting a SwiftUI view via NSHostingView
2. Fixed size 640×480, centered
3. TabView with 8 tabs using SF Symbols icons
4. Remembers last position in UserDefaults
5. Respects Light and Dark mode"
```

#### Task 7.2 — General Tab
```
SwiftUI pane with:
- Toggle: Launch at login (ServiceManagement)
- Toggle: Show menu bar icon
- Picker: Default input — Bangla / English
- Toggle: Show floating preview while composing
- Toggle: Sound feedback on keystroke
```

#### Task 7.3 — Appearance Tab
```
SwiftUI pane with:
- Segmented: Theme — System / Light / Dark
- Color picker: Candidate window accent color
- Picker: Candidate orientation — Horizontal / Vertical
- Slider: Candidate font size (12–24pt)
- Live preview of candidate window
All values bound to @AppStorage.
```

#### Task 7.4 — Shortcuts Tab
```
Prompt Cursor:
"ShortcutsPreferencesView.swift:
List of all configurable shortcuts. Each row: Action label | current binding.
Clicking a binding enters 'recording mode' — next key combo becomes the new binding.
Custom KeyRecorderView (AppKit wrapper) for recording.
Save as strings like 'ctrl+space' to UserDefaults."
```

#### Task 7.5 — Layouts Tab
```
Prompt Cursor:
"LayoutsPreferencesView.swift:
- Draggable List of the 7 Bangladeshi layouts (name in English + বাংলা)
- Toggle to enable/disable each
- Drag handle to reorder (persists to UserDefaults)
- 'Import layout' button: NSOpenPanel for .avrolayout files,
  copies to ~/Library/Application Support/BanglaType/Layouts/"
```

---

## Phase 8 — Theme Support

#### Task 8.1 — ThemeManager
```
Prompt Cursor:
"Create ThemeManager.swift — ObservableObject singleton:
1. KVO-observes NSApp.effectiveAppearance
2. currentTheme: AppTheme enum (.light, .dark, .system)
3. .system follows macOS; .light/.dark forces window.appearance
4. Updates NSStatusItem button image (template vs named)
5. Persists to UserDefaults key 'theme'"
```

#### Task 8.2 — Candidate Window Theming
```
Define NSColor assets in Assets.xcassets with Light and Dark variants:
candidateBackground, candidateText, candidateHighlight, candidateBorder
Apply to the custom NSPanel HUD. For IMKCandidates, set parentWindow.appearance.
```

---

## Phase 9 — On-Screen Keyboard Viewer

#### Task 9.1 — OnScreenKeyboardView (SwiftUI)
```
Prompt Cursor:
"Create OnScreenKeyboardView.swift (SwiftUI):
1. QWERTY grid with Bangladeshi Bangla characters overlaid
2. Each key: physical label (small) + Bangla character (large)
3. Highlights Shift layer when Shift held (NSEvent.modifierFlags)
4. Clicking a key types that character
5. Segmented control: Normal | Shift | AltGr layers
6. Auto-re-renders on layout change (observe BanglaTypeLayoutChanged notification)
7. Floating NSPanel, 800×280pt"
```

#### Task 9.2 — Keyboard Layout ViewModel
```
Prompt Cursor:
"Create KeyboardLayoutViewModel.swift that converts a FixedLayout into
a 2D grid of KeyViewModel (physicalLabel, normalChar, shiftChar, altGrChar).
QWERTY row arrangement:
  Row 1: q w e r t y u i o p
  Row 2: a s d f g h j k l
  Row 3: z x c v b n m"
```

---

## Phase 10 — Per-App Layout Memory

#### Task 10.1 — PerAppLayoutMemory
```
Prompt Cursor:
"Create PerAppLayoutMemory.swift:
1. Observe NSWorkspace.didActivateApplicationNotification
2. On app switch:
   a. Save current layout index for the PREVIOUS app's bundle ID
   b. Restore layout index for the NEWLY active app (if saved)
3. Persist as [String: Int] in UserDefaults
4. Toggle in Preferences → Advanced"
```

---

## Phase 11 — Packaging & Distribution

#### Task 11.1 — DMG Build Script
```
Prompt Cursor:
"tools/build_dmg.sh:
1. xcodebuild release build
2. Code-sign with CERT_NAME env var
3. hdiutil DMG: BanglaType.app + symlink to /Library/Input Methods/
   custom background assets/dmg_background.png, 540×380 window
4. xcrun notarytool notarize (credentials from keychain)
5. Staple notarization ticket"
```

#### Task 11.2 — Homebrew Cask
```ruby
cask 'BanglaType' do
  version 'VERSION'
  sha256 'SHA256'
  url "https://github.com/your-org/BanglaType/releases/download/vVERSION/BanglaType-VERSION.dmg"
  name 'BanglaType'
  desc 'Open-source Bangladeshi Bangla input method for macOS'
  homepage 'https://github.com/your-org/BanglaType'
  app 'BanglaType.app', target: '/Library/Input Methods/BanglaType.app'
end
```

#### Task 11.3 — Sparkle Auto-Update
```
Integrate Sparkle 2.x via SPM.
Add SPUStandardUpdaterController to AppDelegate.
Add 'Check for Updates' to menu bar dropdown.
Generate appcast.xml in GitHub Actions release workflow.
```

---

## Phase 12 — Testing & Polish

#### Task 12.1 — Full Test Suite
```
Prompt Cursor:
"Comprehensive XCTest suite:
1. PhoneticEngineTests — 100+ transliteration cases (Bangladeshi words focus)
2. ClusterDeletionTests — 50+ grapheme cluster edge cases
3. FixedLayoutTests — 7 Bangladeshi layouts × 20 common characters each
4. LayoutParserTests — all 7 .avrolayout files parse without error
5. DictionaryTests — word lookup + Bangladeshi autocorrect
6. HotkeyManagerTests — mock CGEvent for shortcut detection"
```

#### Task 12.2 — Edge Case Handling
```
Prompt Cursor:
"Handle:
1. Secure text input (passwords) — disable composing, ASCII passthrough
   Detect via client.selectedRange() returning {NSNotFound, 0}
2. Terminal.app — test and add workarounds
3. Electron apps (VSCode, Slack) — add Electron-specific insertion path
4. Rapid typing — queue keystrokes, process in order without dropping
5. Unicode NFC normalization — all committed text normalised via
   String.precomposedStringWithCanonicalMapping before client.insertText()"
```

---

## 📋 Cursor Workflow Tips

### Always Give IMKit Context
When prompting about any InputMethodKit code, include:
> "This is a macOS InputMethodKit app for Bangladeshi Bangla. The bundle ID must contain `.inputmethod.`. IMKServer MUST be a global var. The app installs to /Library/Input Methods/ and is NOT sandboxed. @objc class name must match Info.plist exactly."

### Quick Reinstall Loop
```bash
killall BanglaType 2>/dev/null
cp -R ~/Library/Developer/Xcode/DerivedData/BanglaType-*/Build/Products/Debug/BanglaType.app \
  "/Library/Input Methods/"
```

### Unicode Quick Reference (Bengali Block U+0980–U+09FF)
| Character | Codepoint | Name |
|---|---|---|
| ্ | U+09CD | Hasanta (Virama) |
| ঁ | U+0981 | Chandrabindu |
| ং | U+0982 | Anusvar |
| ঃ | U+0983 | Visarga |
| ৎ | U+09CE | Khanda Ta |
| ় | U+09BC | Nukta |
| ‌ | U+200C | ZWNJ |
| ‍ | U+200D | ZWJ |

---

## 🔗 Reference Repositories

| Repo | What to Study |
|---|---|
| [OpenBangla/OpenBangla-Keyboard](https://github.com/OpenBangla/OpenBangla-Keyboard) | Bangladeshi layout files, phonetic engine C++ |
| [OmicronLab/Avro-Phonetic-js](https://github.com/omicronlab/Avro-Phonetic-js) | JS phonetic engine to port to Swift (MIT) |
| [ensan-hcl/macOS_IMKitSample_2021](https://github.com/ensan-hcl/macOS_IMKitSample_2021) | IMKit Swift boilerplate |
| [pkamb/NumberInput_IMKit_Sample](https://github.com/pkamb/NumberInput_IMKit_Sample) | IMKit known bugs & workarounds |

---

## 📅 Estimated Timeline (1 developer, full-time)

```
Week 1   Phase 0 + Phase 1   Scaffold + core IME engine
Week 2   Phase 2             Avro Phonetic engine
Week 3   Phase 3 + Phase 4   7 Bangladeshi layouts + switcher
Week 4   Phase 5 + Phase 6   Cluster delete + Bangladeshi dictionary
Week 5   Phase 7             Preferences UI
Week 6   Phase 8–10          Theme + on-screen keyboard + per-app memory
Week 7   Phase 11            Packaging (DMG + Homebrew + Sparkle)
Week 8   Phase 12            Testing, polish, v1.0.0 release 🎉
```

---

*বাংলাদেশের জন্য, বাংলাদেশিদের দ্বারা তৈরি ❤️ 🇧🇩*