# IlyaasK's Dotfiles

These are my personal dotfiles, configured specifically for **Fedora Asahi Remix** and **macOS**. They use GNU Stow to cleanly symlink configuration files without cluttering the system.

## Setup Instructions

### 1. Clone the repository
```bash
git clone https://github.com/IlyaasK/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 2. Install Packages
Depending on your operating system, run the correct installer to get all required CLI utilities and GUI applications:

**For macOS (Requires Homebrew):**
```bash
bash install-mac.sh
```

**For Fedora Asahi:**
```bash
bash install-fedora.sh
```

**For Arch Linux:**
```bash
bash install-arch.sh
```

### 3. Deploy Configs
Once the packages are installed, deploy the symlinks to your home directory:
```bash
./deploy.sh
```
*Note: This script will automatically backup any existing folders in `~/.config/` or `~/.zshenv` to `.bak` before symlinking to avoid conflicts.*

### 4. macOS Aesthetics & Window Management
If you are running macOS, you can configure it to behave like a tiling window manager (similar to Hyprland) using AeroSpace and JankyBorders. Run the aesthetics script:
```bash
./setup-mac-aesthetics.sh
```
This script will:
1. Remap Caps Lock to Escape
2. Disable macOS system animations for instant window tiling
3. Install and start JankyBorders (for active window borders)
4. Set your desktop wallpaper

## Directory Structure
- `base/` - The core GNU Stow package. Everything in here perfectly mirrors your home folder (`~/`). For example, `base/.config/` maps to `~/.config/`.
- `Brewfile` - Declarative Homebrew package and cask list for macOS.
- `install-mac.sh` - Installs macOS packages by running `brew bundle`.
- `install-fedora.sh` - Installs Fedora dnf packages.
- `install-arch.sh` - Installs Arch pacman/AUR packages (using paru).
- `setup-zsh-plugins.sh` - Installs Zsh plugins into `${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins` for platforms that do not provide them through the package manager.
- `setup-git.sh` - Configures Git and generates an SSH key for GitHub.
- `setup-updater-cron.sh` - Installs a weekly background cronjob to safely fetch OS updates.
- `setup-mac-aesthetics.sh` - Terminal commands to tweak macOS to feel like Hyprland.
- `deploy.sh` - Uses Stow to safely link your dotfiles.

## 🛡️ Safe Migration for Existing Machines
Because this repository is engineered using **GNU Stow** and **Homebrew/OS Package Managers**, it is incredibly safe to install on a machine that already has an active workspace.

If you are pulling these dotfiles down to an existing machine (like an established Mac):

1. **Package Managers are Idempotent**: If you run `bash install-mac.sh`, Homebrew will simply skip any apps you already have installed (e.g. `neovim` or `git`) without overwriting or destroying them.
2. **GNU Stow prevents Data Loss**: If Stow attempts to link a config file (like `~/.zshrc`) but notices you already have an existing physical file there, **it will throw an error and refuse to link**. It forces you to manually rename/backup your old config (`mv ~/.zshrc ~/.zshrc.bak`) and run `./deploy.sh` again, completely preventing accidental overwrites.
3. **SSH Key Preservation**: `./setup-git.sh` natively checks for existing `id_ed25519` SSH keys. If you already have one, it safely skips key generation to preserve your current GitHub access, and only appends the correct `~/.ssh/config` parameters.
