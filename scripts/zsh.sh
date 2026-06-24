#!/usr/bin/env bash
# zsh.sh — Install Zsh and set as default shell
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

if has_cmd zsh; then
    log_success "Zsh already installed: $(zsh --version)"
else
    pkg_install zsh
fi

# Set zsh as default shell. Read the actual login shell from the user database
# rather than $SHELL, which stays stale within the bootstrap session after chsh.
CURRENT_SHELL="$(basename "$(current_login_shell)")"
if [[ "$CURRENT_SHELL" != "zsh" ]]; then
    ZSH_PATH="$(which zsh)"
    if [[ "${HAVE_SUDO:-false}" == true ]]; then
        # Ensure zsh is in /etc/shells
        if ! grep -qx "$ZSH_PATH" /etc/shells 2>/dev/null; then
            log_info "Adding $ZSH_PATH to /etc/shells..."
            echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
        fi
        log_info "Changing default shell to zsh..."
        sudo usermod -s "$ZSH_PATH" "$(whoami)" 2>/dev/null \
            || sudo chsh -s "$ZSH_PATH" "$(whoami)" 2>/dev/null \
            || log_warn "Could not change default shell — run 'chsh -s $(which zsh)' manually"
    else
        log_warn "No sudo — run 'chsh -s $(which zsh)' manually to set default shell"
    fi
else
    log_success "Zsh is already the default shell"
fi
