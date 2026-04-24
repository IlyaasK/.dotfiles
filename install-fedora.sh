#!/bin/bash
set -e

echo "Updating Fedora system..."
sudo dnf upgrade --refresh -y

echo "Installing core tools, CLI utilities, and Hyprland ecosystem..."

# Note: Some package names might slightly vary depending on the Fedora version and active repositories.
sudo dnf install -y \
    stow \
    zsh \
    neovim \
    eza \
    bat \
    fzf \
    lf \
    highlight \
    ffmpeg \
    yt-dlp \
    transmission-cli \
    zathura \
    zathura-pdf-mupdf \
    hyprland

# Some newer/niche tools might not be in the default Fedora repos:
echo "--------------------------------------------------------"
echo "Note: If 'ghostty' or 'zen-browser' failed to install,"
echo "you may need to install them via Flatpak or COPR."
echo "Example for Ghostty (if COPR exists) or build from source."
echo "--------------------------------------------------------"

echo "✅ Fedora installation script finished!"
