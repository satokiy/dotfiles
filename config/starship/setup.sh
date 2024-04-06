#!/bin/zsh

current=$(pwd)
if [[ $current != *dotfiles ]]; then
    echo "The current directory does not end with 'dotfiles'. Please run this script from the 'dotfiles' directory."
    exit 1
fi

if [ -L $HOME/.config/starship.toml ]; then
    unlink $HOME/.config/starship.toml
fi

ln -s $(pwd)/config/starship/starship.toml $HOME/.config/starship.toml
