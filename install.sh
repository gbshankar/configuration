#!/usr/bin/env bash
set -euo pipefail

# Idempotent dotfiles installer
# Creates symlinks from ~/personal/configuration/overhaul to home directory
# Silently skips existing symlinks that point to the correct location

REPO_DIR="${HOME}/personal/configuration/overhaul"
LINKS=(
    ".tmux.conf:tmux.conf"
    ".config/git/config:gitconfig"
    ".zshrc:zshrc"
    ".config/starship.toml:starship.toml"
    ".config/atuin/config.toml:atuin.toml"
    ".config/nvim/init.lua:nvim/init.lua"
    ".local/bin/tmux-sessionizer:tmux-sessionizer"
)

main() {
    for link_spec in "${LINKS[@]}"; do
        IFS=':' read -r target source <<< "$link_spec"
        local_path="${HOME}/${target}"
        repo_path="${REPO_DIR}/${source}"

        # Create parent directory if needed
        mkdir -p "$(dirname "$local_path")"

        # Skip if symlink already points to the correct location
        if [[ -L "$local_path" ]] && [[ "$(readlink "$local_path")" == "$repo_path" ]]; then
            continue
        fi

        # Remove existing file/symlink if it exists
        if [[ -e "$local_path" ]] || [[ -L "$local_path" ]]; then
            rm -f "$local_path"
        fi

        # Create the symlink
        ln -s "$repo_path" "$local_path"
    done
}

main "$@"
