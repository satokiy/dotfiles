#!/bin/zsh

current=$(pwd)
if [[ $current != *dotfiles ]]; then
    echo "The current directory does not end with 'dotfiles'. Please run this script from the 'dotfiles' directory."
    exit 1
fi

if [[ -L $HOME/.config/karabiner ]]; then
    unlink $HOME/.config/karabiner
fi

ln -s $(pwd)/config/karabiner $HOME/.config/karabiner
