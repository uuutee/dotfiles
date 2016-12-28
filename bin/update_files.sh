#! /bin/bash
TARGET_PATH=cwp/wp-includes/class-phpmailer.php;
FROM_DIR=~/Dropbox/dev/designinc/files/update/public_html/domain;
SEARCH_DIR=~/Downloads/test/public_html;

for file in `find ${SEARCH_DIR} -path ${TARGET_PATH}`; do 
	ls -l ${file};
done | xargs echo
