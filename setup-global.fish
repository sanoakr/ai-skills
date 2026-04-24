#!/usr/bin/env fish
# Install or update all skills globally for Claude Code, Codex, and GitHub Copilot.
# Local skills are installed from this repo; external skills are fetched from GitHub.

set REPO_DIR (dirname (realpath (status --current-filename)))
set AGENTS claude-code codex github-copilot
set SCOPE user

# External skills: {repo} {skill-name}
set external_skills \
    "netresearch/git-workflow-skill"   "git-workflow" \
    "github/awesome-copilot"           "meeting-minutes" \
    "ph3on1x/claude-cmux-skill"        "skills/cmux" \
    "anthropics/skills"                "algorithmic-art" \
    "anthropics/skills"                "brand-guidelines" \
    "anthropics/skills"                "canvas-design" \
    "anthropics/skills"                "claude-api" \
    "anthropics/skills"                "doc-coauthoring" \
    "anthropics/skills"                "docx" \
    "anthropics/skills"                "frontend-design" \
    "anthropics/skills"                "internal-comms" \
    "anthropics/skills"                "mcp-builder" \
    "anthropics/skills"                "pdf" \
    "anthropics/skills"                "pptx" \
    "anthropics/skills"                "skill-creator" \
    "anthropics/skills"                "slack-gif-creator" \
    "anthropics/skills"                "theme-factory" \
    "anthropics/skills"                "web-artifacts-builder" \
    "anthropics/skills"                "webapp-testing" \
    "anthropics/skills"                "xlsx" \
    "microsoft/azure-skills"           "azure-deploy" \
    "microsoft/azure-skills"           "azure-cost" \
    "microsoft/azure-skills"           "azure-resource-lookup" \
    "microsoft/azure-skills"           "azure-rbac" \
    "microsoft/azure-skills"           "azure-ai" \
    "microsoft/azure-skills"           "microsoft-foundry" \
    "awslabs/agent-plugins"            "deploy" \
    "Imbad0202/academic-research-skills" "deep-research" \
    "Imbad0202/academic-research-skills" "academic-paper" \
    "Imbad0202/academic-research-skills" "academic-paper-reviewer" \
    "Imbad0202/academic-research-skills" "academic-pipeline"

# Repo-level installs: repos with SKILL.md at root (no skill-name argument)
set repo_installs

# Require gh CLI
if not command -q gh
    echo "Error: gh CLI not found. Install it from https://cli.github.com/" >&2
    exit 1
end

# Discover local skills (directories containing SKILL.md)
set local_skills
for dir in $REPO_DIR/*/
    if test -f $dir/SKILL.md
        set local_skills $local_skills (basename $dir)
    end
end

echo "Local skills:    $local_skills"
echo "External skills: git-workflow, meeting-minutes, cmux, anthropics/skills (17), azure-* (6), deploy, academic-* (4)"
echo "Repo installs:   (none)"
echo "Agents:          $AGENTS"
echo "Scope:           $SCOPE"
echo ""

set errors 0

for agent in $AGENTS
    echo "=== $agent ==="

    # Local skills
    for skill in $local_skills
        printf "  %-36s ... " $skill
        set output (gh skill install $REPO_DIR $skill --from-local --scope $SCOPE --agent $agent --force 2>&1)
        if test $status -eq 0
            echo "ok"
        else
            echo "FAILED"
            echo $output | string replace -ra "^" "      "
            set errors (math $errors + 1)
        end
    end

    # External skills (pairs: repo skill)
    set i 1
    while test $i -le (count $external_skills)
        set repo $external_skills[$i]
        set skill $external_skills[(math $i + 1)]
        printf "  %-36s ... " "$skill ($repo)"
        set output (gh skill install $repo $skill --scope $SCOPE --agent $agent --force 2>&1)
        if test $status -eq 0
            echo "ok"
        else
            echo "FAILED"
            echo $output | string replace -ra "^" "      "
            set errors (math $errors + 1)
        end
        set i (math $i + 2)
    end

    # Repo-level installs (no skill-name argument; installs all skills in the repo)
    for repo in $repo_installs
        printf "  %-36s ... " $repo
        set output (gh skill install $repo --scope $SCOPE --agent $agent --force 2>&1)
        if test $status -eq 0
            echo "ok"
        else
            echo "FAILED"
            echo $output | string replace -ra "^" "      "
            set errors (math $errors + 1)
        end
    end

    echo ""
end

if test $errors -gt 0
    echo "Completed with $errors error(s)." >&2
    exit 1
else
    echo "All skills installed successfully."
end
