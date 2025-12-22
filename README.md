# dotfiles

macOS向けの個人的なdotfiles設定です。

## 構成

```
.
├── .zshrc              # Zsh設定
├── .config/
│   └── starship.toml  # Starshipプロンプト設定
├── .gitconfig          # Git設定
└── install.sh          # セットアップスクリプト
```

## 前提条件

- macOS
- [Homebrew](https://brew.sh/ja/)
- Zsh

## 必要なツールのインストール

```bash
# Homebrew経由でインストール
brew install starship zsh-completions zsh-autosuggestions zsh-syntax-highlighting
brew install ghq peco kubectl

# オプション: Google Cloud SDK
# https://cloud.google.com/sdk/docs/install
```

## セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/kkato/dotfiles.git ~/dotfiles
cd ~/dotfiles

# セットアップスクリプトを実行
./install.sh
```

## 主な機能

### プロンプト
- **Starship**: カスタマイズ可能な高速プロンプト
  - ディレクトリ表示
  - Gitブランチ表示
  - 時刻表示

### エイリアス
- `ls='ls -G'` - カラー表示
- `ghqcd` - ghqリポジトリをpecoで選択して移動
- `k=kubectl` - kubectl省略形

### Zsh拡張
- **zsh-completions**: 補完機能強化
- **zsh-autosuggestions**: コマンド履歴からの自動提案
- **zsh-syntax-highlighting**: シンタックスハイライト

### kubectl
- 補完機能が有効化
- エイリアス `k` でkubectlを使用可能

### Google Cloud SDK
- パスと補完機能の自動設定
- 認証情報の環境変数設定

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

## トラブルシューティング

### compinit: insecure directories エラー
```bash
chmod 755 /opt/homebrew/share/zsh
chmod 755 /opt/homebrew/share/zsh/site-functions
```

### zsh-autosuggestions が動作しない
```bash
brew reinstall zsh-autosuggestions
source ~/.zshrc
```
