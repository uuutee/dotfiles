# bashrc を読み込み
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

# 重複するコマンドを履歴に残さない
export HISTCONTROL=erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd:cdf:cdg"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# adbコマンド用
export PATH="$PATH:/Applications/adt-bundle-mac-x86/sdk/platform-tools"

# rbenv
export PATH="$PATH:$HOME/.rbenv/bin"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# anyenv
if [ -d "$HOME/.anyenv/" ]; then 
	export PATH="$HOME/.anyenv/bin:$PATH"
	eval "$(anyenv init -)"
fi

# 日本語の文字化け対策
export LANG=ja_JP.UTF-8

# lessの文字化け対策
export LESSCHARSET=utf-8

# source-highlight で lessをハイライトする
export LESS='-R'
export LESSOPEN='| /usr/local//Cellar/source-highlight/3.1.8_4/bin/src-hilite-lesspipe.sh %s'

# i-search 用に ctrl+s をリセットする
stty stop undef

# homebrewの ctags を使うようにする
alias ctags='/usr/local/bin/ctags'

# subl
alias subl="~/Dropbox/dev/src/github.com/uuutee/dotfiles/etc/scripts/subl.sh"

# rperm
alias rperm="~/Dropbox/dev/src/github.com/uuutee/dotfiles/etc/scripts/rperm.sh"

# httpstat
alias httpstat="~/Dropbox/dev/src/github.com/uuutee/dotfiles/etc/scripts/httpstat.sh"

# ghq & hub
alias cdg='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# Finderで現在開いているディレクトリに移動
cdf () {
	target=`osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)'`
	if [ "$target" != "" ]
	then
		cd "$target"
		pwd
	else
		echo 'No Finder window found' >&2
	fi
}

# bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# enhancd
ENHANCD_HYPHEN_ARG="-ls"
ENHANCD_DOT_ARG="-up"
source ~/Dropbox/dev/src/github.com/b4b4r07/enhancd/init.sh

# search history
peco-select-history() {
  local l=$(\history | tail -r | sed -e 's/^\ *[0-9]*\ *//' | peco)
  READLINE_LINE="${l}"
  READLINE_POINT=${#l}
}
bind -x '"\C-r": peco-select-history'

# search current directory
peco-find() {
  local l=$(\find . -maxdepth 8 -a \! -regex '.*/\..*' | peco)
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${l}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(($READLINE_POINT + ${#l}))
}
bind -x '"\C-uc": peco-find'

function peco-find-all() {
  local l=$(\find . -maxdepth 8 | peco)
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${l}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(($READLINE_POINT + ${#l}))
}
bind -x '"\C-ua": peco-find-all'

# node のrequire先にnpm -gのパスを追加する
export NODE_PATH=`npm root -g`

# python 2.7 用にパスを通す
export PATH="$PATH:~/Library/Python/2.7/bin/"
