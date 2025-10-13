# make-peco

Makefile 内のターゲット（コマンド）を抽出して peco でフィルタリングし、選択されたターゲットを実行するスクリプトです。

## 機能

- Makefile からターゲット（コマンド）を自動抽出
- peco でインタラクティブにフィルタリング
- 選択されたターゲットを自動実行
- 非対話的環境では利用可能なターゲットをリスト表示
- ヘルプ機能とリスト表示機能

## 使用方法

```bash
# 基本的な使用方法（カレントディレクトリのMakefileを使用）
make-peco

# 指定したMakefileを使用
make-peco ../Makefile

# 利用可能なターゲットをリスト表示（実行しない）
make-peco --list

# ヘルプを表示
make-peco --help
```

## 前提条件

- `peco` がインストールされている必要があります
- macOS の場合: `brew install peco`

## 例

Makefile に以下のようなターゲットがある場合：

```makefile
.PHONY: build clean test

build:
	go build -o app

clean:
	rm -f app

test:
	go test ./...
```

`make-peco`を実行すると、peco で以下のターゲットから選択できます：

- build
- clean
- test

選択されたターゲットが自動的に実行されます。

## 非対話的環境での使用

CI/CD やスクリプト内で使用する場合、自動的にターゲットのリストが表示されます：

```bash
$ make-peco
Available targets:
build
clean
test
```
