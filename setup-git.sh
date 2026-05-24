#!/bin/bash
set -e

NAME="IlyaasK"
EMAIL="86218345+IlyaasK@users.noreply.github.com"
SSH_KEY_PATH="${SSH_KEY_PATH:-$HOME/.ssh/id_ed25519_github}"
SSH_KEY_TITLE="${GITHUB_SSH_KEY_TITLE:-$(hostname)-github}"
SSH_CONFIG="$HOME/.ssh/config"
SSH_CONFIG_BEGIN="# >>> dotfiles github.com ssh"
SSH_CONFIG_END="# <<< dotfiles github.com ssh"

if ! command -v git &> /dev/null; then
    echo "❌ Error: Git is not installed."
    echo "If you are on macOS, please run ./install-mac.sh first."
    echo "If you are on Linux, run the appropriate install script first."
    exit 1
fi

echo "Setting up global Git configuration..."
git config --global user.name "$NAME"
git config --global user.email "$EMAIL"
git config --global core.editor "nvim"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global url."git@github.com:".insteadOf "https://github.com/"

echo "Preparing SSH directory..."
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$SSH_CONFIG"
chmod 600 "$SSH_CONFIG"

if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Generating a GitHub Ed25519 SSH key."
    echo "Use a strong passphrase when prompted; it will be cached by ssh-agent/keychain."
    ssh-keygen -t ed25519 -a 100 -C "$EMAIL" -f "$SSH_KEY_PATH"
else
    echo "SSH key already exists at $SSH_KEY_PATH"
fi

chmod 600 "$SSH_KEY_PATH"
chmod 644 "${SSH_KEY_PATH}.pub"

echo "Configuring SSH for GitHub..."
TMP_CONFIG="$(mktemp)"
awk -v begin="$SSH_CONFIG_BEGIN" -v end="$SSH_CONFIG_END" '
    $0 == begin { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
' "$SSH_CONFIG" > "$TMP_CONFIG"

{
    echo "$SSH_CONFIG_BEGIN"
    echo "Host github.com"
    echo "  HostName github.com"
    echo "  User git"
    echo "  IdentityFile $SSH_KEY_PATH"
    echo "  IdentitiesOnly yes"
    echo "  AddKeysToAgent yes"
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "  UseKeychain yes"
    fi
    echo "$SSH_CONFIG_END"
    cat "$TMP_CONFIG"
} > "$SSH_CONFIG"
rm -f "$TMP_CONFIG"
chmod 600 "$SSH_CONFIG"

echo "Starting ssh-agent..."
if [ -z "${SSH_AUTH_SOCK:-}" ]; then
    eval "$(ssh-agent -s)"
fi

if [[ "$(uname)" == "Darwin" ]]; then
    ssh-add --apple-use-keychain "$SSH_KEY_PATH" 2>/dev/null || ssh-add "$SSH_KEY_PATH"
else
    ssh-add "$SSH_KEY_PATH"
fi

if command -v gh &> /dev/null; then
    echo "Configuring GitHub CLI to use SSH..."
    gh config set -h github.com git_protocol ssh || echo "⚠️ Warning: Failed to set gh git_protocol=ssh"

    if ! gh auth status -h github.com &> /dev/null; then
        echo "Starting GitHub CLI login. Choose SSH if prompted."
        gh auth login --hostname github.com --git-protocol ssh --web || echo "⚠️ Warning: gh auth login did not complete"
    fi

    if gh auth status -h github.com &> /dev/null; then
        gh ssh-key add "${SSH_KEY_PATH}.pub" --title "$SSH_KEY_TITLE" || echo "⚠️ Warning: Failed to upload SSH key; it may already exist on GitHub"
    fi
else
    echo "⚠️ GitHub CLI is not installed. Run the install script, then run:"
    echo "  gh auth login --hostname github.com --git-protocol ssh --web"
    echo "  gh ssh-key add ${SSH_KEY_PATH}.pub --title \"$SSH_KEY_TITLE\""
fi

echo ""
echo "======================================================================="
echo "✅ Git configuration, SSH setup, and GitHub CLI auth setup complete!"
echo "Your global user is set to: $NAME ($EMAIL)"
echo "SSH key path: $SSH_KEY_PATH"
echo "======================================================================="
