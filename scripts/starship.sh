#!/usr/bin/env bash
# starship.sh — Install/update Starship prompt + deploy config
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Install or update Starship
if has_cmd starship; then
    log_info "Updating Starship..."
else
    log_info "Installing Starship..."
fi

if [[ "${HAVE_SUDO:-false}" == true ]]; then
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
else
    # Install to ~/.local/bin without sudo
    ensure_local_bin
    curl -fsSL https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${HOME}/.local/bin"
fi

# Deploy starship.toml
CONFIG_SRC="${DOTSTRAP_DIR}/configs/starship.toml"
CONFIG_DST="${HOME}/.config/starship.toml"

if [[ -f "$CONFIG_SRC" ]]; then
    mkdir -p "${HOME}/.config"
    if [[ -f "$CONFIG_DST" ]] && diff -q "$CONFIG_SRC" "$CONFIG_DST" &>/dev/null; then
        log_success "starship.toml already up to date"
    else
        cp "$CONFIG_SRC" "$CONFIG_DST"
        log_success "Deployed starship.toml"
    fi
fi

log_success "Starship ready"
