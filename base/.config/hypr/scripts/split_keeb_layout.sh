#!/bin/bash

IMAGE_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/split_keep_layout_new.jpg"
TMP_IMAGE="/tmp/kb_overlay_scaled.jpg"
PID_FILE="/tmp/kb_overlay_pid"

get_target_size() {
    python3 - "$IMAGE_PATH" <<'EOF'
import sys, json, subprocess
from PIL import Image

img = Image.open(sys.argv[1])
img_w, img_h = img.size

try:
    monitors = json.loads(subprocess.check_output(['hyprctl', 'monitors', '-j'], stderr=subprocess.DEVNULL))
    m = next((m for m in monitors if m.get('focused')), monitors[0])
    screen_h = int(m['height'] / m['scale'])
except Exception:
    screen_h = 1050

target_h = int(screen_h * 0.95)
target_w = int(target_h * img_w / img_h)

img_scaled = img.resize((target_w, target_h), Image.LANCZOS)
img_scaled.save(sys.argv[1].replace(sys.argv[1], '/tmp/kb_overlay_scaled.jpg'))
print(f"{target_w}x{target_h}")
EOF
}

show_overlay() {
    local geo
    geo=$(get_target_size)
    feh --geometry "$geo" --borderless --no-menus \
        --title "kb-overlay" "$TMP_IMAGE" &
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
