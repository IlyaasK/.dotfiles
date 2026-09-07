#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${AI_SKILL_REPO_URL:-https://github.com/cursor/plugins.git}"
REPO_REF="${AI_SKILL_REPO_REF:-main}"
REPO_DIR="${AI_SKILL_REPO_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/cursor-plugins}"

CURSOR_PLUGINS_DIR="${CURSOR_PLUGINS_DIR:-$HOME/.cursor/plugins/local}"
CLAUDE_SKILLS_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
CODEX_SKILLS_DIR="${CODEX_SKILLS_DIR:-${CODEX_HOME:-$HOME/.codex}/skills}"

usage() {
    cat <<EOF
Usage: $0 [--list] [plugin ...]

Installs Cursor plugins from:
  $REPO_URL

Defaults:
  source cache:  $REPO_DIR
  cursor:        $CURSOR_PLUGINS_DIR
  claude code:   $CLAUDE_SKILLS_DIR
  codex:         $CODEX_SKILLS_DIR

Environment:
  AI_SKILL_REPO_URL    Git repository to clone
  AI_SKILL_REPO_REF    Git ref to checkout
  AI_SKILL_REPO_DIR    Local cache/checkout path
  AI_SKILL_PLUGINS     Space-separated plugin list; defaults to all plugins
  CURSOR_PLUGINS_DIR   Cursor local plugin directory
  CLAUDE_SKILLS_DIR    Claude Code user skills directory
  CODEX_HOME           Codex config root; defaults to ~/.codex
  CODEX_SKILLS_DIR     Codex user skills directory

Examples:
  $0
  $0 cursor-team-kit cli-for-agent
  AI_SKILL_PLUGINS="cursor-team-kit create-plugin" $0
EOF
}

clone_or_update_repo() {
    if ! command -v git >/dev/null 2>&1; then
        echo "git is required to install AI skills/plugins." >&2
        exit 1
    fi

    if [ -d "$REPO_DIR/.git" ]; then
        echo "Updating $REPO_DIR..."
        git -C "$REPO_DIR" fetch --depth 1 origin "$REPO_REF"
        git -C "$REPO_DIR" checkout -q FETCH_HEAD
    elif [ -e "$REPO_DIR" ]; then
        echo "$REPO_DIR exists but is not a git checkout. Move it or set AI_SKILL_REPO_DIR." >&2
        exit 1
    else
        echo "Cloning $REPO_URL into $REPO_DIR..."
        mkdir -p "$(dirname "$REPO_DIR")"
        git clone --depth 1 "$REPO_URL" "$REPO_DIR"
        git -C "$REPO_DIR" fetch --depth 1 origin "$REPO_REF"
        git -C "$REPO_DIR" checkout -q FETCH_HEAD
    fi
}

plugin_sources() {
    if [ -n "${AI_SKILL_PLUGINS:-}" ]; then
        printf '%s\n' $AI_SKILL_PLUGINS
    elif [ "$#" -gt 0 ]; then
        printf '%s\n' "$@"
    elif [ -f "$REPO_DIR/.cursor-plugin/marketplace.json" ] && command -v python3 >/dev/null 2>&1; then
        python3 - "$REPO_DIR/.cursor-plugin/marketplace.json" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as f:
    marketplace = json.load(f)

for plugin in marketplace.get("plugins", []):
    source = plugin.get("source") or plugin.get("name")
    if source:
        print(source)
PY
    else
        find "$REPO_DIR" -mindepth 2 -maxdepth 2 -path '*/.cursor-plugin/plugin.json' -print \
            | sed "s#^$REPO_DIR/##; s#/.cursor-plugin/plugin.json\$##" \
            | sort
    fi
}

link_dir() {
    src="$1"
    dest="$2"
    label="$3"

    mkdir -p "$(dirname "$dest")"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Skipping $label: $dest exists and is not a symlink."
        return 0
    fi

    rm -f "$dest"
    ln -s "$src" "$dest"
    echo "Linked $label -> $src"
}

list_plugins() {
    clone_or_update_repo
    plugin_sources | while IFS= read -r plugin; do
        [ -n "$plugin" ] && echo "$plugin"
    done
}

install_plugin() {
    plugin="$1"
    plugin_dir="$REPO_DIR/$plugin"

    if [ ! -f "$plugin_dir/.cursor-plugin/plugin.json" ]; then
        echo "Skipping $plugin: no .cursor-plugin/plugin.json found."
        return 0
    fi

    link_dir "$plugin_dir" "$CURSOR_PLUGINS_DIR/$plugin" "Cursor plugin $plugin"

    if [ ! -d "$plugin_dir/skills" ]; then
        return 0
    fi

    find "$plugin_dir/skills" -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r skill_dir; do
        skill_name="$(basename "$skill_dir")"

        if grep -Fxq "$skill_name" "$SEEN_SKILLS_FILE"; then
            echo "Skipping duplicate skill $skill_name from $plugin."
            continue
        fi

        echo "$skill_name" >> "$SEEN_SKILLS_FILE"
        link_dir "$skill_dir" "$CLAUDE_SKILLS_DIR/$skill_name" "Claude Code skill $skill_name"
        link_dir "$skill_dir" "$CODEX_SKILLS_DIR/$skill_name" "Codex skill $skill_name"
    done
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

if [ "${1:-}" = "--list" ]; then
    list_plugins
    exit 0
fi

clone_or_update_repo

SEEN_SKILLS_FILE="$(mktemp)"
trap 'rm -f "$SEEN_SKILLS_FILE"' EXIT

plugin_sources "$@" | while IFS= read -r plugin; do
    [ -n "$plugin" ] && install_plugin "$plugin"
done

echo "AI skills/plugins installed."
