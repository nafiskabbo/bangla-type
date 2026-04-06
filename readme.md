# BanglaType IME (standalone Swift + Rust)

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

```bash
cd BanglaType-IME
make clean && make build
```

Output: `BanglaType-IME/build/BanglaTypeIME.app`

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

Rust engine (riti), MPL-2.0 — same stack as before; see repo root `README.md`.
