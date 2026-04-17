---
name: ja-proofreading
license: MIT
description: |
  日本語文章をtextlintで自動校正するスキル。Markdownやテキストファイルをtextlintのプリセットルールでチェックし、問題点を日本語で分かりやすく報告する。

  以下のような場合に必ず使用すること：
  - 「日本語の文章を校正して」「textlintでチェックして」「文章の誤りを見つけて」
  - 「ら抜き言葉」「二重否定」「読点の多用」「文体の統一」などの確認依頼
  - ブログ記事、技術文書、マニュアルなどの日本語テキストの品質チェック
  - `.md`、`.txt`、`.mdx`ファイルの日本語校正
  - 「文章を直して」「読みやすくして」「おかしい表現を直して」という依頼でテキストが日本語の場合
---

# 日本語文章校正スキル（textlint）

このスキルはtextlintと日本語プリセットを使って、文章の問題点を検出・報告します。

## 使用するルールプリセット

- **textlint-rule-preset-ja-technical-writing** — 技術文書向け25ルール（文の長さ、読点数、ら抜き言葉、文体統一など）
- **textlint-rule-preset-japanese** — 一般文書向け12ルール（誤検知が少なく安定したルールのみ）
- **textlint-rule-preset-ja-spacing** — 日本語と英数字の間のスペースルール

## 手順

### Step 1: 入力テキストの確認

ユーザーが提供した内容を確認する：
- テキストが会話中に貼り付けられた場合 → 一時ファイルに書き出して処理
- ファイルパスが指定された場合 → そのファイルをそのまま使用
- ファイルがアップロードされた場合 → `/sessions/eager-fervent-faraday/mnt/uploads/` 以下に保存されているのでそこから読み込む

### Step 2: 環境セットアップ

`scripts/setup_textlint.sh` を使って環境を確認・セットアップする。

まず既存のセットアップが `/tmp/textlint-ja/` にあるかチェックし、なければ新規インストールする：

```bash
# /tmp/textlint-ja/ に環境を作る
ls /tmp/textlint-ja/node_modules/.bin/textlint 2>/dev/null || bash <skill-dir>/scripts/setup_textlint.sh
```

### Step 3: 校正の実行

```bash
cd /tmp/textlint-ja
./node_modules/.bin/textlint --config .textlintrc.json --format json <対象ファイル>
```

JSONフォーマットで出力することで、構造化されたエラーリストを取得できる。

### Step 4: 結果の整形と報告

textlintのJSON出力を解析して、以下の形式で日本語報告を生成する：

```
## 校正結果: <ファイル名>

### 概要
- 指摘件数: X件
- エラー（必須修正）: X件
- 警告（推奨修正）: X件

### 指摘一覧

**1行目: 「〇〇〇」**
- ルール: `preset-ja-technical-writing/no-dropping-the-ra`
- 問題: ら抜き言葉が使われています
- 修正案: 「〇〇られ」→「〇〇れ」

...（以降同様）

### 修正済みテキスト（任意）
<指摘を反映した修正版>
```

### Step 4.5: 口語縮約形の補足チェック

textlintは「ら抜き言葉（食べれる→食べられる）」は検出するが、**口語的な縮約形**は検出しない。これらは読み手に稚拙な印象を与えるため、技術文書・ブログ記事では修正が望ましい。textlint実行後に以下のgrepを追加で走らせて報告する：

```bash
# コードブロック以外の行で口語縮約形を検出
grep -n "てた\b\|てる\b\|てく\b\|でた\b\|でる\b\|ちゃ\|じゃ\|なきゃ" <対象ファイル> \
  | grep -v "^\`\`\`" \
  | grep -v "^    "  # インデントされたコードブロックも除外
```

代表的な縮約形と修正案：

| 縮約形 | 正式形 | 例 |
|--------|--------|-----|
| 〜てた | 〜ていた | 「作業をしてたのですが」→「作業をしていたのですが」 |
| 〜てる | 〜ている | 「確認してる」→「確認している」 |
| 〜てく | 〜ていく | 「進めてく」→「進めていく」 |
| 〜ちゃ | 〜ては | 「やっちゃいけない」→「やってはいけない」 |
| 〜なきゃ | 〜なければ | 「直さなきゃ」→「直さなければ」 |

コードブロック内・引用文・ファイル名・URLにマッチした場合は誤検知として除外する。

### Step 5: 修正案の提示（オプション）

ユーザーが「直してほしい」と言っている場合や修正版を求めている場合は、指摘箇所を自動修正したテキストも提供する。ルールによって機械的に直せるものと、文脈判断が必要なものがあることを明示する。

## textlintrc 設定

`/tmp/textlint-ja/.textlintrc.json` に以下の設定を使用する：

```json
{
  "rules": {
    "preset-ja-technical-writing": {
      "sentence-length": {
        "max": 150,
        "skipPatterns": ["\\[.*?\\]\\(.*?\\)"]
      },
      "max-ten": {
        "max": 4
      },
      "no-mix-dearu-desumasu": {
        "preferInBody": "です・ます",
        "preferInHeader": "である",
        "strict": true
      },
      "no-exclamation-question-mark": false,
      "ja-no-weak-phrase": false
    },
    "preset-japanese": true,
    "preset-ja-spacing": {
      "ja-space-between-half-and-full-width": {
        "open": false,
        "close": false
      }
    }
  },
  "filters": {
    "comments": true
  }
}
```

主なカスタマイズの理由：
- `sentence-length.max: 150` — 技術文書はURLやコードを含むことが多いため標準の100より緩く
- `max-ten.max: 4` — 読点3個制限はやや厳しいため4個に緩和
- `no-mix-dearu-desumasu.strict: true` — 箇条書きや文末を含め全体で文体の混在を厳格にチェック（段落の途中でである調が混入するケースも検出できる）
- `no-exclamation-question-mark: false` — ブログ記事での感嘆符・疑問符を許可
- `ja-no-weak-phrase: false` — 「〜と思います」等は文脈次第のため無効化

## エラーメッセージの日本語化

主なルールのエラーを日本語で説明する対訳表：

| ルールID | 日本語説明 |
|---------|-----------|
| `sentence-length` | 1文が長すぎます（{max}文字以内にしてください） |
| `max-ten` | 読点「、」が多すぎます（{max}個以内にしてください） |
| `max-comma` | カンマが多すぎます（{max}個以内にしてください） |
| `no-mix-dearu-desumasu` | 「です・ます調」と「だ・である調」が混在しています |
| `no-doubled-conjunction` | 接続詞が連続しています |
| `no-doubled-conjunctive-particle-ga` | 逆接の「が」が連続しています |
| `no-double-negative-ja` | 二重否定が使われています |
| `no-dropping-the-ra` | ら抜き言葉が使われています |
| `no-doubled-joshi` | 同じ助詞が連続しています |
| `ja-no-successive-word` | 同じ単語が連続しています |
| `ja-no-abusage` | よくある誤用が含まれています |
| `ja-no-redundant-expression` | 冗長な表現が含まれています |
| `ja-no-weak-phrase` | 弱い表現（〜かもしれない等）が使われています |
| `no-nfd` | Mac由来の濁点エラーがあります |
| `no-zero-width-spaces` | ゼロ幅スペースが含まれています |
| `ja-no-mixed-period` | 文末句点が統一されていません |
| `no-hankaku-kana` | 半角カナが含まれています |

## 注意事項

- コードブロック（\`\`\`）の中はチェックされない（これは正常な動作）
- URLやコマンド例が「長い文」として検出される場合があるが、これは誤検知として扱ってよい
- ユーザーの文体（ですます/である）が判断できない場合は、文書全体を見て優勢な方を報告する
- 指摘が多い場合は「エラー（severity: error）」を優先して報告し、警告は件数のみ伝えてもよい
- `no-mix-dearu-desumasu` を `strict: true` にすると、箇条書き内のである調もエラーになる。もしユーザーが「箇条書きはである調でいい」と言った場合は `strict: false` に変更するか、その指摘だけを除外してよい
- Step 4.5の縮約形チェックで得たヒットは、コード・引用・URLに含まれている場合は誤検知として除外する
