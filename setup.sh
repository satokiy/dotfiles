#!/bin/zsh

# configディレクトリ配下の各ディレクトリでsetup.shを探し、存在する場合は実行する
for setup_script in $(find ./config -name 'setup.sh'); do
    echo "Running $setup_script"
    chmod +x $setup_script
    ./$setup_script
done
