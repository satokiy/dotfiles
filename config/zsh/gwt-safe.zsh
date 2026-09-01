# gwt-safe.zsh
#
# git worktree の削除を「復元可能」にする。
# gwd / gwclean は git worktree remove で worktree ディレクトリを rm するが、
# .claude* など gitignore 対象の未追跡ファイルは --force なしでも一緒に消える。
# ここでは削除前に worktree を丸ごと ~/.Trash へ退避してから prune する。
#
# この後で source されることで、.zshrc 内の inline な gwd / gwclean を上書きする。

# worktree ディレクトリを丸ごとゴミ箱へ退避する。
# ~/.Trash が同一ボリュームなら mv で瞬時、別ボリュームなら copy + rm にフォールバック。
_gwt_trash() {
  local src="$1"
  [ -d "$src" ] || { echo "gwt(safe): ディレクトリではない: $src" >&2; return 1; }
  local dest="$HOME/.Trash/gwt_${src:t}_$(date +%Y%m%d-%H%M%S)"
  if mv "$src" "$dest" 2>/dev/null || { cp -a "$src" "$dest" && rm -rf "$src"; }; then
    echo "gwt(safe): ゴミ箱へ退避: $dest"
    return 0
  fi
  echo "gwt(safe): 退避に失敗: $src" >&2
  return 1
}

# ゴミ箱に退避した worktree の一覧表示 / 復元。
#   gwt-restore                       -> 退避済み一覧
#   gwt-restore <ゴミ箱内の名前> <復元先> -> 復元
gwt-restore() {
  if [ $# -lt 2 ]; then
    echo "退避済み worktree:"
    ls -dt "$HOME/.Trash"/gwt_* 2>/dev/null
    echo "使い方: gwt-restore <ゴミ箱内の名前> <復元先ディレクトリ>"
    return
  fi
  local src="$HOME/.Trash/$1"
  [ -d "$src" ] || { echo "見つからない: $src" >&2; return 1; }
  cp -a "$src" "$2" && echo "復元 -> $2"
}

# 削除: peco で選んで、ゴミ箱へ退避してから worktree を prune する。
gwd() {
  local target_dir=$(git worktree list | grep "=" | peco | awk '{print $1}')
  [ -n "$target_dir" ] || return
  _gwt_trash "$target_dir" || return
  git worktree prune
  echo "Deleted worktree (Trash へ退避済み): $target_dir"
}

# 不要なworktreeを一掃（ゴミ箱へ退避してから削除）。
# 条件: コミットされていない変更がない（未追跡ファイルは無視）かつ
#       ブランチが origin/main または origin/master にマージ済み
# 注意: origin の最新状態で判定するため、必要なら事前に git fetch しておく
gwclean() {
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

  echo "以下の worktree を削除します（ゴミ箱へ退避してから削除）:"
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
        _gwt_trash "$p" && echo "Deleted worktree (Trash へ退避済み): $p"
      done
      git worktree prune
      ;;
    *)
      echo "中止しました"
      ;;
  esac
}
