#!/bin/zsh

for setup_script in $(find ./config -name 'setup.sh'); do
    echo "Running $setup_script"
    chmod +x $setup_script
    ./$setup_script
done
