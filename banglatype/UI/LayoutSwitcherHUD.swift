//
//  LayoutSwitcherHUD.swift
//  BanglaType
//
//  NSPanel HUD listing layouts; keyboard nav, auto-dismiss.
//

import AppKit
import SwiftUI

final class LayoutSwitcherHUDController: NSObject {
    static let shared = LayoutSwitcherHUDController()
    private var panel: NSPanel?
    private var windowController: NSWindowController?
    private var dismissWorkItem: DispatchWorkItem?
    private let dismissInterval: TimeInterval = 2.0

    func show() {
        DispatchQueue.main.async { [weak self] in
            self?.showOnMain()
        }
    }

    private func showOnMain() {
        dismissWorkItem?.cancel()
        if panel == nil {
            let content = LayoutSwitcherHUDView(onSelect: { [weak self] index in
                LayoutManager.shared.switchToLayout(index: index)
                self?.dismiss()
            }, onDismiss: { [weak self] in
                self?.dismiss()
            })
            let hosting = NSHostingView(rootView: content)
            hosting.frame = NSRect(x: 0, y: 0, width: 360, height: 280)
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 360, height: 280),
                styleMask: [.nonactivatingPanel, .titled],
                backing: .buffered,
                defer: false
            )
            panel.isOpaque = false
            panel.backgroundColor = .clear
            panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            panel.hidesOnDeactivate = false
            panel.level = .floating
            panel.contentView = hosting
            self.panel = panel
            windowController = NSWindowController(window: panel)
        }
        guard let panel = panel, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - panel.frame.width / 2
        let y = screenFrame.midY - panel.frame.height / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))
        panel.orderFrontRegardless()
        scheduleDismiss()
    }

    func dismiss() {
        dismissWorkItem?.cancel()
        panel?.orderOut(nil)
    }

    private func scheduleDismiss() {
        dismissWorkItem = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + dismissInterval, execute: dismissWorkItem!)
    }
}

struct LayoutSwitcherHUDView: View {
    let onSelect: (Int) -> Void
    let onDismiss: () -> Void
    @State private var selectedIndex: Int = LayoutManager.shared.activeLayoutIndex
    @State private var hoverIndex: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            Text("Layout")
                .font(.headline)
                .padding(.bottom, 12)
            let count = LayoutManager.shared.layoutCount
            ForEach(0..<count, id: \.self) { index in
                if let desc = LayoutManager.shared.layoutDescriptor(at: index) {
                    let isActive = index == LayoutManager.shared.activeLayoutIndex
                    let isHover = index == hoverIndex
                    Button {
                        onSelect(index)
                    } label: {
                        HStack {
                            Text(desc.nameEn)
                            Text(desc.nameBn)
                                .foregroundColor(.secondary)
                            Spacer()
                            if isActive {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isActive || isHover ? Color.accentColor.opacity(0.2) : Color.clear)
                        .cornerRadius(6)
                    }
                    .buttonStyle(.plain)
                    .onHover { inside in
                        hoverIndex = inside ? index : nil
                    }
                }
            }
            Spacer(minLength: 8)
            Text("Press Esc or wait to close")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(VisualEffectBackground())
        .onReceive(NotificationCenter.default.publisher(for: .banglaTypeLayoutChanged)) { _ in
            selectedIndex = LayoutManager.shared.activeLayoutIndex
        }
    }
}

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let v = NSVisualEffectView()
        v.material = .hudWindow
        v.blendingMode = .behindWindow
        v.state = .active
        return v
    }
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
