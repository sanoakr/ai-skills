#!/usr/bin/env python3
"""
textlintのJSON出力を読みやすい日本語レポートに変換するスクリプト

使い方:
  python format_results.py <textlint_output.json>
  または
  textlint --format json <file> | python format_results.py -
"""

import json
import sys

# ルールIDを日本語説明に変換
RULE_DESCRIPTIONS = {
    "sentence-length": "1文が長すぎます",
    "max-ten": "読点「、」が多すぎます",
    "max-comma": "カンマ「,」が多すぎます",
    "no-mix-dearu-desumasu": "「です・ます調」と「だ・である調」が混在しています",
    "no-doubled-conjunction": "接続詞が連続しています",
    "no-doubled-conjunctive-particle-ga": "逆接の「が」が連続しています",
    "no-double-negative-ja": "二重否定が使われています",
    "no-dropping-the-ra": "ら抜き言葉が使われています",
    "no-doubled-joshi": "同じ助詞が連続しています",
    "ja-no-successive-word": "同じ単語が連続しています",
    "ja-no-abusage": "よくある誤用が含まれています",
    "ja-no-redundant-expression": "冗長な表現が含まれています",
    "ja-no-weak-phrase": "弱い表現（〜かもしれない等）が使われています",
    "no-nfd": "Mac由来の濁点エラーがあります（コピペ時の文字化け）",
    "no-zero-width-spaces": "ゼロ幅スペースが含まれています",
    "ja-no-mixed-period": "文末句点が統一されていません",
    "no-hankaku-kana": "半角カナが含まれています",
    "ja-unnatural-alphabet": "不自然なアルファベットの使い方があります",
    "no-invalid-control-character": "不正な制御文字が含まれています",
    "no-kangxi-radicals": "康煕部首の文字が含まれています（通常の漢字と異なる文字コード）",
    "arabic-kanji-numbers": "算用数字と漢数字の使い方が統一されていません",
    "no-parentheses-ja": "括弧の対応が正しくありません",
    "consecutive-cn": "連続した漢字が多すぎます",
}

SEVERITY_LABELS = {
    0: "情報",
    1: "⚠️ 警告",
    2: "❌ エラー",
}


def get_rule_description(rule_id):
    """プリセット付きのルールIDから短縮ルールIDを抽出して説明を返す"""
    # "preset-ja-technical-writing/no-dropping-the-ra" → "no-dropping-the-ra"
    short_id = rule_id.split("/")[-1]
    return RULE_DESCRIPTIONS.get(short_id, f"ルール違反（{short_id}）")


def format_results(data):
    """textlintのJSON出力を日本語レポートにフォーマット"""

    # data はリスト形式（各ファイルの結果）またはオブジェクト
    if isinstance(data, dict):
        data = [data]

    total_errors = 0
    total_warnings = 0
    report_lines = []

    for file_result in data:
        filepath = file_result.get("filePath", "（テキスト）")
        messages = file_result.get("messages", [])

        if not messages:
            report_lines.append(f"✅ **{filepath}**: 問題は見つかりませんでした")
            continue

        errors = [m for m in messages if m.get("severity", 1) == 2]
        warnings = [m for m in messages if m.get("severity", 1) == 1]

        total_errors += len(errors)
        total_warnings += len(warnings)

        filename = filepath.split("/")[-1]
        report_lines.append(f"\n## 校正結果: {filename}\n")
        report_lines.append(f"- 指摘件数: **{len(messages)}件**（エラー {len(errors)}件 / 警告 {len(warnings)}件）\n")
        report_lines.append("\n### 指摘一覧\n")

        for i, msg in enumerate(messages, 1):
            line = msg.get("line", "?")
            col = msg.get("column", "?")
            rule_id = msg.get("ruleId", "unknown")
            message = msg.get("message", "")
            severity = msg.get("severity", 1)

            # 問題箇所のテキスト取得
            fix = msg.get("fix")

            severity_label = SEVERITY_LABELS.get(severity, "情報")
            description = get_rule_description(rule_id)

            report_lines.append(f"**{i}. {severity_label}** — {line}行{col}列目")
            report_lines.append(f"- **問題**: {description}")
            report_lines.append(f"- **詳細**: {message}")
            report_lines.append(f"- **ルール**: `{rule_id}`")
            if fix:
                report_lines.append(f"- **自動修正可能**: あり")
            report_lines.append("")

    # サマリー
    if total_errors + total_warnings > 0:
        summary = f"\n---\n**合計: エラー {total_errors}件 / 警告 {total_warnings}件**"
        report_lines.insert(0, summary)

    return "\n".join(report_lines)


def main():
    if len(sys.argv) < 2 or sys.argv[1] == "-":
        raw = sys.stdin.read()
    else:
        with open(sys.argv[1], "r", encoding="utf-8") as f:
            raw = f.read()

    if not raw.strip():
        print("✅ 問題は見つかりませんでした")
        return

    try:
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"JSONの解析エラー: {e}")
        print("生の出力:")
        print(raw)
        sys.exit(1)

    report = format_results(data)
    print(report)


if __name__ == "__main__":
    main()
