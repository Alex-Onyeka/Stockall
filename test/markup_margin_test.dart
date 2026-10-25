import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/constants/calculations.dart';

void main() {
  group('Markup and Margin Calculations', () {
    test('calculateMarkup correctly calculates markup percentage', () {
      expect(calculateMarkup(costPrice: 100, sellingPrice: 150), closeTo(50.0, 0.001));
      expect(calculateMarkup(costPrice: 100, sellingPrice: 100), closeTo(0.0, 0.001));
      expect(calculateMarkup(costPrice: 100, sellingPrice: 80), closeTo(-20.0, 0.001));
      expect(calculateMarkup(costPrice: 50, sellingPrice: 125), closeTo(150.0, 0.001));
      expect(calculateMarkup(costPrice: 0, sellingPrice: 100), isNull);
      expect(calculateMarkup(costPrice: -10, sellingPrice: 100), isNull);
    });

    test('calculateMargin correctly calculates margin percentage', () {
      expect(calculateMargin(costPrice: 100, sellingPrice: 200), closeTo(50.0, 0.001));
      expect(calculateMargin(costPrice: 100, sellingPrice: 125), closeTo(20.0, 0.001));
      expect(calculateMargin(costPrice: 100, sellingPrice: 100), closeTo(0.0, 0.001));
      expect(calculateMargin(costPrice: 100, sellingPrice: 80), closeTo(-25.0, 0.001));
      expect(calculateMargin(costPrice: 100, sellingPrice: 0), isNull);
      expect(calculateMargin(costPrice: 100, sellingPrice: -50), isNull);
    });

    test('calculateSellingPriceFromMarkup computes selling price correctly', () {
      expect(calculateSellingPriceFromMarkup(costPrice: 100, markup: 50), closeTo(150.0, 0.001));
      expect(calculateSellingPriceFromMarkup(costPrice: 100, markup: 0), closeTo(100.0, 0.001));
      expect(calculateSellingPriceFromMarkup(costPrice: 100, markup: -20), closeTo(80.0, 0.001));
      expect(calculateSellingPriceFromMarkup(costPrice: 0, markup: 50), isNull);
    });

    test('calculateSellingPriceFromMargin computes selling price correctly', () {
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: 50), closeTo(200.0, 0.001));
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: 20), closeTo(125.0, 0.001));
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: 0), closeTo(100.0, 0.001));
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: -25), closeTo(80.0, 0.001));
      // Margin >= 100 is impossible
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: 100), isNull);
      expect(calculateSellingPriceFromMargin(costPrice: 100, margin: 120), isNull);
      expect(calculateSellingPriceFromMargin(costPrice: 0, margin: 20), isNull);
    });

    test('Bidirectional consistency between Markup and Margin', () {
      const cost = 80.0;
      const targetMarkup = 25.0; // 25% markup
      final spFromMarkup = calculateSellingPriceFromMarkup(costPrice: cost, markup: targetMarkup)!;
      expect(spFromMarkup, closeTo(100.0, 0.001));

      final marginFromSp = calculateMargin(costPrice: cost, sellingPrice: spFromMarkup)!;
      expect(marginFromSp, closeTo(20.0, 0.001)); // (100 - 80) / 100 = 20%

      final spFromMargin = calculateSellingPriceFromMargin(costPrice: cost, margin: marginFromSp)!;
      expect(spFromMargin, closeTo(spFromMarkup, 0.001));
    });

    test('formatPercentage formats numbers cleanly without trailing zeros', () {
      expect(formatPercentage(25.0), '25');
      expect(formatPercentage(0.0), '0');
      expect(formatPercentage(25.5), '25.5');
      expect(formatPercentage(33.33333), '33.33');
      expect(formatPercentage(-10.0), '-10');
      expect(formatPercentage(-12.5), '-12.5');
    });
  });
}

