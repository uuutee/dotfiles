#!/bin/bash

# tmux_attach_peco - pecoを使ってtmuxセッションを選択してアタッチする
# 使い方: tmux_attach_peco

# tmuxセッションが存在するかチェック
if ! tmux ls >/dev/null 2>&1; then
  echo "実行中のtmuxセッションがありません。"
  exit 1
fi

# tmuxセッション一覧から選択
# フォーマット: セッション名: ウィンドウ数 windows (作成日時) (attached)
selected=$(tmux ls | peco --prompt "Select tmux session >")

# 選択がキャンセルされた場合は終了
if [ -z "$selected" ]; then
  echo "セッションが選択されませんでした。"
  exit 0
fi

# セッション名を抽出（最初の:までの部分）
session_name=$(echo "$selected" | cut -d: -f1)

# 既にtmux内にいる場合はswitch、そうでなければattach
if [ -n "$TMUX" ]; then
  tmux switch-client -t "$session_name"
else
  tmux attach-session -t "$session_name"
fi