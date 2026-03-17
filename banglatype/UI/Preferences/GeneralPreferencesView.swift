//
//  GeneralPreferencesView.swift
//  BanglaType
//

import SwiftUI
import ServiceManagement

struct GeneralPreferencesView: View {
    @AppStorage("BanglaTypeLaunchAtLogin") private var launchAtLogin = false
    @AppStorage("BanglaTypeShowMenuBarIcon") private var showMenuBarIcon = true
    @AppStorage("BanglaTypeDefaultInput") private var defaultInput = "Bangla"
    @AppStorage("BanglaTypeShowFloatingPreview") private var showFloatingPreview = true
    @AppStorage("BanglaTypeSoundFeedback") private var soundFeedback = false

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { new in
                    if new {
                        try? SMAppService.mainApp.register()
                    } else {
                        try? SMAppService.mainApp.unregister()
                    }
                }
            Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
                .onChange(of: showMenuBarIcon) { new in
                    MenuBarController.shared.isVisible = new
                }
            Picker("Default input", selection: $defaultInput) {
                Text("Bangla").tag("Bangla")
                Text("English").tag("English")
            }
            Toggle("Show floating preview while composing", isOn: $showFloatingPreview)
            Toggle("Sound feedback on keystroke", isOn: $soundFeedback)
        }
        .formStyle(.grouped)
        .padding()
    }
}
