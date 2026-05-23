#!/bin/bash
set -e

echo "Configuring pacman for 20 parallel downloads..."
sudo sed -i 's/^#\?ParallelDownloads.*/ParallelDownloads = 20/' /etc/pacman.conf

echo "Installing reflector to find the fastest US mirrors..."
sudo pacman -Sy --noconfirm reflector
sudo reflector --country US --latest 20 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo "Updating Arch Linux system with new fast mirrors..."
sudo pacman -Syu --noconfirm

echo "Ensuring base-devel and git are installed for building packages..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v paru &> /dev/null; then
    echo "Installing paru (AUR helper)..."
    git clone https://aur.archlinux.org/paru.git /tmp/paru
    cd /tmp/paru
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/paru
fi

echo "Installing core tools, CLI utilities, and Hyprland ecosystem from official repos..."
sudo pacman -S --needed --noconfirm \
    curl \
    github-cli \
    jq \
    mupdf \
    ncdu \
    redis \
    stow \
    tailscale \
    tmux \
    tree \
    unzip \
    usbutils \
    wget \
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
    python \
    go \
    typst \
    texlive-basic \
    nodejs \
    npm \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    zsh-history-substring-search \
    hyprland \
    hyprpaper \
    hypridle \
    hyprlock \
    waybar \
    dunst \
    udiskie \
    rofi-wayland \
    brightnessctl \
    playerctl \
    qmk \
    ttf-jetbrains-mono-nerd

echo "Configuring Caps Lock/Escape swap for Linux XKB..."
sudo localectl set-x11-keymap us pc105 "" caps:swapescape || echo "⚠️ Warning: Failed to configure Caps Lock/Escape swap with localectl"

echo "Installing AUR packages via paru..."
paru -S --needed --noconfirm \
    zen-browser-bin \
    ghostty \
    standardnotes-desktop \
    zsh-autocomplete \
    zmk

echo "Installing uv (Fast Python package installer)..."
curl -LsSf https://astral.sh/uv/install.sh | sh || echo "⚠️ Warning: Failed to install uv"

echo "Installing Temporal CLI..."
go install github.com/temporalio/cli/cmd/temporal@latest || echo "⚠️ Warning: Failed to install Temporal CLI"

echo "Installing gemini-cli via npm..."
sudo npm install -g gemini-cli || echo "⚠️ Warning: Failed to install gemini-cli"

echo "Installing bootdev CLI..."
go install github.com/bootdotdev/bootdev@latest || echo "⚠️ Warning: Failed to install bootdev"

echo "Installing Zsh plugins..."
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-zsh-plugins.sh"

echo "Installing AI agent skills/plugins..."
bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/setup-ai-skills.sh" || echo "⚠️ Warning: Failed to install AI agent skills/plugins"

echo "✅ Arch Linux installation script finished!"
