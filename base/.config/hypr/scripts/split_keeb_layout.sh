#!/bin/bash

IMAGE_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/glove80_layout.png"
PID_FILE="/tmp/kb_overlay_pid"

get_target_geometry() {
    python3 <<'EOF'
import json
import subprocess

try:
    monitors = json.loads(subprocess.check_output(['hyprctl', 'monitors', '-j'], stderr=subprocess.DEVNULL))
    m = next((m for m in monitors if m.get('focused')), monitors[0])
    screen_w = int(m['width'] / m['scale'])
    screen_h = int(m['height'] / m['scale'])
except Exception:
    screen_w = 1600
    screen_h = 1050

print(f"{int(screen_w * 0.95)}x{int(screen_h * 0.95)}")
EOF
}

show_overlay() {
    local geo
    if [ ! -f "$IMAGE_PATH" ]; then
        echo "Error: Glove80 layout image not found at $IMAGE_PATH" >&2
        exit 1
    fi

    hide_overlay
    geo=$(get_target_geometry)
    feh --geometry "$geo" --scale-down --auto-zoom --borderless --no-menus \
        --title "kb-overlay" "$IMAGE_PATH" &
    echo $! > "$PID_FILE"
}

hide_overlay() {
    if [ -f "$PID_FILE" ]; then
        kill "$(cat "$PID_FILE")" 2>/dev/null
        rm -f "$PID_FILE"
    fi
}

case "$1" in
    show) show_overlay ;;
    hide) hide_overlay ;;
esac
