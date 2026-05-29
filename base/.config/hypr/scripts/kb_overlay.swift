#!/usr/bin/swift
// kb_overlay.swift
// Opens the current keyboard layout as a borderless, always-on-top floating
// window on the screen where the mouse cursor currently is.

import Cocoa
import Foundation

let args = CommandLine.arguments

struct KeyboardImage {
    let name: String
    let path: String
}

let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0])
    .deletingLastPathComponent()
    .path

let ferrisImageCandidates = [
    "\(scriptDir)/ferris_layout.png",
    "\(scriptDir)/split_keep_layout_new.jpg",
    "\(scriptDir)/split_keeb_keymap.png",
]

let glove80ImageCandidates = [
    "\(scriptDir)/glove80_layout.png",
]

func firstExistingPath(_ candidates: [String]) -> String? {
    candidates.first { FileManager.default.fileExists(atPath: $0) }
}

func commandOutput(_ launchPath: String, _ arguments: [String]) -> String {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: launchPath)
    process.arguments = arguments

    let pipe = Pipe()
    process.standardOutput = pipe
    process.standardError = Pipe()

    do {
        try process.run()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return String(data: data, encoding: .utf8) ?? ""
    } catch {
        return ""
    }
}

func connectedKeyboard() -> String? {
    let registryText = [
        commandOutput("/usr/sbin/ioreg", ["-p", "IOUSB", "-l", "-w", "0"]),
        commandOutput("/usr/sbin/ioreg", ["-r", "-c", "IOHIDDevice", "-l", "-w", "0"]),
        commandOutput("/usr/sbin/system_profiler", ["SPBluetoothDataType"]),
    ].joined(separator: "\n").lowercased()

    if registryText.contains("glove80") || registryText.contains("moergo") {
        return "glove80"
    }

    let ferrisMarkers = [
        "ferris",
        "sweep",
        "qmk",
        "ilyaask",
        "arduino leonardo",
        "pro micro",
        "caterina",
    ]

    if ferrisMarkers.contains(where: { registryText.contains($0) }) {
        return "ferris"
    }

    return nil
}

func automaticImage() -> KeyboardImage {
    guard let keyboard = connectedKeyboard() else {
        fputs("No supported external keyboard detected; not showing overlay.\n", stderr)
        exit(0)
    }

    switch keyboard {
    case "glove80":
        if let glove80Path = firstExistingPath(glove80ImageCandidates) {
            return KeyboardImage(name: "Glove80", path: glove80Path)
        }
    case "ferris":
        if let ferrisPath = firstExistingPath(ferrisImageCandidates) {
            return KeyboardImage(name: "Ferris", path: ferrisPath)
        }
    default:
        break
    }

    fputs("Error: no layout image found for detected keyboard: \(keyboard)\n", stderr)
    exit(1)
}

let shouldPrintImage = args.contains("--print-image")
let imageArgs = args.dropFirst().filter { $0 != "--print-image" }

let selectedImage: KeyboardImage
if let explicitPath = imageArgs.first, explicitPath != "auto" {
    selectedImage = KeyboardImage(name: "explicit", path: String(explicitPath))
} else {
    selectedImage = automaticImage()
}

let imgPath = selectedImage.path
if shouldPrintImage {
    print("\(selectedImage.name)\t\(imgPath)")
    exit(0)
}

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

// Scale to 95% of screen height, preserving image aspect ratio
let imgAspect = img.size.width / img.size.height
let winH = floor(screenFrame.height * 0.95)
let winW = floor(winH * imgAspect)

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
