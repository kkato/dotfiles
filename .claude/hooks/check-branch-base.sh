#!/bin/bash
# git switch -c / checkout -b でデフォルトブランチ(main/master)以外から切ろうとしたら警告する（ブロックはしない）
set -euo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")

re='git[[:space:]]+(switch[[:space:]]+-c|checkout[[:space:]]+-b)[[:space:]]+([^[:space:];&|]+)([[:space:]]+([^[:space:];&|-][^[:space:];&|]*))?'
[[ "$cmd" =~ $re ]] || exit 0
start="${BASH_REMATCH[4]:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/default-branch.sh"

base=$(default_branch)

# 起点を明示している場合はそれを見る。省略時は現在のブランチが起点
if [[ -n "$start" ]]; then
  [[ "$start" == "$base" || "$start" == */"$base" ]] && exit 0
  from="$start"
else
  from=$(git rev-parse --abbrev-ref HEAD)
  [[ "$from" == "$base" ]] && exit 0
fi

msg="警告: \"$from\" から新しいブランチを切ろうとしています（デフォルトブランチは \"$base\"）。意図した操作か確認してください。"
jq -n --arg msg "$msg" '{
  systemMessage: $msg,
  hookSpecificOutput: {hookEventName: "PreToolUse", additionalContext: $msg}
}'
