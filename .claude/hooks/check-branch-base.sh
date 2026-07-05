#!/bin/bash
# git switch -c / checkout -b した際、デフォルトブランチ(main/master)から切っていなければ警告する
set -euo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ "$cmd" =~ git[[:space:]]+(switch[[:space:]]+-c|checkout[[:space:]]+-b) ]] || exit 0

default_branch() {
  local ref
  if ref=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null); then
    echo "${ref##*/}"
    return
  fi
  for b in main master; do
    if git rev-parse --verify "$b" >/dev/null 2>&1; then
      echo "$b"
      return
    fi
  done
  echo master
}

base=$(default_branch)
current=$(git rev-parse --abbrev-ref HEAD)

if [[ "$current" != "$base" ]]; then
  jq -n --arg msg "警告: 現在のブランチ \"$current\" はデフォルトブランチ \"$base\" ではありません。$base から切り出すことを推奨します。" \
    '{systemMessage: $msg}'
fi
