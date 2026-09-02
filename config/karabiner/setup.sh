#!/bin/zsh

current=$(pwd)
if [[ $current != *dotfiles ]]; then
    echo "The current directory does not end with 'dotfiles'. Please run this script from the 'dotfiles' directory."
    exit 1
fi

if [[ -L $HOME/.config/karabiner ]]; then
    unlink $HOME/.config/karabiner
elif [[ -e $HOME/.config/karabiner ]]; then
    echo "A file or directory already exists at ~/.config/karabiner. Please remove it manually."
    exit 1
fi

ln -s $(pwd)/config/karabiner $HOME/.config/karabiner
