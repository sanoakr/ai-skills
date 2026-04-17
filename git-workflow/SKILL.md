---
name: git-workflow
license: MIT
description: |
  Perform commits and branch management consistently following Conventional Commits.
  Activate when the user asks to commit, stage changes, prepare a PR, or manage branches.

  Trigger on:
  - "commit", "stage", "push", "create a branch", "prepare a PR"
  - "コミットして" "変更をまとめて" "PRを準備して" "ブランチを作って"
---

# Skill: Git Workflow

**Goal**: Consistent commits and branch management following Conventional Commits.

**Trigger**: "commit", "stage changes", "prepare PR", "create branch" — in any language.

---

## Steps

### Step 1: Assess current state

```fish
git status                    # changed files
git diff                      # unstaged changes
git diff --staged             # staged changes
git log --oneline -5          # recent commit history
```

### Step 2: Stage and commit in logical units

One commit = one purpose. Stage only related files:

```fish
git add src/auth/login.ts tests/auth/login.test.ts

# Conventional Commits format
git commit -m "feat(auth): improve error message on login failure"
```

### Step 3: Verify commit message format

```
✅ Good:
feat(user): add profile image upload
fix(api): handle empty search query (was returning 500)
docs(readme): update setup instructions

❌ Avoid:
fix: bug fix
update
WIP
```

Write commit messages in the language of the project. For Japanese projects, Japanese messages are fine:
```
feat(auth): ログイン失敗時のエラーメッセージを改善
```

### Step 4: Review before push

```fish
git log --oneline origin/main..HEAD   # unpushed commits
git diff origin/main...HEAD           # full diff to be pushed
```

---

## Branch Operations (fish)

```fish
# New feature branch
git checkout -b feature/42-add-search-filter

# Sync with remote
git fetch origin
git rebase origin/main   # or git merge origin/main

# Push and set upstream
git push -u origin (git branch --show-current)
```

---

## Post-commit Report

After committing, report:

```
✅ Committed
  Hash:    abc1234
  Message: feat(auth): implement JWT auto-refresh
  Changes: 3 files (+45/-12)

Next: git push to send to remote (confirm first)
```

---

## Safety Rules

- Never commit directly to `main`/`master` — ask to confirm first
- Always confirm before running `git reset --hard` or `git push --force`
- Warn and unstage if `.env` or `secrets.*` are staged
- Always run `git diff --staged` before committing to verify the content
