
zshrcのシンボリックリンクは`.zshrc_personal`に設定します。  
そのため`.zshrc`では下記のように記述します。  

```sh
# Path: ~/.zshrc
if [ -f ~/.zshrc_personal ]; then
    source ~/.zshrc_personal
fi
```
