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
        guard let client = client() as? IMKTextInput else { return }
        client.setMarkedText(NSAttributedString(string: text), selectionRange: NSRange(location: text.count, length: 0), replacementRange: NSRange(location: NSNotFound, length: 0))
    }

    /// Secure text (e.g. password fields): selectedRange is often {NSNotFound, 0}. Don't compose; passthrough.
    private func isSecureTextInput(_ sender: Any?) -> Bool {
        guard let client = sender as? NSTextInputClient else { return false }
        let r = client.selectedRange()
        return r.location == NSNotFound && r.length == 0
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

        let key = ev.characters ?? ""
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
            if !composingBuffer.text.isEmpty {
                let committed = composingBuffer.commit()
                client.insertText(committed.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
            if !str.isEmpty {
                client.insertText(str.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
            return true
        case .compose(let str):
            composingBuffer.append(string: str)
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
        guard let s = string, let client = sender as? IMKTextInput else { return false }
        if isSecureTextInput(sender) { return false }
        setupBufferDelegateIfNeeded()
        let engine = LayoutManager.shared.activeEngine
        let output = engine.process(key: s, modifiers: [])
        switch output {
        case .commit(let str):
            if !composingBuffer.text.isEmpty {
                let committed = composingBuffer.commit()
                client.insertText(committed.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
            }
            client.insertText(str.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
            return true
        case .compose(let str):
            composingBuffer.append(string: str)
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
        return false
    }

    private func commitComposition(client: IMKTextInput) {
        let text = composingBuffer.commit()
        if !text.isEmpty {
            client.insertText(text.precomposedStringWithCanonicalMapping, replacementRange: NSRange(location: NSNotFound, length: 0))
        }
    }
}
