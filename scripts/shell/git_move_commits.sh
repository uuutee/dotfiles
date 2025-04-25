#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $(basename $0) <base-commit> <new-branch-name> [<old-branch>]"
  echo
  echo "  <base-commit>     : 新ブランチの起点とするコミットハッシュ"
  echo "  <new-branch-name> : 作成するブランチ名"
  echo "  [<old-branch>]    : 誤ってコミットしたブランチ (省略時はカレントブランチ)"
  exit 1
}

[ $# -ge 2 ] || usage

BASE_COMMIT=$1
NEW_BRANCH=$2
OLD_BRANCH=${3:-$(git rev-parse --abbrev-ref HEAD)}

# 存在チェック
git rev-parse --verify "$BASE_COMMIT" >/dev/null 2>&1 \
  || { echo "Error: base commit '$BASE_COMMIT' not found"; exit 1; }

echo "🏷️  誤ったブランチ: $OLD_BRANCH"
echo "🔖 ベースコミット : $BASE_COMMIT"
echo "🌿 新規ブランチ   : $NEW_BRANCH"
echo

# ベース以降のコミットを古い順で取得
COMMITS=$(git rev-list --reverse "${BASE_COMMIT}".."${OLD_BRANCH}")

# 新規ブランチをベースコミットから作成
git checkout -b "$NEW_BRANCH" "$BASE_COMMIT"

# ひとつひとつ cherry-pick
for C in $COMMITS; do
  echo "→ cherry-pick $C"
  git cherry-pick "$C"
done

# 元のブランチに戻る
git checkout "$OLD_BRANCH"
echo "✅ 完了: $NEW_BRANCH にコミットを移動しました。"
