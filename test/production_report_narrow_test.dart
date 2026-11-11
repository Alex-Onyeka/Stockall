// Every Production Report page at a 360 px phone width: the toolbar
// behind "View", the filters panel, the period strip, the cards and the
// tab chips must lay out without overflowing.
//
// The app's font is loaded so text measures as it does on a device (the
// test font draws every glyph a full em wide).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_summary/components/production_summary_view.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_analysis_view.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_summary_view.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_view.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_items_view.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_summary/components/usage_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'production_report_fixtures.dart';

const appFont = 'Plus Jakarta Sans';

/// A long period label: the widest the period strip gets.
final october = ReceiptsReportPeriod.range(
  DateTime(2026, 10, 1),
  DateTime(2026, 10, 31),
);

ProductionStockEnv stockEnv(ProductionStockKind kind) =>
    fakeStockEnv(kind: kind, departmentsEnabled: true);

final Map<String, Widget Function()> pages = {
  'Production Records Table':
      () => ProductionRecordsTableView(
        isDesktop: false,
        initialPeriod: october,
        env: fakeRecordsEnv(records: sampleRecords(), departmentsEnabled: true),
      ),
  'Production Summary':
      () => ProductionSummaryView(
        isDesktop: false,
        initialPeriod: october,
        env: fakeRecordsEnv(records: sampleRecords(), departmentsEnabled: true),
      ),
  'Usage Records Table':
      () => UsageRecordsTableView(
        isDesktop: false,
        initialPeriod: october,
        env: fakeUsageEnv(
          usages: sampleUsages(),
          records: sampleRecords(),
          departmentsEnabled: true,
        ),
      ),
  'Usage Summary':
      () => UsageSummaryView(
        isDesktop: false,
        initialPeriod: october,
        env: fakeUsageEnv(
          usages: sampleUsages(),
          records: sampleRecords(),
          departmentsEnabled: true,
        ),
      ),
  for (final kind in ProductionStockKind.values) ...{
    '${kind.plural} Table':
        () => StockItemsView(
          isDesktop: false,
          kind: kind,
          initialPeriod: october,
          env: stockEnv(kind),
        ),
    '${kind.plural} Analysis':
        () => StockAnalysisView(
          isDesktop: false,
          kind: kind,
          initialPeriod: october,
          env: stockEnv(kind),
        ),
    '${kind.singular} History Table':
        () => StockHistoryView(
          isDesktop: false,
          kind: kind,
          initialPeriod: october,
          env: stockEnv(kind),
        ),
    '${kind.singular} History Summary':
        () => StockHistorySummaryView(
          isDesktop: false,
          kind: kind,
          initialPeriod: october,
          env: stockEnv(kind),
        ),
  },
};

Future<void> loadAppFont() async {
  final loader = FontLoader(appFont);
  for (final f in ['Regular', 'Bold']) {
    loader.addFont(rootBundle.load('assets/fonts/PlusJakartaSans-$f.ttf'));
  }
  await loader.load();
}

/// No overflow (or any other error) since the last check.
void expectClean(WidgetTester tester, String step) {
  final e = tester.takeException();
  expect(e, isNull, reason: '$step: $e');
}

Future<void> tapIfThere(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) return;
  await tester.ensureVisible(f.first);
  await tester.pumpAndSettle();
  await tester.tap(f.first, warnIfMissed: false);
  await tester.pumpAndSettle();
}

/// Scrolls every vertical scrollable to its end, so lazily built rows
/// and the pager are laid out too.
Future<void> scrollToEnd(WidgetTester tester) async {
  final vertical = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  for (var i = 0; i < vertical.evaluate().length; i++) {
    final state = tester.state<ScrollableState>(vertical.at(i));
    final p = state.position;
    p.jumpTo(p.maxScrollExtent);
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(loadAppFont);

  for (final entry in pages.entries) {
    testWidgets('${entry.key} at 360 px', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
          child: MaterialApp(
            theme: ThemeData(fontFamily: appFont),
            home: entry.value(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expectClean(tester, 'first frame');

      // The toolbar behind "View", then the filters panel.
      await tapIfThere(tester, find.text('View'));
      expectClean(tester, 'View');
      await tapIfThere(tester, find.textContaining('Filters'));
      expectClean(tester, 'Filters');

      // Every tab chip of an analysis or summary.
      final chips = find.byType(ChoiceChip);
      for (var i = 0; i < chips.evaluate().length; i++) {
        await tester.ensureVisible(chips.at(i));
        await tester.pumpAndSettle();
        await tester.tap(chips.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
        expectClean(tester, 'tab ${i + 1}');
      }

      await scrollToEnd(tester);
      expectClean(tester, 'scrolled to the end');
    });
  }
}
