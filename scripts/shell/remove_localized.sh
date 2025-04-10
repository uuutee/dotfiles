#!/bin/bash

# Finder で日本語表示されるフォルダをオリジナルの名前に戻す
# e.g. アプリケーション, デスクトップ, 書類
find ~ -name '.localized' -maxdepth 2 | xargs rm -f
file_list=(
    '/Applications/.localized'
    '/Users/Shared/.localized'
    '/Library/.localized'
)
for file in "${file_list[@]}"
do
    if [ -f "$file" ]; then
        sudo rm -f "$file"
    else
        echo "$file は存在しません。"
    fi
done
