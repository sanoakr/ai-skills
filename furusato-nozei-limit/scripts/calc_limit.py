#!/usr/bin/env python3
"""ふるさと納税の控除上限額と控除内訳を計算する（標準ライブラリのみ）。

計算式の根拠は ../references/sources.md を参照。
使い方: uv run python calc_limit.py --taxable-sogo 8120000 --separate-5pct 24382000 --donation 245000
"""
from __future__ import annotations

import argparse
import json
import math
import sys
from dataclasses import dataclass, field

# ---- 定数（根拠は references/sources.md） ----
SELF_PAY = 2_000  # 自己負担額
BASIC_RATE = 0.10  # 住民税 基本控除率
SPECIAL_CAP_RATE = 0.20  # 特例控除の上限（調整控除後の所得割額に対する割合）
RESIDENT_RATE_SOGO = 0.10  # 住民税 所得割（総合課税）
RESIDENT_RATE_SEPARATE = 0.05  # 住民税 所得割（株式等・先物の申告分離）
RECON_FACTOR = 1.021  # 復興特別所得税込みの係数（令和9年以降も合計税率は同じ）
SEPARATE_INCOME_TAX_RATE = 0.15  # 申告分離（先物等）の所得税率
ADJ_MIN = 2_500  # 調整控除の最低額（課税総所得 200万円超の場合）
ADJ_RATE = 0.05  # 調整控除の率
ADJ_THRESHOLD = 2_000_000  # 調整控除の計算式が切り替わる課税所得
ADJ_TOTAL_INCOME_LIMIT = 25_000_000  # 合計所得金額がこれを超えると調整控除なし
DEFAULT_JINTEKI_DIFF = 50_000  # 人的控除差（基礎控除のみ）
BRACKET_WARN_MARGIN = 300_000  # 税率区分の境界までの余裕がこれ未満なら警告
SAFE_UNIT = 1_000  # 安全側に丸める単位

# 所得税の速算表: (課税所得の下限, 税率, 控除額)
INCOME_TAX_BRACKETS: list[tuple[int, float, int]] = [
    (0, 0.05, 0),
    (1_950_000, 0.10, 97_500),
    (3_300_000, 0.20, 427_500),
    (6_950_000, 0.23, 636_000),
    (9_000_000, 0.33, 1_536_000),
    (18_000_000, 0.40, 2_796_000),
    (40_000_000, 0.45, 4_796_000),
]


def _bracket_index(taxable: int) -> int:
    """課税所得（千円未満切捨て）が属する速算表の行番号を返す。"""
    floored = max(taxable, 0) // 1000 * 1000
    index = 0
    for i, (lower, _rate, _ded) in enumerate(INCOME_TAX_BRACKETS):
        if floored >= lower:
            index = i
    return index


def income_tax(taxable: int) -> float:
    """速算表による所得税額（復興特別所得税を含まない）。"""
    floored = max(taxable, 0) // 1000 * 1000
    _lower, rate, ded = INCOME_TAX_BRACKETS[_bracket_index(floored)]
    return floored * rate - ded


def marginal_rate(base: int) -> float:
    """限界税率を返す。base は『住民税の課税総所得 − 人的控除差調整額』。"""
    return INCOME_TAX_BRACKETS[_bracket_index(base)][1]


def adjustment_deduction(
    taxable_sogo: int, total_income: int | None, jinteki_diff: int
) -> int:
    """住民税の調整控除額（市民税+県民税の合計）を求める。

    total_income（合計所得金額）が 2,500万円超なら 0。None の場合は判定しない。
    """
    if total_income is not None and total_income > ADJ_TOTAL_INCOME_LIMIT:
        return 0
    if taxable_sogo <= 0:
        return 0
    if taxable_sogo <= ADJ_THRESHOLD:
        return math.floor(min(jinteki_diff, taxable_sogo) * ADJ_RATE)
    value = math.floor((jinteki_diff - (taxable_sogo - ADJ_THRESHOLD)) * ADJ_RATE)
    return max(value, ADJ_MIN)


@dataclass
class Result:
    """計算結果。"""

    income_tax_rate: float
    special_rate: float
    resident_tax_sogo: int
    resident_tax_separate: int
    resident_tax_total: int
    adjustment: int
    special_cap: float
    limit: int
    limit_safe: int
    breakdown: dict[str, float] | None = None
    warnings: list[str] = field(default_factory=list)


def compute(
    taxable_sogo: int,
    separate_5pct: int = 0,
    donation: int | None = None,
    total_income: int | None = None,
    jinteki_diff: int = DEFAULT_JINTEKI_DIFF,
    adjustment: int | None = None,
    income_tax_rate: float | None = None,
    rate_adjust: int = 0,
    income_tax_taxable: int | None = None,
) -> Result:
    """控除上限額（全額控除の目安）と、donation 指定時は控除内訳を計算する。"""
    warnings: list[str] = []

    # 所得税の限界税率（総務省: 住民税の課税総所得 − 人的控除差調整額 で判定）
    if income_tax_rate is not None:
        rate = income_tax_rate
    elif taxable_sogo <= 0:
        rate = SEPARATE_INCOME_TAX_RATE if separate_5pct > 0 else 0.0
        if separate_5pct > 0:
            warnings.append("課税総所得なし: 申告分離のみとして所得税率15%で計算")
    else:
        base = taxable_sogo - rate_adjust
        rate = marginal_rate(base)
        idx = _bracket_index(base)
        if idx + 1 < len(INCOME_TAX_BRACKETS):
            upper = INCOME_TAX_BRACKETS[idx + 1][0]
            if upper - base < BRACKET_WARN_MARGIN:
                warnings.append(
                    f"次の税率区分（{upper:,}円）まで {upper - base:,}円。"
                    "所得が増えると限界税率が上がり、上限額が下がる"
                )
        lower = INCOME_TAX_BRACKETS[idx][0]
        if idx > 0 and base - lower < BRACKET_WARN_MARGIN:
            warnings.append(
                f"税率区分の下限（{lower:,}円）まで {base - lower:,}円。"
                "寄附金控除で課税所得が区分を跨ぐ場合、所得税の軽減は概算より小さくなる"
            )
        if rate_adjust == 0:
            warnings.append(
                "人的控除差調整額が 0 の前提。所得税率の判定に影響する場合は "
                "--rate-adjust で指定する（references/sources.md 参照）"
            )

    special_rate = 1 - BASIC_RATE - rate * RECON_FACTOR

    tax_sogo = math.floor(max(taxable_sogo, 0) * RESIDENT_RATE_SOGO)
    tax_separate = math.floor(max(separate_5pct, 0) * RESIDENT_RATE_SEPARATE)
    tax_total = tax_sogo + tax_separate

    if adjustment is None:
        adj = adjustment_deduction(taxable_sogo, total_income, jinteki_diff)
        if total_income is None:
            warnings.append(
                "合計所得金額が未指定のため 2,500万円超の調整控除なし判定をしていない。"
                "決定通知書の調整控除額があれば --adjustment で指定する"
            )
    else:
        adj = adjustment

    cap = max(tax_total - adj, 0) * SPECIAL_CAP_RATE
    limit_raw = cap / special_rate + SELF_PAY if cap > 0 else 0.0
    limit = math.floor(limit_raw)
    limit_safe = limit // SAFE_UNIT * SAFE_UNIT

    breakdown: dict[str, float] | None = None
    if donation is not None:
        effective = max(donation - SELF_PAY, 0)
        if income_tax_taxable is not None:
            before = income_tax(income_tax_taxable)
            after = income_tax(income_tax_taxable - effective)
            reduction = (before - after) * RECON_FACTOR
        else:
            reduction = effective * rate * RECON_FACTOR
        basic = effective * BASIC_RATE
        special_uncapped = effective * special_rate
        special = min(special_uncapped, cap)
        total = reduction + basic + special
        breakdown = {
            "income_tax_reduction": reduction,
            "resident_basic": basic,
            "resident_special": special,
            "total_deduction": total,
            "net_burden": donation - total,
            "excess_burden": donation - total - SELF_PAY,
            "headroom": limit - donation,
        }
        if donation > limit:
            warnings.append(f"寄附額が上限を {donation - limit:,}円 超過")

    return Result(
        income_tax_rate=rate,
        special_rate=special_rate,
        resident_tax_sogo=tax_sogo,
        resident_tax_separate=tax_separate,
        resident_tax_total=tax_total,
        adjustment=adj,
        special_cap=cap,
        limit=limit,
        limit_safe=limit_safe,
        breakdown=breakdown,
        warnings=warnings,
    )


def _format(result: Result) -> str:
    """人間向けの出力を組み立てる。"""
    lines = [
        f"所得税の限界税率        : {result.income_tax_rate:.0%}",
        f"特例控除率              : {result.special_rate:.5f}",
        f"住民税所得割（総合）    : {result.resident_tax_sogo:,}円",
        f"住民税所得割（分離5%）  : {result.resident_tax_separate:,}円",
        f"住民税所得割 合計       : {result.resident_tax_total:,}円",
        f"調整控除                : {result.adjustment:,}円",
        f"特例控除の上限（20%）   : {result.special_cap:,.0f}円",
        f"控除上限額（目安）      : {result.limit:,}円",
        f"  〃 千円未満切捨て（推奨）: {result.limit_safe:,}円",
    ]
    if result.breakdown is not None:
        b = result.breakdown
        lines += [
            "--- 控除の内訳 ---",
            f"所得税の軽減            : {b['income_tax_reduction']:,.0f}円",
            f"住民税 基本控除         : {b['resident_basic']:,.0f}円",
            f"住民税 特例控除         : {b['resident_special']:,.0f}円",
            f"控除合計                : {b['total_deduction']:,.0f}円",
            f"実質自己負担            : {b['net_burden']:,.0f}円",
            f"2,000円超過分（損）     : {b['excess_burden']:,.0f}円",
            f"上限までの残り          : {b['headroom']:,.0f}円",
        ]
    for message in result.warnings:
        lines.append(f"[注意] {message}")
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    """CLI エントリポイント。"""
    parser = argparse.ArgumentParser(description="ふるさと納税 控除上限額の計算")
    parser.add_argument("--taxable-sogo", type=int, required=True, help="住民税の課税総所得金額")
    parser.add_argument("--separate-5pct", type=int, default=0, help="株式等・先物など住民税5%%の分離課税所得")
    parser.add_argument("--donation", type=int, help="寄附額（内訳を計算する場合）")
    parser.add_argument("--total-income", type=int, help="合計所得金額（調整控除の2,500万円超判定用）")
    parser.add_argument("--jinteki-diff", type=int, default=DEFAULT_JINTEKI_DIFF, help="人的控除差の合計（既定: 基礎控除のみ5万円）")
    parser.add_argument("--adjustment", type=int, help="調整控除額（決定通知書の値。指定時は自動計算しない）")
    parser.add_argument("--income-tax-rate", type=float, help="所得税の限界税率を直接指定（例 0.23）")
    parser.add_argument("--rate-adjust", type=int, default=0, help="人的控除差調整額（所得税率の判定用）")
    parser.add_argument("--income-tax-taxable", type=int, help="所得税の課税総所得（寄附前）。指定時は税率区分を跨ぐ軽減額を厳密計算")
    parser.add_argument("--json", action="store_true", help="JSON で出力")
    args = parser.parse_args(argv)

    result = compute(
        taxable_sogo=args.taxable_sogo,
        separate_5pct=args.separate_5pct,
        donation=args.donation,
        total_income=args.total_income,
        jinteki_diff=args.jinteki_diff,
        adjustment=args.adjustment,
        income_tax_rate=args.income_tax_rate,
        rate_adjust=args.rate_adjust,
        income_tax_taxable=args.income_tax_taxable,
    )
    if args.json:
        print(json.dumps(result.__dict__, ensure_ascii=False, indent=2))
    else:
        print(_format(result))
    return 0


if __name__ == "__main__":
    sys.exit(main())
