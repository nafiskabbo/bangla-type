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

    static func layoutIndex(forInputSourceID id: String) -> Int? {
        all.firstIndex(of: id)
    }
}

final class InputSourceModeCoordinator {
    static let shared = InputSourceModeCoordinator()

    private var syncingFromSystem = false

    private init() {}

    /// Avoid calling TIS when the app is the XCTest host (would be meaningless and can confuse tests).
    private var isRunningAsXCTestHost: Bool {
        NSClassFromString("XCTestCase") != nil
    }

    /// Read the active keyboard input source and align `LayoutManager` (no TIS select).
    func syncLayoutIndexFromSystem() {
        guard !isRunningAsXCTestHost else { return }
        guard let id = currentKeyboardInputSourceID(),
              let idx = BanglaInputModeIDs.layoutIndex(forInputSourceID: id) else { return }
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
        guard currentKeyboardInputSourceID() != targetID else { return }
        selectInputSource(withID: targetID)
    }

    private func currentKeyboardInputSourceID() -> String? {
        guard let current = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() else { return nil }
        guard let ptr = TISGetInputSourceProperty(current, kTISPropertyInputSourceID) else { return nil }
        return Unmanaged<CFString>.fromOpaque(ptr).takeUnretainedValue() as String
    }

    private func selectInputSource(withID modeID: String) {
        let filter: [CFString: Any] = [kTISPropertyInputSourceID: modeID as CFString]
        guard let list = TISCreateInputSourceList(filter as CFDictionary, false)?.takeRetainedValue() as? [TISInputSource],
              let source = list.first else { return }
        TISSelectInputSource(source)
    }
}
