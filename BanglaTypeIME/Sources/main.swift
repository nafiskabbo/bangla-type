import Cocoa
import InputMethodKit

// Connection name MUST match Info.plist's InputMethodConnectionName
let kConnectionName = "com.banglatype.inputmethod.BanglaTypeIME_Connection"

// IMKServer must be a global to stay alive for the process lifetime
var server: IMKServer!

// Build identifier — check Console.app for "BanglaTypeIME" to verify which build is running
let banglaTypeBuildId = "build-20260329a"
NSLog("BanglaTypeIME: starting %@", banglaTypeBuildId)

// Register menu bar icon as template BEFORE IMKServer loads it —
// PDF template icon: macOS auto-inverts for dark menu bars + Globe key overlay
if let iconPath = Bundle.main.path(forResource: "iconTemplate", ofType: "pdf"),
   let icon = NSImage(contentsOfFile: iconPath) {
    icon.isTemplate = true
    icon.setName("iconTemplate")
}

autoreleasepool {
    server = IMKServer(name: kConnectionName,
                       bundleIdentifier: Bundle.main.bundleIdentifier!)

    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate

    // Keep a strong reference so ARC doesn't release it
    withExtendedLifetime(delegate) {
        NSApplication.shared.run()
    }
}
