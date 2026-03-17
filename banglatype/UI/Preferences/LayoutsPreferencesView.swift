//
//  LayoutsPreferencesView.swift
//  BanglaType
//

import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct LayoutsPreferencesView: View {
    @State private var layouts: [(id: String, nameEn: String, nameBn: String)] = (0..<LayoutManager.shared.layoutCount).compactMap { i in
        guard let d = LayoutManager.shared.layoutDescriptor(at: i) else { return nil }
        return (d.id, d.nameEn, d.nameBn)
    }
    @State private var showImport = false

    var body: some View {
        VStack(alignment: .leading) {
            List {
                ForEach(Array(layouts.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        Text("\(item.nameEn) — \(item.nameBn)")
                        Spacer()
                    }
                }
            }
            Button("Import layout…") {
                let panel = NSOpenPanel()
                panel.allowedContentTypes = [.json]
                panel.allowsMultipleSelection = false
                panel.canChooseDirectories = false
                if panel.runModal() == .OK, let url = panel.url {
                    let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
                    let dir = support.appendingPathComponent("BanglaType/Layouts", isDirectory: true)
                    try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
                    let dest = dir.appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: dest)
                    try? FileManager.default.copyItem(at: url, to: dest)
                }
            }
            .padding()
        }
    }
}
