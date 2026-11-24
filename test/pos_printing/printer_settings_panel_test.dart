import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_sources.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';
import 'package:stockall/services/pos_printing/printer_settings_panel.dart';

const _hp = Printer(url: 'HP_LaserJet', name: 'HP LaserJet', isDefault: true);
const _canon = Printer(url: 'Canon_G3010', name: 'Canon G3010');

// Stands in for the Bluetooth/installed/network lists.
Widget _fakeSources(
  PosPrinterConfig? current,
  ValueChanged<PosPrinterChoice> onPick,
) => TextButton(
  key: const ValueKey('fake-roll-printer'),
  onPressed:
      () => onPick((
        transport: PosTransport.network,
        address: '192.168.1.50',
        name: '192.168.1.50:9100',
        port: 9100,
      )),
  child: const Text('Fake roll printer'),
);

Future<void> _pumpPanel(
  WidgetTester tester, {
  required PosPlatform platform,
  PrinterSettingsFocus focus = PrinterSettingsFocus.roll,
  int? shopPrintType,
}) async {
  await tester.runAsync(() => PrinterSettingsProvider().load());
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PrinterSettingsPanel(
              platform: platform,
              focus: focus,
              shopPrintType: shopPrintType,
              listA4Printers: () async => const [_hp, _canon],
              rollSourcesBuilder: _fakeSources,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

// Taps, lets Hive write, then redraws.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.runAsync(() async {
    await tester.tap(finder);
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });
  await tester.pumpAndSettle();
}

void main() {
  late Directory dir;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('stockall_printer_panel');
    Hive.init(dir.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(PosPrinterStore.boxName)) {
      await Hive.box(PosPrinterStore.boxName).clear();
    }
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  testWidgets('web: roll width only, with the browser note', (tester) async {
    await _pumpPanel(tester, platform: PosPlatform.web, shopPrintType: 2);
    expect(find.text('Receipt roll printer'), findsOneWidget);
    expect(find.textContaining('Your browser asks'), findsOneWidget);
    expect(find.text('58mm'), findsOneWidget);
    expect(find.text('80mm'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey('printer-settings-paper-mm80')),
          )
          .selected,
      isTrue,
    );
    expect(find.byKey(const ValueKey('printer-settings-cut')), findsNothing);
    expect(find.text('A4 printer'), findsNothing);
    expect(find.byKey(const ValueKey('fake-roll-printer')), findsNothing);
  });

  testWidgets('web: choosing a width saves it', (tester) async {
    await _pumpPanel(tester, platform: PosPlatform.web);
    await _tap(
      tester,
      find.byKey(const ValueKey('printer-settings-paper-mm80')),
    );
    final saved = await tester.runAsync(PosPrinterStore.loadRollOptions);
    expect(saved?.paper, PosPaper.mm80);
  });

  testWidgets('Android: A4 uses the system dialog note', (tester) async {
    await _pumpPanel(tester, platform: PosPlatform.android);
    expect(find.text('A4 printer'), findsOneWidget);
    expect(find.textContaining('Android asks'), findsOneWidget);
    expect(find.text('HP LaserJet'), findsNothing);
    expect(find.byKey(const ValueKey('printer-settings-cut')), findsOneWidget);
    expect(find.textContaining('No roll printer selected'), findsOneWidget);
  });

  testWidgets('roll: picking a printer puts it at the top', (tester) async {
    await _pumpPanel(tester, platform: PosPlatform.android);
    await _tap(tester, find.byKey(const ValueKey('fake-roll-printer')));
    final current = find.byKey(
      const ValueKey('printer-settings-roll-current'),
    );
    expect(current, findsOneWidget);
    expect(
      find.descendant(of: current, matching: find.text('192.168.1.50:9100')),
      findsOneWidget,
    );
    final saved = await tester.runAsync(PosPrinterStore.load);
    expect(saved?.address, '192.168.1.50');
  });

  testWidgets('roll: width and cut save on the printer too', (tester) async {
    await tester.runAsync(
      () => PosPrinterStore.save(
        const PosPrinterConfig(
          transport: PosTransport.bluetooth,
          address: '66:22:B3:01:9F:10',
          name: 'BlueTooth Printer',
          paper: PosPaper.mm58,
        ),
      ),
    );
    await _pumpPanel(tester, platform: PosPlatform.android);
    await _tap(
      tester,
      find.byKey(const ValueKey('printer-settings-paper-mm80')),
    );
    await _tap(tester, find.byKey(const ValueKey('printer-settings-cut')));
    final options = await tester.runAsync(PosPrinterStore.loadRollOptions);
    expect(options, const RollOptions(paper: PosPaper.mm80, cut: true));
    final printer = await tester.runAsync(PosPrinterStore.load);
    expect(printer?.paper, PosPaper.mm80);
    expect(printer?.cut, isTrue);
  });

  testWidgets('desktop: A4 printers listed, picked one goes to the top', (
    tester,
  ) async {
    await _pumpPanel(tester, platform: PosPlatform.windows);
    expect(find.textContaining('No A4 printer selected'), findsOneWidget);
    expect(find.text('HP LaserJet'), findsOneWidget);
    expect(find.text('Canon G3010'), findsOneWidget);
    await _tap(tester, find.byKey(const ValueKey('printer-settings-a4-Canon_G3010')));
    final current = find.byKey(const ValueKey('printer-settings-a4-current'));
    expect(
      find.descendant(of: current, matching: find.text('Canon G3010')),
      findsOneWidget,
    );
    final saved = await tester.runAsync(PosPrinterStore.loadA4);
    expect(saved, const A4PrinterConfig(url: 'Canon_G3010', name: 'Canon G3010'));
  });

  testWidgets('desktop: focus on A4 shows the A4 section first', (
    tester,
  ) async {
    await _pumpPanel(
      tester,
      platform: PosPlatform.macos,
      focus: PrinterSettingsFocus.a4,
    );
    final a4 = tester.getTopLeft(
      find.byKey(const ValueKey('printer-settings-a4')),
    );
    final roll = tester.getTopLeft(
      find.byKey(const ValueKey('printer-settings-roll')),
    );
    expect(a4.dy, lessThan(roll.dy));
  });

  testWidgets('iOS: AirPrint picker, no list', (tester) async {
    await _pumpPanel(tester, platform: PosPlatform.ios);
    expect(find.text('Choose AirPrint printer'), findsOneWidget);
    expect(find.text('HP LaserJet'), findsNothing);
  });
}
