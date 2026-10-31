# Codex CLI

応答完了時の端末通知を有効にする。端末がフォーカスされている場合も通知する。
通知の表示・音は端末とOSの通知設定に従う。

セットアップ処理はGoで実装している。Go 1.22以降が必要。
初回実行時に `go.mod` / `go.sum` で固定したTOMLライブラリを取得する。

```sh
./config/codex/setup.sh
```

既存の `~/.codex/config.toml` をバックアップし、通知設定だけを同じファイルに反映する。
端末固有の設定はdotfilesへコピーしない。シンボリックリンクも作らない。
`CODEX_HOME` が指定されている場合は、その配下の設定を対象にする。
dotfiles ルートの `setup.sh` からも実行される。

- `config.toml`: Git管理する通知設定。
- 通知設定を変更したら `setup.sh` を再実行し、Codex CLIを起動し直す。
- 既存の `notify` コマンドは保持する。
- 設定全体をTOMLとして書き直すため、コメント・項目の並び・書式は保持しない。

この通知は1回の応答の終了を表し、作業の成功を保証するものではない。
`codex exec` 向けの設定ではなく、対話CLIの通知設定。

公式資料: https://developers.openai.com/codex/config-advanced#notifications
