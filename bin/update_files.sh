#! /bin/bash

# update_files.sh
# 対象のディレクトリに一致したファイルが存在したら、バックアップを取得して、SRC_DIR内の同ファイルを上書きする

# テスト実行フラグ
IS_DRYRUN=true
# 置き換えるファイルのソースディレクトリ
SRC_DIR=~/.update_files/src
# 検索対象のディレクトリ
SEARCH_DIR=~/public_html/
# 置き換えるファイルの相対パスを配列で指定。（先頭と末尾のスラッシュは不要）
TARGETS=('cwp/wp-includes/class-phpmailer.php' 'cwp/wp-includes/class-smtp.php')
# バックアップディレクトリ
TIME=`date +"%Y%m%d%H%M%S"`
BACKUP_DIR=~/.update_files/backup/${TIME}

for target in "${TARGETS[@]}"; do
	# 対象ファイルが見つかれば、backupして、上書き
	for file in `find ${SEARCH_DIR} -path *${target}`; do 
		if ${IS_DRYRUN} ; then
			# dryrun
			echo "${file}"
		else
			# backup
			TARGET_DIR_PATH=`dirname ${file}`
			mkdir -p "${BACKUP_DIR}${TARGET_DIR_PATH}"
			cp -rp ${file} "${BACKUP_DIR}/${TARGET_DIR_PATH}"

			# 削除して上書き
			rm -rf ${file} # ディレクトリの内容を置き換えない（ファイルを統合する）場合はrm不要
			cp -rf "${SRC_DIR}/${target}" ${TARGET_DIR_PATH}
		fi
	done
done
