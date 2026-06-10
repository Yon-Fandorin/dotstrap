#!/usr/bin/env bash
# claude.sh — Install/update Claude Code CLI
set -euo pipefail

DOTSTRAP_DIR="$(cd "$(dirname "$0")/.." && pwd)"
source "${DOTSTRAP_DIR}/lib/common.sh"

# Ensure npm/node are on PATH (may have been installed by volta-node.sh)
export VOLTA_HOME="${HOME}/.volta"
export PATH="${VOLTA_HOME}/bin:${PATH}"

if has_cmd claude; then
    claude_path="$(command -v claude)"
    if has_cmd volta && [[ "$claude_path" == "${VOLTA_HOME}/bin/claude" ]]; then
        log_info "Updating Claude Code via Volta..."
        volta install @anthropic-ai/claude-code@latest
    else
        log_info "Updating Claude Code..."
        claude update || log_warn "Claude update failed — may already be latest"
    fi
else
    log_info "Installing Claude Code CLI..."
    if has_cmd volta; then
        volta install @anthropic-ai/claude-code@latest
    elif has_cmd npm; then
        npm install -g @anthropic-ai/claude-code
    else
        log_error "npm not found — install Node.js first (run volta-node.sh)"
        exit 1
    fi
fi

# ─── Deploy statusline ──────────────────────────────────────────────────────

CLAUDE_SRC="${DOTSTRAP_DIR}/configs/claude"
CLAUDE_DST="${HOME}/.claude"

mkdir -p "${CLAUDE_DST}"

deploy_file() {
    local src="$1" dst="$2" mode="${3:-644}"
    if [[ ! -f "$src" ]]; then
        log_error "Source not found: ${src}"
        return 1
    fi
    if [[ -f "$dst" ]] && diff -q "$src" "$dst" &>/dev/null; then
        log_success "$(basename "$dst") already up to date"
    else
        install -m "$mode" "$src" "$dst"
        log_success "Deployed $(basename "$dst")"
    fi
}

deploy_file "${CLAUDE_SRC}/statusline.sh" "${CLAUDE_DST}/statusline.sh" 755

# ─── Activate statusline in settings.json ───────────────────────────────────

SETTINGS="${CLAUDE_DST}/settings.json"
STATUSLINE_CMD="bash ${CLAUDE_DST}/statusline.sh"

if has_cmd jq; then
    if [[ -f "$SETTINGS" ]]; then
        tmp="$(mktemp)"
        jq --arg cmd "$STATUSLINE_CMD" \
           '.statusLine = {type: "command", command: $cmd}' \
           "$SETTINGS" > "$tmp" && mv "$tmp" "$SETTINGS"
    else
        jq -n --arg cmd "$STATUSLINE_CMD" \
           '{statusLine: {type: "command", command: $cmd}}' \
           > "$SETTINGS"
    fi
    log_success "statusLine activated in settings.json"
else
    log_warn "jq not found — skipping settings.json update; add .statusLine manually"
fi

log_success "Claude Code ready"
