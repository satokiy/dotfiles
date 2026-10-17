# brew
BREW_PATH=/opt/homebrew

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"
export HOMEBREW_CACHE=/opt/homebrew/cache

# ~/local/bin (aws session-manager-plugin などを置いている)
export PATH="$HOME/local/bin:$PATH"


# export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$HOME/.rbenv/shims:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/jamf/bin:/bin

# git
export GIT_CONFIG_GLOBAL=${HOME}/.config/git/config

# trash
#if type trash > /dev/null 2>&1; then
#  alias rm='trash -F'
#fi

# mise
eval "$($BREW_PATH/bin/mise activate zsh)"

# rbenv
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init - zsh)"

# go
export GOPATH=$HOME/go
export PATH="$HOME/go/bin:$PATH"
export PATH="$PATH:'$(go env GOPATH)'/bin"

# nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# postgresql
export PATH="$BREW_PATH/opt/postgresql@13/bin:$PATH"
export PATH="$BREW_PATH/opt/postgresql@15/bin:$PATH"
# direnv
eval "$(direnv hook zsh)"

# python
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
# pyenv
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# https://eitya.hatenadiary.org/entry/20110707/1310023383
setopt nonomatch

# starship
eval "$(starship init zsh)"

autoload -Uz compinit
# キャッシュがない、または24時間以上古い場合は通常の初期化
local -a old_compdump=(~/.zcompdump(Nmh+24))
if [[ ! -f ~/.zcompdump || ${#old_compdump} -gt 0 ]]; then
  compinit
else
  # if there are new functions can be omitted by giving the option -C.
  compinit -C
fi

# cargo
export PATH="$HOME/.cargo/bin:$PATH"

# kubectl autocomplete
# source <(kubectl completion zsh)

# istioctl
export PATH=$HOME/.istioctl/bin:$PATH

# Created by `pipx` on 2024-04-15 00:59:40
export PATH="$PATH:$HOME/.local/bin"

# https://github.com/ajeetdsouza/zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

function precmd() {
  # カレントディレクトリを $HOME を ~ として表示
  local wname=`pwd | sed -e "s|$HOME|~|"`
  # カレントディレクトリ名
  local tname=`pwd | sed -e 's|^.*/||'`

  echo -ne "\033]2;$wname\007" # window title
  echo -ne "\033]1;$tname\007" # tab title
}

# コマンド定義（symlink 経由でも .zshrc の実体を基準に読み込む）
source "${${(%):-%x}:A:h}/scripts/aliases.zsh"
source "${${(%):-%x}:A:h}/scripts/git.zsh"
source "${${(%):-%x}:A:h}/scripts/gwt-safe.zsh"
source "${${(%):-%x}:A:h}/scripts/aws.zsh"

# git checkout のキー設定
zle -N peco-git-checkout
bindkey '^p' peco-git-checkout
