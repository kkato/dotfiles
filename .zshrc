# ============================================================================
# Zsh Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------
# Starship prompt
eval "$(starship init zsh)"

# zoxide (modern cd alternative)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# ----------------------------------------------------------------------------
# General Aliases
# ----------------------------------------------------------------------------
# Modern CLI tools (Rust-based)
if command -v eza &>/dev/null; then
    alias ls='eza --icons'
    alias ll='eza -l --icons --git'
    alias la='eza -la --icons --git'
    alias tree='eza --tree --icons'
else
    alias ls='ls -G'
    alias ll='ls -lha'
    alias la='ls -A'
fi

if command -v bat &>/dev/null; then
    alias cat='bat'
    export BAT_THEME="TwoDark"
fi

if command -v rg &>/dev/null; then
    alias grep='rg'
fi

alias ..='cd ..'
alias ...='cd ../..'

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------
# ghq + peco
alias ghqcd='cd "$(ghq list --full-path | peco)"'

# kubectl
alias k='kubectl'

# ----------------------------------------------------------------------------
# Useful Functions
# ----------------------------------------------------------------------------
# mkdir and cd
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"    ;;
            *.tar.gz)    tar xzf "$1"    ;;
            *.bz2)       bunzip2 "$1"    ;;
            *.rar)       unrar x "$1"    ;;
            *.gz)        gunzip "$1"     ;;
            *.tar)       tar xf "$1"     ;;
            *.tbz2)      tar xjf "$1"    ;;
            *.tgz)       tar xzf "$1"    ;;
            *.zip)       unzip "$1"      ;;
            *.Z)         uncompress "$1" ;;
            *.7z)        7z x "$1"       ;;
            *)           echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Find process by name
findproc() {
    ps aux | grep -i "$1" | grep -v grep
}

# Create a backup of a file
backup() {
    cp "$1" "$1.backup-$(date +%Y%m%d-%H%M%S)"
}

# ----------------------------------------------------------------------------
# Zsh Plugins
# ----------------------------------------------------------------------------
if type brew &>/dev/null; then
    # zsh-completions
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    # Initialize completion
    autoload -Uz compinit
    compinit

    # zsh-autosuggestions
    source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

    # zsh-syntax-highlighting (must be sourced last)
    source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ----------------------------------------------------------------------------
# kubectl completion
# ----------------------------------------------------------------------------
if command -v kubectl &>/dev/null; then
    source <(kubectl completion zsh)
fi

# ----------------------------------------------------------------------------
# Google Cloud SDK
# ----------------------------------------------------------------------------
# Path
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# Completion
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
    source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Credentials
if [ -f "$HOME/.config/gcloud/active-chimera-351913-0f994a455ec1.json" ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$HOME/.config/gcloud/active-chimera-351913-0f994a455ec1.json"
fi

# ----------------------------------------------------------------------------
# Language Specific
# ----------------------------------------------------------------------------
# Ruby (rbenv)
# if command -v rbenv &>/dev/null; then
#     export RBENV_ROOT="$HOME/.rbenv"
#     export PATH="$RBENV_ROOT/bin:$PATH"
#     eval "$(rbenv init -)"
# fi

# icu4c for pkg-config
if [ -d "/opt/homebrew/opt/icu4c" ]; then
    export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS

# ----------------------------------------------------------------------------
# Local Configuration
# ----------------------------------------------------------------------------
# Load local configuration if exists
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
