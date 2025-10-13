#!/bin/bash

# Makefile内のターゲットを抽出してpecoでフィルタリングするスクリプト
# 使用方法: make-peco [Makefileのパス]
# 
# 機能:
# - Makefileからターゲット（コマンド）を自動抽出
# - pecoでインタラクティブにフィルタリング
# - 選択されたターゲットを自動実行
# - 非対話的環境では利用可能なターゲットをリスト表示

set -e

# ヘルプ表示
show_help() {
    cat << EOF
Usage: make-peco [Makefileのパス]

Makefile内のターゲットを抽出してpecoでフィルタリングし、選択されたターゲットを実行します。

Options:
    -h, --help    このヘルプを表示
    -l, --list    利用可能なターゲットをリスト表示（実行しない）

Examples:
    make-peco                    # カレントディレクトリのMakefileを使用
    make-peco ../Makefile       # 指定したMakefileを使用
    make-peco --list            # ターゲットをリスト表示のみ

EOF
}

# コマンドライン引数の処理
LIST_ONLY=false
MAKEFILE_PATH="Makefile"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -l|--list)
            LIST_ONLY=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            show_help
            exit 1
            ;;
        *)
            MAKEFILE_PATH="$1"
            shift
            ;;
    esac
done

# Makefileが存在するかチェック
if [ ! -f "$MAKEFILE_PATH" ]; then
    echo "Error: Makefile not found at $MAKEFILE_PATH" >&2
    exit 1
fi

# Makefileからターゲットを抽出する関数
extract_targets() {
    local makefile="$1"
    
    # Makefileからターゲットを抽出
    # 1. コロン(:)で終わる行を探す
    # 2. .PHONYやコメント、空行を除外
    # 3. インデントされていない行のみを対象とする
    grep -E '^[a-zA-Z0-9_-]+:' "$makefile" | \
    grep -v '^\.' | \
    grep -v '^#' | \
    sed 's/:.*$//' | \
    sort | \
    uniq
}

# ターゲットを抽出
TARGETS=$(extract_targets "$MAKEFILE_PATH")

# ターゲットが存在しない場合
if [ -z "$TARGETS" ]; then
    echo "No targets found in $MAKEFILE_PATH" >&2
    exit 1
fi

# pecoがインストールされているかチェック
if ! command -v peco >/dev/null 2>&1; then
    echo "Error: peco is not installed. Please install peco first." >&2
    echo "Install with: brew install peco" >&2
    exit 1
fi

# リスト表示のみの場合
if [ "$LIST_ONLY" = true ]; then
    echo "Available targets in $MAKEFILE_PATH:"
    echo "$TARGETS"
    exit 0
fi

# 対話的な環境かチェック
if [ ! -t 0 ] || [ ! -t 1 ]; then
    echo "Available targets:"
    echo "$TARGETS"
    exit 0
fi

# pecoでターゲットを選択
SELECTED_TARGET=$(echo "$TARGETS" | peco --prompt "Select make target> ")

# 何も選択されなかった場合
if [ -z "$SELECTED_TARGET" ]; then
    echo "No target selected"
    exit 0
fi

# 選択されたターゲットを実行
echo "Running: make $SELECTED_TARGET"
make "$SELECTED_TARGET"
