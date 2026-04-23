#!/usr/bin/env bash
# Claude Code status line script
# Reads JSON from stdin and outputs a formatted status line

input=$(cat)

# --- Extract fields from JSON ---
cwd=$(echo "$input"   | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Context window
ctx_used=$(echo "$input"      | jq -r '.context_window.used_percentage // empty')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
ctx_size=$(echo "$input"      | jq -r '.context_window.context_window_size // empty')
in_tokens=$(echo "$input"     | jq -r '.context_window.current_usage.input_tokens // empty')
out_tokens=$(echo "$input"    | jq -r '.context_window.current_usage.output_tokens // empty')
cache_read=$(echo "$input"    | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_write=$(echo "$input"   | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
total_in=$(echo "$input"      | jq -r '.context_window.total_input_tokens // empty')
total_out=$(echo "$input"     | jq -r '.context_window.total_output_tokens // empty')

# Rate limits
five_pct=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage // empty')

# --- Derive display values ---
dir_name=$(basename "$cwd")
user=$(whoami)
current_time=$(date +%H:%M:%S)

# Git branch (skip lock, fall back gracefully)
git_branch=""
if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
                 || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- ANSI colour codes ---
RESET="\033[0m"
BOLD="\033[1m"
DIM="\033[2m"
CYAN="\033[36m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
RED="\033[31m"
WHITE="\033[37m"

# --- Build status line ---
line=""

# User
line+="$(printf "${GREEN}%s${RESET}" "$user")"

# Directory
line+=" $(printf "${CYAN}${BOLD}%s${RESET}" "$dir_name")"

# Git branch (only when inside a repo)
if [ -n "$git_branch" ]; then
    line+=" $(printf "${YELLOW}(%s)${RESET}" "$git_branch")"
fi

# Model
if [ -n "$model" ]; then
    line+=" $(printf "${MAGENTA}[%s]${RESET}" "$model")"
fi

# Time
line+=" $(printf "${BLUE}%s${RESET}" "$current_time")"

# Context window usage
if [ -n "$ctx_used" ] && [ -n "$ctx_remaining" ]; then
    # Pick colour based on usage level
    if   (( $(echo "$ctx_used >= 80" | bc -l 2>/dev/null || [ "${ctx_used%%.*}" -ge 80 ] && echo 1 || echo 0) )); then
        ctx_color="$RED"
    elif (( $(echo "$ctx_used >= 50" | bc -l 2>/dev/null || [ "${ctx_used%%.*}" -ge 50 ] && echo 1 || echo 0) )); then
        ctx_color="$YELLOW"
    else
        ctx_color="$GREEN"
    fi
    used_fmt=$(printf "%.0f" "$ctx_used")
    rem_fmt=$(printf "%.0f" "$ctx_remaining")
    line+=" $(printf "${DIM}ctx:${RESET}${ctx_color}${used_fmt}%%${RESET}${DIM}(${rem_fmt}%% left)${RESET}")"
fi

# Per-call token detail (only when data is present)
if [ -n "$in_tokens" ]; then
    tok_parts=""
    [ -n "$in_tokens" ]    && tok_parts+="in:${in_tokens}"
    [ -n "$out_tokens" ]   && tok_parts+=" out:${out_tokens}"
    [ -n "$cache_read" ]   && [ "$cache_read"  != "0" ] && tok_parts+=" cr:${cache_read}"
    [ -n "$cache_write" ]  && [ "$cache_write" != "0" ] && tok_parts+=" cw:${cache_write}"
    line+=" $(printf "${DIM}[%s]${RESET}" "$tok_parts")"
fi

# Session cumulative totals
if [ -n "$total_in" ] && [ -n "$total_out" ]; then
    line+=" $(printf "${DIM}total↑%s↓%s${RESET}" "$total_in" "$total_out")"
fi

# Context window size
if [ -n "$ctx_size" ]; then
    line+=" $(printf "${DIM}/%s${RESET}" "$ctx_size")"
fi

# Rate limits
rate_str=""
if [ -n "$five_pct" ]; then
    five_fmt=$(printf "%.0f" "$five_pct")
    rate_str+="5h:${five_fmt}%"
fi
if [ -n "$week_pct" ]; then
    week_fmt=$(printf "%.0f" "$week_pct")
    [ -n "$rate_str" ] && rate_str+=" "
    rate_str+="7d:${week_fmt}%"
fi
if [ -n "$rate_str" ]; then
    line+=" $(printf "${DIM}limits[%s]${RESET}" "$rate_str")"
fi

printf "%b\n" "$line"
