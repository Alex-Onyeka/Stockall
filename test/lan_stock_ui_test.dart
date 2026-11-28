import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/components/alert_dialogues/stock_conflict_alert.dart';
import 'package:stockall/components/lan_stock_banner.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/remote/remote_client.dart';

/// The stock widgets: the stock conflict dialog at a phone and a desktop
/// width, and the "store server unreachable" banner of the sales pages.
void main() {
  const rows = [
    StockConflictRow(
      product: 'Rice 50kg',
      cart: 'Default 1 · Cart 2',
      wanted: '3 Bag(s)',
      available: '1 Bag(s)',
      mainCartId: 'm1',
      cartId: 'c2',
    ),
    StockConflictRow(
      product: 'Sugar',
      cart: 'Checked-out sale',
      wanted: '2 Unit(s)',
      available: '0 Unit(s)',
    ),
  ];

  Future<void> pumpAt(WidgetTester tester, double width, Widget home) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: home));
  }

  /// A page with a button that opens the dialog.
  Widget opener({VoidCallback? onGoToCart}) => Builder(
    builder:
        (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed:
                  () => showDialog<void>(
                    context: context,
                    builder:
                        (_) => StockConflictAlert(
                          theme: ThemeProvider(),
                          rows: rows,
                          onGoToCart: onGoToCart,
                        ),
                  ),
              child: const Text('open'),
            ),
          ),
        ),
  );

  group('StockConflictAlert', () {
    testWidgets('phone width: one card per product with its cart, wanted '
        'and available; Go to Cart then OK, stacked', (tester) async {
      var went = 0;
      await pumpAt(tester, 400, opener(onGoToCart: () => went++));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Stock Held by Other Tills'), findsOneWidget);
      expect(find.text('Rice 50kg'), findsOneWidget);
      expect(find.text('Default 1 · Cart 2'), findsOneWidget);
      expect(find.text('Wanted 3 Bag(s) · Available 1 Bag(s)'), findsOneWidget);
      expect(find.text('Checked-out sale'), findsOneWidget);
      // No table header on a phone.
      expect(find.text('Available'), findsNothing);
      final go = tester.getCenter(find.text('Go to Cart'));
      final ok = tester.getCenter(find.text('OK'));
      expect(go.dy, lessThan(ok.dy));

      await tester.tap(find.text('Go to Cart'));
      await tester.pumpAndSettle();
      expect(went, 1);
      expect(find.text('Stock Held by Other Tills'), findsNothing);
    });

    testWidgets('desktop width: a table with a header row; OK and Go to Cart '
        'side by side; OK closes it', (tester) async {
      var went = 0;
      await pumpAt(tester, 1400, opener(onGoToCart: () => went++));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      for (final header in ['Item', 'Cart', 'Wanted', 'Available']) {
        expect(find.text(header), findsOneWidget);
      }
      expect(find.text('Rice 50kg'), findsOneWidget);
      expect(find.text('3 Bag(s)'), findsOneWidget);
      expect(find.text('1 Bag(s)'), findsOneWidget);
      expect(find.text('Sugar'), findsOneWidget);
      final go = tester.getCenter(find.text('Go to Cart'));
      final ok = tester.getCenter(find.text('OK'));
      expect(go.dy, closeTo(ok.dy, 1));
      expect(ok.dx, lessThan(go.dx));

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(went, 0);
      expect(find.text('Stock Held by Other Tills'), findsNothing);
    });

    testWidgets('no cart to go to: OK only', (tester) async {
      await pumpAt(tester, 1400, opener());
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Go to Cart'), findsNothing);
      expect(find.text('OK'), findsOneWidget);
    });
  });

  group('LanStockBanner', () {
    tearDown(() => RemoteRouter.useSupabase());

    testWidgets('shown only while the store server is unreachable; the page '
        'under it keeps its state', (tester) async {
      RemoteRouter.useSupabase();
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: LanStockBanner(child: _Probe())),
        ),
      );
      expect(find.text(LanStockBanner.text), findsNothing);
      expect(LanStockBanner.salesPagesOpen, 1);

      RemoteRouter.useNothing();
      await tester.pump();
      expect(find.text(LanStockBanner.text), findsOneWidget);
      expect(find.text('page'), findsOneWidget);

      for (final away in [LanRoute.server, LanRoute.offLan]) {
        RemoteRouter.useSupabase(away);
        await tester.pump();
        expect(find.text(LanStockBanner.text), findsNothing);
      }
      // Built once: the banner coming and going didn't rebuild the page.
      expect(_Probe.inits, 1);

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      expect(LanStockBanner.salesPagesOpen, 0);
    });
  });
}

class _Probe extends StatefulWidget {
  const _Probe();

  static int inits = 0;

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _Probe.inits++;
  }

  @override
  Widget build(BuildContext context) => const Text('page');
}
