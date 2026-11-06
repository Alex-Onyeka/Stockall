import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'report_export_fixtures.dart';

class _Call {
  final String kind;
  final RollPaper? paper;
  final List<String?>? groupings;
  final String? splitId;

  const _Call(this.kind, {this.paper, this.groupings, this.splitId});
}

class _FakeBackend implements ReportExportBackend {
  final Set<ReportPrintGate> denied;
  Object? printError;
  Object? pdfError;
  bool showSaved;
  RollPaper? saved;
  final calls = <_Call>[];
  final logged = <String>[];

  _FakeBackend({this.denied = const {}, this.showSaved = true, this.saved});

  @override
  RollPaper? savedPaper() => saved;

  @override
  bool isAllowed(BuildContext context, ReportPrintGate gate) =>
      !denied.contains(gate);

  @override
  ExportContext exportContext() => testContext;

  @override
  void logError(String action, Object error, StackTrace stack) =>
      logged.add(action);

  @override
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  }) async {
    calls.add(_Call('print', paper: paper, groupings: groupings));
    if (printError != null) throw printError!;
  }

  @override
  Future<ReportSaveResult> downloadPdf(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async {
    calls.add(const _Call('pdf'));
    if (pdfError != null) throw pdfError!;
    return ReportSaveResult(
      fileName: reportExportFileName(spec, 'pdf', now: ctx.generatedAt),
      showSaved: showSaved,
    );
  }

  @override
  Future<ReportSaveResult> exportExcel(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    String? splitId,
    required VoidCallback beforeUi,
  }) async {
    calls.add(_Call('excel', splitId: splitId));
    return ReportSaveResult(
      fileName: reportExportFileName(spec, 'xlsx', now: ctx.generatedAt),
      showSaved: showSaved,
    );
  }
}

ReportExportSpec _noSplitSpec() => ReportExportSpec(
  reportName: 'General Report',
  fileSlug: 'general_report',
  sections: [
    ExportTableSection<TItem>(
      title: 'Items',
      rows: sampleItems,
      columns: [
        ExportColumn<TItem>(id: 'name', label: 'Item Name', value: (r) => r.name),
      ],
      roll: const RollLayout(cols58: ['name'], cols80: ['name']),
    ),
  ],
);

ReportExportSpec _oneSplitSpec() => ReportExportSpec(
  reportName: 'Items Report',
  fileSlug: 'items_report',
  sections: [
    ExportTableSection<TItem>(
      title: 'Items',
      rows: sampleItems,
      columns: [
        ExportColumn<TItem>(id: 'name', label: 'Item Name', value: (r) => r.name),
      ],
      splits: [
        categorySplit<TItem>(
          categoryIds: (r) => r.categories,
          names: categoryNames,
        ),
      ],
      roll: const RollLayout(cols58: ['name'], cols80: ['name']),
    ),
  ],
);

List<TItem> _rows(int n, {bool ownDepartment = false}) => [
  for (var i = 0; i < n; i++)
    TItem(
      id: '$i',
      name: 'Item $i',
      qty: 1,
      price: 1,
      total: 1,
      dept: ownDepartment ? 'dept-$i' : null,
    ),
];

/// 101 rows, each in its own group of the "dept" split.
ReportExportSpec _manyGroupsSpec() {
  final rows = _rows(101, ownDepartment: true);
  return ReportExportSpec(
    reportName: 'Items Report',
    fileSlug: 'items_report',
    sections: [
      ExportTableSection<TItem>(
        title: 'Items',
        rows: rows,
        columns: [
          ExportColumn<TItem>(id: 'name', label: 'Item Name', value: (r) => r.name),
        ],
        splits: [
          fieldSplit<TItem>(
            id: 'dept',
            label: 'Department',
            noneLabel: 'No Department',
            rows: rows,
            key: (r) => r.dept,
            name: (r) => r.dept,
          ),
        ],
        roll: const RollLayout(cols58: ['name'], cols80: ['name']),
      ),
    ],
  );
}

Future<void> _pump(
  WidgetTester tester, {
  required bool desktop,
  required _FakeBackend backend,
  ReportExportSpec Function()? spec,
}) async {
  tester.view.physicalSize =
      desktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ReportExportButton(
                buildSpec: spec ?? () => itemsSpec(sampleItems),
                backend: backend,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.text('Export'));
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.tap(find.text(text).last);
  await tester.pumpAndSettle();
}

MenuItemButton _menuItem(WidgetTester tester, String text) =>
    tester.widget<MenuItemButton>(
      find.ancestor(
        of: find.text(text),
        matching: find.byType(MenuItemButton),
      ),
    );

void main() {
  for (final desktop in [true, false]) {
    final size = desktop ? 'desktop' : 'mobile';

    group('ReportExportButton ($size)', () {
      testWidgets('shows the four entries', (tester) async {
        await _pump(tester, desktop: desktop, backend: _FakeBackend());
        await _openMenu(tester);
        expect(find.text('Print 80mm'), findsOneWidget);
        expect(find.text('Print 58mm'), findsOneWidget);
        expect(find.text('Download PDF'), findsOneWidget);
        expect(find.text('Export Excel'), findsOneWidget);
      });

      testWidgets('builds the spec only when the menu opens', (tester) async {
        var built = 0;
        await _pump(
          tester,
          desktop: desktop,
          backend: _FakeBackend(),
          spec: () {
            built++;
            return itemsSpec(sampleItems);
          },
        );
        expect(built, 0);
        await _openMenu(tester);
        expect(built, 1);
      });

      group('Excel options follow the spec splits', () {
        testWidgets('one sheet per category and per department', (
          tester,
        ) async {
          await _pump(tester, desktop: desktop, backend: _FakeBackend());
          await _openMenu(tester);
          await _tapText(tester, 'Export Excel');
          expect(find.text('All in one sheet'), findsOneWidget);
          expect(find.text('One sheet per Category'), findsOneWidget);
          expect(find.text('One sheet per Department'), findsOneWidget);
        });

        testWidgets('no splits: Excel and print are plain entries', (
          tester,
        ) async {
          final backend = _FakeBackend();
          await _pump(
            tester,
            desktop: desktop,
            backend: backend,
            spec: _noSplitSpec,
          );
          await _openMenu(tester);
          expect(_menuItem(tester, 'Export Excel').onPressed, isNotNull);
          expect(_menuItem(tester, 'Print 80mm').onPressed, isNotNull);
          await _tapText(tester, 'Export Excel');
          expect(find.text('All in one sheet'), findsNothing);
          expect(backend.calls.single.kind, 'excel');
          expect(backend.calls.single.splitId, isNull);
        });

        testWidgets('one split: no "All groupings" on print', (tester) async {
          await _pump(
            tester,
            desktop: desktop,
            backend: _FakeBackend(),
            spec: _oneSplitSpec,
          );
          await _openMenu(tester);
          await _tapText(tester, 'Print 80mm');
          expect(find.text('As shown'), findsOneWidget);
          expect(find.text('By Category'), findsOneWidget);
          expect(find.text('All groupings'), findsNothing);
        });
      });

      testWidgets('print gate off: print disabled, PDF and Excel still work', (
        tester,
      ) async {
        final backend = _FakeBackend(denied: {ReportPrintGate.receiptPrint});
        await _pump(tester, desktop: desktop, backend: backend);
        await _openMenu(tester);

        expect(_menuItem(tester, 'Print 80mm').onPressed, isNull);
        expect(_menuItem(tester, 'Print 58mm').onPressed, isNull);
        expect(find.text(reportExportNotOnPlan), findsNWidgets(2));
        expect(_menuItem(tester, 'Download PDF').onPressed, isNotNull);

        await tester.tap(find.text('Print 80mm'), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(backend.calls, isEmpty);

        await _tapText(tester, 'Download PDF');
        expect(backend.calls.map((c) => c.kind), ['pdf']);

        await _openMenu(tester);
        await _tapText(tester, 'Export Excel');
        await _tapText(tester, 'All in one sheet');
        expect(backend.calls.map((c) => c.kind), ['pdf', 'excel']);
      });

      testWidgets('a download gate, when set, disables PDF and Excel', (
        tester,
      ) async {
        final backend = _FakeBackend(denied: {ReportPrintGate.itemsReport});
        await _pump(
          tester,
          desktop: desktop,
          backend: backend,
          spec: () => ReportExportSpec(
            reportName: 'Items Report',
            fileSlug: 'items_report',
            sections: itemsSpec(sampleItems).sections,
            downloadGate: ReportPrintGate.itemsReport,
          ),
        );
        await _openMenu(tester);
        expect(_menuItem(tester, 'Download PDF').onPressed, isNull);
        expect(_menuItem(tester, 'Export Excel').onPressed, isNull);
        expect(find.text('Print 80mm'), findsOneWidget);
      });

      group('print confirmation', () {
        testWidgets('shows the record count; cancel prints nothing', (
          tester,
        ) async {
          final backend = _FakeBackend();
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Print 80mm');
          await _tapText(tester, 'As shown');

          expect(find.text('Print Report'), findsOneWidget);
          expect(
            find.textContaining('print 4 records on 80mm roll paper'),
            findsOneWidget,
          );
          expect(find.textContaining('long print'), findsNothing);

          await _tapText(tester, 'Cancel');
          expect(backend.calls, isEmpty);
        });

        testWidgets('warns above 500 records', (tester) async {
          await _pump(
            tester,
            desktop: desktop,
            backend: _FakeBackend(),
            spec: () => itemsSpec(_rows(501)),
          );
          await _openMenu(tester);
          await _tapText(tester, 'Print 58mm');
          await _tapText(tester, 'As shown');
          expect(find.textContaining('501 records'), findsOneWidget);
          expect(
            find.textContaining('This is a long print'),
            findsOneWidget,
          );
        });

        testWidgets('no rows: "No Matching Records" and no print', (
          tester,
        ) async {
          final backend = _FakeBackend();
          await _pump(
            tester,
            desktop: desktop,
            backend: backend,
            spec: () => itemsSpec(const []),
          );
          await _openMenu(tester);
          await _tapText(tester, 'Print 80mm');
          await _tapText(tester, 'As shown');
          expect(find.text('No Matching Records'), findsOneWidget);
          await _tapText(tester, 'OK');
          expect(backend.calls, isEmpty);
        });
      });

      group('choices reach the backend', () {
        Future<_FakeBackend> printWith(
          WidgetTester tester,
          String paper,
          String option,
        ) async {
          final backend = _FakeBackend();
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, paper);
          await _tapText(tester, option);
          await _tapText(tester, 'Print');
          return backend;
        }

        testWidgets('58mm as shown', (tester) async {
          final b = await printWith(tester, 'Print 58mm', 'As shown');
          expect(b.calls.single.paper, RollPaper.mm58);
          expect(b.calls.single.groupings, [null]);
        });

        testWidgets('80mm by category', (tester) async {
          final b = await printWith(tester, 'Print 80mm', 'By Category');
          expect(b.calls.single.paper, RollPaper.mm80);
          expect(b.calls.single.groupings, ['category']);
        });

        testWidgets('all groupings', (tester) async {
          final b = await printWith(tester, 'Print 80mm', 'All groupings');
          expect(b.calls.single.groupings, [null, 'category', 'department']);
        });

        testWidgets('Excel one sheet per department', (tester) async {
          final backend = _FakeBackend();
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Export Excel');
          await _tapText(tester, 'One sheet per Department');
          expect(backend.calls.single.kind, 'excel');
          expect(backend.calls.single.splitId, 'department');
        });
      });

      group('" · your printer" marks the saved paper width', () {
        testWidgets('80mm saved', (tester) async {
          await _pump(
            tester,
            desktop: desktop,
            backend: _FakeBackend(saved: RollPaper.mm80),
          );
          await _openMenu(tester);
          expect(find.text('Print 80mm · your printer'), findsOneWidget);
          expect(find.text('Print 58mm'), findsOneWidget);
          expect(find.text('Print 58mm · your printer'), findsNothing);
        });

        testWidgets('58mm saved', (tester) async {
          await _pump(
            tester,
            desktop: desktop,
            backend: _FakeBackend(saved: RollPaper.mm58),
          );
          await _openMenu(tester);
          expect(find.text('Print 58mm · your printer'), findsOneWidget);
          expect(find.text('Print 80mm'), findsOneWidget);
          expect(find.text('Print 80mm · your printer'), findsNothing);
        });

        testWidgets('nothing saved: neither is marked', (tester) async {
          await _pump(tester, desktop: desktop, backend: _FakeBackend());
          await _openMenu(tester);
          expect(find.textContaining('your printer'), findsNothing);
        });

        testWidgets('the marked entry still prints at its width', (
          tester,
        ) async {
          final backend = _FakeBackend(saved: RollPaper.mm58);
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Print 58mm · your printer');
          await _tapText(tester, 'As shown');
          await _tapText(tester, 'Print');
          expect(backend.calls.single.paper, RollPaper.mm58);
        });

        testWidgets('plain (no splits) entries are marked too', (
          tester,
        ) async {
          final backend = _FakeBackend(saved: RollPaper.mm80);
          await _pump(
            tester,
            desktop: desktop,
            backend: backend,
            spec: _noSplitSpec,
          );
          await _openMenu(tester);
          await _tapText(tester, 'Print 80mm · your printer');
          await _tapText(tester, 'Print');
          expect(backend.calls.single.paper, RollPaper.mm80);
        });
      });

      group('more than 100 groups', () {
        testWidgets('"Export One Sheet" exports without a split', (
          tester,
        ) async {
          final backend = _FakeBackend();
          await _pump(
            tester,
            desktop: desktop,
            backend: backend,
            spec: _manyGroupsSpec,
          );
          await _openMenu(tester);
          await _tapText(tester, 'Export Excel');
          await _tapText(tester, 'One sheet per Department');

          expect(find.text('Too Many Sheets'), findsOneWidget);
          expect(find.textContaining('101 sheets'), findsOneWidget);
          expect(backend.calls, isEmpty);

          await _tapText(tester, 'Export One Sheet');
          expect(backend.calls.single.kind, 'excel');
          expect(backend.calls.single.splitId, isNull);
        });

        testWidgets('cancel exports nothing', (tester) async {
          final backend = _FakeBackend();
          await _pump(
            tester,
            desktop: desktop,
            backend: backend,
            spec: _manyGroupsSpec,
          );
          await _openMenu(tester);
          await _tapText(tester, 'Export Excel');
          await _tapText(tester, 'One sheet per Department');
          await _tapText(tester, 'Cancel');
          expect(backend.calls, isEmpty);
        });
      });

      group('feedback', () {
        testWidgets('an error shows a snackbar and closes the overlay', (
          tester,
        ) async {
          final backend = _FakeBackend()..pdfError = StateError('boom');
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Download PDF');

          expect(
            find.text("Couldn't create the PDF. Please try again."),
            findsOneWidget,
          );
          expect(find.text('Preparing PDF…'), findsNothing);
          expect(find.byType(CircularProgressIndicator), findsNothing);
          expect(backend.logged, ['pdf']);
        });

        testWidgets('a print failure shows its own message', (tester) async {
          final backend = _FakeBackend()
            ..printError = const ReportExportException('Printer is offline.');
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Print 80mm');
          await _tapText(tester, 'As shown');
          await _tapText(tester, 'Print');
          expect(find.text('Printer is offline.'), findsOneWidget);
        });

        testWidgets('desktop/web saves show "Saved <file name>"', (
          tester,
        ) async {
          final backend = _FakeBackend(showSaved: true);
          await _pump(tester, desktop: desktop, backend: backend);
          final epoch = testContext.generatedAt.millisecondsSinceEpoch;

          await _openMenu(tester);
          await _tapText(tester, 'Download PDF');
          expect(
            find.text('Saved downloaded_items_report_$epoch.pdf'),
            findsOneWidget,
          );

          await _openMenu(tester);
          await _tapText(tester, 'Export Excel');
          await _tapText(tester, 'All in one sheet');
          expect(
            find.text('Saved downloaded_items_report_$epoch.xlsx'),
            findsOneWidget,
          );
        });

        testWidgets('mobile saves (share sheet) show no snackbar', (
          tester,
        ) async {
          final backend = _FakeBackend(showSaved: false);
          await _pump(tester, desktop: desktop, backend: backend);
          await _openMenu(tester);
          await _tapText(tester, 'Download PDF');
          expect(backend.calls.single.kind, 'pdf');
          expect(find.byType(SnackBar), findsNothing);
        });
      });
    });
  }
}
