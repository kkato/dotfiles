# gitsigns.nvim

行番号の横にGitの変更状態を表示するプラグイン。
追加・変更・削除がひと目でわかる。

## 表示される記号

| 記号 | 意味 |
|------|------|
| `│` (緑) | 追加された行 |
| `│` (青) | 変更された行 |
| `_` (赤) | 削除された行 |

## コマンド

| コマンド | 動作 |
|------|------|
| `:Gitsigns next_hunk` | 次の変更箇所へ |
| `:Gitsigns prev_hunk` | 前の変更箇所へ |
| `:Gitsigns preview_hunk` | 変更内容をプレビュー |
| `:Gitsigns reset_hunk` | 変更を元に戻す |
| `:Gitsigns blame_line` | 行のコミット情報を表示 |
