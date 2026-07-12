#!/usr/bin/env bash
# Claude Code スキル一括セットアップスクリプト
# 複数 PC 間で設定を共有するために GitHub リポジトリで管理する
#
# ローカルスキル: リポジトリ内の SKILL.md を含むディレクトリから自動検出
# 外部スキル:     skills.conf に記載されたリポジトリからインストール
#
# 使い方:
#   ./setup.sh              サブコマンド一覧を表示
#   ./setup.sh install      全スキルをインストール・更新
#   ./setup.sh add <s@r>    外部スキルを追加してコミット・プッシュ
#   ./setup.sh remove <s>   外部スキルを削除してコミット・プッシュ
#   ./setup.sh list         全スキル（ローカル＋外部）を日本語説明付きで表示
#   ./setup.sh sync         リモートから pull して全スキルを同期
#   ./setup.sh help         ヘルプを表示

REPO_DIR="$(dirname "$(realpath "$0")")"
SCRIPT="$(basename "$0")"
CONF="$REPO_DIR/skills.conf"
DESC_FILE="$REPO_DIR/skills.desc"
AGENTS="claude-code"
SCOPE=user

# ---------- ヘルパー関数 ----------

read_skills() {
    if [[ ! -f "$CONF" ]]; then
        echo "Error: $CONF not found" >&2
        return 1
    fi
    grep -v '^\s*#' "$CONF" | grep -v '^\s*$' | grep -v '^\s*[?~]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

read_skills_optional() {
    if [[ ! -f "$CONF" ]]; then return 1; fi
    grep -v '^\s*#' "$CONF" | grep -v '^\s*$' | grep '^\s*?' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^?//'
}

read_skills_pending() {
    if [[ ! -f "$CONF" ]]; then return 1; fi
    grep -v '^\s*#' "$CONF" | grep -v '^\s*$' | grep '^\s*~' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/^~//'
}

is_installed() {
    local skill_name="$1"
    local dname
    dname="$(display_name "$skill_name")"
    local base="$HOME/.claude/skills"
    if [[ -d "$base/$dname" ]]; then
        return 0
    fi
    local found
    found="$(find "$base" -maxdepth 3 -name SKILL.md -path "*/$dname/SKILL.md" 2>/dev/null | head -1)"
    if [[ -n "$found" ]]; then
        return 0
    fi
    return 1
}

status_mark() {
    if is_installed "$1"; then echo "[+]"; else echo "[-]"; fi
}

parse_skill() {
    # skill-name@owner/repo → 1行目: skill-name、2行目: owner/repo
    local entry="$1"
    if [[ "$entry" == *@* ]]; then
        echo "${entry%%@*}"
        echo "${entry#*@}"
    else
        echo "Error: invalid entry '$entry' (must be skill-name@owner/repo)" >&2
        return 1
    fi
}

display_name() {
    echo "${1##*/}"
}

discover_local_skills() {
    for dir in "$REPO_DIR"/*/; do
        if [[ -f "$dir/SKILL.md" ]]; then
            basename "$dir"
        fi
    done
}

get_description() {
    local lookup
    lookup="$(display_name "$1")"
    if [[ -f "$DESC_FILE" ]]; then
        local desc
        desc="$(grep "^${lookup}=" "$DESC_FILE" | head -1 | sed "s/^${lookup}=//")"
        if [[ -n "$desc" ]]; then
            echo "$desc"
            return
        fi
    fi
    echo ""
}

install_local_skill() {
    local skill="$1" agent="$2"
    local output
    output="$(gh skill install "$REPO_DIR" "$skill" --from-local --scope "$SCOPE" --agent "$agent" --force 2>&1)"
    if [[ $? -eq 0 ]]; then echo "ok"; return 0
    else echo "FAILED: $output"; return 1; fi
}

install_external_skill() {
    local repo="$1" skill="$2" agent="$3"
    local output
    output="$(gh skill install "$repo" "$skill" --scope "$SCOPE" --agent "$agent" --force 2>&1)"
    if [[ $? -eq 0 ]]; then echo "ok"; return 0
    else echo "FAILED: $output"; return 1; fi
}

git_commit_and_push() {
    local msg="$1"
    git -C "$REPO_DIR" add skills.conf skills.desc pending-descs/ 2>/dev/null
    if git -C "$REPO_DIR" diff --cached --quiet; then
        echo "  No changes to commit."
        return 0
    fi
    git -C "$REPO_DIR" commit -m "$msg" 2>&1 | sed 's/^/  /'
    echo ""
    if git -C "$REPO_DIR" remote get-url origin &>/dev/null; then
        echo "  Pushing..."
        git -C "$REPO_DIR" push 2>&1 | sed 's/^/  /'
    else
        echo "  No remote configured, skipping push."
    fi
}

do_install() {
    local skill_name repo entry skill agent errors=0

    local local_skills=()
    while IFS= read -r s; do local_skills+=("$s"); done < <(discover_local_skills)

    local entries=()
    while IFS= read -r e; do entries+=("$e"); done < <(read_skills)

    echo "Agents:          $AGENTS"
    echo "Scope:           $SCOPE"
    echo "Local skills:    ${local_skills[*]}"
    echo "External skills: ${#entries[@]} entries from skills.conf"
    echo ""

    for agent in $AGENTS; do
        echo "=== $agent ==="

        for skill in "${local_skills[@]}"; do
            printf "  %-36s ... " "$skill"
            install_local_skill "$skill" "$agent" || ((errors++))
        done

        for entry in "${entries[@]}"; do
            skill_name="$(parse_skill "$entry" | head -1)"
            repo="$(parse_skill "$entry" | tail -1)"
            printf "  %-36s ... " "$(display_name "$skill_name") ($repo)"
            install_external_skill "$repo" "$skill_name" "$agent" || ((errors++))
        done

        echo ""
    done

    if [[ $errors -gt 0 ]]; then
        echo "Completed with $errors error(s)." >&2
        exit 1
    else
        echo "All skills installed successfully."
    fi
}

# ---------- 前提チェック ----------

if ! command -v gh &>/dev/null; then
    echo "Error: gh CLI not found. Install it from https://cli.github.com/" >&2
    exit 1
fi

# ---------- サブコマンド ----------

subcmd="${1:-}"

case "$subcmd" in

    add)
        if [[ $# -lt 2 ]]; then
            echo "Usage: $SCRIPT add <skill-name@owner/repo>" >&2
            exit 1
        fi
        entry="$2"

        if [[ "$entry" != *@* ]]; then
            echo "Error: external skills must be in skill-name@owner/repo format" >&2
            exit 1
        fi
        skill_name="$(parse_skill "$entry" | head -1)"
        repo="$(parse_skill "$entry" | tail -1)"

        while IFS= read -r e; do
            ename="$(parse_skill "$e" | head -1)"
            if [[ "$ename" == "$skill_name" ]]; then
                echo "Skill '$skill_name' is already in skills.conf"
                exit 0
            fi
        done < <(read_skills)

        echo "$entry" >> "$CONF"
        echo "Added '$entry' to skills.conf"

        errors=0
        for agent in $AGENTS; do
            printf "  [%s] %-36s ... " "$agent" "$skill_name"
            install_external_skill "$repo" "$skill_name" "$agent" || ((errors++))
        done

        if [[ $errors -gt 0 ]]; then
            echo "Warning: $errors install(s) failed" >&2
        fi

        echo ""
        git_commit_and_push "Add skill: $(display_name "$skill_name")"
        ;;

    remove)
        if [[ $# -lt 2 ]]; then
            echo "Usage: $SCRIPT remove <skill-name>" >&2
            exit 1
        fi
        name="$2"

        if ! grep -q "^${name}@\|^${name}$" "$CONF" 2>/dev/null; then
            if ! grep -q "^skills/${name}@" "$CONF" 2>/dev/null; then
                echo "Skill '$name' not found in skills.conf" >&2
                exit 1
            fi
            name="skills/$name"
        fi

        sed -i '' "/^${name}@/d" "$CONF"
        echo "Removed '$name' from skills.conf"
        echo "  Note: manual uninstall may be needed (gh skill uninstall is not yet available)"

        echo ""
        git_commit_and_push "Remove skill: $(display_name "$name")"
        ;;

    list)
        local_skills=()
        while IFS= read -r s; do local_skills+=("$s"); done < <(discover_local_skills)
        entries=()
        while IFS= read -r e; do entries+=("$e"); done < <(read_skills)
        optional_entries=()
        while IFS= read -r e; do optional_entries+=("$e"); done < <(read_skills_optional)
        pending_entries=()
        while IFS= read -r e; do pending_entries+=("$e"); done < <(read_skills_pending)

        echo "Status: [+] installed  [-] not installed"
        echo ""

        echo "Local skills (auto-discovered):"
        echo ""
        if [[ ${#local_skills[@]} -eq 0 ]]; then
            echo "  (none)"
        else
            for skill in "${local_skills[@]}"; do
                mark="$(status_mark "$skill")"
                desc="$(get_description "$skill")"
                printf "  %s  %-26s  %s\n" "$mark" "$skill" "$desc"
            done
        fi
        echo ""

        echo "External skills (from skills.conf):"
        echo ""
        if [[ ${#entries[@]} -eq 0 ]]; then
            echo "  (none)"
        else
            for entry in "${entries[@]}"; do
                skill_name="$(parse_skill "$entry" | head -1)"
                repo="$(parse_skill "$entry" | tail -1)"
                dname="$(display_name "$skill_name")"
                mark="$(status_mark "$skill_name")"
                desc="$(get_description "$skill_name")"
                printf "  %s  %-26s  %-34s  %s\n" "$mark" "$dname" "($repo)" "$desc"
            done
        fi
        echo ""

        echo "Optional skills (individual install only):"
        echo ""
        if [[ ${#optional_entries[@]} -eq 0 ]]; then
            echo "  (none)"
        else
            for entry in "${optional_entries[@]}"; do
                skill_name="$(parse_skill "$entry" | head -1)"
                repo="$(parse_skill "$entry" | tail -1)"
                dname="$(display_name "$skill_name")"
                mark="$(status_mark "$skill_name")"
                desc="$(get_description "$skill_name")"
                printf "  %s  %-26s  %-34s  %s\n" "$mark" "$dname" "($repo)" "$desc"
            done
        fi
        echo ""

        echo "Pending skills (gh skill not yet supported):"
        echo ""
        if [[ ${#pending_entries[@]} -eq 0 ]]; then
            echo "  (none)"
        else
            for entry in "${pending_entries[@]}"; do
                skill_name="$(parse_skill "$entry" | head -1)"
                repo="$(parse_skill "$entry" | tail -1)"
                dname="$(display_name "$skill_name")"
                mark="$(status_mark "$skill_name")"
                desc="$(get_description "$skill_name")"
                printf "  %s  %-26s  %-34s  %s\n" "$mark" "$dname" "($repo)" "$desc"
            done
        fi
        ;;

    sync)
        echo "=== Pulling latest ==="
        if git -C "$REPO_DIR" remote get-url origin &>/dev/null; then
            git -C "$REPO_DIR" pull --ff-only 2>&1 | sed 's/^/  /'
        else
            echo "  No remote configured, skipping pull."
        fi
        echo ""
        do_install
        ;;

    update)
        echo "=== Updating installed skills ==="
        echo ""
        # dry-run でアップデート対象スキル名を抽出し、名前指定で実行（メタデータなしスキルへの対話プロンプトを回避）
        targets=$(gh skill update --dry-run --all 2>/dev/null | grep '^\s*•' | sed 's/.*• \([^ ]*\) .*/\1/' | sort -u | tr '\n' ' ' | sed 's/ $//')
        if [[ -z "$targets" ]]; then
            echo "All skills are up to date."
        else
            echo "Updates available: $targets"
            echo ""
            gh skill update --all $targets
        fi
        ;;

    install|"")
        do_install
        ;;

    pending-list)
        pending_entries=()
        while IFS= read -r e; do pending_entries+=("$e"); done < <(read_skills_pending)

        if [[ ${#pending_entries[@]} -eq 0 ]]; then
            echo "No pending skills."
            exit 0
        fi
        desc_dir="$REPO_DIR/pending-descs"

        for entry in "${pending_entries[@]}"; do
            skill_name="$(parse_skill "$entry" | head -1)"
            repo="$(parse_skill "$entry" | tail -1)"
            repo_name="${repo##*/}"
            repo_owner="${repo%%/*}"
            desc="$(get_description "$skill_name")"
            tsv_file="$desc_dir/$repo_owner-$repo_name.tsv"
            echo "=== $repo  —  $desc ==="
            echo ""

            if [[ ! -f "$tsv_file" ]]; then
                echo "  (no description file — run '$SCRIPT fetch-pending' to fetch)" >&2
                echo ""
                continue
            fi

            tree_file="$(mktemp /tmp/ai-skills-tree.XXXXXX)"
            gh api "repos/$repo/git/trees/HEAD?recursive=1" > "$tree_file" 2>/dev/null
            python3 "$REPO_DIR/print_pending_list.py" "$repo_name" "$tree_file" "$tsv_file"
            rm -f "$tree_file"
            echo ""
        done
        ;;

    fetch-pending)
        echo "=== Updating pending skill descriptions ==="
        echo ""
        pending_entries=()
        while IFS= read -r e; do pending_entries+=("$e"); done < <(read_skills_pending)

        desc_dir="$REPO_DIR/pending-descs"
        mkdir -p "$desc_dir"
        updated_files=()

        for entry in "${pending_entries[@]}"; do
            skill_name="$(parse_skill "$entry" | head -1)"
            repo="$(parse_skill "$entry" | tail -1)"
            repo_name="${repo##*/}"
            repo_owner="${repo%%/*}"
            tsv_file="$desc_dir/$repo_owner-$repo_name.tsv"
            printf "  %-44s ... " "$repo"

            tree_file="$(mktemp /tmp/ai-skills-tree.XXXXXX)"
            gh api "repos/$repo/git/trees/HEAD?recursive=1" > "$tree_file" 2>/dev/null
            if [[ $? -ne 0 ]]; then
                echo "FAILED (tree fetch)"
                rm -f "$tree_file"
                continue
            fi

            python3 "$REPO_DIR/fetch_skill_descs.py" "$repo_owner" "$repo_name" "$tree_file" > /tmp/ai-skills-raw.tsv 2>/dev/null
            rm -f "$tree_file"

            if [[ $(wc -l < /tmp/ai-skills-raw.tsv | tr -d ' ') -eq 0 ]]; then
                echo "FAILED (graphql)"
                rm -f /tmp/ai-skills-raw.tsv
                continue
            fi

            if command -v claude &>/dev/null; then
                claude -p "以下のスキル説明（英語）を日本語に翻訳してください。入力はTSV形式（スキル名\t英語説明）、出力もTSV形式（スキル名\t日本語説明）で、スキル名はそのままにして説明だけ翻訳してください。説明は内容が分かる程度に簡潔にまとめ、40文字以内を目安にしてください。" < /tmp/ai-skills-raw.tsv 2>/dev/null \
                    | grep -v '^\s*```' | grep -v '^\s*$' > "$tsv_file"
            else
                cp /tmp/ai-skills-raw.tsv "$tsv_file"
            fi
            rm -f /tmp/ai-skills-raw.tsv
            echo "ok ($(wc -l < "$tsv_file" | tr -d ' ') lines)"
            updated_files+=("$tsv_file")
        done

        if [[ ${#updated_files[@]} -gt 0 ]]; then
            echo ""
            git_commit_and_push "Update pending skill descriptions"
        fi
        ;;

    help|-h|--help)
        echo "Usage: $SCRIPT <command>"
        echo ""
        echo "Commands:"
        echo "  install              Install all skills (local + external)"
        echo "  update               Update installed skills via gh skill update"
        echo "  fetch-pending        Fetch pending skill descriptions (TSV re-generation)"
        echo "  add <skill@repo>     Add external skill, install, commit & push"
        echo "  remove <skill>       Remove external skill, uninstall, commit & push"
        echo "  list                 Show all skills with install status"
        echo "  pending-list         List sub-skills of pending repos (offline)"
        echo "  sync                 Pull from remote and install all"
        echo "  help                 Show this help"
        echo ""
        echo "Skill entry format (skills.conf):"
        echo "  skill@owner/repo     Installed by setup"
        echo "  ?skill@owner/repo    Optional (individual install only)"
        echo "  ~skill@owner/repo    Pending (gh skill not yet supported)"
        exit 0
        ;;

    *)
        echo "Unknown command: $subcmd" >&2
        echo "Run '$SCRIPT help' for usage." >&2
        exit 1
        ;;
esac
