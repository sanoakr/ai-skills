#!/usr/bin/env fish
# Claude Code / Codex / GitHub Copilot スキル一括セットアップスクリプト
# 複数 PC 間で設定を共有するために GitHub リポジトリで管理する
#
# ローカルスキル: リポジトリ内の SKILL.md を含むディレクトリから自動検出
# 外部スキル:     skills.conf に記載されたリポジトリからインストール
#
# 使い方:
#   ./setup-global.fish              サブコマンド一覧を表示
#   ./setup-global.fish install      全スキルをインストール・更新
#   ./setup-global.fish add <s@r>    外部スキルを追加してコミット・プッシュ
#   ./setup-global.fish remove <s>   外部スキルを削除してコミット・プッシュ
#   ./setup-global.fish list         全スキル（ローカル＋外部）を日本語説明付きで表示
#   ./setup-global.fish sync         リモートから pull して全スキルを同期
#   ./setup-global.fish help         ヘルプを表示

set REPO_DIR (dirname (realpath (status --current-filename)))
set SCRIPT (basename (status --current-filename))
set CONF "$REPO_DIR/skills.conf"
set DESC_FILE "$REPO_DIR/skills.desc"
set AGENTS claude-code codex github-copilot
set SCOPE user

# ---------- ヘルパー関数 ----------

function read_skills
    # skills.conf から通常エントリ（コメント・空行・?・~ プレフィックス行を除く）を返す
    if not test -f $CONF
        echo "Error: $CONF not found" >&2
        return 1
    end
    grep -v '^\s*#' $CONF | grep -v '^\s*$' | grep -v '^\s*[?~]' | string trim
end

function read_skills_optional
    # ? プレフィックス行（個別インストール推奨・setup 対象外）を返す（? を除いた本体）
    if not test -f $CONF
        return 1
    end
    grep -v '^\s*#' $CONF | grep -v '^\s*$' | grep '^\s*?' | string trim | string replace -r '^\?' ''
end

function read_skills_pending
    # ~ プレフィックス行（gh skill 非対応・対応待ち）を返す（~ を除いた本体）
    if not test -f $CONF
        return 1
    end
    grep -v '^\s*#' $CONF | grep -v '^\s*$' | grep '^\s*~' | string trim | string replace -r '^~' ''
end

function is_installed --argument-names skill_name
    # ~/.claude/skills/<name>/ が存在するか確認（ユーザースコープのみ）
    # 直接一致、またはサブディレクトリに SKILL.md があるネスト構造も考慮
    set -l dname (display_name $skill_name)
    set -l base "$HOME/.claude/skills"
    if test -d "$base/$dname"
        return 0
    end
    # ネスト構造: $base/<anything>/<dname>/SKILL.md
    set -l found (find "$base" -maxdepth 3 -name SKILL.md -path "*/$dname/SKILL.md" 2>/dev/null | head -1)
    if test -n "$found"
        return 0
    end
    return 1
end

function status_mark --argument-names skill_name
    if is_installed $skill_name
        echo "[+]"
    else
        echo "[-]"
    end
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
    git -C $REPO_DIR add skills.conf skills.desc pending-descs/ 2>/dev/null
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
            echo "Usage: $SCRIPT add <skill-name@owner/repo>" >&2
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
            echo "Usage: $SCRIPT remove <skill-name>" >&2
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
        set -l optional_entries (read_skills_optional)
        set -l pending_entries (read_skills_pending)

        echo "Status: [+] installed  [-] not installed"
        echo ""

        # ローカルスキル
        echo "Local skills (auto-discovered):"
        echo ""
        if test (count $local_skills) -eq 0
            echo "  (none)"
        else
            for skill in $local_skills
                set -l mark (status_mark $skill)
                set -l desc (get_description $skill)
                printf "  %s  %-26s  %s\n" $mark $skill "$desc"
            end
        end
        echo ""

        # 外部スキル（setup 対象）
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
                set -l mark (status_mark $skill_name)
                set -l desc (get_description $skill_name)
                printf "  %s  %-26s  %-34s  %s\n" $mark $dname "($repo)" "$desc"
            end
        end
        echo ""

        # 個別インストールスキル（setup 対象外）
        echo "Optional skills (individual install only):"
        echo ""
        if test (count $optional_entries) -eq 0
            echo "  (none)"
        else
            for entry in $optional_entries
                set -l parsed (parse_skill $entry)
                set -l skill_name $parsed[1]
                set -l repo $parsed[2]
                set -l dname (display_name $skill_name)
                set -l mark (status_mark $skill_name)
                set -l desc (get_description $skill_name)
                printf "  %s  %-26s  %-34s  %s\n" $mark $dname "($repo)" "$desc"
            end
        end
        echo ""

        # 対応待ちスキル（gh skill 非対応）
        echo "Pending skills (gh skill not yet supported):"
        echo ""
        if test (count $pending_entries) -eq 0
            echo "  (none)"
        else
            for entry in $pending_entries
                set -l parsed (parse_skill $entry)
                set -l skill_name $parsed[1]
                set -l repo $parsed[2]
                set -l dname (display_name $skill_name)
                set -l mark (status_mark $skill_name)
                set -l desc (get_description $skill_name)
                printf "  %s  %-26s  %-34s  %s\n" $mark $dname "($repo)" "$desc"
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

    case pending-list
        # pending-descs/<owner>-<repo>.tsv を読んで表示（API 呼び出しなし）
        set -l pending_entries (read_skills_pending)
        if test (count $pending_entries) -eq 0
            echo "No pending skills."
            exit 0
        end
        set -l desc_dir "$REPO_DIR/pending-descs"
        set -l missing_tsv 0

        for entry in $pending_entries
            set -l parsed (parse_skill $entry)
            set -l repo $parsed[2]
            set -l repo_name (string replace -r '^.*/' '' -- $repo)
            set -l repo_owner (string replace -r '/.*' '' -- $repo)
            set -l desc (get_description $parsed[1])
            set -l tsv_file "$desc_dir/$repo_owner-$repo_name.tsv"
            echo "=== $repo  —  $desc ==="
            echo ""

            if not test -f $tsv_file
                echo "  (no description file — run '$SCRIPT update' to fetch)" >&2
                set missing_tsv 1
                echo ""
                continue
            end

            # TSV を読んでリポジトリのファイルツリーと照合して表示
            set -l tree_file (mktemp /tmp/ai-skills-tree.XXXXXX)
            gh api "repos/$repo/git/trees/HEAD?recursive=1" > $tree_file 2>/dev/null
            python3 -c "
import sys, json

data = json.load(open(sys.argv[2]))
repo_name = sys.argv[1]
tsv_path = sys.argv[3]

desc_map = {}
with open(tsv_path) as f:
    for line in f:
        line = line.strip()
        if '\t' in line:
            k, v = line.split('\t', 1)
            desc_map[k.strip()] = v.strip()

paths = [t['path'] for t in data.get('tree', [])
         if t['path'].endswith('/SKILL.md') or t['path'] == 'SKILL.md']

cats = set()
for p in paths:
    parts = p.split('/')
    if len(parts) == 3:
        cats.add(parts[0])
use_category = len(cats) > 1

prev_cat = None
for path in sorted(paths):
    parts = path.split('/')
    if len(parts) == 1:
        skill = repo_name
        d = desc_map.get(skill, '')
        print(f'  [-]  {skill:<28}  {d}')
    elif len(parts) == 2:
        skill = parts[0]
        d = desc_map.get(skill, '')
        print(f'  [-]  {skill:<28}  {d}')
    elif len(parts) == 3:
        cat, skill = parts[0], parts[1]
        d = desc_map.get(skill, '')
        if use_category:
            if cat != prev_cat:
                print(f'  [{cat}]')
                prev_cat = cat
            print(f'    [-]  {skill:<26}  {d}')
        else:
            print(f'  [-]  {skill:<28}  {d}')
" $repo_name $tree_file $tsv_file
            rm -f $tree_file
            echo ""
        end

    case update
        # gh skill update --all + pending repos の説明 TSV を再生成・翻訳 → コミット・プッシュ
        echo "=== Updating installed skills ==="
        echo ""
        gh skill update --all
        echo ""

        echo "=== Updating pending skill descriptions ==="
        echo ""
        set -l pending_entries (read_skills_pending)
        set -l desc_dir "$REPO_DIR/pending-descs"
        mkdir -p $desc_dir
        set -l updated_files

        for entry in $pending_entries
            set -l parsed (parse_skill $entry)
            set -l repo $parsed[2]
            set -l repo_name (string replace -r '^.*/' '' -- $repo)
            set -l repo_owner (string replace -r '/.*' '' -- $repo)
            set -l tsv_file "$desc_dir/$repo_owner-$repo_name.tsv"
            printf "  %-44s ... " "$repo"

            # ファイルツリー取得
            set -l tree_file (mktemp /tmp/ai-skills-tree.XXXXXX)
            gh api "repos/$repo/git/trees/HEAD?recursive=1" > $tree_file 2>/dev/null
            if test $status -ne 0
                echo "FAILED (tree fetch)"
                rm -f $tree_file
                continue
            end

            # GraphQL で全 SKILL.md の description を一括取得
            python3 -c "
import sys, json, subprocess, re

data = json.load(open(sys.argv[3]))
owner, name = sys.argv[1], sys.argv[2]
paths = [t['path'] for t in data.get('tree', [])
         if t['path'].endswith('/SKILL.md') or t['path'] == 'SKILL.md']

aliases, fields = [], []
for p in paths:
    alias = re.sub(r'[^a-zA-Z0-9]', '_', p.replace('/SKILL.md', '').replace('SKILL.md', '_root'))
    if alias[0].isdigit():
        alias = 's_' + alias
    aliases.append((alias, p))
    fields.append(f'{alias}: object(expression: \"HEAD:{p}\") {{ ... on Blob {{ text }} }}')

query = '{repository(owner:\"' + owner + '\",name:\"' + name + '\"){' + ' '.join(fields) + '}}'
result = subprocess.run(['gh', 'api', 'graphql', '-f', f'query={query}'],
                        stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)
try:
    rdata = json.loads(result.stdout)
    repo_data = rdata['data']['repository']
except Exception:
    sys.exit(1)

rows = []
for alias, path in aliases:
    parts = path.split('/')
    skill = parts[-2] if len(parts) >= 2 else name
    obj = repo_data.get(alias)
    if obj and obj.get('text'):
        lines = obj['text'].split('\n')
        desc = ''
        in_block = False
        for l in lines:
            if l.startswith('description:'):
                val = l[len('description:'):].strip().strip('\"').strip(\"'\")
                if val == '>':
                    in_block = True
                else:
                    desc = val
                    break
            elif in_block:
                s = l.strip()
                if s and not s.startswith('-'):
                    desc = s
                    break
        rows.append(f'{skill}\t{desc[:120]}')

print('\n'.join(rows))
" $repo_owner $repo_name $tree_file > /tmp/ai-skills-raw.tsv 2>/dev/null
            rm -f $tree_file

            if test (wc -l < /tmp/ai-skills-raw.tsv) -eq 0
                echo "FAILED (graphql)"
                rm -f /tmp/ai-skills-raw.tsv
                continue
            end

            # claude -p で一括翻訳
            if command -q claude
                cat /tmp/ai-skills-raw.tsv | claude -p "以下のスキル説明（英語）を各20文字以内の日本語に翻訳してください。入力はTSV形式（スキル名\t英語説明）、出力もTSV形式（スキル名\t日本語説明）で、スキル名はそのままにして説明だけ翻訳してください。" 2>/dev/null | grep -v '^\s*```' | grep -v '^\s*$' > $tsv_file
            else
                cp /tmp/ai-skills-raw.tsv $tsv_file
            end
            rm -f /tmp/ai-skills-raw.tsv
            echo "ok ("(wc -l < $tsv_file | string trim)" lines)"
            set updated_files $updated_files $tsv_file
        end

        # 変更があればコミット・プッシュ
        if test (count $updated_files) -gt 0
            echo ""
            git_commit_and_push "Update pending skill descriptions"
        end

    case install
        # 明示的インストール（下で処理）

    case help -h --help ''
        echo "Usage: $SCRIPT <command>"
        echo ""
        echo "Commands:"
        echo "  install              Install/update all skills (local + external)"
        echo "  update               Update installed skills + refresh pending descriptions"
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

    case '*'
        echo "Unknown command: $subcmd" >&2
        echo "Run '$SCRIPT help' for usage." >&2
        exit 1
end

# ---------- 全スキルインストール（デフォルト / sync 後） ----------

if test "$subcmd" = "install" -o "$subcmd" = "sync"
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
