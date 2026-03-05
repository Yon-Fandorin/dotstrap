#!/usr/bin/env bash
# volta-node.sh — Install Volta + Node LTS
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Ensure Volta is on PATH for this session
export VOLTA_HOME="${HOME}/.volta"
export PATH="${VOLTA_HOME}/bin:${PATH}"

if has_cmd volta; then
    log_success "Volta already installed"
else
    log_info "Installing Volta..."
    curl -fsSL https://get.volta.sh | bash -s -- --skip-setup
    export PATH="${VOLTA_HOME}/bin:${PATH}"
fi

# Install Node LTS
log_info "Installing Node LTS via Volta..."
volta install node@lts

log_success "Volta + Node ready: node $(node --version)"
