#! /bin/bash

# rperm.sh
# 再帰的に親のパーミッションを表示する
# ls -Rlでもいいけど、見づらいのでそういうときに使う。


# 引数を省略したら現在のディレクトリをセット
# -n Nonzero length。空文字としての入力が必要なので、 "" は必要
if [ -n "${1}" ]; then
	target=$1
else
	target=`pwd`
fi

# ファイル/ディレクトリが存在するなら実行
if [ -e ${target} ]; then
	# 対象が相対パスなら絶対パスに変換
	if [[ ! ${target} =~ ^/ ]]; then
		target=$(cd $(dirname ${target}) && pwd)/$(basename ${target})
	fi

	# IFSでsplitして、配列に変換
	IFS_ORIGINAL=${IFS}
	IFS=/
	arr=(${target})
	IFS=${IFS_ORIGINAL}

	# ループ用変数
	cur=0
	cur_dir=""
	next=1

	# ルートからlsしていく
	for value in "${arr[@]}"; do
		# 最後の値以外なら ls
		# 配列のlengthは ${#arr[@]} で取得
		if [ "${next}" != "${#arr[@]}" ]; then
			# ループ用変数をインクリメント
			cur_dir=${cur_dir}${value}"/"

			permission=`ls -l ${cur_dir} | awk -v file=${arr[${next}]} '($9 == file) { print $1 }'`
			owner=`ls -l ${cur_dir} | awk -v file=${arr[${next}]} '($9 == file) { print $3 }'`
			group=`ls -l ${cur_dir} | awk -v file=${arr[${next}]} '($9 == file) { print $4 }'`

			echo "Path:        "${cur_dir}${arr[${next}]}
			echo "File:        "${arr[${next}]}
			echo "Permission:  "${permission}
			echo "Owner:       "${owner}:${group}
			echo "\
			"
		fi

		cur=`expr ${cur} + 1`
		next=`expr ${next} + 1`
	done
fi

exit 0
