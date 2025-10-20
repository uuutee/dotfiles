---
description: All development
---

Phase1-3 の実装から Pull request の作成までを行ってください。

## Phase1: Start development

- [arguments] のリソースを参照して実装を行ってください
- GitHub issue の URL, `#123` の形式の issue 番号, が [arguments] で渡された場合は、 `gh issue` コマンドで内容を確認してください
- リソースを元に適切な名前の branch を作成してから実装を開始してください

## Phase2: Code check

- プロジェクト内に `docs/code-check.md` が存在するかチェック
- 存在する場合は、その内容にしたがってコード品質チェック
- 存在しない場合は、何もしない

## Phase3: Create or update pull request

現在のブランチから Pull request を作成・更新する

- ステージング: `git add -A`
- コミット: `git commit`
- origin に push `git push`
- Pull request 作成: `gh pr edit`
- Pull request 更新: `gh pr edit`

title や description 日本語でわかりやすく書くこと

## Context

- Create branch: !`git switch -c`
- View issue: !`gh issue view <issue_number>`
- Pull request status: `gh pr status`
