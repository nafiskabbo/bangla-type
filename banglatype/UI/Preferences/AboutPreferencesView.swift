//
//  AboutPreferencesView.swift
//  BanglaType
//

import SwiftUI

struct AboutPreferencesView: View {
    private let releasesURL = URL(string: "https://github.com/nafiskabbo/bangla-type/releases")!
    private let readmeURL = URL(string: "https://github.com/nafiskabbo/bangla-type#readme")!

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("BanglaType")
                    .font(.largeTitle)
                Text("Bangladeshi Bangla input method for macOS")
                    .foregroundColor(.secondary)
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                    Text("Version \(version)")
                        .font(.caption)
                }
                Text("বাংলাদেশের জন্য, বাংলাদেশিদের দ্বারা তৈরি ❤️ 🇧🇩")
                    .font(.caption)
                    .padding(.top, 4)

                Divider()

                Text("Help & links")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    Link("Releases (download DMG)", destination: releasesURL)
                    Link("Documentation (README)", destination: readmeURL)
                    Text("Preferences → Phonetic tab: choose \"Traditional (র্)\" for old-style Reph placement.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Divider()

                Text("Traditional Reph (র্)")
                    .font(.headline)
                Text("In Preferences → Phonetic, use \"Reph style: Traditional (র্)\" for the classic Avro-style র্ (reph) placement. Use \"Modern\" for the newer Unicode ordering.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
