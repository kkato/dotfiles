# ============================================================================
# Zsh Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------
# Starship prompt
eval "$(starship init zsh)"

# ----------------------------------------------------------------------------
# General Aliases
# ----------------------------------------------------------------------------
alias ls='ls -G'
alias ll='ls -lha'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'

# ----------------------------------------------------------------------------
# Git Aliases
# ----------------------------------------------------------------------------
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'
alias glog='git log --oneline --graph --decorate'

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------
# ghq + peco
alias ghqcd='cd "$(ghq list --full-path | peco)"'

# kubectl
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias klog='kubectl logs -f'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias dimg='docker images'
alias dexec='docker exec -it'

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
