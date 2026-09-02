# alias
alias ll='ls -l'
alias dc='docker compose'
alias d='docker'
alias k='kubectl'
alias tf='terraform'

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

# git checkout
function peco-git-checkout {
  git branch | peco | xargs git checkout
}
zle -N peco-git-checkout
bindkey '^p' peco-git-checkout

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
# compauditが遅いので24時間に一度だけ実行
local now=$(date +"%s")
local updated=$(date -r ~/.zcompdump +"%s")
local threshold=$((60 * 60 * 24))
if [ $((${now} - ${updated})) -gt ${threshold} ]; then
  compinit
else
  # if there are new functions can be omitted by giving the option -C.
  compinit -C
fi

# cargo
export PATH="$HOME/.cargo/bin:$PATH"

# kubectl autocomplete
source <(kubectl completion zsh)

# istioctl
export PATH=$HOME/.istioctl/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/satoki.yamada/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/satoki.yamada/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/satoki.yamada/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/satoki.yamada/google-cloud-sdk/completion.zsh.inc'; fi

# Created by `pipx` on 2024-04-15 00:59:40
export PATH="$PATH:$HOME/.local/bin"

# vim ctags
alias ctags="`brew --prefix`/bin/ctags"

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

### git worktree
# 移動
function gww() {
  local target_dir=$(git worktree list | peco | awk '{print $1}')
  if [ -n "$target_dir" ]; then
    cd "$target_dir"
  fi
}

# 削除
function gwd() {
  # メインディレクトリ以外（=が含まれるパス）を表示して選択
  local target_dir=$(git worktree list | grep "=" | peco | awk '{print $1}')
  
  if [ -n "$target_dir" ]; then
    # ディレクトリパスからブランチ名（または末尾のディレクトリ名）を抽出して削除
    # gwq remove はディレクトリパス指定でも動くことが多いですが、念のため
    git worktree remove "$target_dir"
    echo "Deleted worktree: $target_dir"
  fi
}

# 不要なworktreeを一掃
# 条件: コミットされていない変更がない（未追跡ファイルは無視）かつ
#       ブランチが origin/main または origin/master にマージ済み
# 注意: origin の最新状態で判定するため、必要なら事前に git fetch しておく
function gwclean() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "git リポジトリ内で実行してください"
    return 1
  fi

  # マージ先（origin/main / origin/master のうち存在するもの）を決定
  local base_refs=()
  git rev-parse --verify --quiet refs/remotes/origin/main >/dev/null && base_refs+=("origin/main")
  git rev-parse --verify --quiet refs/remotes/origin/master >/dev/null && base_refs+=("origin/master")
  if [ ${#base_refs[@]} -eq 0 ]; then
    echo "origin/main も origin/master も見つかりません"
    return 1
  fi

  local paths=() labels=()
  local wt="" head="" branch=""
  # porcelain の先頭レコードはメインworktreeなので除外する
  local first=1
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) wt="${line#worktree }" ;;
      "HEAD "*)     head="${line#HEAD }" ;;
      "branch "*)   branch="${line#branch refs/heads/}" ;;
      "")
        if [ -n "$wt" ]; then
          if [ "$first" -eq 1 ]; then
            first=0
          else
            # 未追跡ファイルは無視して、変更の有無を確認
            if [ -z "$(git -C "$wt" status --porcelain --untracked-files=no 2>/dev/null)" ]; then
              # HEAD が base のいずれかにマージ済みか確認
              local b merged=0
              for b in "${base_refs[@]}"; do
                if git merge-base --is-ancestor "$head" "$b" 2>/dev/null; then
                  merged=1
                  break
                fi
              done
              if [ "$merged" -eq 1 ]; then
                paths+=("$wt")
                labels+=("${branch:-(detached) ${head:0:7}}")
              fi
            fi
          fi
        fi
        wt="" head="" branch=""
        ;;
    esac
  done < <(git worktree list --porcelain)

  if [ ${#paths[@]} -eq 0 ]; then
    echo "削除対象の worktree はありません"
    return 0
  fi

  echo "以下の worktree を削除します:"
  local i
  for i in {1..${#paths[@]}}; do
    echo "  ${paths[$i]}  [${labels[$i]}]"
  done

  echo -n "削除しますか? [y/N]: "
  local ans
  read -r ans
  case "$ans" in
    [yY]|[yY][eE][sS])
      local p
      for p in "${paths[@]}"; do
        git worktree remove "$p" && echo "Deleted worktree: $p"
      done
      ;;
    *)
      echo "中止しました"
      ;;
  esac
}

# git worktreeの作成後に親の.claudeを参照することで、claude設定を一元管理する
# 親の `git rev-parse --git-path info/exclude`に.claudeを書いておく
function gwq-init() {
  local PARENT_DIR=$(git rev-parse --path-format=absolute --git-common-dir)/..
  local PARENT_CLAUDE="$PARENT_DIR/.claude"
  local PARENT_ENVRC="$PARENT_DIR/.envrc"

  # main checkoutで実行するとPARENT_DIRが自分自身になり、自己ループのsymlinkができてしまう
  if [ "$PARENT_DIR" -ef "$(git rev-parse --show-toplevel)" ]; then
    echo "gwq-init: main checkoutでは実行できません（worktree内で実行してください）" >&2
    return 1
  fi

  if [ -d "$PARENT_CLAUDE" ]; then
    mv .claude .claude.bak
    git ls-files .claude | xargs git update-index --skip-worktree
    ln -s "$PARENT_CLAUDE" .claude
  fi

  if [ -f "$PARENT_ENVRC" ]; then
    [ -f .envrc ] && mv .envrc .envrc.bak
    git ls-files .envrc | xargs git update-index --skip-worktree
    ln -s "$PARENT_ENVRC" .envrc
  fi
}

# git worktree の安全削除。gwd / gwclean を「ゴミ箱へ退避してから削除」する版で上書きする。
# （このファイルの実体ディレクトリ = config/zsh。symlink 経由でも :A で解決される）
source "${${(%):-%x}:A:h}/gwt-safe.zsh"

