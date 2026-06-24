#!/usr/bin/env bash
# common.sh — Shared library for setup scripts
# Provides: OS/arch detection, package manager abstraction, logging, idempotency helpers

set -euo pipefail

# ─── Logging ──────────────────────────────────────────────────────────────────

DOTSTRAP_LOG="${HOME}/.dotstrap.log"

_log() {
    local level="$1" color="$2" msg="$3"
    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
    printf "%b[%s]%b %s\n" "$color" "$level" "\033[0m" "$msg" >&2
    printf "[%s] [%s] %s\n" "$timestamp" "$level" "$msg" >> "$DOTSTRAP_LOG"
}

log_info()    { _log "INFO"    "\033[0;34m" "$*"; }
log_success() { _log "OK"      "\033[0;32m" "$*"; }
log_warn()    { _log "WARN"    "\033[0;33m" "$*"; }
log_error()   { _log "ERROR"   "\033[0;31m" "$*"; }

# ─── OS / Architecture Detection ─────────────────────────────────────────────

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "macos" ;;
        Linux)
            if [[ -f /etc/os-release ]]; then
                # shellcheck source=/dev/null
                source /etc/os-release
                case "${ID:-}" in
                    ubuntu)         echo "ubuntu" ;;
                    debian)         echo "debian" ;;
                    fedora)         echo "fedora" ;;
                    rhel|centos|rocky|alma) echo "fedora" ;;
                    arch|manjaro)   echo "arch" ;;
                    *)              echo "unknown" ;;
                esac
            else
                echo "unknown"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo "x86_64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             echo "$(uname -m)" ;;
    esac
}

OS="$(detect_os)"
ARCH="$(detect_arch)"

# ─── Package Name Mapping ────────────────────────────────────────────────────
# Maps logical package names to OS-specific names.
# Format: map_pkg <logical-name> → prints OS-specific name (or empty to skip)

map_pkg() {
    local name="$1"
    case "$name" in
        build-essential)
            case "$OS" in
                macos)          echo "" ;;  # handled separately (Xcode CLT)
                ubuntu|debian)  echo "build-essential" ;;
                fedora)         echo "gcc gcc-c++ make" ;;
                arch)           echo "base-devel" ;;
            esac
            ;;
        openssl-dev)
            case "$OS" in
                macos)          echo "openssl" ;;
                ubuntu|debian)  echo "libssl-dev" ;;
                fedora)         echo "openssl-devel" ;;
                arch)           echo "openssl" ;;
            esac
            ;;
        pkg-config)
            case "$OS" in
                fedora|arch)    echo "pkgconf" ;;
                *)              echo "pkg-config" ;;
            esac
            ;;
        fd)
            case "$OS" in
                ubuntu|debian|fedora) echo "fd-find" ;;
                *)                    echo "fd" ;;
            esac
            ;;
        xclip)
            case "$OS" in
                macos) echo "" ;;  # macOS uses pbcopy/pbpaste
                *)     echo "xclip" ;;
            esac
            ;;
        python3)
            case "$OS" in
                ubuntu|debian)  echo "python3 python3-pip python3-venv" ;;
                *)              echo "python3" ;;
            esac
            ;;
        *)
            echo "$name"
            ;;
    esac
}

# ─── Package Manager Abstraction ─────────────────────────────────────────────

pkg_install() {
    local names=("$@")
    local to_install=()

    for name in "${names[@]}"; do
        local mapped
        mapped="$(map_pkg "$name")"
        [[ -z "$mapped" ]] && continue
        # mapped may contain multiple space-separated packages
        # shellcheck disable=SC2206
        to_install+=($mapped)
    done

    [[ ${#to_install[@]} -eq 0 ]] && return 0

    log_info "Installing: ${to_install[*]}"

    case "$OS" in
        macos)
            brew install "${to_install[@]}" 2>/dev/null || brew upgrade "${to_install[@]}" 2>/dev/null || true
            ;;
        ubuntu|debian)
            if [[ "${HAVE_SUDO:-false}" == true ]]; then
                sudo apt-get install -y "${to_install[@]}"
            else
                log_warn "Skipping apt install (no sudo): ${to_install[*]}"
                return 0
            fi
            ;;
        fedora)
            if [[ "${HAVE_SUDO:-false}" == true ]]; then
                sudo dnf install -y "${to_install[@]}"
            else
                log_warn "Skipping dnf install (no sudo): ${to_install[*]}"
                return 0
            fi
            ;;
        arch)
            if [[ "${HAVE_SUDO:-false}" == true ]]; then
                sudo pacman -S --noconfirm --needed "${to_install[@]}"
            else
                log_warn "Skipping pacman install (no sudo): ${to_install[*]}"
                return 0
            fi
            ;;
        *)
            log_error "Unsupported OS: $OS"
            return 1
            ;;
    esac
}

# ─── Idempotency Helpers ─────────────────────────────────────────────────────

has_cmd() {
    command -v "$1" &>/dev/null
}

# Print the user's login shell from the system database (not $SHELL, which is
# fixed at login time and goes stale after chsh until the next full re-login).
# Falls back to $SHELL when no user database is available.
current_login_shell() {
    local user shell=""
    user="$(whoami)"
    if has_cmd getent; then
        shell="$(getent passwd "$user" | cut -d: -f7)"
    elif has_cmd dscl; then
        shell="$(dscl . -read "/Users/$user" UserShell 2>/dev/null | awk '{print $2}')"
    fi
    echo "${shell:-${SHELL:-}}"
}

# Clone a git repo if not present; pull if already cloned.
git_clone_or_pull() {
    local repo="$1" dest="$2"
    if [[ -d "$dest/.git" ]]; then
        log_info "Updating $(basename "$dest")..."
        git -C "$dest" pull --quiet 2>/dev/null || true
    else
        log_info "Cloning $(basename "$dest")..."
        git clone --quiet --depth 1 "$repo" "$dest"
    fi
}

# Ensure ~/.local/bin exists
ensure_local_bin() {
    mkdir -p "${HOME}/.local/bin"
}
