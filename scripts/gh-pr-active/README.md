# gh-pr-active

特定のコメントが含まれていて、かつ未承認（unapproved）の PR を検索・表示する CLI ツール

## 概要

`gh-pr-active` は GitHub CLI (`gh`) を使用して、レビューが承認されていない PR の中から、特定のコメントを含むものを検索できるツールです。

## インストール

```bash
# ビルド
cd /path/to/dotfiles/scripts/gh-pr-active
make build

# または直接go buildを実行
go build -o ../../bin/gh-pr-active

# PATHに /path/to/dotfiles/bin を追加していない場合は追加
# export PATH="$PATH:/path/to/dotfiles/bin"

# 直接実行
/path/to/dotfiles/bin/gh-pr-active
```

## 使い方

### ビルドせずに直接実行

```bash
cd /path/to/dotfiles/scripts/gh-pr-active
go run main.go
go run main.go -r owner/repo
go run main.go -c "LGTM" -f json
```

### ビルド済みバイナリを実行

```bash
# 基本的な使い方（現在のリポジトリの未承認PRを表示）
gh-pr-active

# 特定のコメントを含むPRを検索
gh-pr-active -c "LGTM"
gh-pr-active --comment "needs review"

# 特定のリポジトリを指定
gh-pr-active -r owner/repo
gh-pr-active --repo organization/project

# JSON形式で出力
gh-pr-active -f json
gh-pr-active --format json

# 組み合わせ
gh-pr-active -r owner/repo -c "LGTM" -f json
```

## オプション

| オプション      | 説明                                  | デフォルト       |
| --------------- | ------------------------------------- | ---------------- |
| `-c, --comment` | PR のコメントに含まれるテキストで検索 | なし             |
| `-r, --repo`    | 対象リポジトリ (owner/repo 形式)      | 現在のリポジトリ |
| `-f, --format`  | 出力フォーマット (table/json)         | table            |
| `-h, --help`    | ヘルプメッセージを表示                | -                |

## 出力例

### テーブル形式（デフォルト）

```
リポジトリ: owner/repo
検索中...

Review Required PRs:
====================

PR#      Title                               Author       Comments Reviews  Last updated URL
---      -----                               ------       -------- -------  ------------ ---
#123     Add new feature for user authentic  @developer1  3        0        3h ago       https://github.com/owner/repo/pull/123
#125     Fix memory leak in data processing  @developer2  5        2        1d ago       https://github.com/owner/repo/pull/125
#128     Update documentation for API endpo  @developer3  0        1        No comments  https://github.com/owner/repo/pull/128
```

### JSON 形式

```json
[
  {
    "number": 123,
    "title": "Add new feature for user authentication",
    "author": {
      "login": "developer1"
    },
    "url": "https://github.com/owner/repo/pull/123",
    "reviewDecision": null,
    "isDraft": false,
    "createdAt": "2024-01-01T00:00:00Z",
    "updatedAt": "2024-01-02T00:00:00Z"
  }
]
```

## フィルタリング条件

- `REVIEW_REQUIRED`: レビューが必要な PR のみを表示
- ドラフト PR は除外
- レビュー数と最新コメント/レビューからの経過時間を表示

## 依存関係

- `gh` (GitHub CLI) がインストールされている必要があります
- GitHub への認証が必要です（`gh auth login`）
- Go 1.21 以上（ビルド時のみ）

## 注意事項

- コメント検索を行う場合、各 PR のコメントを個別に取得するため、PR 数が多い場合は時間がかかることがあります
- `--limit 1000` で PR を取得しているため、1000 件を超えるオープン PR がある場合は全てを取得できません
- プライベートリポジトリの場合は適切な権限が必要です
