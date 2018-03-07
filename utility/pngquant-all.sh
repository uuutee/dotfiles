#! /usr/bin/env bash

# 引数を省略したら現在のディレクトリをセット
# -n Nonzero length。空文字としての入力が必要なので、 "" は必要
if [ -n "${1}" ]; then
	target=${1}
else
	target=$(pwd)
fi

files=$(find ${target} -name "*.png")

for f in ${files}; do
	pngquant --ext .png --speed 1 --force ${f}
done

exit 0
