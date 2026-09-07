#!/bin/bash
# One-shot Omarchy dotfiles setup. Reproduces the ilyaascompute config.
# Usage:  bash install-omarchy.sh
#   Optional: OMP_SOURCE=<ssh-host-of-your-other-machine> bash install-omarchy.sh
#             (ports the secret omp config + keys from that machine)
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OM="$DOTFILES_DIR/omarchy"
OMP_SOURCE="${OMP_SOURCE:-}"

step() { printf '\n\033[1;36m▸ %s\033[0m\n' "$*"; }
copy() { # copy <repo-rel> <home-rel>; backs up any existing real file/dir
  local src="$DOTFILES_DIR/$1" tgt="$HOME/$2"
  [ -e "$src" ] || { echo "  skip (missing in repo): $1"; return; }
  if [ -e "$tgt" ] && [ ! -L "$tgt" ]; then
    mv "$tgt" "$tgt.omarchy.bak" 2>/dev/null || true
  fi
  mkdir -p "$(dirname "$tgt")"
  cp -a "$src" "$tgt"
}

step "1/7 Packages (sudo; enter password when prompted)"
sudo pacman -S --needed --noconfirm \
    stow feh zsh zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search \
    || echo "⚠️  install aborted — run that pacman line manually."

step "2/7 Copy base configs (nvim, ghostty, zsh/shell, lf, rofi, tmux, .zshenv) — skips hypr (Omarchy owns it)"
for p in .config/nvim .config/ghostty .config/zsh .config/shell .config/lf .config/rofi .zshenv .tmux.conf; do
  copy "base/$p" "$p"
done
# .local/bin scripts (individual, don't clobber ~/.local)
if [ -d "$DOTFILES_DIR/base/.local/bin" ]; then
  mkdir -p "$HOME/.local/bin"
  for f in "$DOTFILES_DIR"/base/.local/bin/*; do
    [ -f "$f" ] && cp -a "$f" "$HOME/.local/bin/$(basename "$f")"
  done
fi

step "3/7 Omarchy Hyprland overrides (bindings, looknfeel, keyboard overlay)"
mkdir -p "$HOME/.config/hypr/scripts"
cp "$OM/hypr/bindings.lua"   "$HOME/.config/hypr/bindings.lua"
cp "$OM/hypr/looknfeel.lua"  "$HOME/.config/hypr/looknfeel.lua"
cp "$OM/scripts/kb-layout-overlay.sh" "$HOME/.config/hypr/scripts/"
chmod +x "$HOME/.config/hypr/scripts/kb-layout-overlay.sh"
# keyboard layout image (tracked in base)
cp "$DOTFILES_DIR/base/.config/hypr/scripts/glove80_layout.png" "$HOME/.config/hypr/scripts/" 2>/dev/null \
  || echo "  ⚠️  glove80_layout.png not in repo"

step "4/7 Omarchy defaults"
omarchy default terminal ghostty || echo "  ⚠️  terminal default failed"
omarchy default browser    zen     || echo "  ⚠️  browser default failed"

step "5/7 zsh as login shell + preserve Omarchy in zsh"
chsh -s /usr/bin/zsh 2>/dev/null || sudo chsh -s /usr/bin/zsh "$(id -un)" 2>/dev/null \
  || echo "  ⚠️  run: sudo chsh -s /usr/bin/zsh"
if ! grep -q "env-bootstrap" "$HOME/.zshenv" 2>/dev/null; then
  printf '\n# Omarchy environment (preserved for zsh)\nsource /usr/share/omarchy/default/bash/env-bootstrap 2>/dev/null\n' >> "$HOME/.zshenv"
fi
ZRC="$HOME/.config/zsh/.zshrc"
if [ -f "$ZRC" ] && ! grep -q "default/bash/rc" "$ZRC" 2>/dev/null; then
  sed -i '1a source "${OMARCHY_PATH:-/usr/share/omarchy}/default/bash/rc" 2>/dev/null' "$ZRC"
fi
bash "$DOTFILES_DIR/setup-zsh-plugins.sh" 2>/dev/null || true

step "6/7 omp config + keys (SECRET — not in this public repo)"
if [ -n "$OMP_SOURCE" ]; then
  mkdir -p "$HOME/.omp/agent" "$HOME/.omp/remote-host"
  rsync -a -e ssh "$OMP_SOURCE":~/.omp/agent/ "$HOME/.omp/agent/" 2>/dev/null && echo "  ported omp config" || echo "  ⚠️  omp rsync failed"
  rsync -a -e ssh "$OMP_SOURCE":~/.omp/remote-host/ "$HOME/.omp/remote-host/" 2>/dev/null || true
else
  echo "  omp config+keys are secret. After setup, transfer from your other machine:"
  echo "    rsync -a -e ssh <machine>:~/.omp/agent/ ~/.omp/agent/"
  echo "    rsync -a -e ssh <machine>:~/.omp/remote-host/ ~/.omp/remote-host/"
fi

step "7/7 Reload Hyprland"
hyprctl reload 2>/dev/null || true

echo
echo "✅ Omarchy setup complete. Terminal=ghostty · Browser=zen · zsh=login · overlay=Super+Shift+K."
echo "   Open a new terminal (or log out/in) to get zsh."
