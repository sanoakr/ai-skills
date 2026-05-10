---
name: md-to-pdf
description: |
  pandoc・xelatex・wkhtmltopdf などの CLI ツールが使える環境限定で、
  Markdownファイルを高品質なPDF・HTML・LaTeXに変換するスキル。
  日本語を含む文書の変換に対応。
  Python ライブラリ（pypdf / reportlab など）による PDF 操作が目的の場合は pdf スキルを使うこと。

  以下のような場合に使用すること:
  - 「Markdownを PDF/HTML/LaTeX に変換して」
  - 「日本語のMarkdownをきれいなPDFにしたい」
  - 「レイアウトを整えてPDFを作りたい」
  - 「pandoc で変換して」「レポートをPDF出力したい」
  - .md ファイルを受け取り PDF/HTML/tex ファイルを出力するあらゆる作業
---

# Markdown → PDF / HTML / LaTeX 変換スキル

## 環境の前提条件

以下のツールがすでにインストール済みであることを確認済み:
- `pandoc` 3.1.3（Markdown の中核変換エンジン）
- `xelatex`（日本語対応 LaTeX エンジン）
- `wkhtmltopdf`（HTML → PDF 変換）
- `xeCJK` パッケージ（LaTeX 日本語組版）
- Noto CJK JP フォント（`Noto Serif CJK JP` / `Noto Sans CJK JP`）

インストール済みパッケージ（セッション内で apt install 実行済み）:
```
texlive-lang-cjk   # xeCJK.sty を含む
lmodern            # lmodern.sty（pandoc テンプレート依存）
```

---

## 変換ルート

```
Markdown
  ├─► HTML ──► wkhtmltopdf ──► PDF  （スタイル重視・CSS制御）
  ├─► LaTeX（.tex）              （数式・学術文書向け）
  └─► xelatex ──────────────► PDF  （日本語組版・数式両対応）
```

---

## ルート1: Markdown → HTML

### 基本コマンド

```bash
pandoc input.md -o output.html --standalone
```

### 日本語対応・スタイル付き HTML

```bash
pandoc input.md -o output.html \
  --standalone \
  --metadata title="文書タイトル" \
  --css=style.css
```

### 推奨 CSS（日本語対応）

```css
/* style.css */
body {
  font-family: "Noto Serif CJK JP", "Noto Sans CJK JP", serif;
  margin: 2cm;
  line-height: 1.8;
  font-size: 12pt;
  color: #1a1a1a;
}
h1 { font-size: 22pt; border-bottom: 2px solid #333; padding-bottom: 6px; }
h2 { font-size: 16pt; color: #2c3e50; }
h3 { font-size: 13pt; color: #34495e; }
table { border-collapse: collapse; width: 100%; margin: 1em 0; }
td, th { border: 1px solid #ccc; padding: 6px 10px; }
th { background: #f0f0f0; }
code { background: #f5f5f5; padding: 2px 5px; border-radius: 3px; font-size: 90%; }
pre { background: #f5f5f5; padding: 12px; border-radius: 5px; overflow-x: auto; }
blockquote { border-left: 4px solid #ccc; margin-left: 0; padding-left: 1em; color: #555; }
```

---

## ルート2: HTML → PDF（wkhtmltopdf）

```bash
# HTML → PDF
wkhtmltopdf --encoding utf-8 \
  --page-size A4 \
  --margin-top 20mm --margin-bottom 20mm \
  --margin-left 20mm --margin-right 20mm \
  input.html output.pdf
```

### Markdown → HTML → PDF 一括

```bash
# Step 1: Markdown → HTML
pandoc input.md -o /tmp/work.html \
  --standalone \
  --css=style.css

# Step 2: HTML → PDF
wkhtmltopdf --encoding utf-8 \
  --page-size A4 \
  /tmp/work.html output.pdf
```

---

## ルート3: Markdown → LaTeX（.tex）出力

```bash
# スタンドアロン .tex ファイルを生成
pandoc input.md -o output.tex \
  --standalone \
  -V CJKmainfont="Noto Serif CJK JP"
```

### テンプレートのカスタマイズ

```bash
# デフォルトテンプレートを取得してカスタマイズ
pandoc -D latex > my_template.tex
# my_template.tex を編集後:
pandoc input.md -o output.tex --template=my_template.tex
```

---

## ルート4: Markdown → PDF（xelatex 経由）← **推奨：日本語+数式**

```bash
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  -V documentclass=article \
  -V geometry=margin=2.5cm \
  -V fontsize=11pt \
  -V CJKmainfont="Noto Serif CJK JP" \
  -V lang=ja
```

### よく使うオプション

| オプション | 説明 |
|-----------|------|
| `--pdf-engine=xelatex` | xelatex を使用（日本語必須） |
| `-V documentclass=article` | 文書クラス（article / report / book） |
| `-V geometry=margin=2.5cm` | 余白設定 |
| `-V CJKmainfont="Noto Serif CJK JP"` | 日本語メインフォント |
| `-V CJKsansfont="Noto Sans CJK JP"` | 日本語サンズフォント |
| `-V fontsize=11pt` | 基本フォントサイズ |
| `-V lang=ja` | 言語設定 |
| `--toc` | 目次を生成 |
| `--number-sections` | セクション番号を付与 |
| `-V papersize=a4` | 用紙サイズ（a4 / letter） |

### Pandoc Markdown YAML ヘッダー（.md ファイル先頭）

```yaml
---
title: "文書タイトル"
author: "著者名"
date: "2026年5月"
lang: ja
geometry: margin=2.5cm
fontsize: 11pt
CJKmainfont: "Noto Serif CJK JP"
---
```

---

## Python スクリプト（一括変換）

```python
#!/usr/bin/env python3
"""md_to_pdf.py: Markdown → PDF/HTML/LaTeX 変換スクリプト"""

import subprocess
import sys
from pathlib import Path


def md_to_pdf_xelatex(input_md: str, output_pdf: str, **kwargs):
    """Markdown → PDF（xelatex 経由・日本語対応）"""
    cmd = [
        "pandoc", input_md, "-o", output_pdf,
        "--pdf-engine=xelatex",
        "-V", "documentclass=article",
        "-V", f"geometry=margin={kwargs.get('margin', '2.5cm')}",
        "-V", f"fontsize={kwargs.get('fontsize', '11pt')}",
        "-V", f"CJKmainfont={kwargs.get('cjk_font', 'Noto Serif CJK JP')}",
        "-V", "lang=ja",
    ]
    if kwargs.get("toc"):
        cmd.append("--toc")
    if kwargs.get("number_sections"):
        cmd.append("--number-sections")

    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        return False
    return True


def md_to_html(input_md: str, output_html: str, css: str = None, title: str = ""):
    """Markdown → HTML（スタンドアロン）"""
    cmd = ["pandoc", input_md, "-o", output_html, "--standalone"]
    if title:
        cmd += ["--metadata", f"title={title}"]
    if css:
        cmd += ["--css", css]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def md_to_pdf_via_html(input_md: str, output_pdf: str, css: str = None):
    """Markdown → HTML → PDF（wkhtmltopdf 経由）"""
    tmp_html = "/tmp/_md_to_pdf_tmp.html"
    if not md_to_html(input_md, tmp_html, css=css):
        return False
    cmd = [
        "wkhtmltopdf", "--encoding", "utf-8",
        "--page-size", "A4",
        "--margin-top", "20mm", "--margin-bottom", "20mm",
        "--margin-left", "20mm", "--margin-right", "20mm",
        tmp_html, output_pdf
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0


def md_to_latex(input_md: str, output_tex: str):
    """Markdown → LaTeX（.tex ファイル）"""
    cmd = [
        "pandoc", input_md, "-o", output_tex,
        "--standalone",
        "-V", "CJKmainfont=Noto Serif CJK JP",
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0
```

---

## トラブルシューティング

### 日本語が文字化けする・表示されない

xelatex ルートで `CJKmainfont` を明示する:
```bash
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  -V CJKmainfont="Noto Serif CJK JP"
```

wkhtmltopdf ルートでフォントが表示されない場合は CSS で指定:
```css
body { font-family: "Noto Serif CJK JP", sans-serif; }
```

### `lmodern.sty` が見つからない

```bash
apt-get install -y lmodern
```

### `xeCJK.sty` が見つからない

```bash
apt-get install -y texlive-lang-cjk
```

### pandoc の LaTeX 変換で `! Emergency stop.` エラー

原因は不足パッケージが多い。以下をインストール:
```bash
apt-get install -y texlive-lang-cjk lmodern texlive-xetex
```

---

## 選択ガイド

| 目的 | 推奨ルート |
|------|-----------|
| 日本語文書 ＋ 数式 | Markdown → xelatex → PDF |
| デザイン重視・CSS制御 | Markdown → HTML → wkhtmltopdf → PDF |
| 学術論文・カスタム組版 | Markdown → LaTeX → xelatex → PDF |
| Web公開用 HTML | Markdown → pandoc → HTML |
| 簡易確認用 PDF | Markdown → wkhtmltopdf → PDF |
