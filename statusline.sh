#!/usr/bin/env bash
# ~/.claude/statusline.sh
# Claude Code status line — compact one-liner
# Format: [Model] ctx:[bar]XX% wk:XX% | $X.XXXX | api:XX% | branch

input=$(cat)

# --- JSON field extractor (jq → python3 fallback) ---
json_get() {
  # Usage: json_get "dot.path" — e.g. json_get "context_window.used_percentage"
  local path="$1"
  if command -v jq >/dev/null 2>&1; then
    echo "$input" | jq -r ".$path // empty"
  else
    echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    keys = '$path'.split('.')
    val = d
    for k in keys:
        val = val.get(k, '')
        if val == '':
            break
    if val != '' and val is not None:
        print(val)
except:
    pass
" 2>/dev/null || true
  fi
}

# --- Mini progress bar helper ---
# Usage: make_bar <percentage 0-100> <width>
make_bar() {
  local pct="${1:-0}"
  local width="${2:-10}"
  local filled=$(awk "BEGIN {printf \"%d\", $pct * $width / 100}")
  local half=$(awk "BEGIN {printf \"%d\", int($pct * $width * 2 / 100) % 2}")
  local empty=$(( width - filled - half ))
  local bar=""
  local i
  for ((i=0; i<filled; i++)); do bar="${bar}█"; done
  [ "$half" -eq 1 ] && bar="${bar}▌"
  for ((i=0; i<empty; i++)); do bar="${bar}·"; done
  printf "%s" "$bar"
}

# --- Model ---
model=$(json_get "model.display_name")
[ -z "$model" ] && model=$(json_get "model.id")
[ -z "$model" ] && model="claude-sonnet-4-6"

# --- Current session usage (5-hour rate limit = "Current session" in /status) ---
ses_used=$(json_get "rate_limits.five_hour.used_percentage")
if [ -n "$ses_used" ]; then
  ses_pct=$(printf "%.0f" "$ses_used")
else
  ses_pct=0
fi
ses_bar=$(make_bar "$ses_pct" 10)
ses_part="ses:[${ses_bar}]${ses_pct}%"

# --- Weekly all-models usage (7-day) ---
wk_used=$(json_get "rate_limits.seven_day.used_percentage")
if [ -n "$wk_used" ]; then
  wk_pct=$(printf "%.0f" "$wk_used")
else
  wk_pct=0
fi
wk_bar=$(make_bar "$wk_pct" 10)
wk_part=" wk:[${wk_bar}]${wk_pct}%"



# --- Git branch ---
cwd=$(json_get "workspace.current_dir")
[ -z "$cwd" ] && cwd=$(json_get "cwd")
if [ -n "$cwd" ] && [ -d "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
           || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi
if [ -z "$branch" ]; then
  branch=$(git symbolic-ref --short HEAD 2>/dev/null \
           || git rev-parse --short HEAD 2>/dev/null)
fi
branch_part="${branch:---}"

# --- Project name (basename of cwd) ---
if [ -n "$cwd" ]; then
  project=$(basename "$cwd")
else
  project=$(basename "$PWD")
fi

# --- Active agent ---
agent_name=$(json_get "agent.name")
if [ -n "$agent_name" ]; then
  agent_part=" | @${agent_name}"
else
  agent_part=""
fi

# --- Assemble ---
printf "[%s] %s%s | %s | %s | %s%s" \
  "$model" \
  "$ses_part" \
  "$wk_part" \
  "$project" \
  "$cwd" \
  "$branch_part" \
  "$agent_part"
