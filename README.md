# ai-skills

日本語 | [English](./README.en.md)

Claude Code・Cursor・GitHub Copilot・Codex などの AI ツールで共通利用できる汎用スキル集。

## スキル一覧

| スキル | 説明 |
|--------|------|
| [fish-shell](./fish-shell/SKILL.md) | fish shell の文法・コマンド参照 |
| [git-workflow](./git-workflow/SKILL.md) | Conventional Commits に準拠したコミット手順 |
| [ja-proofreading](./ja-proofreading/SKILL.md) | textlint による日本語文章の自動校正 |
| [simple](./simple/SKILL.md) | 超圧縮コミュニケーションモード |
| [gmail-persona](./gmail-persona/SKILL.md) | Gmail 履歴からペルソナ知識ベースを構築し、Q&A・メール下書きに活用 |

## セットアップ

[GitHub CLI](https://cli.github.com/) の `gh skill` コマンドを使用する。

### ユーザースコープ（全プロジェクトで利用）

```fish
# Claude Code
gh skill install sanoakr/ai-skills --agent claude-code --scope user

# GitHub Copilot
gh skill install sanoakr/ai-skills --agent github-copilot --scope user

# Cursor
gh skill install sanoakr/ai-skills --agent cursor --scope user

# Codex
gh skill install sanoakr/ai-skills --agent codex --scope user
```

### プロジェクトスコープ（カレントリポジトリのみ）

```fish
gh skill install sanoakr/ai-skills --agent claude-code
```

### 特定スキルのみインストール

```fish
gh skill install sanoakr/ai-skills fish-shell --agent claude-code --scope user
```

## アップデート

```fish
gh skill update --all
```

## スキルの形式

```
ai-skills/
└── <スキル名>/
    ├── SKILL.md          # スキル定義（YAML frontmatter + Markdown）
    └── scripts/          # 補助スクリプト（オプション）
```

`SKILL.md` の frontmatter:

```yaml
---
name: スキル名
description: スキルの説明と発動条件
---
```

本文は Markdown で記述し、各ツールでそのまま利用される。

## スキルの追加・公開

1. `SKILL_TEMPLATE.md` を参考に `<スキル名>/SKILL.md` を作成する
2. コミット・プッシュする
3. 公開検証: `gh skill publish --dry-run`
4. 各ツールで `gh skill update --all` を実行して反映する
