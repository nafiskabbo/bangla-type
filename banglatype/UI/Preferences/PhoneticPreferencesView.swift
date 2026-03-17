//
//  PhoneticPreferencesView.swift
//  BanglaType
//

import SwiftUI

struct PhoneticPreferencesView: View {
    @AppStorage("BanglaTypeVowelForming") private var vowelForming = true
    @AppStorage("BanglaTypeRephStyle") private var rephStyle = "traditional"

    var body: some View {
        Form {
            Section("Vowel forming") {
                Toggle("Automatic vowel forming", isOn: $vowelForming)
            }
            Section {
                Picker("Reph style", selection: $rephStyle) {
                    Text("Traditional (র্)").tag("traditional")
                    Text("Modern").tag("modern")
                }
            } header: {
                Text("Traditional Reph (র্)")
            } footer: {
                Text("Traditional places র্ (reph) in the classic Avro position. Modern uses the newer Unicode ordering.")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
