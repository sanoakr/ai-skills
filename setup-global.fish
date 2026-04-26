#!/usr/bin/env fish
# Claude Code / Codex / GitHub Copilot スキル一括セットアップスクリプト
# 複数 PC 間で設定を共有するために GitHub リポジトリで管理する
#
# ローカルスキル: リポジトリ内の SKILL.md を含むディレクトリから自動検出
# 外部スキル:     skills.conf に記載されたリポジトリからインストール
#
# 使い方:
#   ./setup-global.fish              全スキルをインストール・更新
#   ./setup-global.fish add <s@r>    外部スキルを追加してコミット・プッシュ
#   ./setup-global.fish remove <s>   外部スキルを削除してコミット・プッシュ
#   ./setup-global.fish list         全スキル（ローカル＋外部）を日本語説明付きで表示
#   ./setup-global.fish sync         リモートから pull して全スキルを同期
#   ./setup-global.fish help         ヘルプを表示

set REPO_DIR (dirname (realpath (status --current-filename)))
set CONF "$REPO_DIR/skills.conf"
set DESC_FILE "$REPO_DIR/skills.desc"
set AGENTS claude-code codex github-copilot
set SCOPE user

# ---------- ヘルパー関数 ----------

function read_skills
    # skills.conf から有効行（コメント・空行を除く）を返す
    if not test -f $CONF
        echo "Error: $CONF not found" >&2
        return 1
    end
    grep -v '^\s*#' $CONF | grep -v '^\s*$' | string trim
end

function parse_skill --argument-names entry
    # skill-name@owner/repo → skill-name と owner/repo に分割
    # @ の最初の出現で分割（スキル名に / が含まれる場合も対応）
    if string match -q '*@*' -- $entry
        set -l skill_name (string replace -r '@.*' '' -- $entry)
        set -l repo (string replace -r '^[^@]*@' '' -- $entry)
        echo $skill_name
        echo $repo
    else
        echo "Error: invalid entry '$entry' (must be skill-name@owner/repo)" >&2
        return 1
    end
end

function display_name --argument-names skill_name
    # skills/cmux → cmux のように、最後のコンポーネントを表示名として返す
    string replace -r '.+/' '' -- $skill_name
end

function discover_local_skills
    # リポジトリ内の SKILL.md を含むディレクトリを検出
    for dir in $REPO_DIR/*/
        if test -f $dir/SKILL.md
            basename $dir
        end
    end
end

function get_description --argument-names skill_name
    # skills.desc から日本語説明を取得
    # skill_name に / が含まれる場合は display_name で検索
    set -l lookup (display_name $skill_name)
    if test -f $DESC_FILE
        set -l desc (grep "^$lookup=" $DESC_FILE | head -1 | sed "s/^$lookup=//")
        if test -n "$desc"
            echo $desc
            return
        end
    end
    echo ""
end

function install_local_skill --argument-names skill agent
    set -l output (gh skill install $REPO_DIR $skill --from-local --scope $SCOPE --agent $agent --force 2>&1)
    if test $status -eq 0
        echo "ok"
        return 0
    else
        echo "FAILED: $output"
        return 1
    end
end

function install_external_skill --argument-names repo skill agent
    set -l output (gh skill install $repo $skill --scope $SCOPE --agent $agent --force 2>&1)
    if test $status -eq 0
        echo "ok"
        return 0
    else
        echo "FAILED: $output"
        return 1
    end
end

function git_commit_and_push --argument-names msg
    git -C $REPO_DIR add skills.conf skills.desc 2>/dev/null
    if git -C $REPO_DIR diff --cached --quiet
        echo "  No changes to commit."
        return 0
    end
    git -C $REPO_DIR commit -m "$msg" 2>&1 | string replace -ra '^' '  '
    echo ""
    if git -C $REPO_DIR remote get-url origin &>/dev/null
        echo "  Pushing..."
        git -C $REPO_DIR push 2>&1 | string replace -ra '^' '  '
    else
        echo "  No remote configured, skipping push."
    end
end

# ---------- 前提チェック ----------

if not command -q gh
    echo "Error: gh CLI not found. Install it from https://cli.github.com/" >&2
    exit 1
end

# ---------- サブコマンド ----------

set subcmd $argv[1]

switch "$subcmd"

    case add
        if test (count $argv) -lt 2
            echo "Usage: $_ add <skill-name@owner/repo>" >&2
            exit 1
        end
        set entry $argv[2]

        # パース（@ 必須）
        if not string match -q '*@*' -- $entry
            echo "Error: external skills must be in skill-name@owner/repo format" >&2
            exit 1
        end
        set -l parsed (parse_skill $entry)
        set -l skill_name $parsed[1]
        set -l repo $parsed[2]

        # 重複チェック
        set -l existing (read_skills)
        for e in $existing
            set -l ename (parse_skill $e)[1]
            if test "$ename" = "$skill_name"
                echo "Skill '$skill_name' is already in skills.conf"
                exit 0
            end
        end

        # skills.conf に追記
        echo $entry >> $CONF
        echo "Added '$entry' to skills.conf"

        # 全エージェントにインストール
        set errors 0
        for agent in $AGENTS
            printf "  [%s] %-36s ... " $agent $skill_name
            install_external_skill $repo $skill_name $agent
            or set errors (math $errors + 1)
        end

        if test $errors -gt 0
            echo "Warning: $errors install(s) failed" >&2
        end

        # コミット・プッシュ
        echo ""
        git_commit_and_push "Add skill: "(display_name $skill_name)

    case remove
        if test (count $argv) -lt 2
            echo "Usage: $_ remove <skill-name>" >&2
            exit 1
        end
        set name $argv[2]

        # skills.conf から該当行を検索
        if not grep -q "^$name@\|^$name\$" $CONF 2>/dev/null
            # skills/ プレフィクス付きの場合も検索
            if not grep -q "^skills/$name@" $CONF 2>/dev/null
                echo "Skill '$name' not found in skills.conf" >&2
                exit 1
            end
            set name "skills/$name"
        end

        # skills.conf から削除
        sed -i '' "/^$name@/d" $CONF
        echo "Removed '$name' from skills.conf"

        # TODO: gh skill uninstall が利用可能になったらここでアンインストール
        echo "  Note: manual uninstall may be needed (gh skill uninstall is not yet available)"

        # コミット・プッシュ
        echo ""
        git_commit_and_push "Remove skill: "(display_name $name)

    case list
        set -l local_skills (discover_local_skills)
        set -l entries (read_skills)

        # ローカルスキル
        echo "Local skills (auto-discovered):"
        echo ""
        if test (count $local_skills) -eq 0
            echo "  (none)"
        else
            for skill in $local_skills
                set -l desc (get_description $skill)
                printf "  %-28s  %s\n" $skill "$desc"
            end
        end
        echo ""

        # 外部スキル
        echo "External skills (from skills.conf):"
        echo ""
        if test (count $entries) -eq 0
            echo "  (none)"
        else
            for entry in $entries
                set -l parsed (parse_skill $entry)
                set -l skill_name $parsed[1]
                set -l repo $parsed[2]
                set -l dname (display_name $skill_name)
                set -l desc (get_description $skill_name)
                printf "  %-28s  %-36s  %s\n" $dname "($repo)" "$desc"
            end
        end

    case sync
        echo "=== Pulling latest ==="
        if git -C $REPO_DIR remote get-url origin &>/dev/null
            git -C $REPO_DIR pull --ff-only 2>&1 | string replace -ra '^' '  '
        else
            echo "  No remote configured, skipping pull."
        end
        echo ""
        # sync 後はデフォルトのインストールにフォールスルー
        set subcmd ""

    case help -h --help
        echo "Usage: $_ [command]"
        echo ""
        echo "Commands:"
        echo "  (none)              Install/update all skills (local + external)"
        echo "  add <skill@repo>    Add external skill, install, commit & push"
        echo "  remove <skill>      Remove external skill, uninstall, commit & push"
        echo "  list                Show all skills (local + external) with Japanese descriptions"
        echo "  sync                Pull from remote and install all"
        echo "  help                Show help"
        echo ""
        echo "Skill format:"
        echo "  skill-name@owner/repo   External skill from GitHub"
        echo ""
        echo "Local skills (directories with SKILL.md) are auto-discovered."
        exit 0

    case ''
        # デフォルト: 全スキルインストール（下で処理）

    case '*'
        echo "Unknown command: $subcmd" >&2
        echo "Run '$_ help' for usage." >&2
        exit 1
end

# ---------- 全スキルインストール（デフォルト / sync 後） ----------

if test "$subcmd" = "" -o "$subcmd" = "sync"
    set -l local_skills (discover_local_skills)
    set -l entries (read_skills)

    echo "Agents:          $AGENTS"
    echo "Scope:           $SCOPE"
    echo "Local skills:    $local_skills"
    echo "External skills: "(count $entries)" entries from skills.conf"
    echo ""

    set errors 0

    for agent in $AGENTS
        echo "=== $agent ==="

        # ローカルスキル
        for skill in $local_skills
            printf "  %-36s ... " $skill
            install_local_skill $skill $agent
            or set errors (math $errors + 1)
        end

        # 外部スキル
        for entry in $entries
            set -l parsed (parse_skill $entry)
            set -l skill_name $parsed[1]
            set -l repo $parsed[2]
            printf "  %-36s ... " (display_name $skill_name)" ($repo)"
            install_external_skill $repo $skill_name $agent
            or set errors (math $errors + 1)
        end

        echo ""
    end

    # 結果
    if test $errors -gt 0
        echo "Completed with $errors error(s)." >&2
        exit 1
    else
        echo "All skills installed successfully."
    end
end
