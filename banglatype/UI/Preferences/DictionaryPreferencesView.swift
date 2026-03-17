//
//  DictionaryPreferencesView.swift
//  BanglaType
//

import SwiftUI

struct DictionaryPreferencesView: View {
    @AppStorage("BanglaTypeAutocorrect") private var autocorrect = true
    @AppStorage("BanglaTypeSuggestionsCount") private var suggestionsCount: Double = 5

    var body: some View {
        Form {
            Toggle("Enable autocorrect", isOn: $autocorrect)
            VStack(alignment: .leading) {
                Text("Number of suggestions: \(Int(suggestionsCount))")
                Slider(value: $suggestionsCount, in: 3...10, step: 1)
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
