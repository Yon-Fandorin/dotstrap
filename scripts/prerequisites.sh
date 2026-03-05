#!/usr/bin/env bash
# prerequisites.sh — Install system packages
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# ─── macOS: Homebrew + Xcode CLT ─────────────────────────────────────────────

if [[ "$OS" == "macos" ]]; then
    if ! has_cmd brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew already installed"
    fi

    if ! xcode-select -p &>/dev/null; then
        log_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        log_warn "Please complete the Xcode CLT install dialog, then re-run this script."
        exit 1
    else
        log_success "Xcode CLT already installed"
    fi
fi

# ─── Build Tools ─────────────────────────────────────────────────────────────

pkg_install build-essential cmake pkg-config openssl-dev

# ─── Essential CLI ───────────────────────────────────────────────────────────

pkg_install curl wget git jq unzip zip

# ─── Modern CLI ──────────────────────────────────────────────────────────────

pkg_install ripgrep fd bat fzf tree htop zoxide eza

# ─── Other Tools ─────────────────────────────────────────────────────────────

pkg_install xclip luarocks python3 tmux stow

# ─── Ubuntu/Debian: Symlinks for fd and bat ──────────────────────────────────

if [[ "$OS" == "ubuntu" || "$OS" == "debian" ]]; then
    ensure_local_bin

    if has_cmd fdfind && ! has_cmd fd; then
        ln -sf "$(which fdfind)" "${HOME}/.local/bin/fd"
        log_success "Created symlink: fd -> fdfind"
    fi

    if has_cmd batcat && ! has_cmd bat; then
        ln -sf "$(which batcat)" "${HOME}/.local/bin/bat"
        log_success "Created symlink: bat -> batcat"
    fi
fi

log_success "Prerequisites installed"
