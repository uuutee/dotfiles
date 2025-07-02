#!/bin/bash

# gh-pr-unapproved - レビューが必要な(REVIEW_REQUIRED)PRの情報を表示
# 使い方: gh-pr-unapproved [-c comment] [-r repo] [-f format]

# 経過時間を人間が読みやすい形式に変換する関数
format_time_ago() {
  local timestamp="$1"
  
  if [ "$timestamp" = "null" ] || [ -z "$timestamp" ]; then
    echo "No comments"
    return
  fi
  
  # 現在時刻と指定時刻の差を秒で取得
  local now=$(date +%s)
  local then=$(date -d "$timestamp" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" +%s 2>/dev/null)
  
  if [ -z "$then" ]; then
    echo "Unknown"
    return
  fi
  
  local diff=$((now - then))
  
  # 経過時間を人間が読みやすい形式に変換
  if [ $diff -lt 60 ]; then
    echo "${diff}s ago"
  elif [ $diff -lt 3600 ]; then
    echo "$((diff / 60))m ago"
  elif [ $diff -lt 86400 ]; then
    echo "$((diff / 3600))h ago"
  elif [ $diff -lt 604800 ]; then
    echo "$((diff / 86400))d ago"
  else
    echo "$((diff / 604800))w ago"
  fi
}

# デフォルト値
COMMENT=""
REPO=""
FORMAT="table"

# ヘルプメッセージ
show_help() {
  echo "gh-pr-unapproved - レビューが必要なPRの情報を表示"
  echo ""
  echo "使い方: gh-pr-unapproved [オプション]"
  echo ""
  echo "オプション:"
  echo "  -c, --comment TEXT     PRのコメントに含まれるテキストで検索"
  echo "  -r, --repo OWNER/REPO  対象リポジトリ (デフォルト: 現在のリポジトリ)"
  echo "  -f, --format FORMAT    出力フォーマット: table, json (デフォルト: table)"
  echo "  -h, --help             このヘルプメッセージを表示"
  echo ""
  echo "例:"
  echo "  gh-pr-unapproved                               # 現在のリポジトリのレビューが必要なPRを表示"
  echo "  gh-pr-unapproved -c \"LGTM\"                     # \"LGTM\"を含むコメントがあるPR"
  echo "  gh-pr-unapproved -r owner/repo -f json         # 指定リポジトリのPRをJSON形式で出力"
}

# オプション解析
while [[ $# -gt 0 ]]; do
  case $1 in
    -c|--comment)
      COMMENT="$2"
      shift 2
      ;;
    -r|--repo)
      REPO="$2"
      shift 2
      ;;
    -f|--format)
      FORMAT="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      exit 0
      ;;
    *)
      echo "エラー: 不明なオプション: $1"
      echo "詳細は 'gh-pr-unapproved --help' を実行してください。"
      exit 1
      ;;
  esac
done

# リポジトリが指定されていない場合は現在のリポジトリを取得
if [ -z "$REPO" ]; then
  REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
  if [ -z "$REPO" ]; then
    echo "エラー: リポジトリが指定されておらず、現在のディレクトリもgitリポジトリではありません。"
    echo "-r オプションでリポジトリを指定するか、gitリポジトリ内で実行してください。"
    exit 1
  fi
fi

echo "リポジトリ: $REPO"
echo "検索中..."
echo ""

# gh pr list で全てのPR情報を取得（JSON形式）
# reviewDecision フィールドで承認状態を確認
PR_DATA=$(gh pr list \
  --repo "$REPO" \
  --state open \
  --limit 20 \
  --json number,title,author,url,reviewDecision,isDraft,createdAt,updatedAt,reviews \
  2>/dev/null)

if [ $? -ne 0 ]; then
  echo "エラー: PRの取得に失敗しました。"
  exit 1
fi

# jq を使ってフィルタリング
# reviewDecision が REVIEW_REQUIRED かつ isDraft が false のPRのみを抽出
FILTERED_PRS=$(echo "$PR_DATA" | jq -r '
  .[] | 
  select(.reviewDecision == "REVIEW_REQUIRED" and .isDraft == false) |
  @json
')

# PRごとに最新コメント時間を取得
FILTERED_PRS_WITH_COMMENTS=""
while IFS= read -r pr_json; do
  if [ -z "$pr_json" ]; then
    continue
  fi
  
  pr_number=$(echo "$pr_json" | jq -r '.number')
  
  # PRのコメントとレビューデータを取得
  pr_comments_data=$(gh pr view "$pr_number" --repo "$REPO" --json comments,reviews 2>/dev/null)
  
  # コメントデータが正しく取得できたか確認
  if [ -z "$pr_comments_data" ] || ! echo "$pr_comments_data" | jq -e . >/dev/null 2>&1; then
    # エラーの場合はコメント時間をnullにして続行
    pr_json_with_comment=$(echo "$pr_json" | jq -c '. + {latestCommentTime: null, reviewCount: 0}')
  else
    # コメントとレビューの最新時間を取得
    latest_comment_time=$(echo "$pr_comments_data" | jq -r '
      ((.comments // []) + (.reviews // [])) |
      map(select(.createdAt != null or .submittedAt != null)) |
      map(.createdAt // .submittedAt) |
      if length > 0 then max else null end
    ')
    
    # コメント検索が指定されている場合のフィルタリング
    if [ -n "$COMMENT" ]; then
      # コメントとレビューの本文を結合して検索
      all_comments=$(echo "$pr_comments_data" | jq -r '((.comments // []) + (.reviews // [])) | .[].body' 2>/dev/null)
      if [ -z "$all_comments" ] || ! echo "$all_comments" | grep -q "$COMMENT"; then
        continue
      fi
    fi
    
    # レビュー数を取得
    review_count=$(echo "$pr_comments_data" | jq -r '.reviews | length')
    
    # PRデータに最新コメント時間とレビュー数を追加（nullは文字列ではなくJSONのnullとして扱う）
    if [ "$latest_comment_time" = "null" ]; then
      pr_json_with_comment=$(echo "$pr_json" | jq -c --arg count "$review_count" '. + {latestCommentTime: null, reviewCount: ($count | tonumber)}')
    else
      pr_json_with_comment=$(echo "$pr_json" | jq -c --arg time "$latest_comment_time" --arg count "$review_count" '. + {latestCommentTime: $time, reviewCount: ($count | tonumber)}')
    fi
  fi
  
  FILTERED_PRS_WITH_COMMENTS="${FILTERED_PRS_WITH_COMMENTS}${pr_json_with_comment}"$'\n'
done <<< "$FILTERED_PRS"

FILTERED_PRS="$FILTERED_PRS_WITH_COMMENTS"

# コメントフィルタのメッセージ
if [ -n "$COMMENT" ]; then
  echo "コメントフィルタ: \"$COMMENT\""
  echo ""
fi

# 結果がない場合
if [ -z "$FILTERED_PRS" ] || [ "$FILTERED_PRS" = $'\n' ]; then
  echo "条件に一致するPRが見つかりませんでした。"
  exit 0
fi

# 出力フォーマットに応じて表示
if [ "$FORMAT" = "json" ]; then
  # JSON形式で出力（経過時間も追加）
  # 空行を除外してからJSON配列を作成
  echo "$FILTERED_PRS" | grep -v '^$' | jq -s 'map(. + {
    latestCommentTimeAgo: (
      if .latestCommentTime == null then
        "No comments"
      else
        .latestCommentTime
      end
    )
  })'
else
  # テーブル形式で出力
  echo "Review Required PRs:"
  echo "===================="
  echo ""
  
  # ヘッダー
  printf "%-8s %-50s %-20s %-15s %-20s\n" "PR#" "Title" "Author" "Reviews" "Last Comment"
  printf "%-8s %-50s %-20s %-15s %-20s\n" "---" "-----" "------" "-------" "------------"
  
  # 各PRを表示
  while IFS= read -r pr_json; do
    if [ -z "$pr_json" ]; then
      continue
    fi
    
    # JSONが正しいか確認
    if ! echo "$pr_json" | jq -e . >/dev/null 2>&1; then
      continue
    fi
    
    number=$(echo "$pr_json" | jq -r '.number')
    title=$(echo "$pr_json" | jq -r '.title' | cut -c1-50)
    author=$(echo "$pr_json" | jq -r '.author.login')
    latest_comment_time=$(echo "$pr_json" | jq -r '.latestCommentTime // "null"')
    review_count=$(echo "$pr_json" | jq -r '.reviewCount // 0')
    
    # 経過時間を取得
    time_ago=$(format_time_ago "$latest_comment_time")
    
    # レビュー数の表示
    if [ "$review_count" -eq 0 ]; then
      reviews_display="No reviews"
    elif [ "$review_count" -eq 1 ]; then
      reviews_display="1 review"
    else
      reviews_display="${review_count} reviews"
    fi
    
    printf "%-8s %-50s %-20s %-15s %-20s\n" "#$number" "$title" "@$author" "$reviews_display" "$time_ago"
  done <<< "$FILTERED_PRS"
  
  echo ""
  echo "詳細を見るには: gh pr view <PR番号> --repo $REPO"
fi
