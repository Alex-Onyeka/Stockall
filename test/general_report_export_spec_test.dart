import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart' show reportTrendBucketLabel;
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'general_report_view_test.dart'
    show day17, expectedFigures, fakeGeneralEnv, pumpReport;
import 'item_history_export_fixtures.dart' show testCtx;

final f = ExportFormatter(currency: '₦');

({GeneralReportFigures figures, GeneralReportChanges changes, GeneralReportTrend trend})
    screenOf({ReceiptsReportPeriod? period, bool profitVisible = true}) {
  final p = period ?? day17;
  final figures = expectedFigures(period: p, profitVisible: profitVisible);
  final prev = GeneralReportPeriods.previous(p);
  return (
    figures: figures,
    changes: GeneralReportChanges.between(
      figures,
      prev == null ? null : expectedFigures(period: prev, profitVisible: profitVisible),
    ),
    trend: GeneralReportTrendBuilder.build(
      receiptRows: figures.receiptRows,
      expenses: figures.expenses,
      period: p,
      profitVisible: profitVisible,
      now: DateTime(2026, 10, 17, 18),
    ),
  );
}

ReportExportSpec specFor({ReceiptsReportPeriod? period, bool profitVisible = true}) {
  final s = screenOf(period: period, profitVisible: profitVisible);
  return generalReportExportSpec(
    figures: s.figures,
    changes: s.changes,
    trend: s.trend,
    period: period ?? day17,
    currency: '₦',
  );
}

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

ResolvedTable table(ReportExportSpec s, String prefix) =>
    resolved(s).tables.firstWhere((t) => t.title.startsWith(prefix));

/// Metric label → (value, change text) of a section table.
Map<String, (Object?, String)> rowsOf(ResolvedTable t) => {
  for (final r in t.rows)
    r[t.indexOf('metric')].text: (r[t.indexOf('value')].raw, r[t.indexOf('change')].text),
};

void main() {
  group('sections', () {
    test('Money In, Money Out, Profit and the trend; no charts, no splits', () {
      final spec = specFor();
      expect(spec.sections.map((s) => s.title.split(' (').first), [
        'Money In',
        'Money Out',
        'Profit',
        'Trend',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(spec.fileSlug, 'general_report');
      expect(spec.period!.label, 'Oct 17, 2026');
    });

    test('profit figures only with manageCostPrice', () {
      final spec = specFor(profitVisible: false);
      expect(spec.sections.map((s) => s.title.split(' (').first), [
        'Money In',
        'Money Out',
        'Trend',
      ]);
      expect(rowsOf(table(spec, 'Money In')).keys, ['Total Revenue']);
      final trend = table(spec, 'Trend');
      expect(trend.indexOf('grossProfit'), -1);
      expect(trend.indexOf('netProfit'), -1);
    });
  });

  group('figures and changes', () {
    test('metrics equal GeneralReportFigures, changes equal GeneralReportChanges', () {
      final s = screenOf();
      final spec = specFor();
      final moneyIn = rowsOf(table(spec, 'Money In'));
      final moneyOut = rowsOf(table(spec, 'Money Out'));
      final profit = rowsOf(table(spec, 'Profit'));
      String change(GeneralReportChange? c) => generalReportChangeText(c!, f.money);
      expect(moneyIn['Total Revenue'], (s.figures.totalRevenue, change(s.changes.revenue)));
      expect(moneyIn['Gross Profit'], (s.figures.grossProfit, change(s.changes.grossProfit)));
      expect(moneyOut['Total Purchases'], (s.figures.totalPurchases, change(s.changes.purchases)));
      expect(moneyOut['Total Expenses'], (s.figures.totalExpenses, change(s.changes.expenses)));
      expect(profit['Gross Profit'], moneyIn['Gross Profit']);
      expect(profit['Net Profit'], (s.figures.netProfit, change(s.changes.netProfit)));
      expect(moneyIn['Total Revenue']!.$2, endsWith(' vs previous period'));
    });

    test('the card\'s change text, and none for All time', () {
      expect(
        generalReportChangeText(const GeneralReportChange(GeneralReportChangeKind.percent, 12.5), f.money),
        '▲ 12.5% vs previous period',
      );
      expect(
        generalReportChangeText(const GeneralReportChange(GeneralReportChangeKind.amount, -500), f.money),
        '▼ ₦500.00 vs previous period',
      );
      expect(
        generalReportChangeText(const GeneralReportChange(GeneralReportChangeKind.percent, 0), f.money),
        '– 0.0% vs previous period',
      );
      final all = specFor(period: const ReceiptsReportPeriod.allTime());
      for (final (_, change) in rowsOf(table(all, 'Money In')).values) {
        expect(change, '');
      }
    });

    test('the trend rows are GeneralReportTrend', () {
      final s = screenOf();
      final t = table(specFor(), 'Trend');
      expect(t.rows, hasLength(s.trend.points.length));
      expect(
        [for (final r in t.rows) r[t.indexOf('period')].text],
        [for (final p in s.trend.points) reportTrendBucketLabel(s.trend.interval, p.start)],
      );
      expect(
        [for (final r in t.rows) r[t.indexOf('revenue')].raw],
        [for (final p in s.trend.points) p.revenue],
      );
      expect(
        [for (final r in t.rows) r[t.indexOf('netProfit')].raw],
        [for (final p in s.trend.points) p.netProfit],
      );
    });
  });

  group('notes', () {
    test('cost-missing, no-item-data and All time notes from the screen function', () {
      final s = screenOf();
      expect(s.figures.costMissingCount, greaterThan(0));
      expect(s.figures.noItemDataCount, greaterThan(0));
      final spec = specFor();
      expect(spec.notes, generalReportNotes(s.figures));
      expect(spec.notes, [
        'Cost missing on ${s.figures.costMissingCount} receipt${s.figures.costMissingCount == 1 ? '' : 's'}: '
            'counted as 0 in gross profit.',
        '${s.figures.noItemDataCount} receipt${s.figures.noItemDataCount == 1 ? ' has' : 's have'} '
            'no item data: left out of gross profit.',
      ]);
      // Without cost access the profit notes go, as on screen.
      expect(specFor(profitVisible: false).notes, isEmpty);
      final all = specFor(period: const ReceiptsReportPeriod.allTime());
      expect(all.notes.first, 'All time covers the data loaded on this device.');
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.join('\n'));
    });
  });

  group('roll', () {
    String preview(RollPaper paper) =>
        renderRollEscPos(buildRollLines(specFor(), testCtx, paper: paper), paper).preview;

    test('58mm: Metric · Value', () {
      final s = screenOf();
      final out = preview(RollPaper.mm58).split('\n');
      expect(
        out.firstWhere((l) => l.startsWith('Total Revenue')),
        endsWith(f.money(s.figures.totalRevenue).replaceAll('₦', 'N')),
      );
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 32), isTrue);
    });

    test('80mm: Metric · Value · Change (short, printable)', () {
      final s = screenOf();
      final out = preview(RollPaper.mm80).split('\n');
      final revenue = out.firstWhere((l) => l.startsWith('Total Revenue'));
      expect(revenue, contains(f.money(s.figures.totalRevenue).replaceAll('₦', 'N')));
      expect(
        revenue,
        endsWith(generalReportChangeShort(s.changes.revenue!, f).replaceAll('₦', 'N')),
      );
      expect(revenue, isNot(contains('?')));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('General Report screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReport(tester, isDesktop: desktop, env: fakeGeneralEnv());
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
