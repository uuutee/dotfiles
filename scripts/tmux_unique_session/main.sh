#!/bin/bash

# tmux_unique_session - ユニークな名前でtmuxセッションを作成する
# 使い方: tmux_unique_session [base_session_name] [additional_tmux_new_args...]
# 引数を指定しない場合、カレントディレクトリ名がセッション名になる

# ベースとなるセッション名を設定
# 引数がない場合はカレントディレクトリ名を使用
if [ $# -eq 0 ]; then
  base=$(basename "$PWD")
else
  base=$1
  shift  # 残りの引数は tmux new へそのまま渡す
fi

# ユニークなセッション名を生成
name=$base
n=1

# 同名のセッションが存在する限り、数字のサフィックスをインクリメント
while tmux has-session -t "$name" 2>/dev/null; do
  name="${base}-${n}"
  n=$((n+1))
done

# 最終的にユニークなセッション名で新しいセッションを作成
tmux new -s "$name" "$@" 
