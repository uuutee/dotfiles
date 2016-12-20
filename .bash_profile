# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

# findの置換でエラーが出るので
export LANG=C

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoreboth:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="ls*:pwd"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# adbコマンド用に、platform-toolsのパスを通す
export PATH=$PATH:/Applications/adt-bundle-mac-x86/sdk/platform-tools

# rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# 日本語の文字化け対策
export LANG=ja_JP.UTF-8

# lessの文字化け対策
export LESSCHARSET=utf-8

# ターミナルで日本語入力を使用できるようにする
set input-meta on 
set output-meta on 
set convert-meta off

# homebrewの ctags を使うようにする
alias ctags='/usr/local/bin/ctags'

# i-search 用に ctrl+s をリセットする
stty stop undef
