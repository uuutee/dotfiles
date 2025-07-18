####################################
#        環境変数 & PATH 
####################################

# Termius 用に日本語を設定
export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

###### PATH ######

# src
export SRC_DIR=$HOME/src

# dotfiles
export DOTFILES_DIR="$SRC_DIR/github.com/uuutee/dotfiles"

# dotfiles/bin
export PATH="$PATH:$DOTFILES_DIR/bin"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrewの自動更新を無効化
export HOMEBREW_NO_AUTO_UPDATE=1

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

# Load environment variables from .env file
if [ -f ${DOTFILES_DIR}/.env ]; then
  export $(grep -v '^#' ${DOTFILES_DIR}/.env | xargs)
fi

# EDITOR
export EDITOR="vim"

# 重複するコマンドを履歴に残さない
export HISTCONTROL=ignoredups:erasedups

# よく使うコマンドは保存しない（:で区切る）
export HISTIGNORE="pwd:cdf:cdg:gs:gd:gaa:gp"

# ヒストリのサイズを増やす
export HISTSIZE=50000
export SAVEHIST=50000

# direnv
eval "$(direnv hook zsh)"



####################################
#             alias
####################################

# ls -al
alias ll='ls -al'

# git
alias g='git'
alias gs='git status'
alias gb='git branch'
alias gbc='git branch --contains'
alias ga='git add'
alias gaa='git add -A'
alias gap='git add -p'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend --no-edit'
alias gd='git diff'
alias gdc='git diff --cached'

# 変更したファイルをすべてコミット
alias gsave="$DOTFILES_DIR/scripts/git_save_point/main.sh"

# ベースコミットから新規ブランチを作成して、それ以降のコミットを移動する
alias gmv="$DOTFILES_DIR/scripts/git_move_commits/main.sh"

# 最新のブランチを取得してリベースする
alias gupdate="$DOTFILES_DIR/scripts/git_update/main.sh"

# git push && PR 作成URLの表示
alias gp='git push -u origin HEAD && gh-pr-url'

# Claude でPRをレビュー
function claude-review() {
  if [ -z "$1" ]; then
    echo "使用方法: claude-review <PR番号>"
    return 1
  fi
  claude -p "/review #$1 日本語で"
}

# Gemini でPRをレビュー
alias gemini-review="$DOTFILES_DIR/scripts/gemini-review/main.sh"

# GitHub issues export
alias ghei='$DOTFILES_DIR/scripts/gh_export_issues/main.sh'


# tmux
alias tmn="$DOTFILES_DIR/scripts/tmux_unique_session/main.sh"
alias tma="$DOTFILES_DIR/scripts/tmux_attach_peco/main.sh"

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

# 現在のリポジトリのURLを表示
function gh-repo-url() {
  if gh repo view > /dev/null 2>&1; then
    gh repo view --json url --jq .url
  else
    echo "Gitリポジトリではないか、GitHub CLIが正しく設定されていません。" >&2
  fi
}

# 現在のブランチのPR作成URLを表示
function gh-pr-url() {
  local repo_url branch_name
  repo_url=$(gh-repo-url)
  branch_name=$(git rev-parse --abbrev-ref HEAD)
  echo "${repo_url}/compare/${branch_name}?expand=1"
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


# マージ済みブランチを掃除する
# 引数に -f, --force を指定すると強制的に削除する
function gclean () {
  local opt="-d"                                    # デフォ: 安全削除
  [[ "$1" == "--force" || "$1" == "-f" ]] && opt="-D"

  local base=$(git symbolic-ref --short HEAD)       # HEAD の名前
  local protect="(^\\*|${base}|main|master|dev|development)"        # 消さない枝パターン

  git branch --merged \
    | grep -vE "${protect}" \
    | xargs -r -n 1 git branch "${opt}"
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
#           Keybind
####################################

bindkey -e  # Emacs風のキーバインディングを使用
bindkey "^F" forward-char
bindkey "^B" backward-char
bindkey "^S" history-incremental-search-forward
