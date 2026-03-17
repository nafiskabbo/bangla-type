//
//  ThemeManager.swift
//  BanglaType
//
//  System / Light / Dark; persists to UserDefaults, updates NSAppearance.
//

import AppKit
import Combine

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    @Published var currentTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "BanglaTypeTheme")
            apply()
        }
    }

    private init() {
        let raw = UserDefaults.standard.string(forKey: "BanglaTypeTheme") ?? AppTheme.system.rawValue
        currentTheme = AppTheme(rawValue: raw) ?? .system
        apply()
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            self?.apply()
        }
    }

    func apply() {
        let appearance: NSAppearance?
        switch currentTheme {
        case .system: appearance = nil
        case .light: appearance = NSAppearance(named: .aqua)
        case .dark: appearance = NSAppearance(named: .darkAqua)
        }
        NSApp.appearance = appearance
    }
}
