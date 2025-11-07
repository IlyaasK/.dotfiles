#!/bin/bash

IMAGE_PATH="/home/ilyaas/.config/hypr/scripts/split_keeb_keymap.png"


show_overlay() {
    feh --geometry 557*1076 --auto-zoom --borderless --no-menus \
        --title "kb-overlay" "$IMAGE_PATH" &
    echo $! > /tmp/kb_overlay_pid
}

hide_overlay() {
    if [ -f /tmp/kb_overlay_pid ]; then
        kill $(cat /tmp/kb_overlay_pid) 2>/dev/null
        rm -f /tmp/kb_overlay_pid
    fi
}

case "$1" in
    show) show_overlay ;;
    hide) hide_overlay ;;
esac
