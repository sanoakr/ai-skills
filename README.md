# ai-skills

日本語 | [English](./README.en.md)

Claude Code・Cursor・GitHub Copilot・Codex などの AI ツールで共通利用できる汎用スキル集。

## スキル一覧

### このリポジトリのスキル

| スキル | 説明 |
|--------|------|
| [ja-proofreading](./ja-proofreading/SKILL.md) | textlint による日本語文章の自動校正 |
| [simple](./simple/SKILL.md) | 日本語圧縮出力モード |
| [gmail-persona](./gmail-persona/SKILL.md) | Gmail 履歴からペルソナ知識ベースを構築し、Q&A・メール下書きに活用 |

### 外部スキル — 汎用

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [bytesagain1/fish](https://github.com/openclaw/skills/tree/main/skills/bytesagain1/fish) | openclaw/skills | fish shell の文法・コマンド参照 |
| [git-commit](https://github.com/github/awesome-copilot/tree/main/skills/git-commit) | github/awesome-copilot | Conventional Commits に準拠したコミット手順 |
| [meeting-minutes](https://github.com/github/awesome-copilot/tree/main/skills/meeting-minutes) | github/awesome-copilot | 社内短時間ミーティングの議事録作成 |

### 外部スキル — Azure

| スキル | 説明 |
|--------|------|
| [azure-deploy](https://github.com/microsoft/azure-skills) | Azure へのデプロイ |
| [azure-cost](https://github.com/microsoft/azure-skills) | Azure コスト確認 |
| [azure-resource-lookup](https://github.com/microsoft/azure-skills) | Azure リソース確認 |
| [azure-rbac](https://github.com/microsoft/azure-skills) | Azure ユーザー/ロール管理 |
| [azure-ai](https://github.com/microsoft/azure-skills) | Azure AI Services |
| [microsoft-foundry](https://github.com/microsoft/azure-skills) | Azure AI Foundry |

### 外部スキル — AWS

| スキル | 説明 |
|--------|------|
| [deploy](https://github.com/awslabs/agent-plugins) | AWS へのデプロイ |

### 外部スキル — 対応待ち（gh skill 非対応）

> これらのリポジトリは `gh skill` の非標準ディレクトリ構造のため、現時点ではインストール不可。対応 Issue 提出済み。

| リポジトリ | 説明 |
|-----------|------|
| [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | 科学研究向けスキル集（論文執筆・文献検索・バイオインフォ・創薬・量子計算など 120+ スキル） |

## セットアップ

[GitHub CLI](https://cli.github.com/) が必要。

```fish
git clone https://github.com/sanoakr/ai-skills.git
cd ai-skills
./setup-global.fish
```

Claude Code・Codex・GitHub Copilot にグローバルスコープで全スキルをインストールする。

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
