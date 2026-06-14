# ai-skills

日本語 | [English](./README.en.md)

Claude Code・Cursor・GitHub Copilot・Codex などの AI ツールで共通利用できる汎用スキル集。
複数 PC 間で `skills.conf` を通じてスキル設定を共有する。

## セットアップ

[GitHub CLI](https://cli.github.com/) が必要。

```fish
git clone https://github.com/sanoakr/ai-skills.git
cd ai-skills
./setup.fish
```

Claude Code・Codex・GitHub Copilot にグローバルスコープで全スキルをインストールする。

## 使い方

```fish
# サブコマンド一覧を表示
./setup.fish

# 全スキルをインストール
./setup.fish install

# インストール済みスキルを更新（gh skill update）
./setup.fish update

# 対応待ちリポジトリの説明 TSV を再生成（コミット・プッシュまで自動）
./setup.fish fetch-pending

# スキル一覧（インストール状況・日本語説明付き）
./setup.fish list

# 対応待ちリポジトリのサブスキル一覧（日本語説明付き・オフライン）
./setup.fish pending-list

# 外部スキルを追加（インストール → コミット → プッシュまで自動）
./setup.fish add <skill-name>@<owner/repo>

# 外部スキルを削除（コミット → プッシュまで自動）
./setup.fish remove <skill-name>

# リモートから pull して全スキルを同期（別 PC での初回同期に）
./setup.fish sync
```

## スキル一覧

### ローカルスキル（自動検出）

リポジトリ内の `SKILL.md` を含むディレクトリから自動検出される。`skills.conf` への記載不要。

| スキル | 説明 |
|--------|------|
| [ja-proofreading](./ja-proofreading/SKILL.md) | textlint による日本語文章の自動校正 |
| [simple](./simple/SKILL.md) | 日本語圧縮出力モード |
| [gmail-persona](./gmail-persona/SKILL.md) | Gmail 履歴からペルソナ知識ベースを構築し、Q&A・メール下書きに活用 |
| [md-to-pdf](./md-to-pdf/SKILL.md) | Markdown を pandoc/xelatex/wkhtmltopdf で高品質 PDF・HTML・LaTeX に変換（日本語対応） |

### 外部スキル — Anthropic 公式

| スキル | 説明 |
|--------|------|
| [algorithmic-art](https://github.com/anthropics/skills/tree/main/skills/algorithmic-art) | アルゴリズム・ジェネラティブアート生成 |
| [brand-guidelines](https://github.com/anthropics/skills/tree/main/skills/brand-guidelines) | ブランドガイドライン策定・維持 |
| [canvas-design](https://github.com/anthropics/skills/tree/main/skills/canvas-design) | キャンバスベースのデザイン制作 |
| [claude-api](https://github.com/anthropics/skills/tree/main/skills/claude-api) | Claude API 統合・サンプルコード（多言語対応） |
| [doc-coauthoring](https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring) | ドキュメントの共同執筆・コラボレーション |
| [docx](https://github.com/anthropics/skills/tree/main/skills/docx) | Word (.docx) ドキュメントの生成・操作 |
| [frontend-design](https://github.com/anthropics/skills/tree/main/skills/frontend-design) | フロントエンド・UI デザイン |
| [internal-comms](https://github.com/anthropics/skills/tree/main/skills/internal-comms) | 社内コミュニケーション・文書自動化 |
| [mcp-builder](https://github.com/anthropics/skills/tree/main/skills/mcp-builder) | MCP サーバー開発・構築 |
| [pdf](https://github.com/anthropics/skills/tree/main/skills/pdf) | PDF ドキュメントの生成・操作 |
| [pptx](https://github.com/anthropics/skills/tree/main/skills/pptx) | PowerPoint (.pptx) プレゼンテーション生成 |
| [skill-creator](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | 新スキルの作成・テンプレート活用 |
| [slack-gif-creator](https://github.com/anthropics/skills/tree/main/skills/slack-gif-creator) | Slack 用 GIF 作成 |
| [theme-factory](https://github.com/anthropics/skills/tree/main/skills/theme-factory) | テーマ・デザインシステム生成 |
| [web-artifacts-builder](https://github.com/anthropics/skills/tree/main/skills/web-artifacts-builder) | Web アーティファクト構築 |
| [webapp-testing](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) | Web アプリケーションテスト自動化 |
| [xlsx](https://github.com/anthropics/skills/tree/main/skills/xlsx) | Excel (.xlsx) スプレッドシート生成・操作 |

### 外部スキル — 汎用

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [git-workflow](https://github.com/netresearch/git-workflow-skill) | netresearch/git-workflow-skill | Git Flow・GitHub Flow・trunk-based・CI/CD 対応の包括的 Git ワークフロー |
| [meeting-minutes](https://github.com/github/awesome-copilot/tree/main/skills/meeting-minutes) | github/awesome-copilot | 社内短時間ミーティングの議事録作成 |
| [cmux](https://github.com/ph3on1x/claude-cmux-skill/tree/main/skills/cmux) | ph3on1x/claude-cmux-skill | cmux 上で複数の Claude Code セッションを並列オーケストレーション |

### 外部スキル — 学術研究

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [deep-research](https://github.com/Imbad0202/academic-research-skills/tree/main/deep-research) | Imbad0202/academic-research-skills | 13エージェントによる文献レビュー・システマティックレビュー（PRISMA）・ファクトチェック |
| [academic-paper](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-paper) | Imbad0202/academic-research-skills | 12エージェントによる論文執筆（LaTeX/DOCX/PDF・二言語アブストラクト対応） |
| [academic-paper-reviewer](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-paper-reviewer) | Imbad0202/academic-research-skills | 7エージェントによるピアレビューシミュレーター（査読・編集委員長判定） |
| [academic-pipeline](https://github.com/Imbad0202/academic-research-skills/tree/main/academic-pipeline) | Imbad0202/academic-research-skills | 研究→執筆→整合性チェック→査読→改稿→最終化の全工程オーケストレーター |

### 外部スキル — クラウド

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [azure-deploy](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure へのデプロイ |
| [azure-cost](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure コスト確認 |
| [azure-resource-lookup](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure リソース確認 |
| [azure-rbac](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure ユーザー/ロール管理 |
| [azure-ai](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure AI Services |
| [microsoft-foundry](https://github.com/microsoft/azure-skills) | microsoft/azure-skills | Azure AI Foundry |
| [deploy](https://github.com/awslabs/agent-plugins) | awslabs/agent-plugins | AWS へのデプロイ |

### 外部スキル — mattpocock（個別インストール）

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [grill-with-docs](https://github.com/mattpocock/skills/tree/main/skills/engineering/grill-with-docs) | mattpocock/skills | プランを既存ドメインモデルに対して厳密に検証し、用語を明確化し、ドキュメント (CONTEXT.md, ADR) をインラインで更新 |

### 外部スキル — 個別インストール（setup 対象外）

> `skills.conf` に `?` プレフィックスで管理。スキル数が多いため `setup.fish` の自動インストール対象外。  
> `gh skill install {リポジトリ} {スキル名}` で必要なスキルを個別にインストール可能。  
> インストール状況は `./setup.fish list` で確認できる。

| スキル | リポジトリ | 説明 |
|--------|-----------|------|
| [alignment-values-north-star](https://github.com/lyndonkl/claude/tree/main/skills/alignment-values-north-star) | lyndonkl/claude | チームの方向性・意思決定の共通軸となる North Star・バリュー・原則の策定 |
| [brainstorm-diverge-converge](https://github.com/lyndonkl/claude/tree/main/skills/brainstorm-diverge-converge) | lyndonkl/claude | 発散→収束型ブレインストーミングの構造化ファシリテーション |
| [causal-inference-root-cause](https://github.com/lyndonkl/claude/tree/main/skills/causal-inference-root-cause) | lyndonkl/claude | 相関と因果の分離・根本原因特定・交絡変数制御・仮説検証設計 |
| [decision-matrix](https://github.com/lyndonkl/claude/tree/main/skills/decision-matrix) | lyndonkl/claude | 多基準意思決定マトリクスによる選択肢の体系的評価 |
| [environmental-scanning-foresight](https://github.com/lyndonkl/claude/tree/main/skills/environmental-scanning-foresight) | lyndonkl/claude | PESTLE 分析・弱いシグナル検出・シナリオプランニングによる戦略的先見 |
| [forecast-premortem](https://github.com/lyndonkl/claude/tree/main/skills/forecast-premortem) | lyndonkl/claude | 高確信予測のプレモーテム（失敗逆算）によるテール・リスク特定 |
| [kill-criteria-exit-ramps](https://github.com/lyndonkl/claude/tree/main/skills/kill-criteria-exit-ramps) | lyndonkl/claude | プロジェクト中止基準・撤退トリガーの事前設定 |
| [metrics-tree](https://github.com/lyndonkl/claude/tree/main/skills/metrics-tree) | lyndonkl/claude | 北極星指標の分解・KPI 階層・先行指標マッピング |
| [negotiation-alignment-governance](https://github.com/lyndonkl/claude/tree/main/skills/negotiation-alignment-governance) | lyndonkl/claude | 交渉・合意形成・ガバナンス設計の体系的サポート |
| [portfolio-roadmapping-bets](https://github.com/lyndonkl/claude/tree/main/skills/portfolio-roadmapping-bets) | lyndonkl/claude | ポートフォリオ視点でのロードマップ作成・賭けの優先順位付け |
| [project-risk-register](https://github.com/lyndonkl/claude/tree/main/skills/project-risk-register) | lyndonkl/claude | リスク登録簿・確率×影響マトリクス・緩和計画の体系的管理 |
| [roadmap-backcast](https://github.com/lyndonkl/claude/tree/main/skills/roadmap-backcast) | lyndonkl/claude | 目標日から逆算するマイルストーン設計・クリティカルパス特定 |
| [strategy-and-competitive-analysis](https://github.com/lyndonkl/claude/tree/main/skills/strategy-and-competitive-analysis) | lyndonkl/claude | 市場参入・競合分析・Porter 5 Forces・SWOT・Blue Ocean などの戦略フレームワーク |
| [awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills) | VoltAgent/awesome-agent-skills | Microsoft・Google・Anthropic 等の公式チームによるキュレーション済みスキル集インデックス（1,100+） |
| [scientific-agent-skills](https://github.com/K-Dense-AI/scientific-agent-skills) | K-Dense-AI/scientific-agent-skills | 科学研究向けスキル集（論文執筆・文献検索・バイオインフォ・創薬・量子計算など 140 スキル） |

### 外部スキル — 対応待ち（gh skill 非対応）

> `skills.conf` に `~` プレフィックスで管理。非標準ディレクトリ構造のため `gh skill install` 不可。  
> インストール状況は `./setup.fish list` で確認できる。

| リポジトリ | 説明 |
|-----------|------|
| [Orchestra-Research/AI-Research-SKILLs](https://github.com/Orchestra-Research/AI-Research-SKILLs) | AI 研究向けスキル集（モデルアーキテクチャ・ファインチューニング・分散学習・推論・安全性など 87 スキル） |
| [ndpvt-web/latex-document-skill](https://github.com/ndpvt-web/latex-document-skill) | 手書きノート・スキャン・生データから出版品質の LaTeX PDF を自動生成（27 テンプレート・OCR 対応） |

## ファイル構成

```
ai-skills/
├── setup.fish           # セットアップスクリプト（fish）
├── setup.sh             # セットアップスクリプト（bash）
├── fetch_skill_descs.py # pending リポジトリから SKILL.md 説明を取得
├── print_pending_list.py# pending スキル一覧を整形表示
├── skills.conf          # 外部スキルリスト（これを編集して共有）
├── skills.desc          # 日本語説明ファイル
├── pending-descs/       # 対応待ちリポジトリのサブスキル日本語説明 TSV（fetch-pending で生成）
├── SKILL_TEMPLATE.md    # 新スキル作成テンプレート
├── <スキル名>/
│   ├── SKILL.md         # スキル定義（YAML frontmatter + Markdown）
│   └── scripts/         # 補助スクリプト（オプション）
└── README.md
```

## スキルの追加

### 外部スキルの追加

```fish
./setup.fish add new-skill@owner/repo
```

### ローカルスキルの追加

1. `SKILL_TEMPLATE.md` を参考に `<スキル名>/SKILL.md` を作成する
2. コミット・プッシュする
3. 公開検証: `gh skill publish --dry-run`
4. 各ツールで `gh skill update --all` を実行して反映する

## 関連リポジトリ

- [sanoakr/claude-plugins](https://github.com/sanoakr/claude-plugins) — Claude Code プラグイン・MCP 管理
