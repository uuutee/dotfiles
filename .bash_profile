# bashrc を読み込み
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi


####################################
#           環境変数
####################################

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoredups:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd:cdf:cdg"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

# adbコマンド用
export PATH="$PATH:/Applications/adt-bundle-mac-x86/sdk/platform-tools"

# anyenv
if [[ -d "$HOME/.anyenv" ]]; then
  export PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init -)"
fi

# laravel
if [[ -x $(which phpenv) ]]; then
  PHPENV_LARAVEL_BIN_PATH=$(phpenv which laravel)
  if [[ -e $(dirname ${PHPENV_LARAVEL_BIN_PATH}) ]]; then
    PATH="$PATH:${PHPENV_LARAVEL_BIN_PATH}"
  fi
fi

# 日本語の文字化け対策
export LANG=ja_JP.UTF-8

# lessの文字化け対策
export LESSCHARSET=utf-8

# source-highlight で lessをハイライトする
export LESS='-R'
export LESSOPEN='| /usr/local/Cellar/source-highlight/3.1.8_4/bin/src-hilite-lesspipe.sh %s'

# node のrequire先にnpm -gのパスを追加する
export NODE_PATH=$(npm root -g)

# Go Lang用パス
export GOPATH="$HOME/.go/"

# ~/ansible.cfg が反映されないので一応設定する
export ANSIBLE_CONFIG=~/ansible.cfg

# gettext
export PATH=/usr/local/opt/gettext/bin:$PATH

# homebrewのopensslを使用する
export PATH=/usr/local/opt/openssl/bin:$PATH

# i-search 用に ctrl+s をリセットする
stty stop undef



####################################
#             補完系 
####################################

# bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# enhancd
ENHANCD_HYPHEN_ARG="-ls"
ENHANCD_DOT_ARG="-up"
source ~/.ghq/github.com/b4b4r07/enhancd/init.sh

# awsコマンドを補完する
complete -C '~/Library/Python/2.7/bin/aws_completer' aws



####################################
#             alias
####################################

# ls -al
alias ll='ls -al'

# homebrewの ctags を使うようにする
alias ctags='/usr/local/bin/ctags'

# subl
alias subl="~/.ghq/github.com/uuutee/dotfiles/etc/scripts/subl.sh"

# rperm
alias rperm="~/.ghq/github.com/uuutee/dotfiles/etc/scripts/rperm.sh"

# httpstat
alias httpstat="~/.ghq/github.com/uuutee/dotfiles/etc/scripts/httpstat.sh"

# convert-all
alias convert-all="~/.ghq/github.com/uuutee/dotfiles/etc/scripts/convert-all.sh"

# png画像を圧縮する
alias pngquant-all="~/.ghq/github.com/uuutee/dotfiles/etc/scripts/pngquant-all.sh"

# ghq & hub
alias cdg='cd $(ghq root)/$(ghq list | peco)'
alias gh='hub browse $(ghq list | peco | cut -d "/" -f 2,3)'

# diffの代わりにcolordiffを使用する
if [[ -x $(which colordiff) ]]; then
  alias diff='colordiff'
fi

# profileのリロード
alias reload="exec $SHELL -l"

# 自身のグローバルIP
alias ip='curl -s httpbin.org/ip | jq -r .origin'

# Docker: すべてのコンテナを削除
alias docker-rm-all='docker rm -f $(docker ps -a -q)'



####################################
#           functions
####################################

# Finderで現在開いているディレクトリに移動
function cdf() {
  target=$(osascript -e 'tell application "Finder" to if (count of Finder windows) > 0 then get POSIX path of (target of front Finder window as text)')
  if [[ "$target" != "" ]]; then
    cd "$target"
    pwd
  else
    echo 'No Finder window found' >&2
  fi
}

# search history
function peco-select-history() {
  local l=$(\history | tail -r | sed -e 's/^\ *[0-9]*\ *//' | peco)
  READLINE_LINE="${l}"
  READLINE_POINT=${#l}
}
bind -x '"\C-r": peco-select-history'

# search current directory
function peco-find() {
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

# peco-ssh
function s() {
  ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config | peco | awk "{print \$2}")
}

# パスワードを生成
function pw() {
  pwgen -s 12 | awk '{print $0}' | pbcopy && pbpaste
}
