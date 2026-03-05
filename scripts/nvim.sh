#!/usr/bin/env bash
# nvim.sh — Install Neovim + LazyVim starter
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

NVIM_CONFIG="${HOME}/.config/nvim"

# ─── Install Neovim ──────────────────────────────────────────────────────────

install_nvim_linux() {
    local tarball

    case "$ARCH" in
        x86_64) tarball="nvim-linux-x86_64.tar.gz" ;;
        arm64)  tarball="nvim-linux-arm64.tar.gz" ;;
        *)
            log_error "Unsupported architecture: $ARCH"
            exit 1
            ;;
    esac

    local basename="${tarball%.tar.gz}"

    log_info "Downloading Neovim (${ARCH})..."
    local tmp
    tmp="$(mktemp -d)"
    curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${tarball}" \
        -o "${tmp}/${tarball}"

    if [[ "${HAVE_SUDO:-false}" == true ]]; then
        log_info "Installing Neovim to /opt/${basename}/..."
        sudo rm -rf "/opt/${basename}"
        sudo tar -xzf "${tmp}/${tarball}" -C /opt
        sudo ln -sf "/opt/${basename}/bin/nvim" /usr/local/bin/nvim
    else
        log_info "Installing Neovim to ~/.local/..."
        ensure_local_bin
        tar -xzf "${tmp}/${tarball}" -C "${HOME}/.local"
        ln -sf "${HOME}/.local/${basename}/bin/nvim" "${HOME}/.local/bin/nvim"
    fi
    rm -rf "$tmp"
}

if has_cmd nvim; then
    log_success "Neovim already installed: $(nvim --version | head -1)"
else
    case "$OS" in
        macos)
            pkg_install neovim
            ;;
        *)
            install_nvim_linux
            ;;
    esac
fi

# ─── LazyVim Starter ─────────────────────────────────────────────────────────

if [[ -d "$NVIM_CONFIG" ]]; then
    log_success "Neovim config already exists at ${NVIM_CONFIG}"
else
    log_info "Cloning LazyVim starter..."
    git clone --quiet https://github.com/LazyVim/starter "$NVIM_CONFIG"
    # Remove .git so user can manage config independently
    rm -rf "${NVIM_CONFIG}/.git"
    log_success "LazyVim starter installed"
fi

# ─── Deploy Plugin Configs ────────────────────────────────────────────────────

NVIM_PLUGINS_SRC="${DOTSTRAP_DIR}/configs/nvim/plugins"
NVIM_PLUGINS_DST="${NVIM_CONFIG}/lua/plugins"

if [[ -d "$NVIM_PLUGINS_SRC" ]]; then
    mkdir -p "$NVIM_PLUGINS_DST"
    for src in "${NVIM_PLUGINS_SRC}"/*.lua; do
        [[ ! -f "$src" ]] && continue
        dst="${NVIM_PLUGINS_DST}/$(basename "$src")"
        if [[ -f "$dst" ]] && diff -q "$src" "$dst" &>/dev/null; then
            log_success "$(basename "$src") already up to date"
        else
            cp "$src" "$dst"
            log_success "Deployed $(basename "$src")"
        fi
    done
fi

# Verify dependencies (include tool paths that may not be in current PATH)
export PATH="${HOME}/.volta/bin:${HOME}/.cargo/bin:${HOME}/.local/bin:${PATH}"
for dep in rg fd node; do
    if ! has_cmd "$dep"; then
        log_warn "Neovim dependency missing: $dep"
    fi
done

log_success "Neovim ready"
