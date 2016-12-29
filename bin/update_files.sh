#! /bin/bash

FROM_DIR=~/Dropbox/dev/designinc/files/update/public_html/domain;
TARGET_PATH=/cwp/wp-includes/class-phpmailer.php;
PUBLIC_HTML_DIR=~/Dropbox/dev/designinc/files/test/public_html;
BACKUP_DIR=~/Dropbox/dev/designinc/files/backup;

for website in `ls -l ${PUBLIC_HTML_DIR} | grep ^drw | awk '{print $9}'`; do 
	cd "${PUBLIC_HTML_DIR}/${website}"

	# 対象ファイルが見つかれば、backupして、上書き
	for file in `find ./ -path *${TARGET_PATH}`; do 
		# backup
		mkdir -p "${BACKUP_DIR}/${website}"
		cp -p ${file} "${BACKUP_DIR}/${website}"

		# 上書き
		cp -f "${FROM_DIR}${TARGET_PATH}" ${file}
	done
done
