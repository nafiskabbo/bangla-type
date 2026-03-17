//
//  PerAppLayoutMemory.swift
//  BanglaType
//
//  Saves/restores layout index per active app bundle ID.
//

import AppKit

final class PerAppLayoutMemory {
    static let shared = PerAppLayoutMemory()
    private var lastBundleId: String?
    private let key = "BanglaTypePerAppLayout"

    var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "BanglaTypePerAppLayoutEnabled") as? Bool ?? false }
        set { UserDefaults.standard.set(newValue, forKey: "BanglaTypePerAppLayoutEnabled") }
    }

    private init() {}

    func start() {
        NotificationCenter.default.addObserver(self, selector: #selector(appActivated), name: NSWorkspace.didActivateApplicationNotification, object: nil)
    }

    @objc private func appActivated(_ notification: Notification) {
        guard isEnabled,
              let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else { return }
        if let previous = lastBundleId, previous != bundleId {
            let idx = LayoutManager.shared.activeLayoutIndex
            var dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Int] ?? [:]
            dict[previous] = idx
            UserDefaults.standard.set(dict, forKey: key)
        }
        lastBundleId = bundleId
        if let dict = UserDefaults.standard.dictionary(forKey: key) as? [String: Int],
           let saved = dict[bundleId],
           saved >= 0,
           saved < LayoutManager.shared.layoutCount {
            LayoutManager.shared.switchToLayout(index: saved)
        }
    }
}
