# dotfiles

macOS向けの個人的なdotfiles設定です。

## 構成

```
.
├── .zshrc              # Zsh設定
├── .gitconfig          # Git設定
├── AGENTS.md           # Codex向けリポジトリ指示
├── CLAUDE.md           # AGENTS.mdへのシンボリックリンク
├── .claude/
│   └── settings.json   # Claude Code設定
├── .config/
│   ├── agent-skills/   # Claude Code / Codex 共有Skill
│   ├── codex/          # Codexグローバル設定
│   └── starship.toml   # Starshipプロンプト設定
└── install.sh          # セットアップスクリプト
```

## 前提条件

- macOS
- [Homebrew](https://brew.sh/ja/)
- Zsh

## セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/kkato/dotfiles.git ~/dotfiles
cd ~/dotfiles

# セットアップスクリプトを実行
./install.sh
```

## 主な機能

- **Ghostty**: ターミナルエミュレータ
- **VSCode + VSCode Neovim**: エディタ
- **Claude Code**: AIエージェント
- **Codex**: AIコーディングエージェント

## AIエージェント設定

- `AGENTS.md` を正として管理し、`CLAUDE.md` はシンボリックリンクにしています。
- Codex は `~/.codex/AGENTS.md` と `~/.codex/config.toml` を、このリポジトリから参照します。
- Codex は `CLAUDE.md` / `Claude.md` も project doc fallback として読む設定です。
- Skill は `.config/agent-skills` を正として、`~/.claude/skills` と `~/.agents/skills` の両方から参照します。
- `graphify` など Claude Code 用に入れた `SKILL.md` 形式の Skill は、Codex でも検出できます。ただし Skill 内の手順が Claude 固有のツール名を前提にしている場合は、Codex 用に文言調整が必要です。

## 手動セットアップ

セットアップスクリプトを使わない場合:

```bash
# シンボリックリンクを作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.config
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
mkdir -p ~/.claude ~/.codex ~/.agents
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.config/codex/config.toml ~/.codex/config.toml
ln -sf ~/dotfiles/.config/codex/AGENTS.md ~/.codex/AGENTS.md
ln -sf ~/dotfiles/.config/codex/AGENTS.md ~/.claude/CLAUDE.md

# 既存のskillsディレクトリがある場合は、内容を退避してからリンク
ln -sfn ~/dotfiles/.config/agent-skills ~/.claude/skills
ln -sfn ~/dotfiles/.config/agent-skills ~/.agents/skills

# 設定を反映
source ~/.zshrc
```

## カスタマイズ

個人的な設定（機密情報など）は `~/.zshrc.local` に追記してください:

```bash
# ~/.zshrc.local の例
export CUSTOM_VAR="your_value"
```
