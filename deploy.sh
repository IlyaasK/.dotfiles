#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure stow is installed
if ! command -v stow &> /dev/null; then
    echo "Stow is not installed. Attempting to install it..."
    if command -v dnf &> /dev/null; then
        sudo dnf install -y stow
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm stow
    else
        echo "Could not determine package manager. Install stow manually and re-run."
        exit 1
    fi
fi

echo "Preparing to deploy dotfiles using GNU Stow..."

# Backup existing real directories/files to avoid Stow conflicts
# since Stow will refuse to overwrite real files with symlinks.
for d in ghostty hypr lf nvim shell zsh; do
    target_dir="$HOME/.config/$d"
    if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
        echo "Backing up existing directory $target_dir to ${target_dir}.bak"
        # Remove any existing backup
        rm -rf "${target_dir}.bak"
        mv "$target_dir" "${target_dir}.bak"
    fi
done

for f in .zshrc .zshenv; do
    if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
        echo "Backing up existing file $HOME/$f to $HOME/$f.bak"
        rm -f "$HOME/$f.bak"
        mv "$HOME/$f" "$HOME/$f.bak"
    fi
done

# Run stow
cd "$DOTFILES_DIR"
echo "Stowing 'base' package into $HOME..."
stow -t "$HOME" base

chmod +x "$HOME/.config/hypr/scripts"/*.sh 2>/dev/null || true
chmod +x "$HOME/.config/hypr/scripts"/*.swift 2>/dev/null || true

echo "✅ Dotfiles deployed successfully!"
echo "Your ~/.config and ~/.zshrc files are now symlinked to this repository."
