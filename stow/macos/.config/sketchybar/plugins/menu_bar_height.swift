import AppKit
import CoreGraphics

// Get native menu bar height from window list (works even when auto-hidden)
let windows = CGWindowListCopyWindowInfo([.optionAll], kCGNullWindowID) as! [[String: Any]]
var menuBarHeight: CGFloat = NSStatusBar.system.thickness // fallback

for w in windows {
    let owner = w["kCGWindowOwnerName"] as? String ?? ""
    let layer = w["kCGWindowLayer"] as? Int ?? 0
    let bounds = w["kCGWindowBounds"] as? [String: CGFloat] ?? [:]
    let h = bounds["Height"] ?? 0
    // Menu bar windows: Window Server or Control Center, layer 24-25, height 20-50
    if (owner == "Window Server" || owner == "Control Center") && layer >= 24 && layer <= 25 && h >= 20 && h <= 50 {
        menuBarHeight = h
        break
    }
}

print(Int(menuBarHeight))
