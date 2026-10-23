import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/components/calculator_engine.dart';
import 'package:stockall/components/my_calculator.dart';
import 'package:stockall/components/my_calculator_desktop.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_mobile.dart';

void main() {
  test('Calculator widgets instantiate cleanly', () {
    expect(const MyCalculator(), isNotNull);
    expect(const MyCalculatorDesktop(), isNotNull);
    expect(
      const ItemHistoryMobile(productUuid: 'test', fromItemDetails: false),
      isNotNull,
    );
  });

  group('CalculatorEngine - Dot and decimal inputs', () {
    test(
      'entering 1 then . then 2 produces 1.2 without 1.0.',
      () {
        final engine = CalculatorEngine();
        engine.inputDigit('1');
        expect(engine.displayExpression, '1');
        engine.inputDot();
        expect(engine.displayExpression, '1.');
        engine.inputDigit('2');
        expect(engine.displayExpression, '1.2');

        // Subsequent dots should be ignored
        engine.inputDot();
        expect(engine.displayExpression, '1.2');
      },
    );

    test('entering dot initially produces 0.', () {
      final engine = CalculatorEngine();
      engine.inputDot();
      expect(engine.displayExpression, '0.');
      engine.inputDigit('5');
      expect(engine.displayExpression, '0.5');
    });

    test(
      'number formatting with commas preserves decimals and trailing dot',
      () {
        expect(
          CalculatorEngine.formatExpressionForDisplay('1.'),
          '1.',
        );
        expect(
          CalculatorEngine.formatExpressionForDisplay(
            '1.2',
          ),
          '1.2',
        );
        expect(
          CalculatorEngine.formatExpressionForDisplay(
            '1000.',
          ),
          '1,000.',
        );
        expect(
          CalculatorEngine.formatExpressionForDisplay(
            '1000.5',
          ),
          '1,000.5',
        );
        expect(
          CalculatorEngine.formatExpressionForDisplay(
            '1234567.89',
          ),
          '1,234,567.89',
        );
      },
    );
  });

  group('CalculatorEngine - Multi-element operations', () {
    test('2 + 3 + 5 - 10 evaluates to 0.0', () {
      final engine = CalculatorEngine();
      engine.inputDigit('2');
      engine.inputOperator('+');
      engine.inputDigit('3');
      engine.inputOperator('+');
      engine.inputDigit('5');
      engine.inputOperator('-');
      engine.inputDigit('1');
      engine.inputDigit('0');
      expect(engine.displayExpression, '2 + 3 + 5 - 10');
      engine.calculate();
      expect(engine.mainResult, 0.0);
      expect(engine.resultText, '0.0');
    });

    test('operator precedence: 10 - 2 * 3 = 4', () {
      final engine = CalculatorEngine();
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputOperator('-');
      engine.inputDigit('2');
      engine.inputOperator('X');
      engine.inputDigit('3');
      engine.calculate();
      expect(engine.mainResult, 4.0);
      expect(engine.resultText, '4.0');
    });

    test('chaining operations after equals', () {
      final engine = CalculatorEngine();
      engine.inputDigit('2');
      engine.inputOperator('+');
      engine.inputDigit('3');
      engine.calculate();
      expect(engine.mainResult, 5.0);

      // Now tap + 4 = 9
      engine.inputOperator('+');
      engine.inputDigit('4');
      engine.calculate();
      expect(engine.mainResult, 9.0);
    });
  });

  group(
    'CalculatorEngine - Brackets, Power of 2, Square Root',
    () {
      test('brackets: (2 + 3) * (5 - 10) = -25', () {
        final engine = CalculatorEngine();
        engine.inputLeftBracket();
        engine.inputDigit('2');
        engine.inputOperator('+');
        engine.inputDigit('3');
        engine.inputRightBracket();
        engine.inputOperator('X');
        engine.inputLeftBracket();
        engine.inputDigit('5');
        engine.inputOperator('-');
        engine.inputDigit('1');
        engine.inputDigit('0');
        engine.inputRightBracket();
        engine.calculate();
        expect(engine.mainResult, -25.0);
        expect(engine.resultText, '-25.0');
      });

      test('auto-closing brackets on calculate', () {
        final engine = CalculatorEngine();
        engine.inputLeftBracket();
        engine.inputDigit('2');
        engine.inputOperator('+');
        engine.inputDigit('3');
        // No closing bracket
        engine.calculate();
        expect(engine.mainResult, 5.0);
      });

      test('square root: √(9) = 3', () {
        final engine = CalculatorEngine();
        engine.inputSquareRoot();
        engine.inputDigit('9');
        engine.inputRightBracket();
        engine.calculate();
        expect(engine.mainResult, 3.0);
        expect(engine.resultText, '3.0');
      });

      test(
        'square root postfix wrapping: 9 -> √ -> √(9)',
        () {
          final engine = CalculatorEngine();
          engine.inputDigit('9');
          engine.inputSquareRoot();
          expect(engine.rawExpression, '√(9)');
          engine.calculate();
          expect(engine.mainResult, 3.0);
        },
      );

      test('power of 2: 5² = 25', () {
        final engine = CalculatorEngine();
        engine.inputDigit('5');
        engine.inputSquare();
        expect(engine.displayExpression, '5²');
        engine.calculate();
        expect(engine.mainResult, 25.0);
        expect(engine.resultText, '25.0');
      });

      test('power of 2 with brackets: (2 + 3)² = 25', () {
        final engine = CalculatorEngine();
        engine.inputLeftBracket();
        engine.inputDigit('2');
        engine.inputOperator('+');
        engine.inputDigit('3');
        engine.inputRightBracket();
        engine.inputSquare();
        expect(engine.rawExpression, '(2 + 3)²');
        engine.calculate();
        expect(engine.mainResult, 25.0);
      });

      test('combined: √(4² + 9) = 5', () {
        final engine = CalculatorEngine();
        engine.inputSquareRoot();
        engine.inputDigit('4');
        engine.inputSquare();
        engine.inputOperator('+');
        engine.inputDigit('9');
        engine.inputRightBracket();
        engine.calculate();
        expect(engine.mainResult, 5.0);
      });
    },
  );

  group('CalculatorEngine - Errors and Edge Cases', () {
    test('division by zero returns Cannot divide by 0', () {
      final engine = CalculatorEngine();
      engine.inputDigit('1');
      engine.inputDigit('0');
      engine.inputOperator('/');
      engine.inputDigit('0');
      engine.calculate();
      expect(engine.errorMessage, 'Cannot divide by 0');
      expect(engine.resultText, 'Cannot divide by 0');
    });

    test(
      'backspace deletes last character or operator',
      () {
        final engine = CalculatorEngine();
        engine.inputDigit('1');
        engine.inputDigit('2');
        engine.deleteAction();
        expect(engine.displayExpression, '1');

        engine.inputOperator('+');
        expect(engine.displayExpression, '1 + ');
        engine.deleteAction();
        expect(engine.displayExpression, '1');
      },
    );

    test('clear resets everything', () {
      final engine = CalculatorEngine();
      engine.inputDigit('5');
      engine.inputSquare();
      engine.calculate();
      engine.clear();
      expect(engine.rawExpression, '');
      expect(engine.displayExpression, '');
      expect(engine.mainResult, 0.0);
      expect(engine.resultText, '0.0');
    });
  });
}
