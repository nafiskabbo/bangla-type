//
//  ShortcutsPreferencesView.swift
//  BanglaType
//

import SwiftUI

struct ShortcutsPreferencesView: View {
    var body: some View {
        Form {
            ShortcutRow(action: "Toggle Bangla / English", binding: HotkeyManager.shared.binding(for: .toggle))
            ShortcutRow(action: "Layout switcher HUD", binding: HotkeyManager.shared.binding(for: .layoutHUD))
            ShortcutRow(action: "Preferences", binding: HotkeyManager.shared.binding(for: .preferences))
            ShortcutRow(action: "On-Screen Keyboard", binding: HotkeyManager.shared.binding(for: .onScreenKeyboard))
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct ShortcutRow: View {
    let action: String
    let binding: String
    @State private var isRecording = false

    var body: some View {
        HStack {
            Text(action)
            Spacer()
            Text(binding)
                .foregroundColor(.secondary)
                .padding(8)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
        }
    }
}
