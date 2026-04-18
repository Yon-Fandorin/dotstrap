#!/usr/bin/env bash
# Claude Code statusline — model · effort · tokens · context

input=$(cat)

# ── Model ────────────────────────────────────────────────────────────────
model_disp=$(printf '%s' "$input" | jq -r '.model.display_name // ""')
ctx_size=$(printf '%s' "$input"   | jq -r '.context_window.context_window_size // 200000')

# "Opus 4.6 (1M context)" → "opus-4.6"
if [ -n "$model_disp" ]; then
  short_model=$(printf '%s' "$model_disp" \
    | sed 's/^Claude //' \
    | sed 's/ (.*)//' \
    | sed 's/ \([0-9]\)/-\1/' \
    | tr '[:upper:]' '[:lower:]')
else
  model_id=$(printf '%s' "$input" | jq -r '.model.id // "unknown"')
  short_model=$(printf '%s' "$model_id" | sed 's/^claude-//' | sed 's/\[.*//')
fi

if [ "${ctx_size:-0}" -ge 800000 ] 2>/dev/null; then
  short_model="${short_model} 1M"
fi

# ── Effort ───────────────────────────────────────────────────────────────
# Priority: transcript (session-aware) → env var → settings.json → default
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')
effort=""

if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  effort=$(grep -oE 'effort level (to |: )(low|medium|xhigh|high|max|auto)' "$transcript" 2>/dev/null \
    | tail -1 \
    | grep -oE '(low|medium|xhigh|high|max|auto)$')
fi

[ -z "$effort" ] && effort="${CLAUDE_CODE_EFFORT_LEVEL:-}"
[ -z "$effort" ] && effort=$(jq -r '.effortLevel // ""' ~/.claude/settings.json 2>/dev/null)
[ -z "$effort" ] && effort="high"

# ── Tokens & Cost ────────────────────────────────────────────────────────
in_tok=$(printf '%s' "$input"  | jq -r '.context_window.total_input_tokens // 0')
out_tok=$(printf '%s' "$input" | jq -r '.context_window.total_output_tokens // 0')
cost_usd=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // 0')

fmt_num() {
  awk "BEGIN {
    n = $1 + 0
    if (n >= 1000000) printf \"%.1fM\", n/1000000
    else if (n >= 1000) printf \"%.1fk\", n/1000
    else printf \"%d\", n
  }"
}

in_str=$(fmt_num "$in_tok")
out_str=$(fmt_num "$out_tok")
cost_str=$(awk "BEGIN { printf \"\$%.2f\", $cost_usd + 0 }")

# ── Context bar ──────────────────────────────────────────────────────────
used_raw=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // 0')
used_int=$(printf "%.0f" "$used_raw" 2>/dev/null || echo "0")

filled=$(( used_int * 10 / 100 ))
[ "$filled" -gt 10 ] && filled=10
bar=""
i=0; while [ $i -lt $filled ];            do bar="${bar}█"; i=$(( i + 1 )); done
i=0; while [ $i -lt $(( 10 - filled )) ]; do bar="${bar}░"; i=$(( i + 1 )); done

# ── ANSI colors ──────────────────────────────────────────────────────────
R=$'\033[0m'
B=$'\033[1m'
D=$'\033[2m'
WH=$'\033[97m'
GY=$'\033[90m'
OR=$'\033[38;5;208m'
YE=$'\033[33m'
GN=$'\033[32m'
RD=$'\033[31m'
CY=$'\033[36m'

case "$effort" in
  max)            esym="⚡"; ecol="$OR" ;;
  xhigh)          esym="⇈";  ecol="$OR" ;;
  high)           esym="↑";  ecol="$YE" ;;
  medium|med)     esym="≈";  ecol="$GY" ;;
  low)            esym="↓";  ecol="$GY" ;;
  *)              esym="·";  ecol="$GY" ;;
esac

if   [ "$used_int" -ge 90 ]; then bcol="$RD"
elif [ "$used_int" -ge 70 ]; then bcol="$YE"
else                               bcol="$GN"
fi

# ↑ = input (to model), ↓ = output (from model)
printf "${D}◆${R} ${B}${WH}%s${R}  ${ecol}%s %s${R}  ${D}↑${R}${CY}%s ${D}↓${R}${CY}%s${R} ${D}%s${R}  ${bcol}%s %d%%${R}\n" \
  "$short_model" "$esym" "$effort" "$in_str" "$out_str" "$cost_str" "$bar" "$used_int"
