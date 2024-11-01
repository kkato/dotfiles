# PROMPT
PROMPT='%~ %% '
# starship
# eval "$(starship init zsh)"

# alias
alias ls='ls -G'
alias ghqcd='cd "$(ghq list --full-path | peco)"'

# zsh-completions
  if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi

# zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# kubectl
alias k=kubectl
autoload -Uz compinit && compinit
source <(kubectl completion zsh)

# rbenv
export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
eval "$(rbenv init -)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kkato/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/kkato/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/kkato/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/kkato/google-cloud-sdk/completion.zsh.inc'; fi

export GOOGLE_APPLICATION_CREDENTIALS=~/.config/gcloud/active-chimera-351913-0f994a455ec1.json

# No package 'icu-uc' found, No package 'icu-i18n' found
export PKG_CONFIG_PATH="/opt/homebrew/opt/icu4c/lib/pkgconfig"
