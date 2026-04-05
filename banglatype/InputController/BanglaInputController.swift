//
//  BanglaInputController.swift
//  BanglaType
//
//  IMKInputController subclass — class name must match Info.plist exactly.
//

import AppKit
import InputMethodKit

@objc(BanglaInputController)
final class BanglaInputController: IMKInputController, ComposingBufferDelegate {

    private let composingBuffer: ComposingBuffer = {
        let b = ComposingBuffer()
        return b
    }()
    private let candidateController = CandidateController()

    private func setupBufferDelegateIfNeeded() {
        if composingBuffer.delegate == nil { composingBuffer.delegate = self }
    }

    func onBufferChanged(text: String) {
        _ = text
        updateComposition()
    }

    /// IMK uses this when pushing marked text to the client; must match our composing buffer.
    override func composedString(_ sender: Any!) -> Any! {
        composingBuffer.text as NSString
    }

    /// Only skip IM processing for real secure fields. Many IMK clients (e.g. web views) report
    /// `selectedRange.location == NSNotFound` for normal text; treating that as "secure" broke all typing.
    private func isSecureTextInput(_ sender: Any?) -> Bool {
        guard let o = sender as AnyObject? else { return false }
        return String(describing: type(of: o)).contains("SecureText")
    }

    override func recognizedEvents(_ sender: Any!) -> Int {
        Int(NSEvent.EventTypeMask.keyDown.rawValue)
    }

    override func activateServer(_ sender: Any!) {
        super.activateServer(sender)
        InputSourceModeCoordinator.shared.syncLayoutIndexFromSystem()
    }

    override func deactivateServer(_ sender: Any!) {
        composingBuffer.deleteAll()
        LayoutManager.shared.resetPhoneticEngineBufferIfNeeded()
        super.deactivateServer(sender)
    }

    override func commitComposition(_ sender: Any!) {
        setupBufferDelegateIfNeeded()
        guard let client = client() as? IMKTextInput else {
            super.commitComposition(sender)
            return
        }
        let text = composingBuffer.commit()
        LayoutManager.shared.resetPhoneticEngineBufferIfNeeded()
        if !text.isEmpty {
            client.insertText(text.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
        }
        updateComposition()
    }

    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        guard let ev = event, let client = sender as? IMKTextInput else { return false }
        if isSecureTextInput(sender) { return false }
        setupBufferDelegateIfNeeded()
        guard ev.type == .keyDown else { return false }

        let modifiers = ev.modifierFlags.intersection(.deviceIndependentFlagsMask)
        if modifiers.contains(.command) || modifiers.contains(.control) {
            return handleShortcut(ev, client: client)
        }

        let key = (ev.characters?.isEmpty == false ? ev.characters : nil)
            ?? ev.charactersIgnoringModifiers
            ?? ""
        if key.isEmpty {
            if ev.keyCode == 36 {
                commitComposition(client: client)
                return true
            }
            if ev.keyCode == 49 {
                commitComposition(client: client)
                return true
            }
            return false
        }

        let engine = LayoutManager.shared.activeEngine
        let output = engine.process(key: key, modifiers: modifiers)

        switch output {
        case .commit(let str):
            return applyCommit(str, client: client)
        case .compose(let str):
            if LayoutManager.shared.activeEngine is PhoneticEngine {
                composingBuffer.setContents(str)
            } else {
                composingBuffer.append(string: str)
            }
            return true
        case .passthrough:
            if composingBuffer.text.isEmpty {
                return false
            }
            commitComposition(client: client)
            return false
        case .consumed:
            return true
        }
    }

    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        guard let s = string, !s.isEmpty, let client = sender as? IMKTextInput else { return false }
        if isSecureTextInput(sender) { return false }
        setupBufferDelegateIfNeeded()
        let engine = LayoutManager.shared.activeEngine
        let output = engine.process(key: s, modifiers: [])
        switch output {
        case .commit(let str):
            return applyCommit(str, client: client)
        case .compose(let str):
            if LayoutManager.shared.activeEngine is PhoneticEngine {
                composingBuffer.setContents(str)
            } else {
                composingBuffer.append(string: str)
            }
            return true
        case .passthrough, .consumed:
            return false
        }
    }

    override func didCommand(by selector: Selector, client sender: Any!) -> Bool {
        guard let client = sender as? IMKTextInput else { return false }
        if selector == #selector(NSText.deleteBackward(_:)) {
            let modifiers = NSEvent.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if modifiers.contains(.option) && !composingBuffer.text.isEmpty {
                composingBuffer.deleteLastCluster()
                return true
            }
            if modifiers.contains(.command) {
                composingBuffer.deleteAll()
                return true
            }
            if !composingBuffer.text.isEmpty {
                composingBuffer.deleteLastScalar()
                return true
            }
            return false
        }
        if selector == #selector(NSResponder.cancelOperation(_:)) {
            composingBuffer.deleteAll()
            return true
        }
        return false
    }

    private func handleShortcut(_ event: NSEvent, client: IMKTextInput) -> Bool {
        false
    }

    /// Single insert path for committed text; clears IMK composing state.
    private func applyCommit(_ str: String, client: IMKTextInput) -> Bool {
        composingBuffer.deleteAll()
        LayoutManager.shared.resetPhoneticEngineBufferIfNeeded()
        updateComposition()
        if !str.isEmpty {
            client.insertText(str.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
        }
        return true
    }

    private func commitComposition(client: IMKTextInput) {
        let text = composingBuffer.commit()
        LayoutManager.shared.resetPhoneticEngineBufferIfNeeded()
        if !text.isEmpty {
            client.insertText(text.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
        }
    }
}
