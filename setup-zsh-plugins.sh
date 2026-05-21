#!/bin/bash
set -e

PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
mkdir -p "$PLUGIN_DIR"

install_plugin() {
    local name="$1"
    local repo="$2"
    local target="$PLUGIN_DIR/$name"

    if [ -d "$target/.git" ]; then
        git -C "$target" pull --ff-only || echo "⚠️ Warning: Failed to update $name"
    else
        git clone --depth 1 "$repo" "$target" || echo "⚠️ Warning: Failed to install $name"
    fi
}

install_plugin fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git
install_plugin zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git
install_plugin zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git
install_plugin zsh-you-should-use https://github.com/MichaelAquilina/zsh-you-should-use.git
install_plugin powerlevel10k https://github.com/romkatv/powerlevel10k.git
