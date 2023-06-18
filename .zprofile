####################################
#        環境変数 & PATH 
####################################

###### PATH ######

# src
export SRC_DIR=$HOME/src

# dotfiles
export DOTFILES_DIR="$SRC_DIR/github.com/uuutee/dotfiles"

# dotfiles/bin
export PATH="$PATH:$DOTFILES_DIR/bin"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# pyenv
export PATH="$HOME/.pyenv/shims:$PATH"
eval "$(pyenv init -)"

# rbenv
if [[ -d "$HOME/.rbenv" ]]; then
  eval "$(rbenv init -)"
fi

# nodenv
if [[ -d "$HOME/.nodenv" ]]; then
  export PATH="$HOME/.nodenv/bin:$PATH"
  eval "$(nodenv init -)"
fi

# composer
if [[ -x $(which composer) ]]; then
  export PATH="$PATH:$HOME/.composer/vendor/bin"
fi

# rust
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

###### ENV ######

# EDITOR
export EDITOR="vim"

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoredups:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd:cdf:cdg"

# ヒストリのサイズを増やす
export HISTSIZE=10000

# direnv
eval "$(direnv hook zsh)"

####################################
#             補完系 
####################################

# bash_completion
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# awsコマンドを補完する
complete -C '/usr/local/etc/bash_completion.d' aws

# git-completion
source "$DOTFILES_DIR/etc/git/git-completion.bash"

# tmux
source "$DOTFILES_DIR/etc/tmux/completion"



####################################
#             alias
####################################

# ls -al
alias ll='ls -al'

# git
alias g='git'
alias gs='git status'
alias gb='git branch'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gd='git diff'
alias gdc='git diff --cached'

# ghq & hub
alias cdg='cd $(ghq root)/$(ghq list | peco)'

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

# unicode unescape
alias unicode-unescape="sed 's/\\\u\(....\)/\&#x\1;/g' | nkf --numchar-input -w"


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
  ssh $(grep -iE "^host[[:space:]]+[^*]" $HOME/.ssh/config | peco | awk "{print \$2}")
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

# git checkout with peco
function gcop() {
  git branch --sort=-authordate |
    cut -b 3- |
    perl -pe 's#^remotes/origin/###' |
    perl -nlE 'say if !$c{$_}++' |
    grep -v -- "->" |
    peco |
    xargs git checkout
}

# git stash apply with peco
function gsap() {
  git stash list | peco | awk -F '{|}' '{print $2}' | xargs git stash apply
}

# docker-tag-list
function docker-tag-list() {
  curl -s https://registry.hub.docker.com/v1/repositories/${1}/tags | jq -r .[].name
}

# 引数に渡したコマンドの処理時間を測定する
function measure-time() {
  local START_AT=$(date +%s)
  echo "処理開始: $(date)"
  eval $@
  local END_AT=$(date +%s)
  local TIME=$((END_AT - START_AT))
  echo "処理終了: $(date)"
  echo "処理にかかった時間は ${TIME} 秒です"
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

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
