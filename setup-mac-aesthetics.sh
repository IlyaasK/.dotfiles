#!/bin/bash
set -e

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This script is only for macOS."
    exit 1
fi

echo "Setting up macOS to feel like Hyprland..."

parallel_pids=()
parallel_names=()

run_parallel_task() {
    local name="$1"
    shift

    "$@" &
    parallel_pids+=("$!")
    parallel_names+=("$name")
}

wait_parallel_tasks() {
    local failed=0

    for i in "${!parallel_pids[@]}"; do
        if wait "${parallel_pids[$i]}"; then
            echo "  ✅ ${parallel_names[$i]} complete"
        else
            echo "  ⚠️  ${parallel_names[$i]} failed"
            failed=1
        fi
    done

    return "$failed"
}

set_wallpaper() {
    echo "Setting the wallpaper..."
    WALLPAPER_PATH="$HOME/.config/hypr/current-wallpaper.jpg"
    if [ -f "$WALLPAPER_PATH" ]; then
        osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\""
    else
        echo "Wallpaper not found at $WALLPAPER_PATH. Skipping."
    fi
}

start_autoraise() {
    echo "Starting AutoRaise (Focus follows mouse)..."
    if command -v autoraise &> /dev/null; then
        brew services start autoraise || echo "Note: Run 'autoraise' manually if service fails."
    else
        echo "AutoRaise not installed. Run ./install-mac.sh first if you want focus-follows-mouse."
    fi
}

setup_keyboard_overlay() {
    echo "Setting up split keyboard layout overlay (Mac port of feh overlay)..."
    KEEB_SCRIPT="${HOME}/.config/hypr/scripts/split_keeb_layout_mac.sh"
    KEEB_SWIFT="${HOME}/.config/hypr/scripts/kb_overlay.swift"
    KEEB_BIN="${HOME}/.config/hypr/scripts/kb_overlay"
    if [ -f "$KEEB_SCRIPT" ]; then
        chmod +x "$KEEB_SCRIPT"
        if [ -f "$KEEB_SWIFT" ]; then
            echo "  Compiling Swift overlay binary (one-time)..."
            if swiftc -o "$KEEB_BIN" "$KEEB_SWIFT"; then
                echo "  ✅ Binary compiled at $KEEB_BIN"
            else
                echo "  ⚠️  Failed to compile Swift overlay binary"
            fi
        fi
        echo "  ✅ Keyboard overlay ready — bind alt-k in AeroSpace or run: split_keeb_layout_mac.sh toggle"
    else
        echo "  ⚠️  Overlay script not found at $KEEB_SCRIPT — run stow/deploy.sh first."
    fi
}

echo "1. Swapping Caps Lock to Escape..."
# 0x39 = Caps Lock, 0x29 = Escape
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}'

echo "2. Setting blazing fast keyboard repeat rates (ThePrimeagen defaults)..."
defaults write -g InitialKeyRepeat -int 10
defaults write -g KeyRepeat -int 1
defaults write -g ApplePressAndHoldEnabled -bool false

echo "2b. Remapping macOS app menu shortcuts to Alt..."
# macOS key equivalents use ~ for Option/Alt. These target standard app menu item names.
defaults write -g NSUserKeyEquivalents -dict-add "Copy" -string "~c"
defaults write -g NSUserKeyEquivalents -dict-add "Paste" -string "~v"
defaults write -g NSUserKeyEquivalents -dict-add "Cut" -string "~x"
defaults write -g NSUserKeyEquivalents -dict-add "Quit" -string "~q"
echo "Note: apps with custom menu item names may need app-specific follow-up remaps."

echo "3. Disabling natural scrolling..."
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo "4. Enabling tap to click..."
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo "5. Disabling macOS Window Animations..."
defaults write com.apple.universalaccess reduceMotion -bool true
defaults write com.apple.Accessibility ReduceMotionEnabled -bool true
defaults write -g NSWindowResizeTime -float 0.001
killall Dock Finder SystemUIServer || true

echo "6. Keeping Spaces separate per display..."
defaults write com.apple.spaces "spans-displays" -bool false
killall SystemUIServer || true

echo "7. Reducing transparency and Liquid Glass effects..."
defaults write com.apple.universalaccess reduceTransparency -bool true
defaults write com.apple.Accessibility ReduceTransparencyEnabled -bool true
killall cfprefsd Dock Finder SystemUIServer || true

echo "8. Installing and starting JankyBorders for window borders..."
if ! command -v borders &> /dev/null; then
    brew tap FelixKratz/formulae
    brew install borders
fi
# Start borders as a background service so it runs on startup
brew services start borders || echo "Note: Run 'borders &' manually if service fails."

echo "9. Auto-hiding the macOS Dock and Menu Bar..."
defaults write com.apple.dock autohide -bool true
defaults write NSGlobalDomain _HIHideMenuBar -bool true
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
# Make dock appear instantly with no delay
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
killall Dock || true

echo "10. Disabling autocorrect, autocapitalize, and smart substitutions..."
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

echo "11. Finder: show all file extensions, show hidden/dot files, disable extension change warning..."
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
killall Finder || true

echo "12. Screenshots: save to Desktop, no drop shadow..."
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture disable-shadow -bool true

echo "13. Running independent mac setup tasks in parallel..."
run_parallel_task "wallpaper" set_wallpaper
run_parallel_task "AutoRaise" start_autoraise
run_parallel_task "keyboard overlay" setup_keyboard_overlay
wait_parallel_tasks

echo "✅ macOS aesthetics setup complete!"
echo "Note: The Caps Lock mapping via hidutil will reset on reboot."
echo "For a permanent solution, you can either:"
echo "1. Run this script automatically on login."
echo "2. Change it natively in System Settings -> Keyboard -> Keyboard Shortcuts -> Modifier Keys."
