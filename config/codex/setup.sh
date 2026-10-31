#!/bin/zsh
set -eu

script_dir=${0:A:h}
cd "$script_dir"
go run . "$script_dir"
