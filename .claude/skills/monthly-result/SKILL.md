---
name: monthly-result
description: |
  wantedly/infrastructure リポジトリの Monthly Result issue（例: "2026-03 @kkato"）に月次振り返りコメントを書くスキル。「Monthly Result を書きたい」「今月の振り返りを書いて」「#XXXXX を書きたい」「振り返りコメントして」などと言ったときに発動。対象 issue の番号と、参照する Discussion（タスク整理）の番号をユーザーから受け取り、その月の完了タスクをカテゴリ別に整理して `gh issue comment` で投稿する。
---

# Monthly Result コメント作成

## ワークフロー

### 1. 情報収集（並行実行）

```bash
# Monthly Result issue の本文確認（前月 issue 番号も本文に含まれていることが多い）
gh issue view <issue番号> --repo wantedly/infrastructure

# タスク整理 Discussion のコメント一覧（日々のタスク記録）
gh api repos/wantedly/infrastructure/discussions/<discussion番号>/comments --paginate \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
for c in data:
    print('---')
    print(c.get('created_at',''))
    print(c.get('body',''))
"

# 前月の Monthly Result issue のコメントを参考として確認
gh issue view <前月issue番号> --repo wantedly/infrastructure --comments
```

### 2. 完了タスクの抽出とカテゴリ分類

Discussion のコメントから `[x]` がついたタスクを抽出し、カテゴリに分類する。

**分類の指針：**
- 大きなプロジェクト（PostgreSQL アップグレード、OpenSearch 移行など）は独立したセクション
- インシデント対応（`[YYYY/MM/DD ...]` 形式の issue）はまとめて「インシデント対応」セクション
- ISMS 関連はまとめて「ISMS」セクション
- 残りは「その他」にまとめる
- 未完了（`[ ]`）のタスクは含めない

### 3. コメント投稿

issue の本文は **絶対に編集しない**。必ず `gh issue comment` で投稿する：

```bash
gh issue comment <issue番号> --repo wantedly/infrastructure --body "$(cat <<'EOF'
## カテゴリ名

- https://github.com/wantedly/infrastructure/issues/XXXXX

## カテゴリ名

- https://github.com/wantedly/infrastructure/issues/XXXXX
EOF
)"
```

## コメントのフォーマット

```markdown
## <カテゴリ名>

- <issue/PR の URL>
- <issue/PR の URL>

## <カテゴリ名>

- <issue/PR の URL>
```

- セクションタイトルは日本語で端的に（例：`## PostgreSQL メジャーバージョンアップ`）
- 各行は issue/PR の URL のみ（タイトルは GitHub が自動表示する）
- 良かった点・もっとよくできる点・来月の目標セクションはユーザーが自分で書くため **含めない**

## 注意事項

- 振り返り内容は `gh issue comment` で追加する。`gh issue edit` で本文に振り返り内容を書き込まない
- issue 本文の日付（タイトルの月、WHAT セクションの検索リンクの日付範囲など）が誤っている場合は `gh issue edit` で修正してよい
- issue にすでにコメントがある場合でも、振り返りは新規コメントとして投稿する
