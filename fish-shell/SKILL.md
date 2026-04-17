---
name: fish-shell
description: fish shell の文法・コマンドを正しく使い、bash/zsh との混同を避ける。fish 環境でのコマンド実行・スクリプト作成・シェル設定変更時に使用する。
license: MIT
---

# スキル: fish shell 操作

**目的**: fish shell の文法・コマンドを正しく使い、bash/zsh との混同を避ける

**発動条件**: fish 環境でのコマンド実行・スクリプト作成・シェル設定変更

---

## fish と bash/zsh の主な違い

### 変数

```fish
# fish（$ なし、set コマンドを使う）
set my_var "hello"
echo $my_var

# スコープ
set -l local_var "local"      # ローカル（関数内）
set -g global_var "global"    # グローバル（セッション）
set -gx export_var "export"   # エクスポート（環境変数）

# ❌ bash 構文（fish では動かない）
export MY_VAR="hello"         # → set -gx MY_VAR "hello"
MY_VAR="hello"                # → set MY_VAR "hello"
```

### 条件分岐

```fish
# fish
if test $status -eq 0
    echo "成功"
else if test $status -eq 1
    echo "エラー1"
else
    echo "その他"
end

# ファイル存在確認
if test -f "file.txt"
    echo "ファイルあり"
end

# コマンド存在確認
if command -v node > /dev/null
    echo "node がインストール済み"
end
```

### ループ

```fish
# for ループ
for file in *.fish
    echo $file
end

# while ループ
while test $count -lt 10
    set count (math $count + 1)
end

# コマンド置換（バッククォートではなく括弧）
set files (ls *.md)
set count (math 1 + 2)
```

### 関数

```fish
function greet --description "挨拶する関数"
    set name $argv[1]
    echo "こんにちは、$name さん"
end

# 関数の永続化（~/.config/fish/functions/ に保存）
funcsave greet
```

### パイプとリダイレクト

```fish
# パイプ（bash と同じ）
ls | grep ".md"

# リダイレクト（bash と同じ）
echo "hello" > file.txt
echo "world" >> file.txt

# エラーリダイレクト
command 2>/dev/null
command 2>&1 | grep "error"
```

### エイリアス（abbr を推奨）

```fish
# abbr（入力時に展開される、履歴に残る）
abbr --add gs 'git status'

# alias（関数として定義）
alias ll 'ls -la'
```

---

## よく使う fish コマンド

```fish
# 設定ファイルの再読み込み
source ~/.config/fish/config.fish

# 関数一覧
functions

# 環境変数一覧
set -gx

# PATH に追加
fish_add_path /usr/local/bin

# コマンド履歴
history

# fish の設定（GUI）
fish_config
```

---

## スクリプト作成の注意

```fish
#!/usr/bin/env fish
# ← シェバンは fish を明示する

set -e   # ❌ bash の set -e は動かない
# fish はデフォルトでエラー時に継続する
# 明示的なエラーチェックが必要

set result (some_command)
if test $status -ne 0
    echo "エラーが発生しました"
    exit 1
end
```

---

## 注意事項

- bash/zsh のスクリプト構文を fish に混入させない
- `$(command)` → `(command)` に置き換える
- `&&` / `||` の代わりに `and` / `or` を使う（または `;` と `if` を組み合わせる）
- 配列のインデックスは **1始まり**（0始まりではない）
