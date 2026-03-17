//
//  OnScreenKeyboardController.swift
//  BanglaType
//
//  Floating panel for on-screen keyboard; toggle visibility.
//

import AppKit
import SwiftUI

final class OnScreenKeyboardController: NSObject {
    static let shared = OnScreenKeyboardController()
    private var panel: NSPanel?
    private var hostingView: NSHostingView<OnScreenKeyboardView>?

    func toggle() {
        if panel?.isVisible == true {
            close()
        } else {
            show()
        }
    }

    func show() {
        DispatchQueue.main.async { [weak self] in
            self?.showOnMain()
        }
    }

    private func showOnMain() {
        if panel == nil {
            let vm = LayoutManager.shared.currentKeyboardViewModel()
            let content = OnScreenKeyboardView(viewModel: vm, onKeyPress: { [weak self] char in
                self?.insertCharacter(char)
            })
            let hosting = NSHostingView(rootView: content)
            hosting.frame = NSRect(x: 0, y: 0, width: 800, height: 280)
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 800, height: 280),
                styleMask: [.titled, .closable, .nonactivatingPanel],
                backing: .buffered,
                defer: false
            )
            panel.title = "BanglaType Keyboard"
            panel.isFloatingPanel = true
            panel.level = .floating
            panel.contentView = hosting
            self.panel = panel
            self.hostingView = hosting
        }
        panel?.contentView = hostingView
        if let hostingView = hostingView {
            let vm = LayoutManager.shared.currentKeyboardViewModel()
            hostingView.rootView = OnScreenKeyboardView(viewModel: vm, onKeyPress: { [weak self] char in
                self?.insertCharacter(char)
            })
        }
        panel?.orderFrontRegardless()
        if let screen = NSScreen.main {
            let f = screen.visibleFrame
            panel?.setFrameOrigin(NSPoint(x: f.midX - 400, y: f.midY - 140))
        }
    }

    func close() {
        panel?.orderOut(nil)
    }

    private func insertCharacter(_ character: String) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(character, forType: .string)
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
}
