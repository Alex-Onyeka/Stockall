import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/pos_printing/a4_print_dispatcher.dart';
import 'package:stockall/services/pos_printing/pos_print_dispatcher.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_store.dart';

// Runs on the test machine's own platform (macOS, Linux or Windows):
// a network roll printer is reachable from all of them, and all of them
// print A4 straight to a saved printer.

Future<BuildContext> _pumpContext(WidgetTester tester) async {
  late BuildContext context;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (c) {
          context = c;
          return const Scaffold();
        },
      ),
    ),
  );
  return context;
}

void main() {
  late Directory dir;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('stockall_dispatcher');
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

  testWidgets(
    'roll: sent to the saved printer with the roll options in force',
    (tester) async {
      // The fake printer: a local socket that keeps what it is sent.
      // Made inside runAsync so its callbacks run on real time.
      final received = <int>[];
      late final Completer<void> done;
      final server = (await tester.runAsync(() async {
        done = Completer<void>();
        final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
        s.listen((socket) {
          socket.listen(
            received.addAll,
            onDone: () {
              if (!done.isCompleted) done.complete();
            },
            onError: (_) {
              if (!done.isCompleted) done.complete();
            },
          );
        });
        return s;
      }))!;

      await tester.runAsync(() async {
        await PosPrinterStore.save(
          PosPrinterConfig(
            transport: PosTransport.network,
            address: '127.0.0.1',
            port: server.port,
            name: 'Test printer',
            paper: PosPaper.mm58,
          ),
        );
        await PosPrinterStore.saveRollOptions(
          const RollOptions(paper: PosPaper.mm80, cut: true),
        );
        await PrinterSettingsProvider().load();
      });

      final context = await _pumpContext(tester);
      PosPrinterConfig? target;
      await tester.runAsync(() async {
        await printRoll(
          context: context,
          shopPrintType: 1,
          escPos: (t) {
            target = t;
            return withCut([
              Uint8List.fromList([1, 2, 3]),
            ], cut: t.cut);
          },
          rollPdf: (_) => throw StateError('no system print expected'),
        );
        await done.future.timeout(const Duration(seconds: 5));
        await server.close();
      });

      expect(target?.paper, PosPaper.mm80);
      expect(target?.cut, isTrue);
      expect(received, [1, 2, 3, ...escPosCutCommand]);
    },
  );

  testWidgets('roll: an unreachable printer offers retry, change, system', (
    tester,
  ) async {
    // A port nothing listens on.
    final closed = await tester.runAsync(() async {
      final s = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = s.port;
      await s.close();
      return port;
    });
    await tester.runAsync(() async {
      await PosPrinterStore.save(
        PosPrinterConfig(
          transport: PosTransport.network,
          address: '127.0.0.1',
          port: closed,
          name: 'Gone printer',
          paper: PosPaper.mm58,
        ),
      );
      await PrinterSettingsProvider().load();
    });

    final context = await _pumpContext(tester);
    await tester.runAsync(() async {
      unawaited(
        printRoll(
          context: context,
          escPos: (_) => [Uint8List.fromList([1])],
          rollPdf: (_) => throw StateError('not used'),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.text('Printer not reachable'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Change printer'), findsOneWidget);
    expect(find.text('Use system print'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('A4: a saved printer is printed to directly; failure asks', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await PosPrinterStore.saveA4(
        const A4PrinterConfig(url: 'HP_LaserJet', name: 'HP LaserJet'),
      );
      await PrinterSettingsProvider().load();
    });

    final context = await _pumpContext(tester);
    var built = 0;
    await tester.runAsync(() async {
      unawaited(
        printA4Pdf(
          context,
          buildPdf: () async {
            built++;
            return Uint8List(0);
          },
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();
    // No printing plugin in tests, so the direct print fails: the PDF was
    // built for it and the failure choices are offered.
    expect(built, 1);
    expect(find.text('Printer not reachable'), findsOneWidget);
    expect(find.textContaining('HP LaserJet'), findsOneWidget);
    expect(find.text('Use system print'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });
}
