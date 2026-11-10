"""calc_limit.py のテスト。実行: uv run python -m unittest discover -s tests"""
from __future__ import annotations

import sys
import unittest
from pathlib import Path

# -I（isolated）でも読めるよう、scripts ディレクトリを明示的に追加する
sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))
import calc_limit as calc  # noqa: E402

# 既存 Excel（ふるさと納税額計算_2026.xlsx）の値
SHEET_TAXABLE = 8_120_000
SHEET_FUTURES = 24_382_000
SHEET_DONATION = 715_500


class TestExcelParity(unittest.TestCase):
    """調整控除 2,500円・税率23% を与えると Excel と同じ値になること。"""

    def setUp(self) -> None:
        self.result = calc.compute(
            taxable_sogo=SHEET_TAXABLE,
            separate_5pct=SHEET_FUTURES,
            donation=SHEET_DONATION,
            adjustment=2_500,
            income_tax_rate=0.23,
        )

    def test_limit(self) -> None:
        self.assertEqual(self.result.limit, 611_949)  # Excel B24 = 611,949.33

    def test_special_rate(self) -> None:
        self.assertAlmostEqual(self.result.special_rate, 0.66517)

    def test_breakdown(self) -> None:
        b = self.result.breakdown
        self.assertAlmostEqual(b["income_tax_reduction"], 167_551.205, places=2)
        self.assertAlmostEqual(b["resident_basic"], 71_350)
        self.assertAlmostEqual(b["resident_special"], 405_720)
        self.assertAlmostEqual(b["net_burden"], 70_878.795, places=2)


class TestAdjustment(unittest.TestCase):
    def test_over_25m_is_zero(self) -> None:
        self.assertEqual(calc.adjustment_deduction(8_120_000, 32_000_000, 50_000), 0)

    def test_min_2500(self) -> None:
        self.assertEqual(calc.adjustment_deduction(8_120_000, 10_000_000, 50_000), 2_500)

    def test_under_2m(self) -> None:
        self.assertEqual(calc.adjustment_deduction(1_000_000, 1_500_000, 50_000), 2_500)
        self.assertEqual(calc.adjustment_deduction(30_000, 80_000, 50_000), 1_500)

    def test_auto_uses_zero_for_high_income(self) -> None:
        result = calc.compute(
            taxable_sogo=SHEET_TAXABLE, separate_5pct=SHEET_FUTURES,
            total_income=SHEET_TAXABLE + SHEET_FUTURES,
        )
        self.assertEqual(result.adjustment, 0)
        # 調整控除 0 だと Excel（2,500円）より上限が 752円 大きい
        self.assertEqual(result.limit, 612_701)


class TestMarginalRate(unittest.TestCase):
    def test_boundaries(self) -> None:
        self.assertEqual(calc.marginal_rate(6_949_999), 0.20)
        self.assertEqual(calc.marginal_rate(6_950_000), 0.23)
        self.assertEqual(calc.marginal_rate(8_999_999), 0.23)
        self.assertEqual(calc.marginal_rate(9_000_000), 0.33)

    def test_income_tax_table(self) -> None:
        # 国税庁 No.2260 速算表: 7,000,000円 × 23% − 636,000円
        self.assertEqual(calc.income_tax(7_000_000), 974_000)


class TestSeparateOnly(unittest.TestCase):
    def test_futures_only_coefficient(self) -> None:
        """先物のみ（所得税15%）: 上限 = 所得割額×26.779% + 2,000円（生駒市・渋谷区の表）。"""
        result = calc.compute(taxable_sogo=0, separate_5pct=10_000_000, adjustment=0)
        coef = result.special_cap / 0.2 * 0.26779 + 2_000
        self.assertAlmostEqual(result.limit, coef, delta=2)
        self.assertEqual(result.income_tax_rate, 0.15)


class TestBracketCrossing(unittest.TestCase):
    def test_exact_reduction_smaller_when_crossing(self) -> None:
        """課税所得 7,000,000円・寄附で 6,950,000円を割ると、概算より軽減が小さい。"""
        kwargs = dict(taxable_sogo=7_000_000, donation=252_000, adjustment=2_500,
                      income_tax_rate=0.23)
        rough = calc.compute(**kwargs)
        exact = calc.compute(**kwargs, income_tax_taxable=7_000_000)
        self.assertLess(exact.breakdown["income_tax_reduction"],
                        rough.breakdown["income_tax_reduction"])


if __name__ == "__main__":
    unittest.main()
