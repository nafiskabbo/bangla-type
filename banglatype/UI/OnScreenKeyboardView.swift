//
//  OnScreenKeyboardView.swift
//  BanglaType
//
//  SwiftUI QWERTY grid with Bangla characters; layer selector.
//

import SwiftUI

enum KeyboardLayer: String, CaseIterable {
    case normal
    case shift
    case altGr
}

struct OnScreenKeyboardView: View {
    let viewModel: KeyboardLayoutViewModel
    let onKeyPress: (String) -> Void
    @State private var layer: KeyboardLayer = .normal

    var body: some View {
        VStack(spacing: 12) {
            Picker("Layer", selection: $layer) {
                ForEach(KeyboardLayer.allCases, id: \.self) { l in
                    Text(l.rawValue).tag(l)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            ForEach(Array(viewModel.rows.enumerated()), id: \.offset) { _, row in
                HStack(spacing: 4) {
                    ForEach(Array(row.enumerated()), id: \.offset) { _, key in
                        keyButton(key)
                    }
                }
            }
        }
        .padding(12)
        .frame(width: 800, height: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }

    private func keyButton(_ key: KeyViewModel) -> some View {
        let char = character(for: key)
        return Button {
            if !char.isEmpty { onKeyPress(char) }
        } label: {
            VStack(spacing: 2) {
                Text(key.physicalLabel)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
                Text(char.isEmpty ? " " : char)
                    .font(.system(size: 18))
            }
            .frame(minWidth: 36, minHeight: 44)
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }

    private func character(for key: KeyViewModel) -> String {
        switch layer {
        case .normal: return key.normalChar
        case .shift: return key.shiftChar
        case .altGr: return key.altGrChar
        }
    }
}
