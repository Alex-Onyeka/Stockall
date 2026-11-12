// All Items: while items are selected, Back (app bar arrow or system
// back) clears the selection and stays on the page; otherwise Back
// leaves the page. Runs on the real page at mobile and desktop widths.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/products/total_products/total_products_page.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'all_items_test_env.dart';

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TotalProductsPage(theme: ThemeProvider()),
              ),
            );
          },
          child: const Text('Open All Items'),
        ),
      ),
    );
  }
}

final _backArrow = find.byIcon(Icons.arrow_back_ios_new_rounded);
final _allItemsPage = find.byType(TotalProductsPage);

Future<void> _openAllItems(WidgetTester tester, {required bool desktop}) async {
  await pumpAllItemsApp(tester, const _Launcher(), desktop: desktop);
  await tester.tap(find.text('Open All Items'));
  await settleAllItems(tester);
  expect(_allItemsPage, findsOneWidget);
}

Future<void> _select(WidgetTester tester) async {
  DataProvider().toggleIsSelectProduct(true);
  await settleAllItems(tester);
  expect(DataProvider().isSelectProducts, isTrue);
}

Future<void> _systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settleAllItems(tester);
}

Future<void> _tapBackArrow(WidgetTester tester) async {
  await tester.tap(_backArrow);
  await settleAllItems(tester);
}

void main() {
  setUpAll(() async {
    await setUpAllItemsEnvironment();
  });

  setUp(() {
    DataProvider().toggleIsSelectProduct(false);
  });

  tearDown(() async {
    DataProvider().toggleIsSelectProduct(false);
  });

  for (final desktop in [false, true]) {
    final size = desktop ? 'desktop' : 'mobile';

    group('All Items back ($size)', () {
      testWidgets('not selecting: the back arrow leaves the page', (
        tester,
      ) async {
        await _openAllItems(tester, desktop: desktop);

        await _tapBackArrow(tester);

        expect(_allItemsPage, findsNothing);
        // Let the page's floating button timer (5 s) finish.
        await tester.pump(const Duration(seconds: 6));
      });

      testWidgets('not selecting: system back leaves the page', (
        tester,
      ) async {
        await _openAllItems(tester, desktop: desktop);

        await _systemBack(tester);

        expect(_allItemsPage, findsNothing);
        await tester.pump(const Duration(seconds: 6));
      });

      testWidgets('selecting: the back arrow clears the selection', (
        tester,
      ) async {
        await _openAllItems(tester, desktop: desktop);
        await _select(tester);

        await _tapBackArrow(tester);

        expect(DataProvider().isSelectProducts, isFalse);
        expect(_allItemsPage, findsOneWidget);

        // The next back leaves the page.
        await _tapBackArrow(tester);
        expect(_allItemsPage, findsNothing);
        await tester.pump(const Duration(seconds: 6));
      });

      testWidgets('selecting: system back clears the selection', (
        tester,
      ) async {
        await _openAllItems(tester, desktop: desktop);
        await _select(tester);

        await _systemBack(tester);

        expect(DataProvider().isSelectProducts, isFalse);
        expect(_allItemsPage, findsOneWidget);

        await _systemBack(tester);
        expect(_allItemsPage, findsNothing);
        await tester.pump(const Duration(seconds: 6));
      });

      testWidgets(
        'selection cleared by provider code: back leaves at once',
        (tester) async {
          await _openAllItems(tester, desktop: desktop);
          await _select(tester);

          // As after a bulk action: cleared without the page's setState.
          DataProvider().toggleIsSelectProduct(false);
          await settleAllItems(tester);

          await _systemBack(tester);

          expect(_allItemsPage, findsNothing);
          await tester.pump(const Duration(seconds: 6));
        },
      );
    });
  }
}
