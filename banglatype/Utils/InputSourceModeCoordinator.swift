//
//  InputSourceModeCoordinator.swift
//  BanglaType
//
//  Maps TIS input-mode IDs (Info.plist ComponentInputModeDict) to layout indices.
//

import AppKit
import Carbon

/// Input mode IDs must match `ComponentInputModeDict` → `tsInputModeListKey` keys in Info.plist.
enum BanglaInputModeIDs {
    static let all: [String] = [
        "com.banglatype.inputmethod.BanglaType.AvroPhonetic",
        "com.banglatype.inputmethod.BanglaType.Probhat",
        "com.banglatype.inputmethod.BanglaType.MunirOptima",
        "com.banglatype.inputmethod.BanglaType.AvroEasy",
        "com.banglatype.inputmethod.BanglaType.Bornona",
        "com.banglatype.inputmethod.BanglaType.NationalJatiya",
        "com.banglatype.inputmethod.BanglaType.Akkhor",
    ]

    static func layoutIndex(forInputModeID id: String) -> Int? {
        all.firstIndex(of: id)
    }
}

final class InputSourceModeCoordinator {
    static let shared = InputSourceModeCoordinator()
    private static let fallbackBundleID = "com.banglatype.inputmethod.BanglaType"

    private var syncingFromSystem = false

    private init() {}

    /// Avoid calling TIS when the app is the XCTest host (would be meaningless and can confuse tests).
    private var isRunningAsXCTestHost: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    /// Read the active keyboard input source and align `LayoutManager` (no TIS select).
    func syncLayoutIndexFromSystem() {
        guard !isRunningAsXCTestHost else { return }
        guard let id = currentKeyboardInputModeID(),
              let idx = BanglaInputModeIDs.layoutIndex(forInputModeID: id) else { return }
        syncingFromSystem = true
        defer { syncingFromSystem = false }
        LayoutManager.shared.setActiveLayoutIndexFromSystem(idx)
    }

    /// When the user picks a layout in our UI, switch the system input mode so Input Sources stay in sync.
    func selectInputModeIfNeeded(layoutIndex index: Int) {
        guard !isRunningAsXCTestHost else { return }
        guard !syncingFromSystem else { return }
        guard index >= 0, index < BanglaInputModeIDs.all.count else { return }
        let targetID = BanglaInputModeIDs.all[index]
        guard currentKeyboardInputModeID() != targetID else { return }
        selectInputMode(withID: targetID)
    }

    private func currentKeyboardInputModeID() -> String? {
        guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        if let modeID = inputSourceStringProperty(current, key: kTISPropertyInputModeID) {
            return modeID
        }
        return inputSourceStringProperty(current, key: kTISPropertyInputSourceID)
    }

    private func inputSourceStringProperty(_ source: TISInputSource, key: CFString) -> String? {
        guard let ptr = TISGetInputSourceProperty(source, key) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private func selectInputMode(withID modeID: String) {
        let bundleID = Bundle.main.bundleIdentifier ?? Self.fallbackBundleID
        let exactFilter: [CFString: Any] = [
            kTISPropertyBundleID: bundleID as CFString,
            kTISPropertyInputModeID: modeID as CFString,
            kTISPropertyInputSourceType: kTISTypeKeyboardInputMode!
        ]

        let fallbackFilter: [CFString: Any] = [
            kTISPropertyInputModeID: modeID as CFString
        ]

        guard let source = firstMatchingInputSource(filter: exactFilter)
            ?? firstMatchingInputSource(filter: fallbackFilter) else { return }
        TISSelectInputSource(source)
    }

    private func firstMatchingInputSource(filter: [CFString: Any]) -> TISInputSource? {
        guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() as? [TISInputSource] else {
            return nil
        }
        return list.first
    }
}
