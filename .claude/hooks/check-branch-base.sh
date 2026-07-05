#!/bin/bash
# git switch -c / checkout -b した際、デフォルトブランチ(main/master)から切っていなければブロックする
set -euo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ "$cmd" =~ git[[:space:]]+(switch[[:space:]]+-c|checkout[[:space:]]+-b) ]] || exit 0

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/default-branch.sh"

base=$(default_branch)
current=$(git rev-parse --abbrev-ref HEAD)

if [[ "$current" != "$base" ]]; then
  jq -n --arg msg "ブランチ \"$current\" はデフォルトブランチ \"$base\" ではありません。$base に切り替えてから新しいブランチを切ってください。" \
    '{continue: false, stopReason: $msg}'
fi
