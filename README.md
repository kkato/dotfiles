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
│   ├── statusline.sh   # Claude Codeステータスライン
│   ├── hooks/          # Claude Codeフック
│   └── skills/         # Claude Codeカスタムスキル
├── .codex/
│   └── config.toml     # Codex CLI設定
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

## カスタマイズ

個人的な設定（機密情報など）は `~/.zshrc.local` に追記してください:

```bash
# ~/.zshrc.local の例
export CUSTOM_VAR="your_value"
```

