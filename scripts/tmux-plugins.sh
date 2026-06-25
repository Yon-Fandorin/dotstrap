#!/usr/bin/env bash
# tmux-plugins.sh — tmux session persistence (resurrect + continuum) and the
# sesh session manager. No TPM: plugins are cloned directly and sourced from
# tmux.conf via run-shell. fzf and zoxide (sesh's deps) are installed elsewhere.
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# ─── tmux-resurrect + tmux-continuum (pure shell, no TPM) ────────────────────
PLUGIN_DIR="${HOME}/.config/tmux/plugins"
mkdir -p "$PLUGIN_DIR"
git_clone_or_pull "https://github.com/tmux-plugins/tmux-resurrect" "${PLUGIN_DIR}/tmux-resurrect"
git_clone_or_pull "https://github.com/tmux-plugins/tmux-continuum" "${PLUGIN_DIR}/tmux-continuum"
log_success "tmux-resurrect + tmux-continuum ready"

# ─── sesh (session manager) ──────────────────────────────────────────────────
if has_cmd sesh; then
    log_success "sesh already installed: $(command -v sesh)"
elif [[ "$OS" == "macos" ]]; then
    pkg_install sesh                      # Homebrew has sesh
elif has_cmd go; then
    log_info "Installing sesh via go install..."
    go install github.com/joshmedeski/sesh/v2@latest
    GOBIN="$(go env GOBIN)"; [[ -z "$GOBIN" ]] && GOBIN="$(go env GOPATH)/bin"
    # Symlink into ~/.local/bin so sesh is on PATH — unless go already installed
    # it there (GOBIN=~/.local/bin), which would make ln self-reference and fail.
    if [[ -x "${GOBIN}/sesh" && "${GOBIN}/sesh" != "${HOME}/.local/bin/sesh" ]]; then
        ensure_local_bin
        ln -sf "${GOBIN}/sesh" "${HOME}/.local/bin/sesh"
    fi
else
    log_warn "sesh not installed: need Homebrew (macOS) or Go. See https://github.com/joshmedeski/sesh"
fi

if has_cmd sesh; then
    log_success "sesh ready: $(command -v sesh)"
else
    log_warn "sesh unavailable — the 'prefix + T' binding will be a no-op until installed"
fi
