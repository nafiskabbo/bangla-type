//
//  LayoutParserTests.swift
//  BanglaType
//

import Foundation
import Testing
@testable import BanglaType

struct LayoutParserTests {
    @Test func parseProbhatStyle() throws {
        let json = """
        {"layout_name":"Test","layout_type":"fixed","keys":{"a":{"normal":"আ","shift":"","altgr":"","shift_altgr":""},"b":{"normal":"ব","shift":"ভ","altgr":"","shift_altgr":""}}}
        """
        let data = json.data(using: .utf8)!
        let layout = try AvroLayoutParser.parse(data: data)
        #expect(layout.layoutName == "Test")
        #expect(layout.keyMap["a"]?.normal == "আ")
        #expect(layout.keyMap["b"]?.normal == "ব")
        #expect(layout.keyMap["b"]?.shift == "ভ")
    }

    @Test func parseAllBundledLayouts() throws {
        let bundle = Bundle(for: BanglaInputController.self)
        let names = ["probhat", "munir_optima", "avro_easy", "bornona", "national_jatiya", "akkhor"]
        for name in names {
            guard let url = bundle.url(forResource: name, withExtension: "avrolayout", subdirectory: nil),
                  let data = try? Data(contentsOf: url) else { continue }
            let layout = try AvroLayoutParser.parse(data: data)
            #expect(!layout.layoutName.isEmpty)
            #expect(!layout.keyMap.isEmpty)
        }
    }
}
