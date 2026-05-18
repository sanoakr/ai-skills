# ai-skills

[日本語](./README.md) | English

A collection of reusable AI skills for Claude Code, Cursor, GitHub Copilot, Codex, and other AI tools.
Share skill configurations across multiple PCs via `skills.conf`.

## Setup

Requires [GitHub CLI](https://cli.github.com/).

```fish
git clone https://github.com/sanoakr/ai-skills.git
cd ai-skills
./setup.fish
```

Installs all skills globally for Claude Code, Codex, and GitHub Copilot.

## Usage

```fish
# Show available subcommands
./setup.fish

# Install/update all skills
./setup.fish install

# Update installed skills + refresh pending skill descriptions (commit & push)
./setup.fish fetch-pending

# List all skills with install status and descriptions
./setup.fish list

# List sub-skills of pending repos with Japanese descriptions (offline)
./setup.fish pending-list

# Add an external skill (install → commit → push)
./setup.fish add <skill-name>@<owner/repo>

# Remove an external skill (commit → push)
./setup.fish remove <skill-name>

# Pull from remote and sync all skills (for initial setup on another PC)
./setup.fish sync
```

## Skills

### Local Skills (auto-discovered)

Directories containing `SKILL.md` are automatically detected. No entry in `skills.conf` needed.

| Skill | Description |
|-------|-------------|
| [ja-proofreading](./ja-proofreading/SKILL.md) | Japanese text proofreading with textlint |
| [simple](./simple/SKILL.md) | Compressed Japanese output mode |
| [gmail-persona](./gmail-persona/SKILL.md) | Build a persona knowledge base from Gmail history for Q&A and email drafting |
| [md-to-pdf](./md-to-pdf/SKILL.md) | Convert Markdown to PDF/HTML/LaTeX via pandoc, xelatex, and wkhtmltopdf (Japanese support) |

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

> Tracked in `skills.conf` with a `?` prefix. Too large to include in `setup.fish`.  
> Install specific skills with `gh skill install {repo} {skill-name}`.  
> Check install status with `./setup.fish list`.

| Skill | Repository | Description |
|-------|-----------|-------------|
| [alignment-values-north-star](https://github.com/lyndonkl/claude/tree/main/skills/alignment-values-north-star) | lyndonkl/claude | Define shared North Star, values, and principles for team alignment and decision-making |
| [brainstorm-diverge-converge](https://github.com/lyndonkl/claude/tree/main/skills/brainstorm-diverge-converge) | lyndonkl/claude | Structured diverge-then-converge brainstorming facilitation |
| [causal-inference-root-cause](https://github.com/lyndonkl/claude/tree/main/skills/causal-inference-root-cause) | lyndonkl/claude | Distinguish correlation from causation, identify root causes, control confounders |
| [decision-matrix](https://github.com/lyndonkl/claude/tree/main/skills/decision-matrix) | lyndonkl/claude | Systematic multi-criteria decision evaluation with weighted scoring |
| [environmental-scanning-foresight](https://github.com/lyndonkl/claude/tree/main/skills/environmental-scanning-foresight) | lyndonkl/claude | PESTLE analysis, weak signal detection, and scenario planning for strategic foresight |
| [forecast-premortem](https://github.com/lyndonkl/claude/tree/main/skills/forecast-premortem) | lyndonkl/claude | Pre-mortem stress-testing of high-confidence predictions to surface tail risks |
| [kill-criteria-exit-ramps](https://github.com/lyndonkl/claude/tree/main/skills/kill-criteria-exit-ramps) | lyndonkl/claude | Define project kill criteria and pre-committed exit triggers |
| [metrics-tree](https://github.com/lyndonkl/claude/tree/main/skills/metrics-tree) | lyndonkl/claude | Decompose North Star metrics into KPI hierarchies and leading indicators |
| [negotiation-alignment-governance](https://github.com/lyndonkl/claude/tree/main/skills/negotiation-alignment-governance) | lyndonkl/claude | Structured support for negotiation, consensus-building, and governance design |
| [portfolio-roadmapping-bets](https://github.com/lyndonkl/claude/tree/main/skills/portfolio-roadmapping-bets) | lyndonkl/claude | Portfolio-level roadmap creation and bet prioritization |
| [project-risk-register](https://github.com/lyndonkl/claude/tree/main/skills/project-risk-register) | lyndonkl/claude | Risk register with probability×impact matrix and mitigation plans |
| [roadmap-backcast](https://github.com/lyndonkl/claude/tree/main/skills/roadmap-backcast) | lyndonkl/claude | Backcast from target date to define milestones and critical path |
| [strategy-and-competitive-analysis](https://github.com/lyndonkl/claude/tree/main/skills/strategy-and-competitive-analysis) | lyndonkl/claude | Market entry, competitive analysis, Porter 5 Forces, SWOT, Blue Ocean Strategy |
| [awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | VoltAgent/awesome-agent-skills | Curated skill index from official teams (Microsoft, Google, Anthropic) — 1,100+ skills |

### External Skills — Pending (gh skill unsupported)

> Tracked in `skills.conf` with a `~` prefix. Non-standard directory structures prevent `gh skill install` at this time.  
> Check install status with `./setup.fish list`.

| Repository | Description |
|-----------|-------------|
| [K-Dense-AI/scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | Scientific research skills (paper writing, literature search, bioinformatics, drug discovery, quantum computing, 135+ skills) |
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | AI research skills (model architecture, fine-tuning, distributed training, inference, safety, 87 skills) |
| [ndpvt-web/latex-document-skill](https://github.com/ndpvt-web/latex-document-skill) | Generate publication-ready LaTeX PDFs from handwritten notes, scans, or raw data (27 templates, OCR support) |

## File Structure

```
ai-skills/
├── setup.fish    # Setup script
├── skills.conf          # External skills list (edit to share)
├── skills.desc          # Japanese descriptions
├── pending-descs/       # Japanese description TSVs for pending repos (generated by update)
├── SKILL_TEMPLATE.md    # Template for new skills
├── <skill-name>/
│   ├── SKILL.md         # Skill definition (YAML frontmatter + Markdown)
│   └── scripts/         # Helper scripts (optional)
└── README.md
```

## Adding Skills

### Adding external skills

```fish
./setup.fish add new-skill@owner/repo
```

### Adding local skills

1. Use `SKILL_TEMPLATE.md` as a starting point; create `<skill-name>/SKILL.md`
2. Commit and push
3. Dry-run publish: `gh skill publish --dry-run`
4. Update in each tool: `gh skill update --all`

## Related Repositories

- [sanoakr/claude-plugins](https://github.com/sanoakr/claude-plugins) — Claude Code plugin & MCP management
