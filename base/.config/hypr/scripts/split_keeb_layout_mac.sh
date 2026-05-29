#!/bin/bash
# Mac-native split keyboard layout overlay
# Mirrors Hyprland Super+K (hold=show, release=hide) as a toggle.
# Uses a pre-compiled Swift binary for instant launch — no compile delay.
# Build the binary once with: swiftc -o ~/.config/hypr/scripts/kb_overlay ~/.config/hypr/scripts/kb_overlay.swift
# Usage: split_keeb_layout_mac.sh show | hide | toggle

PID_FILE="/tmp/kb_overlay_pid"
BINARY="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/kb_overlay"
SOURCE="${BINARY}.swift"
SCRIPT_DIR="$(cd "$(dirname "$BINARY")" && pwd)"
GLOVE80_IMAGE="${SCRIPT_DIR}/glove80_layout.png"

ensure_binary() {
    if [ ! -f "$SOURCE" ]; then
        echo "Error: overlay source not found at $SOURCE" >&2
        exit 1
    fi

    if [ ! -x "$BINARY" ] || [ "$SOURCE" -nt "$BINARY" ]; then
        if ! command -v swiftc >/dev/null 2>&1; then
            echo "Error: swiftc not found. Install Xcode Command Line Tools first." >&2
            exit 1
        fi

        CLANG_MODULE_CACHE_PATH="${CLANG_MODULE_CACHE_PATH:-${TMPDIR:-/tmp}/kb-overlay-swift-module-cache}" \
            swiftc -o "$BINARY" "$SOURCE"
    fi
}

show_overlay() {
    ensure_binary

    # Kill any existing instance first
    hide_overlay

    if [ ! -f "$GLOVE80_IMAGE" ]; then
        echo "Error: Glove80 layout image not found at $GLOVE80_IMAGE" >&2
        exit 1
    fi

    "$BINARY" "$GLOVE80_IMAGE" &
    overlay_pid=$!
    echo "$overlay_pid" > "$PID_FILE"
    echo "Keyboard overlay shown (PID: $overlay_pid). Click overlay or run: $0 hide"
}

hide_overlay() {
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
}

case "$1" in
    show)   show_overlay ;;
    hide)   hide_overlay ;;
    toggle)
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            hide_overlay
        else
            show_overlay
        fi
        ;;
    *)
        echo "Usage: $(basename "$0") show | hide | toggle"
        exit 1
        ;;
esac
