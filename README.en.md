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

### External Skills — Anthropic Official

| Skill | Description |
|-------|-------------|
| [algorithmic-art](https://github.com/anthropics/skills/tree/main/skills/algorithmic-art) | Algorithmic and generative art creation |
| [brand-guidelines](https://github.com/anthropics/skills/tree/main/skills/brand-guidelines) | Brand guidelines development and maintenance |
| [canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design) | Canvas-based design work |
| [claude-api](https://github.com/anthropics/skills/tree/main/skills/claude-api) | Claude API integration and examples (multi-language) |
| [doc-coauthoring](https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring) | Document co-authoring and collaboration |
| [docx](https://github.com/anthropics/skills/tree/main/skills/docx) | Microsoft Word (.docx) document generation and manipulation |
| [frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) | Frontend and UI design |
| [internal-comms](https://github.com/anthropics/skills/tree/main/skills/internal-comms) | Internal communications and document automation |
| [mcp-builder](https://github.com/anthropics/skills/tree/main/skills/mcp-builder) | MCP server development and construction |
| [pdf](https://github.com/anthropics/skills/tree/main/skills/pdf) | PDF document generation and manipulation |
| [pptx](https://github.com/anthropics/skills/tree/main/skills/pptx) | PowerPoint (.pptx) presentation generation |
| [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | New skill creation and template tooling |
| [slack-gif-creator](https://github.com/anthropics/skills/tree/main/skills/slack-gif-creator) | GIF creation for Slack |
| [theme-factory](https://github.com/anthropics/skills/tree/main/skills/theme-factory) | Theme and design system generation |
| [web-artifacts-builder](https://github.com/anthropics/skills/tree/main/skills/web-artifacts-builder) | Web artifact construction |
| [webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) | Web application test automation |
| [xlsx](https://github.com/anthropics/skills/tree/main/skills/xlsx) | Excel (.xlsx) spreadsheet generation and manipulation |

### External Skills — General

| Skill | Repository | Description |
|-------|-----------|-------------|
| [git-workflow](https://github.com/netresearch/git-workflow-skill) | netresearch/git-workflow-skill | Comprehensive Git workflows: Git Flow, GitHub Flow, trunk-based, CI/CD integration |
| [meeting-minutes](https://github.com/github/awesome-copilot/tree/main/skills/meeting-minutes) | github/awesome-copilot | Meeting minutes for short internal meetings |
| [cmux](https://github.com/ph3on1x/claude-cmux-skill/tree/main/skills/cmux) | ph3on1x/claude-cmux-skill | Orchestrate multiple parallel Claude Code sessions within cmux |
| [latex-document-skill](https://github.com/ndpvt-web/latex-document-skill) | ndpvt-web/latex-document-skill | Generate publication-ready LaTeX PDFs from handwritten notes, scans, or raw data (27 templates, OCR support) |

### External Skills — Academic Research

| Skill | Repository | Description |
|-------|-----------|-------------|
| [deep-research](https://github.com/Imbad0202/academic-research-skills/tree/main/deep-research) | Imbad0202/academic-research-skills | 13-agent literature review, systematic review (PRISMA), and fact-checking |
| [academic-paper](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-paper) | Imbad0202/academic-research-skills | 12-agent paper writing pipeline (LaTeX/DOCX/PDF, bilingual abstract) |
| [academic-paper-reviewer](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-paper-reviewer) | Imbad0202/academic-research-skills | 7-agent peer review simulator (reviewers + editor-in-chief decision) |
| [academic-pipeline](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-pipeline) | Imbad0202/academic-research-skills | Full-pipeline orchestrator: research → write → integrity → review → revise → finalize |

### External Skills — Cloud

| Skill | Repository | Description |
|-------|-----------|-------------|
| [azure-deploy](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Deploy to Azure |
| [azure-cost](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure cost analysis |
| [azure-resource-lookup](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure resource lookup |
| [azure-rbac](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure user/role management |
| [azure-ai](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure AI Services |
| [microsoft-foundry](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure AI Foundry |
| [deploy](https://github.com/awslabs/agent-plugins) | awslabs/agent-plugins | Deploy to AWS |

### External Skills — Individual Install (not in setup)

> Too large to include in setup-global.fish. Install specific skills with `gh skill install {repo} {skill-name}`.

| Repository | Skills | Description |
|-----------|--------|-------------|
| [lyndonkl/claude](https://github.com/lyndonkl/claude) | 188 | Multi-domain collection: thinking, research, communication, data/ML, finance, sports analytics, and more |
| [VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | 1,100+ | Curated skill index from official teams (Microsoft, Google, Anthropic, Sentry, Trail of Bits) — registry format |

### External Skills — Pending (gh skill unsupported)

> These repositories use non-standard directory structures and cannot be installed via `gh skill` at this time. Issues have been filed.

| Repository | Description |
|-----------|-------------|
| [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | Scientific research skills (paper writing, literature search, bioinformatics, drug discovery, quantum computing, and 120+ more) |
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | AI research skills (model architecture, fine-tuning, distributed training, inference, safety, and 87 more) |

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
