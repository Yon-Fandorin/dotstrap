#!/usr/bin/env bash
# zsh-plugins.sh — Install/update Zsh plugins (no plugin manager)
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

ZSH_DIR="${HOME}/.zsh"
mkdir -p "$ZSH_DIR"

PLUGINS=(
    "zsh-autosuggestions   https://github.com/zsh-users/zsh-autosuggestions.git"
    "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "zsh-completions       https://github.com/zsh-users/zsh-completions.git"
    "zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search.git"
    "fzf-tab               https://github.com/Aloxaf/fzf-tab.git"
    "zsh-you-should-use    https://github.com/MichaelAquilina/zsh-you-should-use.git"
)

for entry in "${PLUGINS[@]}"; do
    name="${entry%% *}"
    url="${entry##* }"
    git_clone_or_pull "$url" "${ZSH_DIR}/${name}"
done

log_success "Zsh plugins installed/updated"
