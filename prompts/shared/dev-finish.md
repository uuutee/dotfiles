---
description: Finish development
---

現在の開発サイクルを終了するので、後始末をしてください

## Step1:

- 今回の session で、ユーザから受けた指摘事項を列挙して。指摘事項がなければ Step2 へ
- 列挙した指摘事項を予防するには、どういった指示があらかじめ必要だったかをユーザに報告して

## Step2:

- [arguments] に `--worktree` オプションが指定されている場合
  - project_root に移動
  - worktree を削除
- BASE_BRANCH に切り替え
- BASE_BRANCH を update
- 今回の session で使用したローカルブランチがマージ済みであれば削除 (リモートブランチは GitHub 側の設定により削除されるので何もしない)

## Context

List worktree

```sh
git worktree list --porcelain
```

Remove worktree

```sh
git worktree remove {{branch}}
```

Confirm BASE_BRANCH

```sh
# masterブランチが存在するかチェックして適切なベースブランチを決定
git rev-parse --verify master >/dev/null 2>&1 && BASE_BRANCH=master || BASE_BRANCH=main
```

Update BASE_BRANCH

```sh
git remote update && git checkout $BASE_BRANCH && git rebase origin/$BASE_BRANCH
```
