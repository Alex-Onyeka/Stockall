import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/alert_dialogues/lan_server_alert.dart';
import 'package:stockall/local_database/lan/lan_alerts_func.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/navigation_service.dart';

/// The store server alert: the dialog at a phone and a desktop width,
/// and the presenter, which shows each alert once and only to a user with
/// `Manage Local Server`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final heldAlert = LanAlert(
    id: 'a1',
    shopId: 7,
    kind: LanAlertKind.forceCleared,
    title: 'Store server cleared',
    message: 'Check these items\' stock by hand.',
    createdAt: DateTime.utc(2026, 11, 26),
    columns: const ['Item', 'Change', 'From', 'Sent'],
    rows: const [
      ['Rice (Product)', '-2', 'Sale 5a1e0000', '2026-11-26 09:00'],
      ['Ada (Customer account)', '+500', 'Change 7f3c2a11', '2026-11-26 09:05'],
    ],
  );

  Future<void> pumpAt(WidgetTester tester, double width, Widget home) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: ThemeProvider(),
        child: MaterialApp(navigatorKey: navigatorKey, home: home),
      ),
    );
  }

  Widget opener(LanAlert alert) => Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) =>
                LanServerAlertDialog(theme: ThemeProvider(), alert: alert),
          ),
          child: const Text('open'),
        ),
      ),
    ),
  );

  group('LanServerAlertDialog', () {
    testWidgets('desktop width: the message and a table with its headings',
        (tester) async {
      await pumpAt(tester, 1200, opener(heldAlert));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Store server cleared'), findsOneWidget);
      expect(find.text('Check these items\' stock by hand.'), findsOneWidget);
      for (final heading in ['Item', 'Change', 'From', 'Sent']) {
        expect(find.text(heading), findsOneWidget);
      }
      expect(find.text('Rice (Product)'), findsOneWidget);
      expect(find.text('-2'), findsOneWidget);
      expect(find.text('Sale 5a1e0000'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Store server cleared'), findsNothing);
    });

    testWidgets('phone width: one card per row, each value with its heading',
        (tester) async {
      await pumpAt(tester, 400, opener(heldAlert));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('Rice (Product)'), findsOneWidget);
      expect(find.text('Change: -2'), findsOneWidget);
      expect(find.text('From: Sale 5a1e0000'), findsOneWidget);
      expect(find.text('Sent: 2026-11-26 09:00'), findsOneWidget);
      // No table header on a phone.
      expect(find.text('Item'), findsNothing);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('an alert without a table shows its message only',
        (tester) async {
      await pumpAt(
        tester,
        1200,
        opener(
          LanAlert(
            id: 'a2',
            shopId: 7,
            kind: LanAlertKind.demoted,
            title: 'This device stopped serving the store',
            message: 'It is now a client of the store server.',
            createdAt: DateTime.utc(2026, 11, 26),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('It is now a client of the store server.'),
          findsOneWidget);
      expect(find.text('Item'), findsNothing);
    });
  });

  group('LanServerAlertPresenter', () {
    setUpAll(() async {
      final dir = Directory.systemTemp.createTempSync('stockall_lan_alerts_ui');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => dir.path,
          );
      Hive.init(dir.path);
      await LanAlertsFunc().init();
    });

    tearDownAll(() async {
      await LanServerAlertPresenter().stop();
      await Hive.close();
    });

    setUp(() => LanAlertsFunc().clearAlerts());

    test('each alert once, only to a user with Manage Local Server, only '
        'for the store signed in; one raised later shows by itself', () async {
      var mayManage = false;
      final shown = <String>[];
      final presenter = LanServerAlertPresenter()
        ..mayManage = (() => mayManage)
        ..shopId = (() => 7)
        ..show = (alert) async {
          shown.add(alert.title);
          return true;
        };

      await LanAlerts().raise(
        shopId: 7,
        kind: LanAlertKind.merged,
        title: 'Changes sent to the store server',
        message: 'Every change has reached the store server.',
      );
      await LanAlerts().raise(
        shopId: 8,
        kind: LanAlertKind.conflict,
        title: 'Another store',
        message: 'Not this one.',
      );
      presenter.start();
      await presenter.showPending();
      // Signed in without the permission: nothing shown, nothing marked.
      expect(shown, isEmpty);
      expect(LanAlerts().unshown(7), hasLength(1));

      mayManage = true;
      await presenter.showPending();
      expect(shown, ['Changes sent to the store server']);
      expect(LanAlerts().unshown(7), isEmpty);

      // Not again.
      await presenter.showPending();
      expect(shown, hasLength(1));

      // Raised now: shown as it comes.
      await LanAlerts().raise(
        shopId: 7,
        kind: LanAlertKind.forceCleared,
        title: 'Store server cleared',
        message: 'Set another desktop as the store server.',
      );
      final end = DateTime.now().add(const Duration(seconds: 5));
      while (shown.length < 2 && DateTime.now().isBefore(end)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
      expect(shown, ['Changes sent to the store server', 'Store server cleared']);
      // The other store's alert was never shown here.
      expect(LanAlerts().unshown(8), hasLength(1));
    });

    test('signed in to another store than the one this desktop serves: '
        'warned (whatever the permissions), and the sign-in goes ahead',
        () async {
      final shown = <LanAlert>[];
      final presenter = LanServerAlertPresenter()
        ..mayManage = (() => false)
        ..shopId = (() => 8)
        ..storeName = ((id) => id == 7 ? 'Main Street' : null)
        ..show = (alert) async {
          shown.add(alert);
          return true;
        };
      addTearDown(() => presenter.otherStoreServed = () async => null);

      presenter.otherStoreServed = () async => null;
      await presenter.warnOtherStoreServed();
      expect(shown, isEmpty);

      presenter.otherStoreServed = () async => 7;
      await presenter.warnOtherStoreServed();
      expect(shown.single.title, 'This Desktop Serves Another Store');
      expect(shown.single.kind, LanAlertKind.otherStoreServed);
      expect(shown.single.message, contains('the store Main Street'));
      expect(shown.single.message, contains('offline'));
      // Not one of the stored alerts.
      expect(LanAlerts().all(), isEmpty);
    });

    test('no page to show it on yet: it stays unshown', () async {
      final presenter = LanServerAlertPresenter()
        ..mayManage = (() => true)
        ..shopId = (() => 7)
        ..show = (_) async => false;
      await LanAlerts().raise(
        shopId: 7,
        kind: LanAlertKind.demoted,
        title: 'This device stopped serving the store',
        message: 'It is now a client of the store server.',
      );
      await presenter.showPending();
      expect(LanAlerts().unshown(7), hasLength(1));
    });
  });
}
