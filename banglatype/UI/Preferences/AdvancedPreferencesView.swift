//
//  AdvancedPreferencesView.swift
//  BanglaType
//

import SwiftUI

struct AdvancedPreferencesView: View {
    @AppStorage("BanglaTypePerAppLayoutEnabled") private var perAppLayout = false

    var body: some View {
        Form {
            Toggle("Per-app layout memory", isOn: $perAppLayout)
            Section {
                Text("When enabled, BanglaType remembers which layout you used in each application and restores it when you switch back.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
