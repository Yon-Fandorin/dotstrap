#!/usr/bin/env bash
# zshrc.sh — Generate ~/.zshrc from template (must run last)
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

TEMPLATE="${DOTSTRAP_DIR}/configs/zshrc.template"
TARGET="${HOME}/.zshrc"

if [[ ! -f "$TEMPLATE" ]]; then
    log_error "Template not found: ${TEMPLATE}"
    exit 1
fi

# Back up existing .zshrc if it differs
if [[ -f "$TARGET" ]]; then
    if diff -q "$TEMPLATE" "$TARGET" &>/dev/null; then
        log_success ".zshrc already up to date"
        exit 0
    fi
    BACKUP="${TARGET}.bak.$(date '+%Y%m%d%H%M%S')"
    cp "$TARGET" "$BACKUP"
    log_info "Backed up existing .zshrc to ${BACKUP}"
fi

cp "$TEMPLATE" "$TARGET"
log_success "Generated ${TARGET} from template"
