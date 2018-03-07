#! /usr/bin/env bash

# カレントディレクトリ内の画像を一括で指定フォーマットに変換する

from_ext=$1
dest_ext=$2

images=($(find . -name "*.${from_ext}"))
dest="./convert"

# ディレクトリがなければ作成
if [[ ! -e ${dest} ]]; then
  mkdir -p ${dest}
fi

for image in ${images[@]}; do
  # ファイル名のみを取得
  name=$(basename ${image})
  name=${name%.*}

  # imagemagickで変換
  convert ${image} -quality 100 ${dest}/${name}.${dest_ext}
done

exit 0