# AWS profile 切り替え
#   awsp sw <profile>  指定した profile に切り替える
#   awsp sw            peco で選んで切り替える
#
# .zshrc から source される前提。直接実行しない。

AWSP_STATE_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/awsp/profile"

awsp() {
  case "$1" in
    sw)
      shift
      _awsp_switch "$@"
      ;;
    *)
      echo "usage: awsp sw [profile]" >&2
      return 1
      ;;
  esac
}

_awsp_switch() {
  local profiles target

  profiles=$(aws configure list-profiles) || return 1
  if [[ -z "$profiles" ]]; then
    echo "awsp: ~/.aws/config に profile がありません" >&2
    return 1
  fi

  if [[ -n "$1" ]]; then
    target="$1"
  else
    if ! command -v peco >/dev/null 2>&1; then
      echo "awsp: peco が見つかりません。awsp sw <profile> で指定してください" >&2
      return 1
    fi
    target=$(print -r -- "$profiles" | peco --prompt="AWS profile>")
    [[ -z "$target" ]] && return 1
  fi

  # typo 対策: config に存在する profile 名と完全一致するときだけ切り替える
  if ! print -r -- "$profiles" | grep -qxF -- "$target"; then
    echo "awsp: profile '$target' は存在しません" >&2
    return 1
  fi

  mkdir -p "${AWSP_STATE_FILE:h}"
  print -r -- "export AWS_PROFILE=${(q)target}" > "$AWSP_STATE_FILE"
  source "$AWSP_STATE_FILE"
  echo "AWS_PROFILE=$AWS_PROFILE"
}

# シェル起動時に、最後に選んだ profile を復元する
[[ -f "$AWSP_STATE_FILE" ]] && source "$AWSP_STATE_FILE"
