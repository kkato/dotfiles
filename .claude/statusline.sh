#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

cwd=$(jq -r '.workspace.current_dir // .cwd // ""' <<<"$input")
model=$(jq -r '.model.display_name // ""' <<<"$input")
ctx=$(jq -r '.context_window.used_percentage // empty' <<<"$input")
h5=$(jq -r '.rate_limits.five_hour.used_percentage // empty' <<<"$input")
d7=$(jq -r '.rate_limits.seven_day.used_percentage // empty' <<<"$input")
branch=$(git -C "$cwd" branch --show-current 2>/dev/null || true)

home_len=${#HOME}
if [[ "${cwd:0:$home_len}" == "$HOME" ]]; then
  cwd_short="~${cwd:$home_len}"
else
  cwd_short="$cwd"
fi
RESET=$'\033[0m'
SEP=$'\033[90m | '"$RESET"

color() {
  local p=${1%.*}
  [[ -z $p ]] && { printf '\033[90m'; return; }
  (( p >= 80 )) && { printf '\033[31m'; return; }
  (( p >= 50 )) && { printf '\033[33m'; return; }
  printf '\033[32m'
}

parts=("$cwd_short")
[[ -n $branch ]] && parts+=("$branch")
[[ -n $model ]] && parts+=("$model")
if [[ -n $ctx ]]; then
  parts+=("$(printf 'ctx %s%.0f%%%s' "$(color "$ctx")" "$ctx" "$RESET")")
fi
if [[ -n $h5 ]]; then
  d7_val=${d7:-0}
  parts+=("$(printf '5h %s%.0f%%%s / 7d %s%.0f%%%s' \
    "$(color "$h5")" "$h5" "$RESET" "$(color "$d7_val")" "$d7_val" "$RESET")")
fi

(IFS=; printf '%s' "${parts[0]}"; for p in "${parts[@]:1}"; do printf '%s%s' "$SEP" "$p"; done)
printf '%s\n' "$RESET"
