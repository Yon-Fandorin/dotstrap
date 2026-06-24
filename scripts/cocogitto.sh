#!/usr/bin/env bash
# cocogitto.sh — Install cocogitto (cog) and enable Conventional Commits
# enforcement on a dotstrap clone. This is a repo-only dev tool, not part of
# machine provisioning, so it is NOT wired into bootstrap.sh. Run it manually
# when you intend to commit to this repo:  bash scripts/cocogitto.sh
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Install cocogitto: native package on Arch/macOS, cargo elsewhere.
if has_cmd cog; then
    log_success "cocogitto already installed: $(cog --version)"
else
    pkg_install cocogitto
    if ! has_cmd cog; then
        if has_cmd cargo; then
            log_info "Installing cocogitto via cargo..."
            cargo install --locked cocogitto
        else
            log_warn "cocogitto unavailable and cargo missing; run rust.sh first"
        fi
    fi
fi

# Install the commit-msg hook so this repo's commits are validated against
# Conventional Commits. Hooks live in .git/hooks and are not tracked, so this
# runs per clone.
if has_cmd cog && [[ -d "${DOTSTRAP_DIR}/.git" ]]; then
    if ( cd "$DOTSTRAP_DIR" && cog install-hook --overwrite commit-msg ); then
        log_success "Installed cocogitto commit-msg hook"
    else
        log_warn "Could not install cocogitto commit-msg hook"
    fi
fi
