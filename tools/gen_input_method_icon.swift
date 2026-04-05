#!/usr/bin/env swift
import AppKit

/// Generates small PNGs + BanglaTypeInputMethod.icns for Input Sources (16–64 pt).
let outDir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : FileManager.default.currentDirectoryPath)

func savePNG(size: Int, to url: URL) {
    let s = CGFloat(size)
    let img = NSImage(size: NSSize(width: s, height: s))
    img.lockFocus()
    NSColor.clear.set()
    NSRect(x: 0, y: 0, width: s, height: s).fill()
    let inset = max(1.5, s * 0.14)
    let r = NSRect(x: inset, y: inset, width: s - 2 * inset, height: s - 2 * inset)
    let rounded = NSBezierPath(roundedRect: r, xRadius: s * 0.22, yRadius: s * 0.22)
    NSColor(srgbRed: 0.11, green: 0.45, blue: 0.33, alpha: 1).setFill()
    rounded.fill()
    NSColor.white.withAlphaComponent(0.92).setFill()
    let dot = NSRect(x: s * 0.33, y: s * 0.33, width: s * 0.34, height: s * 0.34)
    NSBezierPath(ovalIn: dot).fill()
    img.unlockFocus()
    guard let tiff = img.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff) else { return }
    bitmap.size = NSSize(width: s, height: s)
    guard let data = bitmap.representation(using: .png, properties: [:]) else { return }
    try! data.write(to: url)
}

let iconset = outDir.appendingPathComponent("BanglaTypeInputMethod.iconset", isDirectory: true)
try? FileManager.default.removeItem(at: iconset)
try FileManager.default.createDirectory(at: iconset, withIntermediateDirectories: true)

savePNG(size: 16, to: iconset.appendingPathComponent("icon_16x16.png"))
savePNG(size: 32, to: iconset.appendingPathComponent("icon_16x16@2x.png"))
savePNG(size: 32, to: iconset.appendingPathComponent("icon_32x32.png"))
savePNG(size: 64, to: iconset.appendingPathComponent("icon_32x32@2x.png"))

let icnsURL = outDir.appendingPathComponent("BanglaTypeInputMethod.icns")
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
p.arguments = ["-c", "icns", iconset.path, "-o", icnsURL.path]
try p.run()
p.waitUntilExit()
if p.terminationStatus != 0 {
    fputs("iconutil failed\n", stderr)
    exit(1)
}
print("Wrote \(icnsURL.path)")
