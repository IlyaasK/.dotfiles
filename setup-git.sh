#!/bin/bash
set -e

NAME="IlyaasK"
EMAIL="86218345+IlyaasK@users.noreply.github.com"

if ! command -v git &> /dev/null; then
    echo "❌ Error: Git is not installed."
    echo "If you are on macOS, please run ./install-mac.sh first (which installs Homebrew and the Xcode Command Line Tools)."
    echo "If you are on Linux, run the appropriate install script first."
    exit 1
fi

echo "Setting up global Git configuration..."
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
git config --global init.defaultBranch main
git config --global pull.rebase true

echo "Checking for SSH key..."
SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating new Ed25519 SSH key..."
    # Generate the key with an empty passphrase for convenience (-N "")
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH" -N ""
else
    echo "SSH key already exists at $SSH_KEY_PATH"
fi

echo "Starting ssh-agent..."
eval "$(ssh-agent -s)"

mkdir -p ~/.ssh
touch ~/.ssh/config

echo "Configuring ~/.ssh/config for GitHub..."
if ! grep -q "Host github.com" ~/.ssh/config; then
    printf "Host github.com\n  User git\n  IdentityFile %s\n  IdentitiesOnly yes\n\n" "$SSH_KEY_PATH" >> ~/.ssh/config
fi

# OS specific SSH agent loading
if [[ "$(uname)" == "Darwin" ]]; then
    if ! grep -q "Host \*" ~/.ssh/config; then
        printf "Host *\n  AddKeysToAgent yes\n  UseKeychain yes\n  IdentityFile %s\n" "$SSH_KEY_PATH" >> ~/.ssh/config
    fi
    ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null || ssh-add "$SSH_KEY_PATH"
else
    ssh-add "$SSH_KEY_PATH"
fi

echo ""
echo "======================================================================="
echo "✅ Git configuration and SSH setup complete!"
echo "Your global user is set to: $NAME ($EMAIL)"
echo ""
echo "Here is your public SSH key. Copy it and add it to GitHub at:"
echo "https://github.com/settings/ssh/new"
echo "-----------------------------------------------------------------------"
cat "${SSH_KEY_PATH}.pub"
echo "======================================================================="
