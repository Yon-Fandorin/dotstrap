#!/usr/bin/env bash
# zellij.sh — Install Zellij terminal multiplexer + deploy config
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# ─── Install Zellij ─────────────────────────────────────────────────────────

install_zellij_linux() {
    local tarball

    case "$ARCH" in
        x86_64) tarball="zellij-x86_64-unknown-linux-musl.tar.gz" ;;
        arm64)  tarball="zellij-aarch64-unknown-linux-musl.tar.gz" ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    log_info "Downloading Zellij (${ARCH})..."
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/zellij-org/zellij/releases/latest/download/${tarball}" \
        -o "${tmp}/${tarball}"

    tar -xzf "${tmp}/${tarball}" -C "${tmp}"

    if [[ "${HAVE_SUDO:-false}" == true ]]; then
        sudo install -m 755 "${tmp}/zellij" /usr/local/bin/zellij
    else
        ensure_local_bin
        install -m 755 "${tmp}/zellij" "${HOME}/.local/bin/zellij"
    fi
    rm -rf "$tmp"
}

if has_cmd zellij; then
    log_success "Zellij already installed: $(zellij --version)"
else
    case "$OS" in
        macos)
            pkg_install zellij
            ;;
        *)
            install_zellij_linux
            ;;
    esac
fi

# ─── Deploy Config ──────────────────────────────────────────────────────────

ZELLIJ_SRC="${DOTSTRAP_DIR}/configs/zellij"
ZELLIJ_DST="${HOME}/.config/zellij"

mkdir -p "${ZELLIJ_DST}/plugins" "${ZELLIJ_DST}/layouts"

# Deploy config, layouts, and plugins
deploy_file() {
    local src="$1" dst="$2"
    if [[ ! -f "$src" ]]; then
        log_error "Source not found: ${src}"
        return 1
    fi
    if [[ -f "$dst" ]] && diff -q "$src" "$dst" &>/dev/null; then
        log_success "$(basename "$dst") already up to date"
    else
        cp "$src" "$dst"
        log_success "Deployed $(basename "$dst")"
    fi
}

deploy_file "${ZELLIJ_SRC}/config.kdl" "${ZELLIJ_DST}/config.kdl"
deploy_file "${ZELLIJ_SRC}/themes/zjstatus/catppuccin-mocha.kdl" "${ZELLIJ_DST}/layouts/catppuccin-mocha.kdl"
deploy_file "${ZELLIJ_SRC}/plugins/zjstatus.wasm" "${ZELLIJ_DST}/plugins/zjstatus.wasm"
deploy_file "${ZELLIJ_SRC}/plugins/zellij_forgot.wasm" "${ZELLIJ_DST}/plugins/zellij_forgot.wasm"

log_success "Zellij ready"
