import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/buttons/printer_settings_button.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/providers/theme_provider.dart';

import '../report_export_fixtures.dart';

// Allows everything and does nothing: only the menu is under test.
class _AllowAll implements ReportExportBackend {
  @override
  bool isAllowed(BuildContext context, ReportPrintGate gate) => true;
  @override
  ExportContext exportContext() => testContext;
  @override
  RollPaper? savedPaper() => null;
  @override
  void logError(String action, Object error, StackTrace stack) {}
  @override
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  }) async {}
  @override
  Future<void> printA4(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async {}
  @override
  Future<ReportSaveResult> downloadPdf(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async => const ReportSaveResult(fileName: 'x.pdf', showSaved: false);
  @override
  Future<ReportSaveResult> exportExcel(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    String? splitId,
    required VoidCallback beforeUi,
  }) async => const ReportSaveResult(fileName: 'x.xlsx', showSaved: false);
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Size size = const Size(1800, 1000),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: Align(alignment: Alignment.topLeft, child: child),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late Directory dir;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('stockall_printer_button');
    Hive.init(dir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  testWidgets('every report export button shows Printer Settings', (
    tester,
  ) async {
    await _pump(
      tester,
      ReportExportButton(buildSpec: () => itemsSpec(sampleItems)),
    );
    expect(find.text('Export'), findsOneWidget);
    expect(find.text(printerSettingsLabel), findsOneWidget);
  });

  testWidgets('phones: the settings pill shows its icon only', (
    tester,
  ) async {
    await _pump(
      tester,
      ReportExportButton(buildSpec: () => itemsSpec(sampleItems)),
      size: const Size(400, 800),
    );
    expect(find.text('Export'), findsOneWidget);
    expect(find.text(printerSettingsLabel), findsNothing);
    expect(find.byTooltip(printerSettingsLabel), findsOneWidget);
  });

  testWidgets('icon-only export button: Printer Settings is in its menu', (
    tester,
  ) async {
    await _pump(
      tester,
      ReportExportButton(
        buildSpec: () => itemsSpec(sampleItems),
        iconOnly: true,
        label: 'Print Record',
        backend: _AllowAll(),
      ),
    );
    expect(find.text(printerSettingsLabel), findsNothing);
    expect(find.byTooltip(printerSettingsLabel), findsNothing);
    await tester.tap(find.byTooltip('Print Record'));
    await tester.pumpAndSettle();
    expect(find.text(printerSettingsLabel), findsOneWidget);
  });

  testWidgets('screens with their own settings button can hide it', (
    tester,
  ) async {
    await _pump(
      tester,
      ReportExportButton(
        buildSpec: () => itemsSpec(sampleItems),
        showPrinterSettings: false,
      ),
    );
    expect(find.text(printerSettingsLabel), findsNothing);
  });

  testWidgets('the button opens the Printer Settings panel', (tester) async {
    await _pump(tester, const PrinterSettingsButton());
    await tester.runAsync(() async {
      await tester.tap(find.text(printerSettingsLabel));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Receipt roll printer'), findsOneWidget);
  });
}
