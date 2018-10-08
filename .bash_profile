# bashrc を読み込み
if [ -f ~/.bashrc ]; then
  source ~/.bashrc
fi


####################################
#        環境変数 & PATH 
####################################

###### PATH ######

# GO
export GOPATH=$HOME
export PATH=$PATH:$GOPATH/bin

# src
export SRC_DIR=~/src

# dotfiles
export DOTFILES_DIR="$SRC_DIR/github.com/uuutee/dotfiles"

# dotfiles/bin
export PATH="$PATH:$DOTFILES_DIR/bin"

# adb
export PATH="$PATH:/Applications/adt-bundle-mac-x86/sdk/platform-tools"

# anyenv
if [[ -d "$HOME/.anyenv" ]]; then
  export PATH="$HOME/.anyenv/bin:$PATH"
  eval "$(anyenv init -)"
fi

# rbenv
if [[ -d "$HOME/.rbenv" ]]; then
  eval "$(rbenv init -)"
fi

# ndenv
if [[ -d "$HOME/.ndenv" ]]; then
  export PATH="$HOME/.ndenv/bin:$PATH"
  eval "$(ndenv init -)"
fi

# composer
if [[ -x $(which composer) ]]; then
  export PATH="$PATH:$HOME/.composer/vendor/bin"
fi

# direnv
export EDITOR="vim"
eval "$(direnv hook bash)"

# gettext
export PATH=/usr/local/opt/gettext/bin:$PATH

# homebrewのopensslを使用する
export PATH=/usr/local/opt/openssl/bin:$PATH

# bison
export PATH=/usr/local/opt/bison@2.7/bin:$PATH

# node のrequire先にnpm -gのパスを追加する
export NODE_PATH=$(npm root -g)


###### ENV ######

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoredups:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd:cdf:cdg"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# javaの文字化けを回避
export _JAVA_OPTIONS='-Dfile.encoding=UTF-8'

# 日本語の文字化け対策
export LANG=ja_JP.UTF-8

# lessの文字化け対策
export LESSCHARSET=utf-8

# source-highlight で lessをハイライトする
export LESS='-R'
export LESSOPEN='| /usr/local/Cellar/source-highlight/3.1.8_8/bin/src-hilite-lesspipe.sh %s'

# ~/ansible.cfg が反映されないので設定する
export ANSIBLE_CONFIG=~/ansible.cfg

# i-search 用に ctrl+s をリセットする
stty stop undef



####################################
#             補完系 
####################################

# bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# awsコマンドを補完する
complete -C '/usr/local/bin/aws_completer' aws

# git-completion
source /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash



####################################
#             alias
####################################

# ls -al
alias ll='ls -al'

# homebrewの ctags を使うようにする
alias ctags='/usr/local/bin/ctags'

# git
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'

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
alias myip='curl -s httpbin.org/ip | jq -r .origin'

# Docker: すべてのコンテナを削除
alias docker-rm-all='docker rm -f $(docker ps -a -q)'

# ansible-playbook
alias ap='ansible-playbook'



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

# peco-ssh
function s() {
  ssh $(grep -iE "^host[[:space:]]+[^*]" ~/.ssh/config | peco | awk "{print \$2}")
}

# パスワードを生成
function pw() {
  pwgen -s 12 | awk '{print $0}' | pbcopy && pbpaste
}

# find with peco
function fp() {
  if [ -n "${1}" ]; then
    local path=${1}
  else
    local path=.
  fi

  find ${path} -maxdepth 8 -a ! -regex '.*/\..*' | peco
}

# find all with peco
function fpa() {
  if [ -n "${1}" ]; then
    local path=${1}
  else
    local path=.
  fi

  find ${path} -maxdepth 8 | peco
}

# docker-tag-list
function docker-tag-list() {
  curl -s https://registry.hub.docker.com/v1/repositories/${1}/tags | jq -r .[].name
}



####################################
#           key bind
####################################

# search history
function _peco-select-history() {
  local l=$(\history | tail -r | sed -e 's/^\ *[0-9]*\ *//' | peco)
  READLINE_LINE="${l}"
  READLINE_POINT=${#l}
}
bind -x '"\C-r": _peco-select-history'

# search current directory
function _peco-find() {
  local l=$(\find . -maxdepth 8 -a \! -regex '.*/\..*' | peco)
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${l}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(($READLINE_POINT + ${#l}))
}
bind -x '"\C-uc": _peco-find'

# search all current directory
function _peco-find-all() {
  local l=$(\find . -maxdepth 8 | peco)
  READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${l}${READLINE_LINE:$READLINE_POINT}"
  READLINE_POINT=$(($READLINE_POINT + ${#l}))
}
bind -x '"\C-uca": _peco-find-all'

####################################
#           other
####################################
