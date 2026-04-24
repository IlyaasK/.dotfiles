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
./install-mac.sh
```

**For Fedora Asahi:**
```bash
./install-fedora.sh
```

**For Arch Linux:**
```bash
./install-arch.sh
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
- `install-mac.sh` - Installs Homebrew packages and casks.
- `install-fedora.sh` - Installs Fedora dnf packages.
- `install-arch.sh` - Installs Arch pacman/AUR packages (using paru).
- `setup-git.sh` - Configures Git and generates an SSH key for GitHub.
- `setup-mac-aesthetics.sh` - Terminal commands to tweak macOS to feel like Hyprland.
- `deploy.sh` - Uses Stow to safely link your dotfiles.
