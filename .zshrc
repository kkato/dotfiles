# ============================================================================
# Zsh Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Path
# ----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$PATH"

# ----------------------------------------------------------------------------
# Prompt
# ----------------------------------------------------------------------------
# Starship prompt
eval "$(starship init zsh)"

# ----------------------------------------------------------------------------
# General Aliases

alias ls='ls -G'
alias ll='ls -lha'
alias la='ls -A'
alias ..='cd ..'
alias ...='cd ../..'
alias history='history 0 | fzf'

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------
# ghq + fzf
alias ghqcd='cd "$(ghq list --full-path | fzf)"'

# kubectl
alias k='kubectl'

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

# ----------------------------------------------------------------------------
# Language Specific
# ----------------------------------------------------------------------------
# Ruby (rbenv)
if command -v rbenv &>/dev/null; then
    export RBENV_ROOT="$HOME/.rbenv"
    export PATH="$RBENV_ROOT/bin:$PATH"
    eval "$(rbenv init -)"
fi

# Node.js (fnm)
if command -v fnm &>/dev/null; then
    eval "$(fnm env --use-on-cd)"
fi

# icu4c for pkg-config
if [ -d "/opt/homebrew/opt/icu4c" ]; then
    export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig:$PKG_CONFIG_PATH"
fi

# direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------
setopt interactivecomments  # Allow comments in interactive shell

# ----------------------------------------------------------------------------
# History Configuration
# ----------------------------------------------------------------------------
HISTFILE=~/.zsh_history      # Path to history file
HISTSIZE=10000               # Max entries in memory
SAVEHIST=10000               # Max entries in file
setopt SHARE_HISTORY         # Share history across sessions
setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicates
setopt HIST_IGNORE_SPACE     # Ignore commands starting with space
setopt HIST_REDUCE_BLANKS    # Remove extra whitespace

# ----------------------------------------------------------------------------
# Local Configuration
# ----------------------------------------------------------------------------
# Load local configuration if exists
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
