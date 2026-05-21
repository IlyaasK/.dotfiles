#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

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

echo "Updating Homebrew..."
brew update

echo "Installing Homebrew packages from $BREWFILE..."
if ! brew bundle --file="$BREWFILE"; then
  echo "⚠️ Warning: brew bundle reported one or more failures. Review the output above for optional packages that may need manual installation."
fi

echo "Installing Codex CLI via npm..."
if command -v npm &>/dev/null; then
  npm install -g @openai/codex || echo "⚠️ Warning: Failed to install Codex CLI. Make sure Node.js is correctly set up."
else
  echo "⚠️ Warning: npm is not installed. Skipping Codex CLI install."
fi

echo "Installing bootdev CLI..."
if command -v go &>/dev/null; then
  go install github.com/bootdotdev/bootdev@latest || echo "⚠️ Warning: Failed to install bootdev"
else
  echo "⚠️ Warning: Go is not installed. Skipping bootdev."
fi

echo "✅ Mac installation script finished!"
