//
//  PhoneticEngineTests.swift
//  BanglaType
//

import Testing
@testable import BanglaType

struct PhoneticEngineTests {
    @Test func vowels() {
        let e = PhoneticEngine()
        var out: String
        out = e.transliterate("a")
        #expect(out == "আ")
        out = e.transliterate("aa")
        #expect(out == "আ")
        out = e.transliterate("i")
        #expect(out == "ই")
        out = e.transliterate("u")
        #expect(out == "উ")
        out = e.transliterate("e")
        #expect(out == "এ")
        out = e.transliterate("o")
        #expect(out == "অ")
    }

    @Test func consonants() {
        let e = PhoneticEngine()
        #expect(e.transliterate("k") == "ক")
        #expect(e.transliterate("kh") == "খ")
        #expect(e.transliterate("g") == "গ")
        #expect(e.transliterate("b") == "ব")
        #expect(e.transliterate("m") == "ম")
        #expect(e.transliterate("n") == "ন")
    }

    @Test func wordAmar() {
        let e = PhoneticEngine()
        let out = e.transliterate("amar")
        #expect(out.contains("আ") && out.contains("ম") && out.contains("র"))
    }

    @Test func juktakshar() {
        let e = PhoneticEngine()
        #expect(e.transliterate("kk") == "ক্ক")
        #expect(e.transliterate("kt") == "ক্ত")
        #expect(e.transliterate("ng") == "ং" || e.transliterate("ng").contains("ং"))
    }

    @Test func bangladeshiWords() {
        let e = PhoneticEngine()
        let bangladesh = e.transliterate("bangladesh")
        #expect(bangladesh.contains("ব") && bangladesh.contains("ং"))
        let dhaka = e.transliterate("dhaka")
        #expect(dhaka.contains("ঢ") || dhaka.contains("ধ"))
    }

    @Test func karVowels() {
        let e = PhoneticEngine()
        #expect(e.transliterate("ka") == "কা" || e.transliterate("ka").hasPrefix("ক"))
        #expect(e.transliterate("ki").contains("ক") && e.transliterate("ki").contains("ি"))
    }
}
