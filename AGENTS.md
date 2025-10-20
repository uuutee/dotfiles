# Repository Guidelines

## 基本

- 依頼内容・ドキュメント更新・完了報告など、対外向けの文章は日本語で統一し、必要に応じて英語表記を補足情報として添える。

## プロジェクト構成とモジュール整理

- `.bashrc`、`.zshrc`、`.vimrc`、`.tmux.conf`、`.config/*` はリポジトリ管理の正本です。編集後は `./init.sh` を再実行し、`$HOME` のシンボリックリンクを更新してください。
- ツール用スクリプトは `scripts/<tool>/main.sh` に配置します。例として `scripts/git-update/main.sh` は追従リベースを自動化します。既存スクリプトの再利用を優先し、付随ファイルは同じディレクトリに保管してください。
- `bin/` はビルド元からコピーした実行バイナリを置き、`etc/` は `homebrew/Brewfile` や `git/git-completion.bash`、tmux テンプレートなどの設定資産をまとめます。`.config/` は macOS の設定パスをミラーします。
- Finder のローカライズ解除など環境メンテ系は `scripts/remove-localized/main.sh` に集約され、`init.sh` から自動実行されます。

## コーディング規約と命名

- Bash スクリプトは `#!/bin/bash` または `#!/usr/bin/env bash` を冒頭に置き、状態変更を伴う場合は `set -euo pipefail` を有効化し、二スペースインデントと大文字の環境変数を採用します。
- 新しいツールディレクトリはハイフン区切り (`git-move-commits`、`tmux-attach-peco` など) で命名し、エントリーポイントは `main.sh` に統一し、必要なアセットと README.md を同居させてください。
- `.bashrc` や `.zshrc` を編集する際は alias と export をアルファベット順に保ち、挙動が直感的でない箇所のみ簡潔なコメントを添えます。

## コミットとプルリクエスト指針

- Conventional Commits (`feat:`、`refactor:`、`fix:` など) に従い、件名は約 65 文字以内で影響範囲を端的に示してください。
- 関連する変更は意味ごとにまとめ、`README.md` や `etc/homebrew/Brewfile` を変更した場合は同じコミットで整合させ、手動検証結果を記録してください。
- プルリクエストには変更サマリ、依存更新の有無、関連 Issue へのリンクを明記し、macOS UI に影響する場合はスクリーンショット (例: Karabiner 設定) を添付してください。
