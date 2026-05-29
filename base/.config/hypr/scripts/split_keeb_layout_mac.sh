#!/bin/bash
# Mac-native split keyboard layout overlay
# Mirrors Hyprland Super+K (hold=show, release=hide) as a toggle.
# Uses a pre-compiled Swift binary for instant launch — no compile delay.
# Build the binary once with: swiftc -o ~/.config/hypr/scripts/kb_overlay ~/.config/hypr/scripts/kb_overlay.swift
# Usage: split_keeb_layout_mac.sh show | hide | toggle

PID_FILE="/tmp/kb_overlay_pid"
BINARY="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/kb_overlay"

show_overlay() {
    if [ ! -x "$BINARY" ]; then
        echo "Error: overlay binary not found. Run: swiftc -o $BINARY ${BINARY}.swift" >&2
        exit 1
    fi

    # Kill any existing instance first
    hide_overlay

    # Launch pre-compiled binary — instant, no Swift compile delay.
    # The Swift app auto-selects Glove80 when it is wired over USB;
    # otherwise it falls back to the Ferris image.
    "$BINARY" auto &
    echo $! > "$PID_FILE"
    echo "Keyboard overlay shown (PID: $!). Click overlay or run: $0 hide"
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
