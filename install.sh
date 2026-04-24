#!/usr/bin/env bash
# install.sh — idempotent symlink installer for dotfiles
# Usage: bash ~/personal/configuration/install.sh
# Safe to re-run. Backs up existing files to <file>.bak before linking.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

symlink() {
    local src="$REPO_DIR/$1"
    local dst="$2"

    # Ensure parent directory exists
    mkdir -p "$(dirname "$dst")"

    # If target exists and is not already the correct symlink
    if [[ -e "$dst" ]] && [[ ! -L "$dst" ]]; then
        echo -e "${YELLOW}Backing up${NC} $dst → $dst.bak"
        [[ -e "$dst.bak" ]] && rm -rf "$dst.bak"
        mv "$dst" "$dst.bak"
    elif [[ -L "$dst" ]]; then
        local current
        current="$(readlink "$dst")"
        if [[ "$current" == "$src" ]]; then
            echo -e "${GREEN}Already linked${NC}: $dst"
            return
        else
            echo -e "${YELLOW}Removing stale symlink${NC} $dst (was → $current)"
            rm "$dst"
        fi
    fi

    echo -e "${GREEN}Linking${NC}: $dst → $src"
    ln -s "$src" "$dst"
}

echo "Installing dotfiles from $REPO_DIR"
echo ""

# Shell
symlink zshrc          ~/.zshrc
symlink alias          ~/.alias
symlink ripgreprc      ~/.ripgreprc

# Git
symlink gitconfig      ~/.gitconfig

# Tmux
symlink tmux.conf      ~/.tmux.conf

# Neovim
symlink config/nvim    ~/.config/nvim

# Starship
symlink config/starship.toml ~/.config/starship.toml

# mise
symlink config/mise/config.toml ~/.config/mise/config.toml

# atuin
symlink config/atuin/config.toml ~/.config/atuin/config.toml

echo ""
echo "Done. Open a new terminal or run: source ~/.zshrc"
