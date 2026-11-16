#!/usr/bin/env bash
# emacs.sh — Install GNU Emacs for terminal editing
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

if has_cmd emacs; then
    log_success "Emacs already installed: $(emacs --version | sed -n '1p')"
else
    pkg_install emacs

    # Package installation may be skipped without sudo or fail under Homebrew.
    if ! has_cmd emacs; then
        log_error "Emacs was not installed. Check package manager access and re-run emacs.sh."
        exit 1
    fi
fi

log_success "Emacs ready — run 'emacs -nw' to edit in the terminal"
