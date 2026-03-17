//
//  DictionaryTests.swift
//  BanglaType
//

import Testing
@testable import BanglaType

struct DictionaryTests {
    @Test func suggestionsEmptyPrefix() {
        let result = BanglaDictionary.shared.suggestions(for: "", limit: 5)
        #expect(result.isEmpty)
    }

    @Test func suggestionsWithPrefix() {
        let result = BanglaDictionary.shared.suggestions(for: "আম", limit: 5)
        #expect(result.count <= 5)
        for word in result {
            #expect(word.hasPrefix("আম"))
        }
    }

    @Test func autocorrectKnown() {
        let out = BanglaDictionary.shared.autocorrect(for: "bangladesh")
        #expect(out == "বাংলাদেশ")
    }

    @Test func autocorrectUnknown() {
        let out = BanglaDictionary.shared.autocorrect(for: "xyznonexistent")
        #expect(out == nil)
    }

    @Test func autocorrectCaseInsensitive() {
        let out = BanglaDictionary.shared.autocorrect(for: "Facebook")
        #expect(out == "ফেসবুক")
    }
}
