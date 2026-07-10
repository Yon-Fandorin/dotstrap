#!/usr/bin/env bash
# tmux.sh - Install tmux terminal multiplexer + deploy config
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Install tmux if prerequisites did not already install it.
if has_cmd tmux; then
    log_success "tmux already installed: $(tmux -V)"
else
    pkg_install tmux
    if has_cmd tmux; then
        log_success "tmux installed: $(tmux -V)"
    else
        log_warn "tmux is not installed; deploying config for future use"
    fi
fi

CONFIG_SRC="${DOTSTRAP_DIR}/configs/tmux/tmux.conf"
CONFIG_DST="${HOME}/.tmux.conf"

if [[ ! -f "$CONFIG_SRC" ]]; then
    log_error "Source not found: ${CONFIG_SRC}"
    exit 1
fi

# Render the config, substituting the resolved zsh path into default-shell.
RENDERED="$(mktemp)"
trap 'rm -f "$RENDERED"' EXIT
ZSH_PATH="$(command -v zsh 2>/dev/null || true)"
if [[ -n "$ZSH_PATH" ]]; then
    sed "s|__ZSH_PATH__|${ZSH_PATH}|g" "$CONFIG_SRC" > "$RENDERED"
else
    # No zsh — drop the line so tmux falls back to $SHELL instead of erroring.
    grep -v '__ZSH_PATH__' "$CONFIG_SRC" > "$RENDERED"
    log_warn "zsh not found; tmux default-shell left to \$SHELL"
fi

if [[ -f "$CONFIG_DST" ]] && diff -q "$RENDERED" "$CONFIG_DST" &>/dev/null; then
    log_success ".tmux.conf already up to date"
else
    cp "$RENDERED" "$CONFIG_DST"
    log_success "Deployed .tmux.conf"
fi

if ! has_cmd tmux; then
    log_warn "tmux config deployed, but tmux is not installed"
    exit 0
fi

if tmux list-sessions &>/dev/null; then
    if ! tmux source-file "$CONFIG_DST"; then
        log_error "Failed to reload ${CONFIG_DST}; fix the config and rerun scripts/tmux.sh"
        exit 1
    fi
    log_success "Reloaded .tmux.conf in the running tmux server"
fi

log_success "tmux ready"
