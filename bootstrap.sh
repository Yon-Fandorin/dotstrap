#!/usr/bin/env bash
# bootstrap.sh — Main orchestrator for development environment setup
# Usage:
#   ./bootstrap.sh              # Run all scripts in order
#   ./bootstrap.sh rust.sh nvim.sh  # Run only specified scripts

set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source common library
# shellcheck source=lib/common.sh
source "${DOTSTRAP_DIR}/lib/common.sh"

# ─── Execution Order ─────────────────────────────────────────────────────────
# Explicit ordering — do not rely on glob or filename sorting.

SCRIPTS=(
    prerequisites.sh
    zsh.sh
    zsh-plugins.sh
    starship.sh
    rust.sh
    volta-node.sh
    bun.sh
    claude.sh
    nvim.sh
    zellij.sh
    zshrc.sh    # must be last — generates .zshrc referencing all tools above
)

# ─── Selective Execution ─────────────────────────────────────────────────────

if [[ $# -gt 0 ]]; then
    SCRIPTS=()
    for arg in "$@"; do
        [[ "$arg" != *.sh ]] && arg="${arg}.sh"
        SCRIPTS+=("$arg")
    done
fi

# ─── Pre-flight Checks ──────────────────────────────────────────────────────

log_info "Detected OS=$OS  ARCH=$ARCH"
log_info "Log: $DOTSTRAP_LOG"

# Cache sudo credentials up front (skip if not needed or unavailable)
if [[ "$OS" != "macos" ]] && command -v sudo &>/dev/null; then
    log_info "Requesting sudo credentials..."
    if sudo -v 2>/dev/null; then
        HAVE_SUDO=true
    else
        HAVE_SUDO=false
        log_warn "sudo not available — some steps may be skipped"
    fi
else
    HAVE_SUDO=false
fi
export HAVE_SUDO

# Update package index once
if [[ "$HAVE_SUDO" == true ]]; then
    case "$OS" in
        ubuntu|debian) sudo apt-get update -y ;;
        fedora)        sudo dnf check-update -y || true ;;
        arch)          sudo pacman -Sy --noconfirm ;;
    esac
fi

# ─── Run Scripts ─────────────────────────────────────────────────────────────

FAILED=()

for script in "${SCRIPTS[@]}"; do
    script_path="${DOTSTRAP_DIR}/scripts/${script}"

    if [[ ! -f "$script_path" ]]; then
        log_error "Script not found: ${script}"
        FAILED+=("$script")
        continue
    fi

    log_info "━━━ Running ${script} ━━━"

    if bash "$script_path"; then
        log_success "Completed ${script}"
    else
        log_error "Failed ${script}"
        FAILED+=("$script")
    fi
done

# ─── Summary ─────────────────────────────────────────────────────────────────

echo ""
if [[ ${#FAILED[@]} -eq 0 ]]; then
    log_success "All scripts completed successfully!"
else
    log_warn "The following scripts had errors:"
    for f in "${FAILED[@]}"; do
        log_warn "  - ${f}"
    done
fi

log_info "Run 'exec zsh' to reload your shell."
