#!/usr/bin/env bash
# codex.sh - Install/update Codex CLI
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

ensure_local_bin
export PATH="${HOME}/.local/bin:${PATH}"

INSTALL_URL="https://chatgpt.com/codex/install.sh"

tmp="$(mktemp -d)"
cleanup() {
    rm -rf "$tmp"
}
trap cleanup EXIT

installer="${tmp}/codex-install.sh"

log_info "Downloading Codex installer..."
if has_cmd curl; then
    curl -fsSL "$INSTALL_URL" -o "$installer"
elif has_cmd wget; then
    wget -q -O "$installer" "$INSTALL_URL"
else
    log_error "curl or wget is required to install Codex"
    exit 1
fi

log_info "Installing/updating Codex CLI..."
CODEX_NON_INTERACTIVE=true \
CODEX_INSTALL_DIR="${HOME}/.local/bin" \
    sh "$installer"

if has_cmd codex; then
    log_success "Codex ready: $(codex --version)"
else
    log_warn "Codex installer completed, but codex is not on PATH"
fi
