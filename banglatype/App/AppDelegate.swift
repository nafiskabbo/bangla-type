//
//  AppDelegate.swift
//  BanglaType
//
//  IMKServer MUST be a global var — required by InputMethodKit.
//

import AppKit
import InputMethodKit

var server: IMKServer = IMKServer(
    name: Bundle.main.infoDictionary?["InputMethodConnectionName"] as? String,
    bundleIdentifier: Bundle.main.bundleIdentifier
)

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        HotkeyManager.shared.onLayoutHUD = { LayoutSwitcherHUDController.shared.show() }
        HotkeyManager.shared.onPreferences = { PreferencesWindowController.shared.show() }
        HotkeyManager.shared.onOnScreenKeyboard = { OnScreenKeyboardController.shared.toggle() }
        HotkeyManager.shared.start()
        MenuBarController.shared.onOpenPreferences = { PreferencesWindowController.shared.show() }
        MenuBarController.shared.onOpenOnScreenKeyboard = { OnScreenKeyboardController.shared.toggle() }
        MenuBarController.shared.setup()
        PerAppLayoutMemory.shared.start()
    }
}
