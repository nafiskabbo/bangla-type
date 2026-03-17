# Contributing to BanglaType

Thank you for your interest in contributing to **BanglaType** — the open-source Bangladeshi Bangla input method for macOS.

---

## Code of conduct

- Be respectful and inclusive.
- This project is **Bangladesh-focused**. We welcome contributions that improve the experience for Bangladeshi Bangla users.

---

## How to contribute

### Reporting bugs

- Open an [Issue](https://github.com/nafiskabbo/bangla-type/issues) with a clear title and description.
- Include: macOS version, steps to reproduce, and what you expected vs what happened.

### Suggesting features

- Open an [Issue](https://github.com/nafiskabbo/bangla-type/issues) with the **feature request** label (if available) or clearly state it’s a suggestion.
- Describe the use case and how it fits Bangladeshi Bangla typing.

### Pull requests

1. **Fork** the repo: [github.com/nafiskabbo/bangla-type](https://github.com/nafiskabbo/bangla-type).
2. **Clone** your fork and create a branch:  
   `git checkout -b fix/short-description` or `feature/short-description`.
3. **Build and test**:
   ```bash
   xcodebuild -scheme banglatype -configuration Debug -derivedDataPath build build test
   ```
4. **Commit** with clear messages (e.g. `Fix layout recursion in Preferences window`).
5. **Push** to your fork and open a **Pull Request** against `main`.
6. In the PR description, explain what changed and why.

---

## Scope policy

- **In scope:** Bangladeshi Bangla layouts, Avro Phonetic, Bangladeshi dictionary/autocorrect, macOS input method behaviour, UI/UX for Bangladeshi users.
- **Out of scope:** Indian regional layouts (e.g. Inscript, Disha), West Bengali–specific vocabulary or behaviour that conflicts with Bangladesh standard. This is a deliberate focus, not a limitation.

---

## Development setup

- **Xcode:** 15+ (or latest stable).
- **macOS:** 13 (Ventura) or later.
- **Clone and open:**  
  `git clone https://github.com/nafiskabbo/bangla-type.git && cd bangla-type && open banglatype.xcodeproj`
- **Run:** Select the `banglatype` scheme and Run. To test as an input method, install the built app to `/Library/Input Methods/` and log out/in (see [Installation](https://github.com/nafiskabbo/bangla-type#-how-to-install) in the README).

---

## Areas where help is welcome

- **Dictionary:** Adding more Bangladeshi Bangla words (e.g. via `tools/wordlist_bd.txt` or `tools/bangla_words_data.py`) and improving autocorrect.
- **Layouts:** Fixes or improvements to bundled `.avrolayout` files.
- **Documentation:** Improving README, docs, or comments in code.
- **Testing:** Testing on different macOS versions and reporting issues.

---

## License

By contributing, you agree that your contributions will be licensed under the same **GPL-3.0** license as the project. See [LICENSE](LICENSE).

---

**বাংলাদেশের জন্য, বাংলাদেশিদের দ্বারা তৈরি ❤️ 🇧🇩**
