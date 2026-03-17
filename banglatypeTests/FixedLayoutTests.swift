//
//  FixedLayoutTests.swift
//  BanglaType
//

import AppKit
import Testing
@testable import BanglaType

struct FixedLayoutTests {
    @Test func probhatCommonKeys() {
        let mgr = LayoutManager.shared
        #expect(mgr.layoutCount >= 1)
        // Switch to first fixed layout (index 1 = Probhat) if available
        if mgr.layoutCount > 1 {
            mgr.activeLayoutIndex = 1
            let engine = mgr.activeEngine
            let out = engine.process(key: "a", modifiers: [])
            switch out {
            case .commit(let s): #expect(!s.isEmpty && s.unicodeScalars.first != nil)
            case .compose(let s): #expect(!s.isEmpty)
            case .passthrough, .consumed: break
            }
            mgr.activeLayoutIndex = 0
        }
    }

    @Test func fixedLayoutCommitOrCompose() {
        let mgr = LayoutManager.shared
        for idx in 0..<min(mgr.layoutCount, 3) {
            mgr.activeLayoutIndex = idx
            let engine = mgr.activeEngine
            let out = engine.process(key: "k", modifiers: [])
            switch out {
            case .commit(let s): #expect(!s.isEmpty)
            case .compose(let s): #expect(!s.isEmpty)
            case .passthrough, .consumed: break
            }
        }
        mgr.activeLayoutIndex = 0
    }
}
