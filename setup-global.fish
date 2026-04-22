#!/usr/bin/env fish
# Install or update all skills globally for Claude Code, Codex, and GitHub Copilot.
# Local skills are installed from this repo; external skills are fetched from GitHub.

set REPO_DIR (dirname (realpath (status --current-filename)))
set AGENTS claude-code codex github-copilot
set SCOPE user

# External skills: {repo} {skill-name}
set external_skills \
    "github/awesome-copilot" "git-commit"

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
echo "External skills: git-commit (github/awesome-copilot)"
echo "Agents:          $AGENTS"
echo "Scope:           $SCOPE"
echo ""

set errors 0

for agent in $AGENTS
    echo "=== $agent ==="

    # Local skills
    for skill in $local_skills
        printf "  %-24s ... " $skill
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
        printf "  %-24s ... " "$skill ($repo)"
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

    echo ""
end

if test $errors -gt 0
    echo "Completed with $errors error(s)." >&2
    exit 1
else
    echo "All skills installed successfully."
end
