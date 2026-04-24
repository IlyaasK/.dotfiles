#!/bin/bash
set -e

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is only for macOS."
    exit 1
fi

echo "Setting up macOS to feel like Hyprland..."

echo "1. Swapping Caps Lock to Escape..."
# 0x39 = Caps Lock, 0x29 = Escape
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'

echo "2. Setting blazing fast keyboard repeat rates (ThePrimeagen defaults)..."
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
defaults write -g ApplePressAndHoldEnabled -bool false

echo "2. Disabling macOS Window Animations..."
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true
defaults write -g NSWindowResizeTime -float 0.001

echo "3. Installing and starting JankyBorders for window borders..."
if ! command -v borders &> /dev/null; then
    brew tap FelixKratz/formulae
    brew install borders
fi
# Start borders as a background service so it runs on startup
brew services start borders || echo "Note: Run 'borders &' manually if service fails."

echo "4. Setting the wallpaper..."
# Ensure the wallpaper exists in the stowed directory
WALLPAPER_PATH="$HOME/.config/hypr/current-wallpaper.jpg"
if [ -f "$WALLPAPER_PATH" ]; then
    osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\""
else
    echo "Wallpaper not found at $WALLPAPER_PATH. Skipping."
fi

echo "5. Auto-hiding the macOS Dock and Menu Bar..."
defaults write com.apple.dock autohide -bool true
defaults write NSGlobalDomain _HIHideMenuBar -bool true
killall Dock || true

echo "6. Starting AutoRaise (Focus follows mouse)..."
if command -v autoraise &> /dev/null; then
    brew services start autoraise || echo "Note: Run 'autoraise' manually if service fails."
else
    echo "AutoRaise not installed. Run ./install-mac.sh first if you want focus-follows-mouse."
fi

echo "✅ macOS aesthetics setup complete!"
echo "Note: The Caps Lock mapping via hidutil will reset on reboot."
echo "For a permanent solution, you can either:"
echo "1. Run this script automatically on login."
echo "2. Change it natively in System Settings -> Keyboard -> Keyboard Shortcuts -> Modifier Keys."
