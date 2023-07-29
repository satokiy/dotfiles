# dotfiles

## set up
```
git clone https://github.com/satokiy/dotfiles.git

# シンボリックリンク
ln -sf ~/<path-to-dotfiles>/_vimrc/_vimrc ~/.vimrc # ディレクトリ構造は個別

# vundleのclone
git clone http://github.com/VundleVim/Vundle.Vim.git ~/dotfiles/vimfiles/.vim/vundle.git

# vimエディタを開く
vi

# プラグインのインストール
:BundleInstall
```


