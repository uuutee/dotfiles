# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'
# findの置換でエラーが出るので
export LANG=C
# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoreboth:erasedups
