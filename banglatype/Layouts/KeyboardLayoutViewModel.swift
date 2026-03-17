//
//  KeyboardLayoutViewModel.swift
//  BanglaType
//
//  Converts FixedLayout keyMap into QWERTY rows for on-screen keyboard.
//

import Foundation

struct KeyViewModel {
    let physicalLabel: String
    let normalChar: String
    let shiftChar: String
    let altGrChar: String
}

struct KeyboardLayoutViewModel {
    let rows: [[KeyViewModel]]

    static func from(layout: FixedLayout) -> KeyboardLayoutViewModel {
        let row1Keys = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
        let row2Keys = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
        let row3Keys = ["z", "x", "c", "v", "b", "n", "m"]
        func row(for keys: [String]) -> [KeyViewModel] {
            keys.map { key in
                let entry = layout.keyMap[key] ?? KeyEntry(normal: key, shift: key.uppercased(), altGr: "", shiftAltGr: "")
                return KeyViewModel(
                    physicalLabel: key,
                    normalChar: entry.normal.isEmpty ? key : entry.normal,
                    shiftChar: entry.shift.isEmpty ? key.uppercased() : entry.shift,
                    altGrChar: entry.altGr
                )
            }
        }
        return KeyboardLayoutViewModel(rows: [
            row(for: row1Keys),
            row(for: row2Keys),
            row(for: row3Keys),
        ])
    }

    static var qwertyPlaceholder: KeyboardLayoutViewModel {
        let layout = FixedLayout(layoutName: "QWERTY", layoutType: "fixed", keyMap: [:])
        return from(layout: layout)
    }
}
