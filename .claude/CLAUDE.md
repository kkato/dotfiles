# Global Rules

## PR / Issue のフォーマット

- PR・Issue ともに Why/What 形式で記述する
  - **Why**: なぜこの変更が必要か（背景・課題）
  - **What**: 何をするか（変更内容）
- PR の description で関連 Issue を `- https://github.com/org/repo/issues/123` の形式でメンションする
  - `- Issue のURL` の形式にすることで GitHub が Issue タイトルを表示してくれる
- PR の description は簡潔第一で書く
  - Why は 2-3 文で課題を述べる。長いコードブロックや詳細な技術解説は貼らず、関連 Issue / 外部 issue へのリンクに委ねる
  - What は変更点を箇条書きで端的に。1 項目 1 行を基本にする
  - 詳細な背景・調査経緯は Issue 側に書き、PR からはリンクで参照する

### コメント・本文を書くときのスタイル

- 構造は「実行したこと → 結果 (表) → 原因/解釈 (表 + 1 段落)」の 3 ブロックで完結させ、節をそれ以上増やさない
- 数字の内訳は必ず表で示す。地の文で「X件 (Y%) は〜、Z件 (W%) は〜」と繰り返さない
- 「なぜこうなるか」「何が結論か」は 1 段落で書き切る。箇条書きで同じ話を角度を変えて書かない
- コードへの参照は commit hash 固定の permalink を貼る (`https://github.com/org/repo/blob/<commit-hash>/path#Lx-Ly`)。関数定義の抜粋や相対行番号参照 (`file.go:107-109`) は避ける
- ES/OS、before/after のような対比がある場合は最後に一文で「A では X、B では Y」と並べて締める
- SQL や詳細手順はコメントに載せない。追試用には集計結果の数字だけでよい。必要なら別ファイル/添付ファイルに分離
- 禁止表現: 比喩 (「幽霊ドキュメント」等)、曖昧な言い回し (「意図的な設計」等)、「仕様どおり」だけで結論を済ませる書き方

### コメント・本文を編集するとき

- **必ず現状の最新本文を取得してから**差分だけを修正する
  - `gh api repos/.../comments/<id> -q .body` や `gh issue view --json body` / `gh pr view --json body` で最新版を取得
  - 全文を書き直して上書きすると、ユーザーが後から追記した内容（添付ファイル、画像、他の人のコメント等）を消してしまうことがあるので禁止

## Git

- 作業を始める前に `git fetch` / `git pull` でリポジトリを最新化する
  - デフォルトブランチが古いままだと、そこから切ったブランチが最新に追従できていないことに気づけない
- 新しいブランチは必ずデフォルトブランチ（`master` または `main`。リポジトリごとに異なるので `git symbolic-ref refs/remotes/origin/HEAD` 等で確認する）から切る
  - PR を作る前に現在のブランチがデフォルトブランチベースかどうか確認すること
  - 既存の作業ブランチで作業している場合でも、別の目的の変更は必ずデフォルトブランチから新しいブランチを切って行う
- ブランチ名は `kkato/<branch-name>` の形式にする
- `git add -A` や `git add .` は使わない。ファイルを明示的に指定して add する
  - 例: `git add kubernetes/sandbox/serviceaccount.yaml kube-generate.yaml`
  - 生成ファイルなど大量にある場合は `git add <ディレクトリ>` で範囲を絞る

## リポジトリ管理

- リポジトリは ghq で管理している: `~/ghq/github.com/<org>/<repo>`
- 例: wantedly/finder-go → `~/ghq/github.com/wantedly/finder-go`
- リポジトリを使う際は clone せず ghq のパスを使うこと
- 一時ファイルやディレクトリが必要な場合は `/tmp` ではなく `~/tmp` を使うこと

## リポジトリの略称

- wtd/wtd → wantedly/wantedly リポジトリ（ghq/github.com/wantedly/wantedly）

## Kubernetes

- `kubectl` の代わりに `kube <env>` コマンドを使用する
- 使い方: `kube sandbox(sb) | qa | production(prod) <kubectlサブコマンド>`
  - 例: `kube sandbox get pods`, `kube sb -n argo-cd get configmap`, `kube prod get nodes`

## Claude Code / Codex の設定管理

- CLAUDE.md・settings.json・hooks・skills・codex の config.toml は `~/ghq/github.com/kkato/dotfiles` でバージョン管理されている
- 新しい plugin/skill を使いたい場合、その場で `claude plugin install` 等を実行して終わりにしない
  - dotfiles 側の `settings.json`（`enabledPlugins`/`extraKnownMarketplaces`）や `.claude/skills/` を先に編集して commit・push する
  - 他のマシンでは `git pull` して反映する
  - こうすることでマシン間の環境差異（片方にだけ入っている plugin/skill）を防ぐ

## Plan mode

- プランは簡潔に書く。調査の経緯や複数選択肢の比較は書かず、結論と変更内容だけを書く
- Context は 2-3 行、変更内容は箇条書きで端的に。詳細な仕様説明は本文に含めず結論のみ書く
