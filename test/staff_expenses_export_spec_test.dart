import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'staff_expenses_table_test.dart' show expensesBase, sampleExpenses, table;
import 'staff_report_fixtures.dart';

ReportExportSpec specFor({
  StaffReportAccess? access,
  StaffExpensesFilters? filters,
  ReceiptsReportPeriod period = allTime,
  List<StaffExpenseRow>? rows,
}) {
  final a = access ?? staffAccess();
  final f = filters ?? StaffExpensesFilters();
  return staffExpensesExportSpec(
    staffName: 'Ada Obi',
    rows: rows ?? table(base: expensesBase(access: a), filters: f, period: period),
    filters: f,
    sortField: StaffExpensesSortField.createdAt,
    ascending: false,
    departmentsEnabled: a.departmentsEnabled,
    period: period,
    currency: '₦',
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  final depts = staffAccess(departmentsEnabled: true);

  group('rows are the screen query, every page', () {
    test('150 expenses: every row, in the screen order', () {
      final base = buildStaffBase(
        expenses: [
          for (var i = 0; i < 150; i++)
            testExpense(
              uuid: 'e-$i',
              amount: 1.0 + i,
              createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            ),
        ],
      );
      final rows = table(base: base);
      final t = tableOf(specFor(rows: rows));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('amount')].raw], [for (final r in rows) r.amount]);
      expect(StaffExpensesTable.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('columns and cells', () {
    test('as on screen; Department only with departments on', () {
      expect([for (final c in tableOf(specFor(access: depts)).columns) c.label], [
        'Date',
        'Time',
        'Name',
        'Description',
        'Quantity',
        'Amount',
        'Department',
      ]);
      expect(tableOf(specFor()).indexOf('department'), -1);
    });

    test('quantity with unit, blanks "—", undated last', () {
      final t = tableOf(specFor(access: depts));
      final fuel = t.rows.firstWhere((r) => r[t.indexOf('title')].text == 'Fuel');
      expect(fuel[t.indexOf('quantity')].text, '20 litres');
      expect(fuel[t.indexOf('description')].text, 'Generator diesel');
      final rent = t.rows.firstWhere((r) => r[t.indexOf('title')].text == 'Rent');
      expect(rent[t.indexOf('quantity')].text, '—');
      expect(rent[t.indexOf('description')].text, '—');
      final old = t.rows.last;
      expect(old[t.indexOf('title')].text, 'Old');
      expect(old[t.indexOf('date')].text, '—');
      expect(old[t.indexOf('department')].text, '—');
    });
  });

  group('totals', () {
    test('equal the StaffExpensesTotals the screen shows', () {
      final rows = table();
      final t0 = StaffExpensesTable.paginate(rows, 1).totals;
      final t = tableOf(specFor());
      expect(t.totals![t.indexOf('title')].text, '${t0.count} expenses');
      expect(t.totals![t.indexOf('amount')].raw, t0.amount);
      expect(t0.amount, 1355);
      expect(sampleExpenses.where((e) => e.userId == 'staff-a'), hasLength(4));
    });
  });

  group('splits', () {
    test('by Department with departments on, "No Department" last; none otherwise', () {
      expect(specFor().splitOptions, isEmpty);
      final spec = specFor(access: depts);
      expect(spec.splitOptions.map((s) => s.id), ['department']);
      final names = [
        for (final g in resolveGroups(spec.tables.single, 'department', ExportFormatter(currency: '₦')))
          g.name,
      ];
      expect(names, ['Bar', 'Kitchen', 'No Department']);
    });
  });

  group('info box and notes', () {
    test('the staff, filters and sort', () {
      final spec = specFor(filters: StaffExpensesFilters(search: 'fu', amountMax: 500));
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Staff: Ada Obi',
        'Search: fu',
        'Amount: Any - ₦500.00',
      ]);
      expect(spec.sortedBy, 'Date (descending)');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor();
      expect(all.notes, ['All time covers the data loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      expect(specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17))).notes, isEmpty);
    });
  });

  group('roll', () {
    String preview(RollPaper paper) =>
        renderRollEscPos(buildRollLines(specFor(), testCtx, paper: paper), paper).preview;

    test('58mm: Name · Amount, date underneath', () {
      final out = preview(RollPaper.mm58).split('\n');
      final i = out.indexWhere((l) => l.startsWith('Rent'));
      expect(out[i], endsWith('N1,000.00'));
      expect(out[i + 1].trim(), 'Oct 18, 2026');
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Name · Description · Amount', () {
      final out = preview(RollPaper.mm80).split('\n');
      final fuel = out.firstWhere((l) => l.startsWith('Fuel'));
      expect(fuel, contains('Generator diesel'));
      expect(fuel, endsWith('N300.00'));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('Staff Expenses screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpStaffExpenses opens "View" on mobile.
        await pumpStaffExpenses(
          tester,
          isDesktop: desktop,
          env: fakeStaffEnv(expenses: sampleExpenses),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
