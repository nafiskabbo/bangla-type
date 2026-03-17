//
//  MenuBarController.swift
//  BanglaType
//
//  NSStatusItem: layout indicator, dropdown with layouts, Preferences, Quit.
//

import AppKit

final class MenuBarController: NSObject {
    static let shared = MenuBarController()
    private var statusItem: NSStatusItem?
    private let menu = NSMenu()
    private var layoutItems: [NSMenuItem] = []

    var isVisible: Bool {
        get { UserDefaults.standard.object(forKey: "BanglaTypeShowMenuBarIcon") as? Bool ?? true }
        set {
            UserDefaults.standard.set(newValue, forKey: "BanglaTypeShowMenuBarIcon")
            if newValue { setupStatusItem() } else { removeStatusItem() }
        }
    }

    var onOpenPreferences: (() -> Void)?
    var onOpenOnScreenKeyboard: (() -> Void)?

    private override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(layoutChanged), name: .banglaTypeLayoutChanged, object: nil)
    }

    func setup() {
        if isVisible { setupStatusItem() }
    }

    private func setupStatusItem() {
        guard statusItem == nil else {
            updateTitle()
            return
        }
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.target = self
        statusItem?.button?.action = #selector(statusItemClicked)
        updateTitle()
        rebuildMenu()
    }

    private func removeStatusItem() {
        if let item = statusItem {
            NSStatusBar.system.removeStatusItem(item)
        }
        statusItem = nil
    }

    private func updateTitle() {
        let title = menuTitleForCurrentLayout()
        statusItem?.button?.title = title
    }

    private func menuTitleForCurrentLayout() -> String {
        let idx = LayoutManager.shared.activeLayoutIndex
        guard let desc = LayoutManager.shared.layoutDescriptor(at: idx) else { return "বাং" }
        switch desc.id {
        case "avro_phonetic": return "বাং·অভ্র"
        case "probhat": return "বাং·প্র"
        case "munir_optima": return "বাং·মু"
        case "avro_easy": return "বাং·অভ্র ই"
        case "bornona": return "বাং·বর্ণ"
        case "national_jatiya": return "বাং·জাতীয়"
        case "akkhor": return "বাং·অক্ষর"
        default: return "বাং·\(desc.nameBn.prefix(2))"
        }
    }

    private func rebuildMenu() {
        menu.removeAllItems()
        layoutItems = []
        let count = LayoutManager.shared.layoutCount
        let active = LayoutManager.shared.activeLayoutIndex
        for i in 0..<count {
            guard let desc = LayoutManager.shared.layoutDescriptor(at: i) else { continue }
            let item = NSMenuItem(title: "\(desc.nameEn) — \(desc.nameBn)", action: #selector(layoutItemSelected(_:)), keyEquivalent: "")
            item.target = self
            item.tag = i
            item.state = (i == active) ? .on : .off
            menu.addItem(item)
            layoutItems.append(item)
        }
        menu.addItem(NSMenuItem.separator())
        let prefs = NSMenuItem(title: "Preferences…", action: #selector(openPreferences), keyEquivalent: ",")
        prefs.target = self
        prefs.keyEquivalentModifierMask = .control
        menu.addItem(prefs)
        let keyboard = NSMenuItem(title: "On-Screen Keyboard", action: #selector(openOnScreenKeyboard), keyEquivalent: "k")
        keyboard.target = self
        keyboard.keyEquivalentModifierMask = .control
        menu.addItem(keyboard)
        let updates = NSMenuItem(title: "Check for Updates…", action: #selector(checkForUpdates), keyEquivalent: "")
        updates.target = self
        menu.addItem(updates)
        menu.addItem(NSMenuItem.separator())
        let quit = NSMenuItem(title: "Quit BanglaType", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        quit.keyEquivalentModifierMask = .command
        menu.addItem(quit)
    }

    @objc private func statusItemClicked() {
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
    }

    @objc private func layoutItemSelected(_ sender: NSMenuItem) {
        LayoutManager.shared.switchToLayout(index: sender.tag)
    }

    @objc private func layoutChanged() {
        updateTitle()
        for (i, item) in layoutItems.enumerated() {
            item.state = (i == LayoutManager.shared.activeLayoutIndex) ? .on : .off
        }
    }

    @objc private func openPreferences() {
        onOpenPreferences?()
    }

    @objc private func openOnScreenKeyboard() {
        onOpenOnScreenKeyboard?()
    }

    @objc private func checkForUpdates() {
        let url = URL(string: "https://github.com/nafiskabbo/bangla-type/releases")!
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}
