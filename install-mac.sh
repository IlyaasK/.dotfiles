#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$DOTFILES_DIR/Brewfile"

export NONINTERACTIVE=1
export HOMEBREW_CASK_OPTS="--appdir=${HOME}/Applications"

install_zmk_cli() {
  echo "Installing ZMK CLI with uv..."

  if [ -f "$HOME/.local/bin/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.local/bin/env"
  fi

  if ! command -v uv &>/dev/null; then
    echo "uv is not installed. Attempting to install it with Homebrew..."
    brew install uv || echo "⚠️ Warning: Failed to install uv"

    if [ -f "$HOME/.local/bin/env" ]; then
      # shellcheck disable=SC1091
      . "$HOME/.local/bin/env"
    fi
  fi

  UV_BIN="$(command -v uv || true)"
  if [ -z "$UV_BIN" ] && [ -x "$HOME/.local/bin/uv" ]; then
    UV_BIN="$HOME/.local/bin/uv"
  fi

  if [ -z "$UV_BIN" ]; then
    echo "⚠️ Warning: uv is not available. Skipping ZMK CLI install."
    return
  fi

  "$UV_BIN" tool install --force zmk || echo "⚠️ Warning: Failed to install ZMK CLI"
  "$UV_BIN" tool update-shell || echo "⚠️ Warning: Failed to update shell PATH for uv tools"
}

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

install_zmk_cli

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

echo "Installing AI agent skills/plugins..."
bash "$DOTFILES_DIR/setup-ai-skills.sh" || echo "⚠️ Warning: Failed to install AI agent skills/plugins"

echo "✅ Mac installation script finished!"
