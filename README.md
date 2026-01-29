# dotfiles

macOS向けの個人的なdotfiles設定です。

## 構成

```
.
├── .zshrc              # Zsh設定
├── .gitconfig          # Git設定
├── .config/
│   ├── starship.toml   # Starshipプロンプト設定
│   └── nvim/           # Neovim設定
└── install.sh          # セットアップスクリプト
```

## 前提条件

- macOS
- [Homebrew](https://brew.sh/ja/)
- Zsh
- Node.js / npm (AIツールのインストール用)

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
- **Neovim**: エディタ
- **Starship**: プロンプト
- **Claude Code / Gemini CLI / Codex**: AIコーディングアシスタント

## 手動セットアップ

セットアップスクリプトを使わない場合:

```bash
# シンボリックリンクを作成
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig
mkdir -p ~/.config
ln -sf ~/dotfiles/.config/starship.toml ~/.config/starship.toml

# 設定を反映
source ~/.zshrc
```

## カスタマイズ

個人的な設定（機密情報など）は `~/.zshrc.local` に追記してください:

```bash
# ~/.zshrc.local の例
export CUSTOM_VAR="your_value"
```

