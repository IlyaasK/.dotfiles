#!/bin/bash
# Omarchy keyboard-layout overlay (Glove80/Ferris physical layout).
# Requires feh. Usage: kb-layout-overlay.sh show | hide | toggle
set -euo pipefail

IMAGE="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts/glove80_layout.png"
PID_FILE="/tmp/kb_overlay_pid"

get_geometry() {
  python3 -c '
import json, struct, subprocess, sys
p = sys.argv[1]
with open(p, "rb") as f:
    d = f.read(24)
iw, ih = struct.unpack(">II", d[16:24])
try:
    mons = json.loads(subprocess.check_output(["hyprctl", "monitors", "-j"], stderr=subprocess.DEVNULL))
    m = next((x for x in mons if x.get("focused")), mons[0])
    sw, sh = int(m["width"] / m["scale"]), int(m["height"] / m["scale"])
except Exception:
    sw, sh = 1920, 1080
th = int(sh * 0.9)
tw = int(th * iw / ih)
print(f"{tw}x{th}")
' "$IMAGE"
}

show_overlay() {
  [ -f "$IMAGE" ] || { echo "Missing layout image: $IMAGE" >&2; exit 1; }
  command -v feh >/dev/null || { echo "feh is not installed (sudo pacman -S feh)" >&2; exit 1; }
  hide_overlay
  geo=$(get_geometry)
  # feh sizes the window to --geometry and scales the image down to fit (portrait, no bars).
  feh --geometry "$geo" --scale-down --borderless --no-menus \
      --title "kb-overlay" "$IMAGE" &
  echo $! > "$PID_FILE"
}

hide_overlay() {
  if [ -f "$PID_FILE" ]; then
    kill "$(cat "$PID_FILE")" 2>/dev/null || true
    rm -f "$PID_FILE"
  fi
}

case "${1:-}" in
  show)   show_overlay ;;
  hide)   hide_overlay ;;
  toggle) if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then hide_overlay; else show_overlay; fi ;;
  *)      echo "usage: $0 show|hide|toggle" >&2; exit 2 ;;
esac
