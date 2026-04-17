---
name: fish-shell
license: MIT
description: |
  Use fish shell syntax and commands correctly, avoiding bash/zsh confusion.
  Activate for command execution, script writing, or shell configuration in a fish environment.

  Trigger on:
  - Running or writing commands/scripts in fish
  - Editing .fish scripts or config.fish
  - Questions about fish vs bash/zsh syntax differences
  - "fish で" "fish shell" "fish スクリプト" "fish の書き方"
---

# Skill: fish shell

**Goal**: Use fish shell syntax correctly; avoid bash/zsh idioms.

**Trigger**: Command execution, script creation, or shell config changes in a fish environment.

---

## Key Differences from bash/zsh

### Variables

```fish
# fish — no $ on assignment, use set
set my_var "hello"
echo $my_var

# Scopes
set -l local_var "local"      # local (function scope)
set -g global_var "global"    # global (session)
set -gx export_var "export"   # exported (environment variable)

# ❌ bash syntax (does not work in fish)
export MY_VAR="hello"         # → set -gx MY_VAR "hello"
MY_VAR="hello"                # → set MY_VAR "hello"
```

### Conditionals

```fish
if test $status -eq 0
    echo "success"
else if test $status -eq 1
    echo "error 1"
else
    echo "other"
end

# File exists
if test -f "file.txt"
    echo "file found"
end

# Command exists
if command -v node > /dev/null
    echo "node is installed"
end
```

### Loops

```fish
# for loop
for file in *.fish
    echo $file
end

# while loop
while test $count -lt 10
    set count (math $count + 1)
end

# Command substitution — parentheses, not backticks
set files (ls *.md)
set count (math 1 + 2)
```

### Functions

```fish
function greet --description "greet a user"
    set name $argv[1]
    echo "Hello, $name"
end

# Persist to ~/.config/fish/functions/
funcsave greet
```

### Pipes and Redirects

```fish
# Pipes — same as bash
ls | grep ".md"

# Redirects — same as bash
echo "hello" > file.txt
echo "world" >> file.txt

# Stderr
command 2>/dev/null
command 2>&1 | grep "error"
```

### Aliases (prefer abbr)

```fish
# abbr — expands on input; appears in history as the full command
abbr --add gs 'git status'

# alias — defined as a function
alias ll 'ls -la'
```

---

## Common fish Commands

```fish
source ~/.config/fish/config.fish   # reload config
functions                           # list all functions
set -gx                             # list exported variables
fish_add_path /usr/local/bin        # add to PATH
history                             # command history
fish_config                         # open config GUI
```

---

## Script Authoring Notes

```fish
#!/usr/bin/env fish
# shebang must specify fish explicitly

# set -e does NOT work in fish
# fish continues on errors by default — check $status explicitly
set result (some_command)
if test $status -ne 0
    echo "error occurred"
    exit 1
end
```

---

## Common Pitfalls

- Do not mix bash/zsh syntax into fish scripts
- `$(command)` → `(command)`
- `&&` / `||` → `and` / `or` (or combine `;` with `if`)
- Arrays are **1-indexed** (not 0-indexed)
