#! /bin/bash

# ディレクトリにマッチしたら終了
if [[ $1 =~ /$ ]]; then
	echo ${1} 'is directory.';

# 存在するファイルなら開く
elif [ -e $1 ]; then
	/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $1;

# 存在しないファイルなら新規作成して開く
else
	while true; do
		read -p 'file is not found do you make file? (y/n) ' yn
		case $yn in
			[Yy]* ) 
				DIR=`dirname ${1}`;
				mkdir -p ${DIR};
				touch $1;
				/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl $1;
				break;;
			[Nn]* ) 
				echo 'not making'; 
				exit;;
			* ) echo 'Please answer yes or no.';;
		esac
	done
fi

exit 0