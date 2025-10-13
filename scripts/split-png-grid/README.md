# split-png-grid

PNG画像を縦横に分割するためのGo製CLIです。

## 必要な環境

- Go 1.22 以降
- 入力ファイルはPNG形式である必要があります。

## ビルド

```bash
# 推奨: binディレクトリに配置
cd scripts/split-png-grid && go build -o ../../bin/split-png-grid

# カレントディレクトリへビルド
go build -o split-png-grid
```

## 使い方

```bash
cd scripts/split-png-grid
# ビルド済みバイナリを実行
./split-png-grid input.png --vertical 2 --horizontal 4

# ビルドせずに実行
go run . input.png --vertical 2 --horizontal 4

# プレフィックスや出力先を指定
./split-png-grid input.png --vertical 2 --horizontal 4 --output-dir output --prefix tile
```

### 主なオプション

- `--vertical` (`-vertical`): 列数（デフォルト: 1）
- `--horizontal` (`-horizontal`): 行数（デフォルト: 1）
- `--output-dir`: 出力先ディレクトリ（デフォルト: `<入力ファイル>_slices`）
- `--prefix`: 出力ファイルのプレフィックス（デフォルト: 入力ファイル名のstem）

### 出力

ファイルは `prefix_rXX_cYY.png` 形式のファイル名で保存されます。`XX` と `YY` には行番号・列番号がゼロ埋めで入ります。

## ライセンス

このディレクトリ内のスクリプトはリポジトリのライセンスに従います。
