#!/bin/zsh

current=$(pwd)
if [[ $current != *dotfiles ]]; then
    echo "The current directory does not end with 'dotfiles'. Please run this script from the 'dotfiles' directory."
    exit 1
fi

ln -s $(pwd)/config/vim/.vimrc $HOME/.vimrc

# vundleのclone
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim

# vimエディタを開き、プラグインのインストールを実行
vi -c 'BundleInstall' -c 'sleep 5' -c 'qa!'
