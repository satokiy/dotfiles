# alias
alias ll='ls -l'
alias dc='docker compose'
alias d='docker'

## trash
if type trash > /dev/null 2>&1; then
  alias rm='trash -F'
fi

# rbenv
eval "$(rbenv init - zsh)"
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"
export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$HOME/.rbenv/shims:$HOME/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/jamf/bin:/bin

# go
export GOPATH=$HOME/go
export PATH="$HOME/go/bin:$PATH"

# git checkout
function peco-git-checkout {
  git branch | peco | xargs git checkout
}
zle -N peco-git-checkout
bindkey '^o' peco-git-checkout

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# postgresql
export PATH="$HOME/homebrew/opt/postgresql@13/bin:$PATH"

# direnv
eval "$(direnv hook zsh)"

# java
export JAVA_11_HOME=$(/usr/libexec/java_home -v 11)
export JAVA_8_HOME=$(/usr/libexec/java_home -v 1.8)
alias java11="export JAVA_HOME=$JAVA_11_HOME"
alias java8="export JAVA_HOME=$JAVA_8_HOME"

# python
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
# pyenv
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

# asdf
. $HOME/homebrew/opt/asdf/libexec/asdf.sh

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# https://eitya.hatenadiary.org/entry/20110707/1310023383
setopt nonomatch

# starship
eval "$(starship init zsh)"

# zsh autocomplete (!) depends on where homebrew is installed
source ~/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
FPATH=~/homebrew/share/zsh-completions:$FPATH
FPATH=~/homebrew/share/zsh/site-functions:$FPATH

autoload -Uz compinit
compinit
