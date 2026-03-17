//
//  AppearancePreferencesView.swift
//  BanglaType
//

import SwiftUI

struct AppearancePreferencesView: View {
    @AppStorage("BanglaTypeTheme") private var themeRaw = "system"
    @AppStorage("BanglaTypeCandidateAccentR") private var accentR: Double = 0.2
    @AppStorage("BanglaTypeCandidateAccentG") private var accentG: Double = 0.5
    @AppStorage("BanglaTypeCandidateAccentB") private var accentB: Double = 0.3
    @AppStorage("BanglaTypeCandidateOrientation") private var orientation = "Horizontal"
    @AppStorage("BanglaTypeCandidateFontSize") private var fontSize: Double = 14

    private var theme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: themeRaw) ?? .system },
            set: {
                themeRaw = $0.rawValue
                ThemeManager.shared.currentTheme = $0
            }
        )
    }

    var body: some View {
        Form {
            Picker("Theme", selection: theme) {
                Text("System").tag(AppTheme.system)
                Text("Light").tag(AppTheme.light)
                Text("Dark").tag(AppTheme.dark)
            }
            .pickerStyle(.segmented)
            HStack {
                Text("Candidate accent")
                Slider(value: $accentR, in: 0...1).frame(width: 80)
                Slider(value: $accentG, in: 0...1).frame(width: 80)
                Slider(value: $accentB, in: 0...1).frame(width: 80)
            }
            Picker("Candidate orientation", selection: $orientation) {
                Text("Horizontal").tag("Horizontal")
                Text("Vertical").tag("Vertical")
            }
            VStack(alignment: .leading) {
                Text("Candidate font size: \(Int(fontSize)) pt")
                Slider(value: $fontSize, in: 12...24, step: 1)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

