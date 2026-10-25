import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/markup_margin_fields.dart';
import 'package:stockall/providers/theme_provider.dart';

void main() {
  testWidgets('MarkupMarginFields displays and calculates bidirectionally',
      (WidgetTester tester) async {
    final sellingController = TextEditingController(text: '');
    final costController = TextEditingController(text: '100');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkupMarginFields(
            sellingPriceController: sellingController,
            costPriceController: costController,
            theme: theme,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    if (find.byIcon(Icons.keyboard_arrow_down).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();
    }

    // Verify fields are present since cost is 100
    expect(find.text('Markup (%)'), findsOneWidget);
    expect(find.text('Margin (%)'), findsOneWidget);

    // Enter selling price of 150
    sellingController.text = '150';
    await tester.pumpAndSettle();

    // Markup should be 50, Margin should be 33.33
    expect(find.text('50'), findsOneWidget);
    expect(find.text('33.33'), findsOneWidget);

    // Now edit Markup to 100
    await tester.enterText(find.widgetWithText(TextFormField, '50'), '100');
    await tester.pumpAndSettle();

    // Selling price should now be 200 (100 * (1 + 100%))
    expect(sellingController.text, '200');
    // Margin should now be 50 ((200 - 100) / 200 = 50%)
    expect(find.text('50'), findsOneWidget);

    // Now edit Margin to 20
    await tester.enterText(find.widgetWithText(TextFormField, '50'), '20');
    await tester.pumpAndSettle();

    // Selling price should be 125 (100 / (1 - 0.20))
    expect(sellingController.text, '125');
  });

  testWidgets('MarkupMarginFields is hidden when cost price is empty or 0',
      (WidgetTester tester) async {
    final sellingController = TextEditingController(text: '150');
    final costController = TextEditingController(text: '');
    final theme = ThemeProvider();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MarkupMarginFields(
            sellingPriceController: sellingController,
            costPriceController: costController,
            theme: theme,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fields should be hidden
    expect(find.text('Markup (%)'), findsNothing);
    expect(find.text('Margin (%)'), findsNothing);

    // Update cost controller to 100
    costController.text = '100';
    await tester.pumpAndSettle();

    if (find.byIcon(Icons.keyboard_arrow_down).evaluate().isNotEmpty) {
      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pumpAndSettle();
    }

    // Now fields should become visible with calculated values
    expect(find.text('Markup (%)'), findsOneWidget);
    expect(find.text('Margin (%)'), findsOneWidget);
    expect(find.text('50'), findsOneWidget);
  });
}

