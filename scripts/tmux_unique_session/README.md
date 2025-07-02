# tmux_unique_session

重複しないユニークな名前で tmux セッションを作成するスクリプト

## 概要

既存のセッション名と重複しないように、自動的に番号を付与してユニークなセッション名を生成します。

## 使い方

```bash
tmux_unique_session [base_session_name] [additional_tmux_new_args...]
```

### 引数

- `base_session_name` (オプション): ベースとなるセッション名。省略時はカレントディレクトリ名を使用
- `additional_tmux_new_args`: `tmux new` コマンドに渡す追加の引数

### 例

```bash
# カレントディレクトリ名でセッションを作成
tmux_unique_session

# "myproject" という名前でセッションを作成
tmux_unique_session myproject

# "myproject" という名前で、初期コマンドを指定してセッションを作成
tmux_unique_session myproject vim
```

## 動作

1. 指定された名前（または現在のディレクトリ名）でセッションの作成を試みます
2. 同名のセッションが既に存在する場合、`-1`、`-2`、`-3`... とサフィックスを付けていきます
3. 利用可能な名前が見つかったら、その名前で新しいセッションを作成します

例えば、`myproject` というセッションが既に存在する場合、`myproject-1` という名前でセッションが作成されます。

## インストール

1. スクリプトを実行可能にする：

   ```bash
   chmod +x main.sh
   ```

2. PATH の通った場所にシンボリックリンクを作成するか、エイリアスを設定：
   ```bash
   # エイリアスの例
   alias tus='/path/to/tmux_unique_session/main.sh'
   ```
