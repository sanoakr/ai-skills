#!/bin/bash
# textlint日本語校正環境のセットアップスクリプト
# /tmp/textlint-ja/ に環境を構築する

set -e

WORK_DIR="/tmp/textlint-ja"

echo "textlint日本語校正環境をセットアップしています..."

# ディレクトリ作成
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# package.json がなければ作成
if [ ! -f "package.json" ]; then
  cat > package.json << 'EOF'
{
  "name": "textlint-ja",
  "version": "1.0.0",
  "private": true
}
EOF
fi

# 必要なパッケージをインストール
echo "パッケージをインストール中..."
npm install --save-dev \
  textlint \
  textlint-rule-preset-ja-technical-writing \
  textlint-rule-preset-japanese \
  textlint-rule-preset-ja-spacing \
  2>&1

# .textlintrc.json を作成
cat > .textlintrc.json << 'EOF'
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
EOF

echo "セットアップ完了: $WORK_DIR"
echo "textlintバージョン: $(./node_modules/.bin/textlint --version)"
