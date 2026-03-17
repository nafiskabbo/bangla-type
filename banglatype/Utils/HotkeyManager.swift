//
//  HotkeyManager.swift
//  BanglaType
//
//  Global hotkeys via CGEvent tap. Re-registers after sleep/lock.
//

import AppKit
import Carbon.HIToolbox

final class HotkeyManager {
    static let shared = HotkeyManager()
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let queue = DispatchQueue(label: "com.banglatype.hotkey")

    enum Action: String, CaseIterable {
        case toggle = "toggle"
        case layoutHUD = "layoutHUD"
        case preferences = "preferences"
        case onScreenKeyboard = "onScreenKeyboard"
    }

    private let defaultBindings: [Action: String] = [
        .toggle: "ctrl+space",
        .layoutHUD: "ctrl+\\",
        .preferences: "ctrl+,",
        .onScreenKeyboard: "ctrl+k",
    ]

    var onToggle: (() -> Void)?
    var onLayoutHUD: (() -> Void)?
    var onPreferences: (() -> Void)?
    var onOnScreenKeyboard: (() -> Void)?

    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(screenDidWake), name: NSApplication.didBecomeActiveNotification, object: nil)
    }

    func binding(for action: Action) -> String {
        UserDefaults.standard.string(forKey: "BanglaTypeHotkey_\(action.rawValue)") ?? defaultBindings[action] ?? ""
    }

    func setBinding(_ key: String, for action: Action) {
        UserDefaults.standard.set(key, forKey: "BanglaTypeHotkey_\(action.rawValue)")
        reregister()
    }

    func start() {
        queue.async { [weak self] in
            self?.registerTap()
        }
    }

    func stop() {
        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func registerTap() {
        stop()
        let eventMask = (1 << CGEventType.keyDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { _, _, event, context in
                guard let ctx = context else { return Unmanaged.passUnretained(event) }
                let manager = Unmanaged<HotkeyManager>.fromOpaque(ctx).takeUnretainedValue()
                return manager.handleEvent(event)
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return
        }
        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func handleEvent(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = Int(event.getIntegerValueField(.keyboardEventKeycode))
        let flags = event.flags
        let ctrl = flags.contains(.maskControl)
        let alt = flags.contains(.maskAlternate)
        let cmd = flags.contains(.maskCommand)
        let shift = flags.contains(.maskShift)
        let key = keyString(keyCode: keyCode, ctrl: ctrl, alt: alt, cmd: cmd, shift: shift)
        if didMatchBinding(key) {
            DispatchQueue.main.async { [weak self] in
                self?.dispatch(key: key)
            }
            return nil
        }
        return Unmanaged.passUnretained(event)
    }

    private func didMatchBinding(_ key: String) -> Bool {
        Action.allCases.contains { binding(for: $0) == key }
    }

    private func dispatch(key: String) {
        if key == binding(for: .toggle) { onToggle?() }
        else if key == binding(for: .layoutHUD) { onLayoutHUD?() }
        else if key == binding(for: .preferences) { onPreferences?() }
        else if key == binding(for: .onScreenKeyboard) { onOnScreenKeyboard?() }
    }

    private func keyString(keyCode: Int, ctrl: Bool, alt: Bool, cmd: Bool, shift: Bool) -> String {
        var parts: [String] = []
        if ctrl { parts.append("ctrl") }
        if alt { parts.append("alt") }
        if cmd { parts.append("cmd") }
        if shift { parts.append("shift") }
        let keyName: String
        switch keyCode {
        case kVK_Space: keyName = "space"
        case kVK_ANSI_Backslash: keyName = "\\"
        case kVK_ANSI_Comma: keyName = ","
        case kVK_ANSI_K: keyName = "k"
        default: keyName = String(format: "%d", keyCode)
        }
        parts.append(keyName)
        return parts.joined(separator: "+")
    }

    private func reregister() {
        queue.async { [weak self] in
            self?.registerTap()
        }
    }

    @objc private func screenDidWake() {
        reregister()
    }
}
