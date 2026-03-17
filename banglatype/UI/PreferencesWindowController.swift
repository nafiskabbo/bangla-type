//
//  PreferencesWindowController.swift
//  BanglaType
//
//  NSWindow with SwiftUI TabView; 640×480, remembers position.
//

import AppKit
import SwiftUI

final class PreferencesWindowController: NSObject {
    static let shared = PreferencesWindowController()
    private var window: NSWindow?
    private let width: CGFloat = 640
    private let height: CGFloat = 480

    func show() {
        DispatchQueue.main.async { [weak self] in
            self?.showOnMain()
        }
    }

    private func showOnMain() {
        if window == nil {
            let content = PreferencesRootView()
            let hosting = NSHostingView(rootView: content)
            hosting.frame = NSRect(x: 0, y: 0, width: width, height: height)
            let container = HostingContainerView(frame: NSRect(x: 0, y: 0, width: width, height: height))
            container.hostingView = hosting
            hosting.autoresizingMask = [.width, .height]
            container.addSubview(hosting)
            let win = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: width, height: height),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            win.title = "BanglaType Preferences"
            win.contentView = container
            win.center()
            win.isReleasedWhenClosed = false
            win.delegate = self
            window = win
        }
        window?.makeKeyAndOrderFront(nil)
    }
}

extension PreferencesWindowController: NSWindowDelegate {}

/// Wrapper to avoid layout recursion: only set hosting view frame; do not call super.layout() so the hosting view is not laid out during this pass.
private final class HostingContainerView: NSView {
    weak var hostingView: NSView?
    override func layout() {
        if let h = hostingView {
            h.frame = bounds
        }
    }
}

struct PreferencesRootView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralPreferencesView().tabItem { Label("General", systemImage: "gear") }.tag(0)
            AppearancePreferencesView().tabItem { Label("Appearance", systemImage: "paintbrush") }.tag(1)
            ShortcutsPreferencesView().tabItem { Label("Shortcuts", systemImage: "keyboard") }.tag(2)
            LayoutsPreferencesView().tabItem { Label("Layouts", systemImage: "list.bullet") }.tag(3)
            PhoneticPreferencesView().tabItem { Label("Phonetic", systemImage: "character.book.closed") }.tag(4)
            DictionaryPreferencesView().tabItem { Label("Dictionary", systemImage: "book") }.tag(5)
            AdvancedPreferencesView().tabItem { Label("Advanced", systemImage: "slider.horizontal.3") }.tag(6)
            AboutPreferencesView().tabItem { Label("About", systemImage: "info.circle") }.tag(7)
        }
        .frame(width: 640, height: 480)
    }
}
