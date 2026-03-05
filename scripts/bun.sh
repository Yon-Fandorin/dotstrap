#!/usr/bin/env bash
# bun.sh — Install/update Bun runtime
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

export BUN_INSTALL="${HOME}/.bun"
export PATH="${BUN_INSTALL}/bin:${PATH}"

if has_cmd bun; then
    log_info "Updating Bun..."
    bun upgrade || true
else
    log_info "Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="${BUN_INSTALL}/bin:${PATH}"
fi

log_success "Bun ready: $(bun --version)"
