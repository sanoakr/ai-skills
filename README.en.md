# ai-skills

[日本語](./README.md) | English

A collection of reusable AI skills for Claude Code, Cursor, GitHub Copilot, Codex, and other AI tools.

## Skills

### This Repository

| Skill | Description |
|-------|-------------|
| [ja-proofreading](./ja-proofreading/SKILL.md) | Japanese text proofreading with textlint |
| [simple](./simple/SKILL.md) | Compressed Japanese output mode |
| [gmail-persona](./gmail-persona/SKILL.md) | Build a persona knowledge base from Gmail history for Q&A and email drafting |

### External Skills — General

| Skill | Repository | Description |
|-------|-----------|-------------|
| [bytesagain1/fish](https://github.com/openclaw/skills/tree/main/skills/bytesagain1/fish) | openclaw/skills | fish shell syntax and command reference |
| [git-commit](https://github.com/github/awesome-copilot/tree/main/skills/git-commit) | github/awesome-copilot | Commit and branch management following Conventional Commits |
| [meeting-minutes](https://github.com/github/awesome-copilot/tree/main/skills/meeting-minutes) | github/awesome-copilot | Meeting minutes for short internal meetings |

### External Skills — Azure

| Skill | Description |
|-------|-------------|
| [azure-deploy](https://github.com/microsoft/azure-skills) | Deploy to Azure |
| [azure-cost](https://github.com/microsoft/azure-skills) | Azure cost analysis |
| [azure-resource-lookup](https://github.com/microsoft/azure-skills) | Azure resource lookup |
| [azure-rbac](https://github.com/microsoft/azure-skills) | Azure user/role management |
| [azure-ai](https://github.com/microsoft/azure-skills) | Azure AI Services |
| [microsoft-foundry](https://github.com/microsoft/azure-skills) | Azure AI Foundry |

### External Skills — AWS

| Skill | Description |
|-------|-------------|
| [deploy](https://github.com/awslabs/agent-plugins) | Deploy to AWS |

### External Skills — Pending (gh skill unsupported)

> These repositories use non-standard directory structures and cannot be installed via `gh skill` at this time. Issues have been filed.

| Repository | Description |
|-----------|-------------|
| [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | Scientific research skills (paper writing, literature search, bioinformatics, drug discovery, quantum computing, and 120+ more) |

## Setup

Requires [GitHub CLI](https://cli.github.com/).

```fish
git clone https://github.com/sanoakr/ai-skills.git
cd ai-skills
./setup-global.fish
```

Installs all skills globally for Claude Code, Codex, and GitHub Copilot.

## Update

```fish
gh skill update --all
```

## Skill Format

```
ai-skills/
└── <skill-name>/
    ├── SKILL.md          # Skill definition (YAML frontmatter + Markdown)
    └── scripts/          # Helper scripts (optional)
```

`SKILL.md` frontmatter:

```yaml
---
name: skill-name
description: Description and activation conditions (include trigger phrases in all target languages)
license: MIT
---
```

The body is plain Markdown and is consumed as-is by each AI tool.

## Adding a Skill

1. Use `SKILL_TEMPLATE.md` as a starting point; create `<skill-name>/SKILL.md`
2. Commit and push
3. Dry-run publish: `gh skill publish --dry-run`
4. Update in each tool: `gh skill update --all`
