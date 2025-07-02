# gh-pr-unapproved

特定のコメントが含まれていて、かつ未承認（unapproved）のPRを検索・表示するCLIツール

## 概要

`gh-pr-unapproved` は GitHub CLI (`gh`) を使用して、レビューが承認されていないPRの中から、特定のコメントを含むものを検索できるツールです。

## インストール

```bash
# スクリプトをPATHの通った場所にリンク
ln -s /path/to/dotfiles/scripts/gh-pr-unapproved/main.sh /usr/local/bin/gh-pr-unapproved

# または直接実行
./scripts/gh-pr-unapproved/main.sh
```

## 使い方

```bash
# 基本的な使い方（現在のリポジトリの未承認PRを表示）
gh-pr-unapproved

# 特定のコメントを含むPRを検索
gh-pr-unapproved -c "LGTM"
gh-pr-unapproved --comment "needs review"

# 特定のリポジトリを指定
gh-pr-unapproved -r owner/repo
gh-pr-unapproved --repo organization/project

# JSON形式で出力
gh-pr-unapproved -f json
gh-pr-unapproved --format json

# 組み合わせ
gh-pr-unapproved -r owner/repo -c "LGTM" -f json
```

## オプション

| オプション | 説明 | デフォルト |
|-----------|------|------------|
| `-c, --comment` | PRのコメントに含まれるテキストで検索 | なし |
| `-r, --repo` | 対象リポジトリ (owner/repo形式) | 現在のリポジトリ |
| `-f, --format` | 出力フォーマット (table/json) | table |
| `-h, --help` | ヘルプメッセージを表示 | - |

## 出力例

### テーブル形式（デフォルト）

```
リポジトリ: owner/repo
検索中...

Unapproved PRs:
===============

PR#      Title                                              Author               Review Status
---      -----                                              ------               -------------
#123     Add new feature for user authentication            @developer1          NO REVIEWS
#125     Fix memory leak in data processing                 @developer2          CHANGES_REQUESTED
#128     Update documentation for API endpoints             @developer3          DRAFT
```

### JSON形式

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

## レビューステータス

- `NO REVIEWS`: まだレビューされていない
- `CHANGES_REQUESTED`: 変更が要求されている
- `DRAFT`: ドラフト状態のPR
- その他のGitHub標準のレビューステータス

## 依存関係

- `gh` (GitHub CLI) がインストールされている必要があります
- `jq` コマンドがインストールされている必要があります
- GitHubへの認証が必要です（`gh auth login`）

## 注意事項

- コメント検索を行う場合、各PRのコメントを個別に取得するため、PR数が多い場合は時間がかかることがあります
- `--limit 1000` でPRを取得しているため、1000件を超えるオープンPRがある場合は全てを取得できません
- プライベートリポジトリの場合は適切な権限が必要です