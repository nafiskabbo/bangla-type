//
//  AvroLayoutParser.swift
//  BanglaType
//
//  Parses Avro Keyboard Layout v5 JSON (.avrolayout).
//

import Foundation

struct KeyEntry {
    let normal: String
    let shift: String
    let altGr: String
    let shiftAltGr: String
}

struct FixedLayout {
    let layoutName: String
    let layoutType: String
    let keyMap: [String: KeyEntry]
}

enum AvroLayoutParser {
    static func parse(data: Data) throws -> FixedLayout {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let dict = json else { throw NSError(domain: "AvroLayoutParser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON"]) }
        let name = dict["layout_name"] as? String ?? ""
        let type = dict["layout_type"] as? String ?? "fixed"
        let keysDict = dict["keys"] as? [String: [String: String]] ?? [:]
        var keyMap: [String: KeyEntry] = [:]
        for (keyCode, layers) in keysDict {
            let n = layers["normal"] ?? ""
            let s = layers["shift"] ?? ""
            let a = layers["altgr"] ?? ""
            let sa = layers["shift_altgr"] ?? ""
            keyMap[keyCode] = KeyEntry(normal: n, shift: s, altGr: a, shiftAltGr: sa)
        }
        return FixedLayout(layoutName: name, layoutType: type, keyMap: keyMap)
    }

    static func parse(url: URL) throws -> FixedLayout {
        let data = try Data(contentsOf: url)
        return try parse(data: data)
    }
}
