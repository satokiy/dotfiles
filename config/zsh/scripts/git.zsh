# git checkout
function peco-git-checkout {
  git branch --format='%(refname:short)' | peco | xargs git checkout
}

### git worktree
# 移動
function gww() {
  local target_dir=$(git worktree list | peco | awk '{print $1}')
  if [ -n "$target_dir" ]; then
    cd "$target_dir"
  fi
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
