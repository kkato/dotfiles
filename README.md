# dotfiles

macOS向けの個人的なdotfiles設定です。

## 構成

```
.
├── .zshrc              # Zsh設定
├── .gitconfig          # Git設定
├── .config/
│   └── starship.toml   # Starshipプロンプト設定
├── .claude/
│   ├── CLAUDE.md       # Claudeグローバル指示
│   ├── settings.json   # Claude Code設定
│   └── statusline.sh   # Claude Codeステータスライン
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

## 手動セットアップ

セットアップスクリプトを使わない場合:

```bash
# シンボリックリンクを作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.config
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml
mkdir -p ~/.claude
ln -sf ~/dotfiles/.claude/CLAUDE.md ~/.claude/CLAUDE.md
ln -sf ~/dotfiles/.claude/settings.json ~/.claude/settings.json
ln -sf ~/dotfiles/.claude/statusline.sh ~/.claude/statusline.sh

# 設定を反映
source ~/.zshrc
```

## カスタマイズ

個人的な設定（機密情報など）は `~/.zshrc.local` に追記してください:

```bash
# ~/.zshrc.local の例
export CUSTOM_VAR="your_value"
```

