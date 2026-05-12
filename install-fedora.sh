#!/bin/bash
set -e

echo "Updating Fedora system..."
sudo dnf upgrade --refresh -y

echo "Installing core tools, CLI utilities, and Hyprland ecosystem..."

# Note: Some package names might slightly vary depending on the Fedora version and active repositories.
sudo dnf install -y \
    git \
    wget \
    gh \
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
    python3 \
    golang \
    unzip \
    typst \
    texlive-scheme-basic \
    jq \
    nodejs \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
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
    mpv \
    qmk \
    zmk

echo "Installing JetBrains Mono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMonoNerd"
if [ ! -d "$FONT_DIR" ]; then
    mkdir -p "$FONT_DIR"
    wget -qO- "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" | tar -xJ -C "$FONT_DIR"
    fc-cache -fv
else
    echo "JetBrains Mono Nerd Font is already installed."
fi

echo "Installing uv (Fast Python package installer)..."
curl -LsSf https://astral.sh/uv/install.sh | sh || echo "⚠️ Warning: Failed to install uv"

echo "Installing gemini-cli via npm..."
sudo npm install -g gemini-cli || echo "⚠️ Warning: Failed to install gemini-cli"

echo "Installing bootdev CLI..."
go install github.com/bootdotdev/bootdev@latest || echo "⚠️ Warning: Failed to install bootdev"

echo "Note: Standard Notes, zsh-autocomplete, and zsh-history-substring-search might need to be installed manually (e.g. Flatpak for Standard Notes, or git clone for the ZSH plugins if they aren't in dnf)."

# Some newer/niche tools might not be in the default Fedora repos:
echo "--------------------------------------------------------"
echo "Note: If 'ghostty' or 'zen-browser' failed to install,"
echo "you may need to install them via Flatpak or COPR."
echo "Example for Ghostty (if COPR exists) or build from source."
echo "--------------------------------------------------------"

echo "✅ Fedora installation script finished!"
