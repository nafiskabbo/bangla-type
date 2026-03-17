//
//  FixedLayoutEngine.swift
//  BanglaType
//
//  Maps key + modifiers to character from .avrolayout keyMap.
//

import AppKit

final class FixedLayoutEngine: LayoutEngineProtocol {
    private let layout: FixedLayout
    private let hasanta: Unicode.Scalar = "\u{09CD}"

    init(layout: FixedLayout) {
        self.layout = layout
    }

    func process(key: String, modifiers: NSEvent.ModifierFlags) -> LayoutOutput {
        let keyCode = keyToKeyCode(key)
        guard let entry = layout.keyMap[keyCode] else { return .passthrough }
        let char: String
        if modifiers.contains([.shift, .option]) {
            char = entry.shiftAltGr
        } else if modifiers.contains(.option) {
            char = entry.altGr
        } else if modifiers.contains(.shift) {
            char = entry.shift
        } else {
            char = entry.normal
        }
        if char.isEmpty { return .passthrough }
        if char.unicodeScalars.first == hasanta {
            return .compose(char)
        }
        return .commit(char)
    }

    private func keyToKeyCode(_ key: String) -> String {
        if key.count == 1 {
            return key.lowercased()
        }
        return key
    }
}
