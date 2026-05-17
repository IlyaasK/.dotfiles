#!/bin/bash
set -e

export NONINTERACTIVE=1
export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications"

if ! command -v brew &>/dev/null; then
  echo "Homebrew is not installed. Please install Homebrew first:"
  echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"
if [ ! -w "$BREW_PREFIX" ]; then
  echo "Homebrew prefix is not writable by $(whoami): $BREW_PREFIX"
  echo "Fix Homebrew ownership before running this script so brew does not need sudo/password prompts."
  exit 1
fi

mkdir -p "$HOME/Applications"

brew_tap() {
  local tap="$1"
  brew tap "$tap" || echo "⚠️ Warning: Failed to tap $tap"
}

brew_formula() {
  local pkg="$1"
  echo "Installing $pkg..."
  brew install "$pkg" || echo "⚠️ Warning: Failed to install $pkg"
}

brew_cask() {
  local cask="$1"
  echo "Installing $cask..."
  brew install --cask --appdir="$HOME/Applications" "$cask" || echo "⚠️ Warning: Failed to install cask $cask"
}

echo "Updating Homebrew..."
brew update

echo "Configuring Homebrew taps..."
brew_tap FelixKratz/formulae
brew_tap dimentium/autoraise
brew_tap homebrew-zathura/zathura
brew_tap nikitabobko/tap
brew_tap onkernel/tap
brew_tap qmk/qmk

echo "Installing CLI utilities and programming languages..."
CLI_PACKAGES=(
  caddy
  curl
  e2fsprogs
  gh
  jq
  lsusb
  mupdf
  ncdu
  redis
  stow
  tailscale
  temporal
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
  zathura-pdf-mupdf
  python
  go
  tmux
  zsh-autocomplete
  zsh-autosuggestions
  zsh-history-substring-search
  zsh-syntax-highlighting
  unzip
  typst
  tree
  uv
  wget
  node
)

for pkg in "${CLI_PACKAGES[@]}"; do
  brew_formula "$pkg"
done

echo "Installing GUI Applications via Brew Cask..."
CASK_PACKAGES=(
  raycast
  zen-browser
  ghostty
  claude
  codex-app
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
  unclutter
  mactex-no-gui
  font-jetbrains-mono-nerd-font
  nikitabobko/tap/aerospace
)

for cask in "${CASK_PACKAGES[@]}"; do
  brew_cask "$cask"
done

echo "Installing AutoRaise (Focus follows mouse)..."
brew_formula autoraise

echo "Attempting to install Niche/Custom/Internal CLI Tools..."
# Note: These tools might require specific brew taps (e.g., brew tap company/tools)
# or manual installation if they are not in the public Homebrew core.
CUSTOM_PACKAGES=(
  amp
  omlx
  codex
  opencode
  pi
  onkernel/tap/kernel
  antigravity
  qmk/qmk/qmk
  zmk
)

for custom in "${CUSTOM_PACKAGES[@]}"; do
  brew_formula "$custom"
done

echo "Installing gemini-cli via npm..."
npm install -g gemini-cli || echo "⚠️ Warning: Failed to install gemini-cli. Make sure Node.js is correctly set up."

echo "Installing Claude Code and Codex CLI via npm..."
npm install -g @anthropic-ai/claude-code @openai/codex || echo "⚠️ Warning: Failed to install Claude Code/Codex CLI. Make sure Node.js is correctly set up."

echo "Installing bootdev CLI..."
go install github.com/bootdotdev/bootdev@latest || echo "⚠️ Warning: Failed to install bootdev"

echo "✅ Mac installation script finished!"
