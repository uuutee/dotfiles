---
description: Start development
---

[arguments] の内容をもとに Phase を順番に実行して実装を行ってください

## Phase0

コマンドで受け取った [arguments] の内容をどう処理するかをユーザーに表示する

## Phase1: 実装計画

- [arguments] のリソースを参照して内容を確認し、実装計画を策定
- GitHub issue の URL, `#123` の形式の issue 番号, が [arguments] で渡された場合は、 `gh issue` コマンドで内容を確認
- リソースを元に適切な名前の branch を決定

## Phase2: 実装の開始

[arguments] に応じてセットアップを行い実装を開始

### オプションなし

Phase1 で決定した branch を作成

```sh
git switch -c {{branch}}
```

### worktree オプションあり

`--worktree` オプションが指定された場合は下記のセットアップを実行

worktree を追加

```sh
git worktree add .worktrees/{{branch}} -b {{branch}}
```

`.claude` ディレクトリをコピー

```sh
cp -a .claude .worktrees/{{branch}}
```

`.env` ファイルを worktree 内に copy

```sh
DEST=.worktrees/{{branch}

# 現在のディレクトリ直下（.）と 2 階層目までの .env を
# 相対パスそのままで DEST にコピー（BSD/macOS）
find . -maxdepth 2 -type f -name '.env' | while IFS= read -r f; do
  cp "$f" "$DEST/$f"
done
```

worktree に移動

```sh
cd .worktrees/{{branch}}
```

## Phase3: Code check

- プロジェクト内に `docs/code-check.md` が存在するかチェック
- 存在する場合は、その内容にしたがってコード品質チェック
- 存在しない場合は、何もしない

## Phase4: Create pull request

現在のブランチから Pull request を作成・更新する

- ステージング: `git add -A`
- コミット: `git commit`
- origin に push `git push`
- Pull request 作成: `gh pr edit`
- Pull request 更新: `gh pr edit`

title や description 日本語でわかりやすく書くこと
