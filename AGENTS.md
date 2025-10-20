# Repository Guidelines

## プロジェクト構成とモジュール整理
- `.bashrc`、`.zshrc`、`.vimrc`、`.tmux.conf`、`.config/*` はリポジトリ管理の正本です。編集後は `./init.sh` を再実行し、`$HOME` のシンボリックリンクを更新してください。
- ツール用スクリプトは `scripts/<tool>/main.sh` に配置します。例として `scripts/git-update/main.sh` は追従リベースを自動化します。既存スクリプトの再利用を優先し、付随ファイルは同じディレクトリに保管してください。
- `bin/` はビルド元からコピーした実行バイナリを置き、`etc/` は `homebrew/Brewfile` や `git/git-completion.bash`、tmux テンプレートなどの設定資産をまとめます。`.config/` は macOS の設定パスをミラーします。
- Finder のローカライズ解除など環境メンテ系は `scripts/remove-localized/main.sh` に集約され、`init.sh` から自動実行されます。

## ビルド・テスト・開発コマンド
- `./init.sh` — 実行権限の復旧、サブモジュール同期、シンボリックリンク生成、Finder 設定リセットを一括で行います。管理対象を追加したら再実行してください。
- `brew bundle --file etc/homebrew/Brewfile` — 宣言済みの CLI ツール、Cask、VS Code 拡張を macOS に一括導入します。
- `brew bundle dump --file etc/homebrew/Brewfile --force` — ローカルで確認済みのパッケージ更新だけを反映する際に Brewfile を再生成します。
- `scripts/git-update/main.sh` — 現在のブランチを最新 `main` または `master` にリベースします。同種の自動化は `scripts/` を確認し、重複実装を避けてください。

## コーディング規約と命名
- Bash スクリプトは `#!/bin/bash` または `#!/usr/bin/env bash` を冒頭に置き、状態変更を伴う場合は `set -euo pipefail` を有効化し、二スペースインデントと大文字の環境変数を採用します。
- 新しいツールディレクトリはハイフン区切り (`git-move-commits`、`tmux-attach-peco` など) で命名し、エントリーポイントは `main.sh` に統一し、必要なアセットを同居させてください。
- `.bashrc` や `.zshrc` を編集する際は alias と export をアルファベット順に保ち、挙動が直感的でない箇所のみ簡潔なコメントを添えます。

## テスト指針
- `bash -n scripts/<tool>/main.sh` と、可能であれば `shellcheck scripts/<tool>/main.sh` を実行し、構文と静的解析を通過させてください。
- `./init.sh` を再実行後に新しいシェルを開き、`command -v tma` や `command -v gupdate` などで期待通りにエイリアス／コマンドが解決されるか確認します。
- `git status` を実行して作業ツリーが意図通りか確認し、macOS 由来の隠しファイルが混入していないことを確かめてください。
- `git clean -dn` で削除候補を点検し、不要ファイルを連携前に取り除いてください。

## コミットとプルリクエスト指針
- Conventional Commits (`feat:`、`refactor:`、`fix:` など) に従い、件名は約 65 文字以内で影響範囲を端的に示してください。
- 関連する変更は意味ごとにまとめ、`README.md` や `etc/homebrew/Brewfile` を変更した場合は同じコミットで整合させ、手動検証結果を記録してください。
- プルリクエストには変更サマリ、依存更新の有無、関連 Issue へのリンクを明記し、macOS UI に影響する場合はスクリーンショット (例: Karabiner 設定) を添付してください。

## セキュリティと設定のヒント
- ローカル秘密情報は Git に追加せず、`envchain` や macOS Keychain、`.env.local` など未追跡ファイルを利用してください。
- `init.sh` に追加する処理は再実行性と安全性を最優先し、既存ファイルを上書きする場合はバックアップや条件分岐を用意してください。
- 設定変更を共有する際は対象 macOS バージョンや依存アプリを明記し、再現手順を README かコメントに追記するとエージェント間の認識差が減ります。
