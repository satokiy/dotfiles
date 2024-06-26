#!/bin/zsh

current=$(pwd)
if [[ $current != *dotfiles ]]; then
    echo "The current directory does not end with 'dotfiles'. Please run this script from the 'dotfiles' directory."
    exit 1
fi

if [ -L $HOME/.config/git/my.conf ]; then
    unlink $HOME/.config/git/my.conf
fi

if [ -L $HOME/.config/git/config ]; then
    unlink $HOME/.config/git/config
fi

echo "Create your user.conf at .config/git"

ln -s $(pwd)/config/git/my.conf $HOME/.config/git/my.conf
ln -s $(pwd)/config/git/config $HOME/.config/git/config
