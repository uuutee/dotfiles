# debug
echo 'start ~/.bash_profile'

# bashrc を読み込み
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoreboth:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# adbコマンド用に、platform-toolsのパスを通す
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

# i-search 用に ctrl+s をリセットする
stty stop undef

# homebrewの ctags を使うようにする
alias ctags='/usr/local/bin/ctags'

# subl
alias subl="~/dotfiles/etc/scripts/subl.sh"

# rperm
alias rperm="~/dotfiles/etc/scripts/rperm.sh"

# httpstat
alias httpstat="~/dotfiles/etc/scripts/httpstat.sh"

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
