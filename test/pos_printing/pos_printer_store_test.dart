import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';

const _printer = PosPrinterConfig(
  transport: PosTransport.network,
  address: '192.168.1.50',
  port: 9100,
  name: '192.168.1.50:9100',
  paper: PosPaper.mm58,
);
const _a4 = A4PrinterConfig(url: 'HP_LaserJet', name: 'HP LaserJet');

void main() {
  late Directory dir;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('stockall_printer_store');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.box(PosPrinterStore.boxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  group('PosPrinterStore', () {
    test('empty: nothing saved', () async {
      expect(await PosPrinterStore.load(), isNull);
      expect(await PosPrinterStore.loadRollOptions(), isNull);
      expect(await PosPrinterStore.loadA4(), isNull);
    });

    test('roll printer, roll options and A4 printer are kept apart', () async {
      const options = RollOptions(paper: PosPaper.mm80, cut: true);
      await PosPrinterStore.save(_printer);
      await PosPrinterStore.saveRollOptions(options);
      await PosPrinterStore.saveA4(_a4);
      expect(await PosPrinterStore.load(), _printer);
      expect(await PosPrinterStore.loadRollOptions(), options);
      expect(await PosPrinterStore.loadA4(), _a4);

      await PosPrinterStore.clearA4();
      expect(await PosPrinterStore.loadA4(), isNull);
      expect(await PosPrinterStore.load(), _printer);
    });

    test('a corrupt entry reads as nothing saved', () async {
      final box = Hive.box(PosPrinterStore.boxName);
      await box.put('rollOptions', 'not a map');
      await box.put('a4Printer', {'name': 'no url'});
      expect(await PosPrinterStore.loadRollOptions(), isNull);
      expect(await PosPrinterStore.loadA4(), isNull);
    });
  });

  group('PrinterSettingsProvider', () {
    final provider = PrinterSettingsProvider();

    test('older saves: roll options come from the printer', () async {
      await PosPrinterStore.save(_printer.copyWith(cut: true));
      await provider.load();
      expect(
        provider.rollOptions(shopPrintType: 2),
        const RollOptions(paper: PosPaper.mm58, cut: true),
      );
    });

    test('nothing saved: the shop default width, no cut', () async {
      await provider.load();
      expect(provider.rollPrinter, isNull);
      expect(
        provider.rollOptions(shopPrintType: 2),
        const RollOptions(paper: PosPaper.mm80),
      );
    });

    test('new roll options also update the saved printer', () async {
      await PosPrinterStore.save(_printer);
      await provider.load();
      const options = RollOptions(paper: PosPaper.mm80, cut: true);
      await provider.setRollOptions(options);
      expect(provider.rollOptions(), options);
      expect((await PosPrinterStore.load())!.paper, PosPaper.mm80);
      expect((await PosPrinterStore.load())!.cut, isTrue);
      expect(await PosPrinterStore.loadRollOptions(), options);
    });

    test('a new roll printer takes the roll options in force', () async {
      await provider.load();
      await provider.setRollOptions(
        const RollOptions(paper: PosPaper.mm80, cut: true),
      );
      await provider.setRollPrinter(_printer);
      final saved = await PosPrinterStore.load();
      expect(saved!.address, _printer.address);
      expect(saved.paper, PosPaper.mm80);
      expect(saved.cut, isTrue);
    });

    test('A4 printer set and cleared', () async {
      await provider.load();
      var notified = 0;
      void listener() => notified++;
      provider.addListener(listener);
      await provider.setA4Printer(_a4);
      expect(provider.a4Printer, _a4);
      expect(await PosPrinterStore.loadA4(), _a4);
      await provider.setA4Printer(null);
      expect(provider.a4Printer, isNull);
      expect(await PosPrinterStore.loadA4(), isNull);
      expect(notified, 2);
      provider.removeListener(listener);
    });
  });
}
