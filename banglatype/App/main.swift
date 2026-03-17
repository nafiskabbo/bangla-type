//
//  main.swift
//  BanglaType — macOS Input Method for Bangladeshi Bangla
//

import AppKit

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
