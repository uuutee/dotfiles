#!/bin/bash

# 最新のブランチを取得してリベースする
# Usage: ./git_update.sh [base-branch]
# If no base branch is provided, 'main' is used by default.

# 現在のブランチを取得
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# masterブランチが存在するかチェックして適切なベースブランチを決定
if git rev-parse --verify master >/dev/null 2>&1; then
  BASE_BRANCH="master"
else
  BASE_BRANCH="main"
fi

echo ''
echo "🌿 現在のブランチ: $CURRENT_BRANCH"
echo "🌲 ベースブランチ: $BASE_BRANCH を最新の状態にリベースします。"
echo ''

git checkout "$BASE_BRANCH"
git remote update
git rebase "origin/$BASE_BRANCH"

echo ''
echo "♻️ 現在のブランチ: $CURRENT_BRANCH を最新の状態にリベースします。"
echo ''

git checkout -
git rebase "$BASE_BRANCH"

echo ''
echo "✅ 完了: $CURRENT_BRANCH を origin/$BASE_BRANCH にリベースしました。"
echo ''
