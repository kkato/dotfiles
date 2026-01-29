#!/bin/bash

set -e

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ログ関数
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# dotfilesのディレクトリ
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

info "Dotfiles directory: $DOTFILES_DIR"

# バックアップディレクトリの作成
create_backup() {
    local file=$1
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        if [ ! -d "$BACKUP_DIR" ]; then
            mkdir -p "$BACKUP_DIR"
            info "Created backup directory: $BACKUP_DIR"
        fi
        cp -r "$file" "$BACKUP_DIR/"
        info "Backed up: $file -> $BACKUP_DIR/"
    fi
}

# シンボリックリンクの作成
create_symlink() {
    local source=$1
    local target=$2

    if [ -e "$target" ] || [ -L "$target" ]; then
        if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
            info "Already linked: $target"
            return
        fi
        create_backup "$target"
        rm -rf "$target"
    fi

    # ディレクトリが存在しない場合は作成
    local target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        mkdir -p "$target_dir"
    fi

    ln -sf "$source" "$target"
    info "Linked: $target -> $source"
}

# Homebrewのチェック
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        warn "Homebrew is not installed"
        echo "Install Homebrew? (y/n)"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            error "Homebrew is required. Exiting."
            exit 1
        fi
    else
        info "Homebrew is installed"
    fi
}

# 必要なパッケージのインストール
install_packages() {
    info "Checking required packages..."

    local packages=(
        "git"
        "neovim"
        "starship"
        "zsh-completions"
        "zsh-autosuggestions"
        "zsh-syntax-highlighting"
        "ghq"
        "peco"
        "jq"
        "tree"
        "watch"
        "gh"
        "go"
        "fnm"
        "rbenv"
    )

    local casks=(
        "ghostty"
    )

    local to_install=()

    for package in "${packages[@]}"; do
        if ! brew list "$package" &> /dev/null; then
            to_install+=("$package")
        else
            info "$package is already installed"
        fi
    done

    if [ ${#to_install[@]} -gt 0 ]; then
        info "Installing: ${to_install[*]}"
        brew install "${to_install[@]}"
    else
        info "All required packages are already installed"
    fi

    # Check and install casks
    local casks_to_install=()

    for cask in "${casks[@]}"; do
        if ! brew list --cask "$cask" &> /dev/null; then
            casks_to_install+=("$cask")
        else
            info "$cask is already installed"
        fi
    done

    if [ ${#casks_to_install[@]} -gt 0 ]; then
        info "Installing casks: ${casks_to_install[*]}"
        brew install --cask "${casks_to_install[@]}"
    else
        info "All required casks are already installed"
    fi
}

# npm パッケージのインストール
install_npm_packages() {
    info "Checking npm packages..."

    if ! command -v npm &> /dev/null; then
        warn "npm is not installed. Skipping npm packages."
        return
    fi

    local npm_packages=(
        "@anthropic-ai/claude-code"
        "@google/gemini-cli"
        "@openai/codex"
    )

    for package in "${npm_packages[@]}"; do
        if npm list -g "$package" &> /dev/null; then
            info "$package is already installed"
        else
            info "Installing $package..."
            npm install -g "$package"
        fi
    done
}

# メイン処理
main() {
    info "Starting dotfiles installation..."

    # Homebrewのチェック
    check_homebrew

    # パッケージのインストール
    echo "Install required packages? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        install_packages
        install_npm_packages
    fi

    # シンボリックリンクの作成
    info "Creating symlinks..."

    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    create_symlink "$DOTFILES_DIR/.gitconfig" "$HOME/.gitconfig"
    create_symlink "$DOTFILES_DIR/.config/starship.toml" "$HOME/.config/starship.toml"
    create_symlink "$DOTFILES_DIR/.config/nvim" "$HOME/.config/nvim"

    info "Installation completed!"

    if [ -d "$BACKUP_DIR" ]; then
        info "Backup files saved to: $BACKUP_DIR"
    fi

    info "Please restart your terminal or run: source ~/.zshrc"
}

main
