//
//  PhoneticEngine.swift
//  BanglaType
//
//  Avro Phonetic–style transliteration (Bangladeshi standard). Longest-match rules.
//

import AppKit
import Foundation

/// Avro Phonetic–compatible engine. Returns .compose for preview, .commit on space/enter.
final class PhoneticEngine: LayoutEngineProtocol {
    private var buffer: String = ""

    func process(key: String, modifiers: NSEvent.ModifierFlags) -> LayoutOutput {
        if key == " " || key == "\n" || key == "\r" {
            let out = commitCurrentWord()
            if !out.isEmpty {
                return .commit(out)
            }
            return .passthrough
        }
        buffer.append(key)
        let bangla = transliterate(buffer)
        return .compose(bangla)
    }

    func transliterate(_ input: String) -> String {
        var s = input
        var out = ""
        while !s.isEmpty {
            let (optStr, len) = longestMatch(s)
            if len > 0, let str = optStr {
                out.append(str)
                s = String(s.dropFirst(len))
            } else {
                out.append(s.first!)
                s = String(s.dropFirst(1))
            }
        }
        return out
    }

    private func commitCurrentWord() -> String {
        let result = transliterate(buffer)
        buffer = ""
        return result
    }

    private func longestMatch(_ s: String) -> (String?, Int) {
        let keys = AvroRules.patterns.keys.sorted { $0.count > $1.count }
        for key in keys {
            if s.hasPrefix(key), let str = AvroRules.patterns[key] {
                return (str, key.count)
            }
        }
        return (nil, 0)
    }
}

private enum AvroRules {
    static let patterns: [String: String] = [
        "kkh": "\u{0995}\u{09CD}\u{0996}",
        "ndr": "\u{09A8}\u{09CD}\u{09A6}\u{09CD}\u{09B0}",
        "ksh": "\u{0995}\u{09CD}\u{09B7}",
        "kk": "\u{0995}\u{09CD}\u{0995}",
        "kh": "\u{0996}",
        "gh": "\u{0998}",
        "ng": "\u{0999}",
        "ch": "\u{099A}",
        "jh": "\u{099C}",
        "Th": "\u{099F}\u{09CD}\u{09A0}",
        "Dh": "\u{09A1}\u{09CD}\u{09A2}",
        "th": "\u{09A5}",
        "dh": "\u{09A6}",
        "ph": "\u{09AB}",
        "bh": "\u{09AD}",
        "rr": "\u{09DC}",
        "sh": "\u{09B6}",
        "Sh": "\u{09B7}",
        "kt": "\u{0995}\u{09CD}\u{09A4}",
        "k": "\u{0995}",
        "g": "\u{0997}",
        "c": "\u{099A}",
        "j": "\u{099C}",
        "T": "\u{099F}",
        "D": "\u{09A1}",
        "N": "\u{09A3}",
        "t": "\u{09A4}",
        "d": "\u{09A6}",
        "n": "\u{09A8}",
        "p": "\u{09AA}",
        "b": "\u{09AC}",
        "m": "\u{09AE}",
        "z": "\u{09AF}",
        "r": "\u{09B0}",
        "l": "\u{09B2}",
        "S": "\u{09B7}",
        "s": "\u{09B8}",
        "h": "\u{09B9}",
        "R": "\u{09DC}",
        "y": "\u{09DF}",
        "OU": "\u{0994}",
        "OI": "\u{0990}",
        "aa": "\u{0986}",
        "i": "\u{0987}",
        "I": "\u{0988}",
        "ee": "\u{0988}",
        "u": "\u{0989}",
        "U": "\u{098A}",
        "oo": "\u{098A}",
        "e": "\u{098F}",
        "O": "\u{0993}",
        "o": "\u{0985}",
        "a": "\u{0986}",
    ]
}

