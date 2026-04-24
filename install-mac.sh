#!/bin/bash
set -e

if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Please install Homebrew first:"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo "Updating Homebrew..."
brew update

echo "Installing CLI utilities and programming languages..."
CLI_PACKAGES=(
    stow
    zsh
    neovim
    eza
    bat
    fzf
    lf
    highlight
    ffmpeg
    yt-dlp
    transmission-cli
    zathura
    python
    go
    tmux
    zsh-autocomplete
    zsh-autosuggestions
    zsh-history-substring-search
    zsh-syntax-highlighting
    unzip
    typst
    jq
    node
)

for pkg in "${CLI_PACKAGES[@]}"; do
    echo "Installing $pkg..."
    brew install "$pkg" || echo "⚠️ Warning: Failed to install $pkg"
done

echo "Installing GUI Applications via Brew Cask..."
CASK_PACKAGES=(
    raycast
    zen-browser
    ghostty
    claude
    goland
    clion
    vscodium
    cursor
    ticktick
    signal
    discord
    standard-notes
    chromium
    calibre
    freecad
    autodesk-fusion
    microsoft-office
    docker
    betterdisplay
    comet
    linearmouse
    mactex-no-gui
    font-jetbrains-mono-nerd-font
)

for cask in "${CASK_PACKAGES[@]}"; do
    echo "Installing $cask..."
    brew install --cask "$cask" || echo "⚠️ Warning: Failed to install cask $cask"
done

echo "Installing AutoRaise (Focus follows mouse)..."
brew tap dimentium/autoraise
brew install autoraise || echo "⚠️ Warning: Failed to install AutoRaise"


echo "Attempting to install Niche/Custom/Internal CLI Tools..."
# Note: These tools might require specific brew taps (e.g., brew tap company/tools)
# or manual installation if they are not in the public Homebrew core.
CUSTOM_PACKAGES=(
    amp
    omlx
    codex
    opencode
    pi
    kernel
    antigravity
    qmk/qmk/qmk
    zmk
)

for custom in "${CUSTOM_PACKAGES[@]}"; do
    echo "Attempting to install $custom..."
    brew install "$custom" || echo "⚠️ Warning: Failed to install $custom (May require a custom tap or manual install)"
done

echo "Installing uv (Fast Python package installer)..."
curl -LsSf https://astral.sh/uv/install.sh | sh || echo "⚠️ Warning: Failed to install uv"

echo "Installing gemini-cli via npm..."
npm install -g gemini-cli || echo "⚠️ Warning: Failed to install gemini-cli. Make sure Node.js is correctly set up."

echo "✅ Mac installation script finished!"
