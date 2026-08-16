#!/bin/bash
# Claude Code status line
# Reads the session JSON Claude Code provides on stdin and prints a
# single-line status: model · directory · git branch (+dirty marker) ·
# context window usage · (optional) Claude.ai 5h rate-limit usage ·
# (optional) non-default output style.

input=$(cat)

model=$(printf '%s' "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // "."')
dir_name=$(basename "$cwd")
style=$(printf '%s' "$input" | jq -r '.output_style.name // empty')

# Git info (skip optional locks so we never block on a git lock file)
git_segment=""
if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
  dirty=""
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    dirty="*"
  fi
  if [ -n "$branch" ]; then
    git_segment="${branch}${dirty}"
  fi
fi

# Context window usage (pre-calculated percentage used)
ctx_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
ctx_segment=""
if [ -n "$ctx_pct" ]; then
  ctx_segment=$(printf 'ctx %.0f%%' "$ctx_pct")
fi

# Claude.ai subscription 5-hour rate limit usage, when available
five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
limit_segment=""
if [ -n "$five_hour" ]; then
  limit_segment=$(printf '5h %.0f%%' "$five_hour")
fi

# Colors (dim variants so the line stays readable against dark/light themes)
DIM='\033[2m'
CYAN='\033[2;36m'
GREEN='\033[2;32m'
YELLOW='\033[2;33m'
BLUE='\033[2;34m'
RESET='\033[0m'

line=$(printf '%b' "${CYAN}${model}${RESET} ${DIM}·${RESET} ${GREEN}${dir_name}${RESET}")

if [ -n "$git_segment" ]; then
  line="${line} $(printf '%b' "${DIM}·${RESET} ${YELLOW}${git_segment}${RESET}")"
fi

if [ -n "$ctx_segment" ]; then
  line="${line} $(printf '%b' "${DIM}·${RESET} ${BLUE}${ctx_segment}${RESET}")"
fi

if [ -n "$limit_segment" ]; then
  line="${line} $(printf '%b' "${DIM}·${RESET} ${DIM}${limit_segment}${RESET}")"
fi

if [ -n "$style" ] && [ "$style" != "default" ]; then
  line="${line} $(printf '%b' "${DIM}·${RESET} ${DIM}${style}${RESET}")"
fi

printf '%s' "$line"
