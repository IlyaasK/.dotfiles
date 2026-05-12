#!/usr/bin/swift
// kb_overlay.swift
// Opens split_keeb_keymap.png as a borderless, always-on-top floating window
// on the screen where the mouse cursor currently is — no Accessibility needed.

import Cocoa

let args = CommandLine.arguments
guard args.count > 1 else {
    fputs("Usage: kb_overlay.swift <image_path>\n", stderr)
    exit(1)
}

let imgPath = args[1]
guard let img = NSImage(contentsOfFile: imgPath) else {
    fputs("Error: could not load image at \(imgPath)\n", stderr)
    exit(1)
}

// Find the screen the mouse is on (no permissions needed)
let mouseLocation = NSEvent.mouseLocation
let targetScreen = NSScreen.screens.first(where: { NSMouseInRect(mouseLocation, $0.frame, false) })
    ?? NSScreen.main
    ?? NSScreen.screens[0]

let screenFrame = targetScreen.visibleFrame

// Image display size (match original feh geometry)
let winW: CGFloat = 557
let winH: CGFloat = 1076

// Centered on the focused screen
let winX = screenFrame.midX - winW / 2
let winY = screenFrame.midY - winH / 2

let winRect = NSRect(x: winX, y: winY, width: winW, height: winH)

let app = NSApplication.shared
app.setActivationPolicy(.accessory) // No dock icon

let window = NSWindow(
    contentRect: winRect,
    styleMask: [.borderless],
    backing: .buffered,
    defer: false,
    screen: targetScreen
)
window.level = .floating              // Always on top
window.isOpaque = false
window.backgroundColor = .clear
window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
window.hasShadow = false

let imageView = NSImageView(frame: NSRect(origin: .zero, size: CGSize(width: winW, height: winH)))
imageView.image = img
imageView.imageScaling = .scaleAxesIndependently
window.contentView = imageView

// Click anywhere to quit
let clickMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { _ in
    app.terminate(nil)
    return nil
}

window.makeKeyAndOrderFront(nil)
app.run()
