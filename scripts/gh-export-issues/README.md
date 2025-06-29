# GitHub Issues to Markdown Exporter

GitHub リポジトリの Issue を Markdown ファイルとしてエクスポートするツールです。

## 概要

このツールは GitHub CLI (`gh`) を使用して、指定したリポジトリの全ての Issue（オープン・クローズ両方）を個別の Markdown ファイルとしてローカルに保存します。

## 必要な環境

- Go 1.16 以上
- GitHub CLI (`gh`) がインストールされ、認証済みであること

## PATH の設定

dotfiles/bin に PATH を通すことで、どこからでも `gh-export-issues` コマンドを実行できます：

```bash
# ~/.zshrc または ~/.bashrc に以下を追加
export PATH="$HOME/src/github.com/uuutee/dotfiles/bin:$PATH"
```

## インストール

### ビルドして実行

```bash
# dotfiles/bin にビルド（推奨）
go build -o ../../bin/gh-export-issues main.go

# または、カレントディレクトリにビルド
go build -o gh-export-issues main.go
```

### ビルドせずに実行

```bash
go run main.go [options]
```

## 使い方

### 基本的な使い方

```bash
# カレントリポジトリの Issue をエクスポート（./issues/ に保存）
gh-export-issues
# または
go run main.go

# カレントリポジトリを指定ディレクトリにエクスポート
gh-export-issues -o .memo/issues
# または
go run main.go -o .memo/issues

# 特定のリポジトリを指定（./owner/repo/issues/ に保存）
gh-export-issues -r owner/repo
# または
go run main.go -r owner/repo

# リポジトリと出力ディレクトリの両方を指定
gh-export-issues -r owner/repo -o ~/Documents/issues
# または
go run main.go -r owner/repo -o ~/Documents/issues

# フィルタリングの例
gh-export-issues -status open              # オープンな Issue のみ
gh-export-issues -label bug                # "bug" ラベルが付いた Issue
gh-export-issues -author uuutee            # 特定ユーザーが作成した Issue
gh-export-issues -assignee uuutee          # 特定ユーザーにアサインされた Issue
gh-export-issues -id 123                   # Issue #123 のみ
gh-export-issues -status open -label bug   # 複数条件の組み合わせ
```

### オプション

- `-o, --output DIR`: 出力ディレクトリを指定
- `-r, --repo OWNER/REPO`: エクスポートするリポジトリを指定（デフォルト: カレントリポジトリ）
- `-id ID`: 特定の Issue ID を指定してエクスポート
- `-status STATUS`: Issue のステータスでフィルタ（open, closed, all）デフォルト: all
- `-label LABEL`: ラベルでフィルタ
- `-assignee USER`: アサイニーでフィルタ
- `-author USER`: 作成者でフィルタ
- `-h, --help`: ヘルプメッセージを表示

### デフォルトの出力ディレクトリ

- カレントリポジトリの場合: `./issues/`
- リポジトリを指定した場合: `./[owner]/[repo]/issues/`

## 出力形式

各 Issue は以下の形式で保存されます：

- ディレクトリ構造: `{issue番号}/index.md`
- 内容:
  - Issue のメタデータ（状態、作成者、作成日時、更新日時、ラベル、アサイニー）
  - Issue の本文
  - コメント（存在する場合）

## 実装の詳細

- Go 言語で実装
- GitHub CLI (`gh`) コマンドを内部で使用
- JSON 形式で Issue データを取得し、Markdown に変換
- 各 Issue は個別のディレクトリに保存

## 制限事項

- 一度に最大 10,000 件の Issue を取得
- GitHub CLI の認証が必要
