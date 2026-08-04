#!/bin/bash
# Bash にマッチする PreToolUse hook をまとめて実行するラッパー。
# runok の sandbox を正しく動かすには Bash にマッチする hook が1つだけである必要がある
# https://runok.fohte.net/getting-started/claude-code/
set -euo pipefail

input=$(cat)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ブランチのベース確認。ブロックするときだけ JSON を出力するので、
# 出力があればそれをそのまま hook のレスポンスとして返して終了する
branch_check=$(printf '%s' "$input" | "$SCRIPT_DIR/check-branch-base.sh")
if [[ -n "$branch_check" ]]; then
  printf '%s\n' "$branch_check"
  exit 0
fi

# runok によるコマンド許可判定。stdout がそのまま hook のレスポンスになる
printf '%s' "$input" | runok check --input-format claude-code-hook
