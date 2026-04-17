# ai-skills

[日本語](./README.md) | English

A collection of reusable AI skills for Claude Code, Cursor, GitHub Copilot, Codex, and other AI tools.

## Skills

| Skill | Description |
|-------|-------------|
| [fish-shell](./fish-shell/SKILL.md) | fish shell syntax and command reference |
| [git-workflow](./git-workflow/SKILL.md) | Commit and branch management following Conventional Commits |
| [ja-proofreading](./ja-proofreading/SKILL.md) | Japanese text proofreading with textlint |
| [simple](./simple/SKILL.md) | Ultra-compressed Japanese communication mode |
| [gmail-persona](./gmail-persona/SKILL.md) | Build a persona knowledge base from Gmail history for Q&A and email drafting |

## Setup

Uses the `gh skill` command from [GitHub CLI](https://cli.github.com/).

### User scope (available in all projects)

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

### Project scope (current repository only)

```fish
gh skill install sanoakr/ai-skills --agent claude-code
```

### Install a specific skill only

```fish
gh skill install sanoakr/ai-skills fish-shell --agent claude-code --scope user
```

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
