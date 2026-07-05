#!/bin/bash
# gh pr create 実行時、現在のブランチがデフォルトブランチ(main/master)から直接切られていなければブロックする
set -euo pipefail

input=$(cat)
cmd=$(jq -r '.tool_input.command // empty' <<<"$input")

[[ "$cmd" == *"gh pr create"* ]] || exit 0

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
ancestor=$(git merge-base "$base" HEAD 2>/dev/null || true)
base_sha=$(git rev-parse "$base" 2>/dev/null || true)

if [[ -n "$base_sha" && "$ancestor" != "$base_sha" ]]; then
  jq -n --arg msg "ブランチ \"$current\" はデフォルトブランチ \"$base\" から直接切られていません。$base から新しいブランチを切り直してください。" \
    '{continue: false, stopReason: $msg}'
fi
