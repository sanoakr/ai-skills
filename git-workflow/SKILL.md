---
name: git-workflow
description: Conventional Commits に準拠したコミットとブランチ管理を一貫して行う。"コミットして" "変更をまとめて" "PRを準備して" "ブランチを作って" などの際に使用する。
---

# スキル: Git ワークフロー

**目的**: Conventional Commits に準拠したコミットとブランチ管理を一貫して行う

**発動条件**: "コミットして" "変更をまとめて" "PRを準備して" "ブランチを作って"

---

## 手順

### ステップ1: 現状把握

```fish
git status                    # 変更ファイルの確認
git diff                      # 未ステージの変更内容
git diff --staged             # ステージ済みの変更内容
git log --oneline -5          # 直近のコミット履歴
```

### ステップ2: 変更を整理してコミット

意味のある単位でコミットを分割する（1コミット＝1つの変更目的）:

```fish
# 関連ファイルだけをステージ
git add src/auth/login.ts tests/auth/login.test.ts

# コミット（Conventional Commits 形式）
git commit -m "feat(auth): ログイン失敗時のエラーメッセージを改善"
```

### ステップ3: コミットメッセージの確認

```
✅ 良い形式:
feat(user): プロフィール画像のアップロード機能を追加
fix(api): 検索クエリが空の場合の500エラーを修正
docs(readme): セットアップ手順を最新化

❌ 避けるもの:
fix: バグ修正
update
WIP
```

### ステップ4: プッシュ前の確認

```fish
git log --oneline origin/main..HEAD   # プッシュされていないコミット
git diff origin/main...HEAD           # 差分の全体像
```

---

## ブランチ操作（fish）

```fish
# 新しいフィーチャーブランチ
git checkout -b feature/42-add-search-filter

# リモートと同期
git fetch origin
git rebase origin/main   # または git merge origin/main

# プッシュ
git push -u origin (git branch --show-current)
```

---

## 出力形式

コミット後に以下を報告する:

```
✅ コミット完了
  コミットハッシュ: abc1234
  メッセージ: feat(auth): JWT自動更新を実装
  変更ファイル: 3ファイル (+45/-12行)

次のステップ: git push でリモートに送信（確認後）
```

---

## 注意事項

- `main`/`master` への直接コミットは禁止（確認を求める）
- `git reset --hard` / `git push --force` は必ず確認を取ってから実行
- `.env` / `secrets.*` がステージされていたら警告してステージを解除する
- コミット前に `git diff --staged` で内容を必ず確認する
