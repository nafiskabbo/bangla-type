# BanglaType IME (standalone Swift + Rust)

Phonetic **Avro-style** typing is powered by **[riti](https://github.com/OpenBangla/riti)** — the Rust transliteration engine from the **[OpenBangla](https://openbangla.github.io/)** project (**MPL-2.0**). This repo links `riti` into a static library (`libavrobangla_engine.a`) and calls it from Swift via **InputMethodKit**.

This folder builds a **separate** macOS input method from the main **BanglaType** Xcode app so you can **test both at once**:

| | Main app (`banglatype.xcodeproj`) | This folder (`BanglaType-IME/`) |
|--|-------------------------------------|----------------------------------|
| **Bundle ID** | `com.banglatype.inputmethod.BanglaType` | `com.banglatype.inputmethod.BanglaTypeIME` |
| **`.app` name** | `BanglaType.app` | `BanglaTypeIME.app` |
| **Menu / Input Sources name** | BanglaType (per layout) | **BanglaType IME** |
| **User data** | (main app support) | `~/Library/Application Support/BanglaTypeIME` |

Installers here **do not** remove `BanglaType.app`.

---

## Build

From the repository root:

```bash
make clean && make build
```

Output: `build/BanglaTypeIME.app`

```bash
make install          # → ~/Library/Input Methods/BanglaTypeIME.app
# or
bash scripts/create_dmg.sh
```

---

## Docs

- **Remove old builds and run side-by-side:** [docs/BUILDING.md](../docs/BUILDING.md) → section **“BanglaType IME (standalone) & cleanup”**.

---

## Credits

| Component | License | Notes |
|-----------|---------|--------|
| **[riti](https://github.com/OpenBangla/riti)** | **MPL-2.0** | Avro phonetic engine: suggestions, pre-edit text, bundled dictionary/autocorrect data (`data/*.json`). |
| **BanglaType IME** (this tree) | *(see main repo)* | Swift IMK shell + thin Rust bridge (`avro_keycode_for_char`) mapping `NSEvent` characters → riti keycodes. |

Upstream riti is maintained by the OpenBangla community; report engine-specific issues against **riti** / **OpenBangla-Keyboard** when appropriate.
