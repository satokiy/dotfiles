
zshrcのシンボリックリンクは`.zshrc_personal`に設定します。  
そのため`.zshrc`では下記のように記述します。  

```sh
# Path: ~/.zshrc
if [ -f ~/.zshrc_personal ]; then
    source ~/.zshrc_personal
fi
```

## ファイル構成

- `.zshrc`：環境変数、ツール初期化、補完、キー設定、プロンプト設定、コマンド定義の読み込み
- `scripts/aliases.zsh`：コマンドのエイリアス
- `scripts/git.zsh`：`peco-git-checkout`、`gww`、`gwq-init`
- `scripts/gwt-safe.zsh`：`gwd`、`gwclean`、`gwt-restore`（worktree をゴミ箱へ退避・復元）
- `scripts/aws.zsh`：`awsp sw [profile]`（AWSプロファイルの切り替えと起動時の復元）
- `setup.sh`：`~/.zshrc_personal`へのシンボリックリンク作成

`scripts/*.zsh`は、現在のシェルで関数や環境変数を設定するため、直接実行せず`.zshrc`から`source`します。
読み込み先は`.zshrc`の実体を基準に解決するため、シンボリックリンク経由でも読み込めます。

コマンドを追加するときは用途に合う`scripts/*.zsh`へ記述します。
新しいファイルを作った場合は、`.zshrc`の「コマンド定義」に`source`を追加してください。
