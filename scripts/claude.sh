#!/usr/bin/env bash
# claude.sh — Install/update Claude Code CLI
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Ensure npm/node are on PATH (may have been installed by volta-node.sh)
export VOLTA_HOME="${HOME}/.volta"
export PATH="${VOLTA_HOME}/bin:${PATH}"

if has_cmd claude; then
    log_info "Updating Claude Code..."
    claude update || log_warn "Claude update failed — may already be latest"
else
    log_info "Installing Claude Code CLI..."
    if has_cmd npm; then
        npm install -g @anthropic-ai/claude-code
    else
        log_error "npm not found — install Node.js first (run volta-node.sh)"
        exit 1
    fi
fi

log_success "Claude Code ready"
