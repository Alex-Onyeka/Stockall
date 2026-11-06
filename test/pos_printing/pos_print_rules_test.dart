import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';

const _bluetooth = PosPrinterConfig(
  transport: PosTransport.bluetooth,
  address: '66:22:B3:01:9F:10',
  name: 'BlueTooth Printer',
  paper: PosPaper.mm58,
);
const _network = PosPrinterConfig(
  transport: PosTransport.network,
  address: '192.168.1.50',
  port: 9100,
  name: '192.168.1.50:9100',
  paper: PosPaper.mm80,
  cut: true,
);
const _windows = PosPrinterConfig(
  transport: PosTransport.windowsSpooler,
  address: 'POS-80C',
  name: 'POS-80C',
  paper: PosPaper.mm80,
  cut: true,
);
const _cups = PosPrinterConfig(
  transport: PosTransport.cups,
  address: 'POS_80C',
  name: 'POS_80C',
  paper: PosPaper.mm80,
  cut: true,
);

void main() {
  group('which printers each platform can reach', () {
    test('mobile: Bluetooth, then network', () {
      for (final p in [PosPlatform.android, PosPlatform.ios]) {
        expect(transportsFor(p), [PosTransport.bluetooth, PosTransport.network]);
      }
    });
    test('Windows: installed printers (spooler), then network', () {
      expect(transportsFor(PosPlatform.windows), [
        PosTransport.windowsSpooler,
        PosTransport.network,
      ]);
    });
    test('macOS and Linux: print queues (CUPS), then network', () {
      for (final p in [PosPlatform.macos, PosPlatform.linux]) {
        expect(transportsFor(p), [PosTransport.cups, PosTransport.network]);
      }
    });
    test('web: none', () {
      expect(transportsFor(PosPlatform.web), isEmpty);
    });
  });

  group('choosing the route', () {
    test('web always uses the system print dialog', () {
      expect(
        choosePosRoute(PosPlatform.web, null),
        isA<PosSystemPrintRoute>(),
      );
      expect(
        choosePosRoute(PosPlatform.web, _network),
        isA<PosSystemPrintRoute>(),
      );
    });

    test('no saved printer: ask, then print', () {
      for (final p in PosPlatform.values.where((p) => p != PosPlatform.web)) {
        expect(choosePosRoute(p, null), isA<PosSetupRoute>(), reason: '$p');
      }
    });

    test('a saved printer the platform can reach: print straight to it', () {
      final cases = {
        PosPlatform.android: _bluetooth,
        PosPlatform.ios: _network,
        PosPlatform.windows: _windows,
        PosPlatform.macos: _cups,
        PosPlatform.linux: _network,
      };
      cases.forEach((platform, printer) {
        final route = choosePosRoute(platform, printer);
        expect(route, isA<PosDirectRoute>(), reason: '$platform');
        expect((route as PosDirectRoute).printer, printer);
      });
    });

    test('a saved printer the platform cannot reach: ask again', () {
      expect(choosePosRoute(PosPlatform.windows, _bluetooth), isA<PosSetupRoute>());
      expect(choosePosRoute(PosPlatform.android, _windows), isA<PosSetupRoute>());
      expect(choosePosRoute(PosPlatform.macos, _windows), isA<PosSetupRoute>());
    });
  });

  group('when a direct send fails', () {
    test('native: Retry, Change printer, Use system print', () {
      expect(failureChoices(PosPlatform.android), [
        PosFailureChoice.retry,
        PosFailureChoice.changePrinter,
        PosFailureChoice.systemPrint,
      ]);
    });
    test('web never sends directly', () {
      expect(failureChoices(PosPlatform.web), isEmpty);
    });
  });

  group('the saved printer', () {
    test('round-trips through the stored map', () {
      for (final printer in [_bluetooth, _network, _windows, _cups]) {
        expect(PosPrinterConfig.fromMap(printer.toMap()), printer);
      }
    });

    test('anything incomplete is treated as no printer', () {
      expect(PosPrinterConfig.fromMap(null), isNull);
      expect(PosPrinterConfig.fromMap('printer'), isNull);
      expect(
        PosPrinterConfig.fromMap({..._bluetooth.toMap(), 'transport': 'usb'}),
        isNull,
      );
      expect(
        PosPrinterConfig.fromMap({..._bluetooth.toMap(), 'address': ' '}),
        isNull,
      );
      expect(
        PosPrinterConfig.fromMap({..._bluetooth.toMap(), 'paper': '110mm'}),
        isNull,
      );
      expect(
        PosPrinterConfig.fromMap({..._network.toMap(), 'port': null}),
        isNull,
      );
      expect(
        PosPrinterConfig.fromMap({..._network.toMap(), 'port': 70000}),
        isNull,
      );
    });

    test('reads a map Hive hands back with dynamic keys', () {
      final stored = <dynamic, dynamic>{..._network.toMap()};
      expect(PosPrinterConfig.fromMap(stored), _network);
    });

    test('a missing name shows the address', () {
      final map = {..._cups.toMap(), 'name': ''};
      expect(PosPrinterConfig.fromMap(map)!.name, 'POS_80C');
    });
  });

  group('starting point when nothing is saved', () {
    test('Windows reuses the receipt printer the items report saved', () {
      final seed = seedPosPrinter(
        platform: PosPlatform.windows,
        windowsPrinterName: 'POS-80C',
        windowsPaperSize: 2,
        shopPrintType: 1,
      );
      expect(seed, _windows);
    });

    test('its paper falls back to the shop setting', () {
      expect(
        seedPosPrinter(
          platform: PosPlatform.windows,
          windowsPrinterName: 'POS-58',
          shopPrintType: 1,
        )!.paper,
        PosPaper.mm58,
      );
    });

    test('nothing to reuse: no seed', () {
      expect(seedPosPrinter(platform: PosPlatform.windows), isNull);
      expect(
        seedPosPrinter(
          platform: PosPlatform.windows,
          windowsPrinterName: 'Not Set',
        ),
        isNull,
      );
      expect(
        seedPosPrinter(
          platform: PosPlatform.android,
          windowsPrinterName: 'POS-80C',
        ),
        isNull,
      );
    });

    test('the setup starts on the saved paper, else the shop\'s', () {
      expect(initialPaper(_network, 1), PosPaper.mm80);
      expect(initialPaper(null, 2), PosPaper.mm80);
      expect(initialPaper(null, 1), PosPaper.mm58);
      expect(initialPaper(null, null), PosPaper.mm58);
    });
  });

  test('paper sizes', () {
    expect(PosPaper.mm58.dots, 384);
    expect(PosPaper.mm80.dots, 576);
    expect(PosPaper.mm58.printerType, 1);
    expect(PosPaper.mm80.printerType, 2);
    expect(paperFromPrinterType(2), PosPaper.mm80);
    expect(paperFromPrinterType(1), PosPaper.mm58);
    expect(paperFromPrinterType(null), PosPaper.mm58);
  });

  test('cut by default on wired and network printers only', () {
    expect(defaultCut(PosTransport.bluetooth), isFalse);
    expect(defaultCut(PosTransport.network), isTrue);
    expect(defaultCut(PosTransport.windowsSpooler), isTrue);
    expect(defaultCut(PosTransport.cups), isTrue);
  });

  group('network printer address', () {
    test('accepts an IP or host name and a port', () {
      expect(networkPrinterError('192.168.1.50', '9100'), isNull);
      expect(networkPrinterError(' printer.local ', '9100'), isNull);
    });
    test('rejects the rest', () {
      expect(networkPrinterError('', '9100'), isNotNull);
      expect(networkPrinterError('192.168.1.300', '9100'), isNotNull);
      expect(networkPrinterError('bad host!', '9100'), isNotNull);
      expect(networkPrinterError('192.168.1.50', ''), isNotNull);
      expect(networkPrinterError('192.168.1.50', '0'), isNotNull);
      expect(networkPrinterError('192.168.1.50', '65536'), isNotNull);
    });
  });

  test('print queues from lpstat', () {
    expect(parseLpstatQueues('POS_80C\nOffice_Laser\n\n'), [
      'POS_80C',
      'Office_Laser',
    ]);
    expect(
      parseLpstatQueues(
        'POS_80C accepting requests since Tue Nov  4 09:00:00 2026\n'
        'POS_80C accepting requests since Tue Nov  4 09:00:00 2026\n',
      ),
      ['POS_80C'],
    );
    expect(parseLpstatQueues(''), isEmpty);
  });

  group('changing the saved printer', () {
    test('a new choice replaces the saved printer and is saved', () {
      final change = printerAfterSetup(_bluetooth, _network);
      expect(change.printer, _network);
      expect(change.save, isTrue);
    });

    test('cancelling keeps the saved printer and saves nothing', () {
      final change = printerAfterSetup(_bluetooth, null);
      expect(change.printer, _bluetooth);
      expect(change.save, isFalse);
    });

    test('cancelling with nothing saved leaves nothing saved', () {
      final change = printerAfterSetup(null, null);
      expect(change.printer, isNull);
      expect(change.save, isFalse);
    });

    test('the first choice is saved', () {
      final change = printerAfterSetup(null, _cups);
      expect(change.printer, _cups);
      expect(change.save, isTrue);
    });

    test('picking the same printer and settings saves nothing', () {
      final change = printerAfterSetup(_network, PosPrinterConfig.fromMap(_network.toMap()));
      expect(change.printer, _network);
      expect(change.save, isFalse);
    });

    test('keeping the printer with a new paper size and cut', () {
      final kept = keepPrinter(_bluetooth, paper: PosPaper.mm80, cut: true);
      expect(kept.transport, PosTransport.bluetooth);
      expect(kept.address, _bluetooth.address);
      expect(kept.name, _bluetooth.name);
      expect(kept.paper, PosPaper.mm80);
      expect(kept.cut, isTrue);
      final change = printerAfterSetup(_bluetooth, kept);
      expect(change.printer, kept);
      expect(change.save, isTrue);
    });

    test('keeping a network printer keeps its port', () {
      final kept = keepPrinter(_network, paper: PosPaper.mm58, cut: false);
      expect(kept.port, 9100);
      expect(kept.paper, PosPaper.mm58);
      expect(kept.cut, isFalse);
    });
  });
}
