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
go run main.go [options] [owner/repo]
```

## 使い方

### 基本的な使い方

```bash
# カレントリポジトリの Issue をエクスポート（./issues/ に保存）
./gh-export-issues
# または
go run main.go

# 特定のリポジトリを指定（./repo-name/issues/ に保存）
./gh-export-issues owner/repo
# または
go run main.go owner/repo

# 出力ディレクトリを指定
./gh-export-issues -o ~/Documents/issues owner/repo
# または
go run main.go -o ~/Documents/issues owner/repo
```

### オプション

- `-o, --output DIR`: 出力ディレクトリを指定
- `-h, --help`: ヘルプメッセージを表示

### デフォルトの出力ディレクトリ

- カレントリポジトリの場合: `./issues/`
- リポジトリを指定した場合: `./[repo-name]/issues/`

## 出力形式

各 Issue は以下の形式で保存されます：

- ファイル名: `{issue番号}-{サニタイズされたタイトル}.md`
- 内容:
  - Issue のメタデータ（状態、作成者、作成日時、更新日時、ラベル、アサイニー）
  - Issue の本文
  - コメント（存在する場合）

## 実装の詳細

- Go 言語で実装
- GitHub CLI (`gh`) コマンドを内部で使用
- JSON 形式で Issue データを取得し、Markdown に変換
- ファイル名は OS のファイルシステムに適合するようサニタイズ

## 制限事項

- 一度に最大 10,000 件の Issue を取得
- ファイル名のタイトル部分は最大 50 文字に制限
- GitHub CLI の認証が必要
