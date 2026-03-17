//
//  BanglaDictionary.swift
//  BanglaType
//
//  Bangladeshi Bangla word suggestions and autocorrect via SQLite.
//

import Foundation
import SQLite3

final class BanglaDictionary {
    static let shared = BanglaDictionary()
    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "com.banglatype.dictionary")

    private init() {}

    func suggestions(for prefix: String, limit: Int = 5) -> [String] {
        guard !prefix.isEmpty else { return [] }
        return queue.sync {
            guard let db = openDB() else { return [] }
            var stmt: OpaquePointer?
            let sql = "SELECT word FROM words WHERE word LIKE ? ORDER BY frequency DESC LIMIT ?"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
            defer { sqlite3_finalize(stmt) }
            let pattern = prefix + "%"
            pattern.utf8CString.withUnsafeBufferPointer { buf in
                sqlite3_bind_text(stmt, 1, buf.baseAddress, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
            }
            sqlite3_bind_int(stmt, 2, Int32(limit))
            var result: [String] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let c = sqlite3_column_text(stmt, 0) {
                    result.append(String(cString: c))
                }
            }
            return result
        }
    }

    func autocorrect(for romanized: String) -> String? {
        AutocorrectBD.loadedTable[romanized.lowercased()]
    }

    private func openDB() -> OpaquePointer? {
        if db != nil { return db }
        guard let path = Bundle.main.path(forResource: "bd_bangla_words", ofType: "db", inDirectory: nil),
              sqlite3_open(path, &db) == SQLITE_OK else { return nil }
        return db
    }
}

private enum AutocorrectBD {
    static let loadedTable: [String: String] = loadAutocorrectTable()

    static func loadAutocorrectTable() -> [String: String] {
        var table: [String: String] = [
            "facebook": "ফেসবুক", "upazila": "উপজেলা", "bangladesh": "বাংলাদেশ",
        ]
        guard let url = Bundle.main.url(forResource: "autocorrect_bd", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: String] else {
            return table
        }
        table.merge(json) { _, new in new }
        return table
    }
}
