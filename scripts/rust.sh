#!/usr/bin/env bash
# rust.sh — Install/update Rust via rustup
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Ensure cargo/rustup are on PATH for this session
[[ -f "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"

if has_cmd rustup; then
    log_info "Updating Rust toolchain..."
    rustup update stable
else
    log_info "Installing Rust via rustup..."
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
    source "${HOME}/.cargo/env"
fi

log_success "Rust ready: $(rustc --version)"
