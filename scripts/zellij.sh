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

CONFIG_SRC="${DOTSTRAP_DIR}/configs/zellij/config.kdl"
CONFIG_DST="${HOME}/.config/zellij/config.kdl"

if [[ -f "$CONFIG_SRC" ]]; then
    mkdir -p "${HOME}/.config/zellij"
    if [[ -f "$CONFIG_DST" ]] && diff -q "$CONFIG_SRC" "$CONFIG_DST" &>/dev/null; then
        log_success "zellij config already up to date"
    else
        cp "$CONFIG_SRC" "$CONFIG_DST"
        log_success "Deployed zellij config"
    fi
fi

log_success "Zellij ready"
