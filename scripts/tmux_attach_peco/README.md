# tmux_attach_peco

peco を使用して tmux セッションを選択し、アタッチするスクリプト

## 概要

実行中の tmux セッション一覧を peco で表示し、選択したセッションにアタッチまたは切り替えます。

## 使い方

```bash
tmux_attach_peco
```

## 動作

1. `tmux ls` で現在のセッション一覧を取得
2. peco で一覧を表示し、ユーザーが選択
3. 選択されたセッションに対して：
   - tmux 外から実行した場合: `tmux attach-session` でアタッチ
   - tmux 内から実行した場合: `tmux switch-client` でセッションを切り替え

## 特徴

- セッション名、ウィンドウ数、作成日時、アタッチ状態が一覧で確認できる
- peco のインクリメンタルサーチでセッションを素早く検索
- tmux 内外どちらからでも実行可能

## インストール

1. スクリプトを実行可能にする：

   ```bash
   chmod +x main.sh
   ```

2. エイリアスを設定（.zshrc の例）：
   ```bash
   alias tma='/path/to/tmux_attach_peco/main.sh'
   ```

## 必要な依存関係

- tmux
- peco
