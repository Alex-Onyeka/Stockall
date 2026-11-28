import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/lan/lan_paired_server.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/components/alert_dialogues/lan_password_dialog.dart';
import 'package:stockall/pages/lan_settings/components/lan_settings_model.dart';
import 'package:stockall/pages/lan_settings/components/server_role_section.dart';
import 'package:stockall/pages/lan_settings/lan_settings_page.dart';
import 'package:stockall/pages/lan_settings/platforms/lan_settings_desktop.dart';
import 'package:stockall/pages/lan_settings/platforms/lan_settings_mobile.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_transport.dart';

/// The Store Network page with what it reads and does faked, so each
/// test sets the role and permission and records what the page asked for.
class _FakeModel extends LanSettingsModel {
  final _notifier = ChangeNotifier();

  @override
  Listenable get changes => _notifier;

  @override
  bool available = true;
  @override
  LanStatus status = const LanStatus(kind: LanStatusKind.standalone);
  @override
  bool isDesktop = false;
  @override
  bool canScan = false;
  @override
  bool mayManage = false;
  @override
  int? shopId = 7;
  @override
  String? userId = 'manager';
  @override
  LocalServerRecord? record;
  @override
  bool isServing = false;
  @override
  String? pendingPairingCode;
  @override
  Duration? unreachableFor;
  @override
  List<LanConnectedDevice> devices = const [];
  @override
  int ownHolds = 0;
  @override
  List<LanAlert> alerts = const [];

  @override
  String productName(String uuid) => uuid == 'p1' ? 'Rice' : uuid;

  // What the page asked for.
  final calls = <String>[];

  String rightPassword = 'right';
  LocalServerChange makeResult = LocalServerChange.applied;
  LocalServerChange removeResult = LocalServerChange.applied;
  LanForceClearResult forceResult = LanForceClearResult.applied;
  List<LanFound> found = const [];
  LanPairOutcome beginResult = const LanPairOutcome(
    LanPairResult.awaitingCode,
  );
  String rightCode = 'K7QH2MXA';
  String? scanned;
  LanAuthResult signInResult = LanAuthResult.ok;

  static final _server = LanPairedServer(
    serverDeviceId: 'desk-1234567890',
    certFingerprint: 'ab' * 32,
    port: 47811,
    addresses: const ['192.168.1.20'],
    pairedAt: DateTime.utc(2026, 11, 27),
    label: 'Stockall-desk',
  );

  @override
  Future<LanAuthResult> confirmPassword(String password) async {
    calls.add('confirm $password');
    return password == rightPassword
        ? LanAuthResult.ok
        : LanAuthResult.invalidCredentials;
  }

  @override
  Future<LocalServerChange> makeServer() async {
    calls.add('make');
    return makeResult;
  }

  @override
  Future<LocalServerChange> removeServer() async {
    calls.add('remove');
    return removeResult;
  }

  @override
  Future<LanForceClearResult> forceClear(String password) async {
    calls.add('forceClear $password');
    return forceResult;
  }

  @override
  Future<String?> pairingQrPayload() async => 'stockall-pair:payload';

  @override
  void cancelServerPairing() {
    calls.add('cancelServer');
    pendingPairingCode = null;
  }

  @override
  Future<List<LanFound>> browseServers() async {
    calls.add('browse');
    return found;
  }

  @override
  Future<LanPairOutcome> beginPairing(List<String> addresses, int port) async {
    calls.add('begin ${addresses.join(',')}:$port');
    return beginResult;
  }

  @override
  Future<LanPairOutcome> submitPairingCode(String code) async {
    calls.add('code $code');
    return code == rightCode
        ? LanPairOutcome(LanPairResult.paired, server: _server)
        : const LanPairOutcome(LanPairResult.codeMismatch);
  }

  @override
  Future<LanPairOutcome> pairFromQr(String payload) async {
    calls.add('qr $payload');
    return LanPairOutcome(LanPairResult.paired, server: _server);
  }

  @override
  Future<void> cancelPairing() async => calls.add('cancel');

  @override
  Future<String?> scanQr(BuildContext context) async => scanned;

  @override
  Future<LanAuthResult> signInAfterPairing(String serverDeviceId) async {
    calls.add('signIn $serverDeviceId');
    return signInResult;
  }

  @override
  Future<LanAuthResult> signInWithPassword(String password) async {
    calls.add('signInWith $password');
    return password == rightPassword
        ? LanAuthResult.ok
        : LanAuthResult.invalidCredentials;
  }

  @override
  Future<int> releaseDeviceHolds(String deviceId) async {
    calls.add('release $deviceId');
    return 1;
  }

  @override
  Future<void> releaseOwnHolds() async => calls.add('releaseOwn');

  @override
  Future<String?> signInToCloud(String password) async {
    calls.add('cloud:$password');
    return password == rightPassword ? null : 'Wrong password';
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const phone = Size(420, 2400);
  const desktop = Size(1400, 2000);

  Future<void> pumpPage(WidgetTester tester, Size size, _FakeModel model) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: ThemeProvider(),
        child: MaterialApp(home: LanSettingsPage(model: model)),
      ),
    );
    await tester.pump();
  }

  Finder inDialog(Finder matching) =>
      find.descendant(of: find.byType(AlertDialog), matching: matching);

  Future<void> typePassword(WidgetTester tester, String password) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(LanPasswordDialog),
        matching: find.byType(TextField),
      ),
      password,
    );
  }

  testWidgets('a phone without Manage Local Server, connected: the status, '
      'pairing and its own held stock; no server role, devices or alerts',
      (tester) async {
    final model = _FakeModel()
      ..status = const LanStatus(
        kind: LanStatusKind.connected,
        serverOnline: true,
      )
      ..record = LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'desk-1234567890',
      )
      ..canScan = true
      ..ownHolds = 2;
    await pumpPage(tester, phone, model);

    expect(find.byType(LanSettingsMobile), findsOneWidget);
    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('Pair with the store server'), findsOneWidget);
    expect(find.text('Scan QR code'), findsOneWidget);
    expect(find.text('Remove the store server'), findsNothing);
    expect(find.text('Make this desktop the store server'), findsNothing);
    expect(find.textContaining('Clear the store server'), findsNothing);
    expect(find.text('Devices'), findsNothing);
    expect(find.text('Store server alerts'), findsNothing);

    // Its own held stock, released after asking.
    expect(find.text('Stock held by this device'), findsOneWidget);
    expect(find.textContaining('2 items in this device'), findsOneWidget);
    await tester.tap(find.text('Release'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('Cancel')));
    await tester.pumpAndSettle();
    expect(model.calls, isEmpty);
    await tester.tap(find.text('Release'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('Release')));
    await tester.pumpAndSettle();
    expect(model.calls, ['releaseOwn']);
    expect(find.text('Released this device\'s held stock.'), findsOneWidget);
  });

  testWidgets('the serving desktop, with Manage Local Server: remove the '
      'server, the pairing code and QR code, devices with their holds and '
      'release, and the alerts list opening an alert', (tester) async {
    final model = _FakeModel()
      ..status = const LanStatus(kind: LanStatusKind.server, serverOnline: true)
      ..isDesktop = true
      ..mayManage = true
      ..isServing = true
      ..record = LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'this-desk',
      )
      ..pendingPairingCode = 'K7QH2MXA'
      ..devices = [
        const LanConnectedDevice(
          deviceId: 'this-desk',
          isThisDevice: true,
          connected: true,
          holds: [],
        ),
        const LanConnectedDevice(
          deviceId: 'phone-1aaaaaaa',
          isThisDevice: false,
          connected: true,
          holds: [(cartId: 'cart-a', productUuid: 'p1', quantity: 2.0)],
          userEmail: 'ada@shop.test',
        ),
      ]
      ..alerts = [
        LanAlert(
          id: 'a1',
          shopId: 7,
          kind: LanAlertKind.forceCleared,
          title: 'Store server cleared',
          message: 'Ada cleared the store server.',
          createdAt: DateTime.utc(2026, 11, 26, 9),
          columns: const ['Item', 'Change', 'From', 'Sent'],
          rows: const [
            ['Rice (Product)', '-2', 'Sale 5a1e0000', '2026-11-26 09:00'],
          ],
        ),
      ];
    await pumpPage(tester, desktop, model);

    expect(find.byType(LanSettingsDesktop), findsOneWidget);
    expect(find.text('This desktop is the store server.'), findsOneWidget);
    expect(find.textContaining('work through this desktop'), findsOneWidget);
    expect(find.text('Pair with the store server'), findsNothing);

    // Pairing: the code, and the QR code on request.
    expect(find.text('K7QH2MXA'), findsOneWidget);
    expect(find.byType(BarcodeWidget), findsNothing);
    await tester.tap(find.text('Show QR code'));
    await tester.pumpAndSettle();
    expect(find.byType(BarcodeWidget), findsOneWidget);
    expect(find.text('Hide QR code'), findsOneWidget);

    // Devices.
    expect(find.text('This desktop'), findsOneWidget);
    expect(find.text('Device phone-1a'), findsOneWidget);
    expect(find.text('ada@shop.test'), findsOneWidget);
    expect(find.text('Rice × 2 (cart cart-a)'), findsOneWidget);
    expect(find.text('No stock held.'), findsOneWidget);
    await tester.tap(find.text('Release this device\'s holds'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('Release')));
    await tester.pumpAndSettle();
    expect(model.calls, ['release phone-1aaaaaaa']);
    expect(
      find.text('Released 1 held item from device phone-1a.'),
      findsOneWidget,
    );

    // Alerts: the list, then the alert itself.
    expect(find.text('Store server alerts'), findsOneWidget);
    expect(
      find.textContaining('Server cleared · '),
      findsOneWidget,
    );
    await tester.tap(find.text('Store server cleared'));
    await tester.pumpAndSettle();
    expect(find.text('Ada cleared the store server.'), findsOneWidget);
    expect(find.text('Sale 5a1e0000'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Ada cleared the store server.'), findsNothing);

    // Remove the server: a wrong password changes nothing.
    model.calls.clear();
    await tester.tap(find.text('Remove the store server'));
    await tester.pumpAndSettle();
    await typePassword(tester, 'wrong');
    await tester.tap(inDialog(find.text('Remove')));
    await tester.pumpAndSettle();
    expect(find.text('That password isn\'t right.'), findsOneWidget);
    expect(model.calls, ['confirm wrong']);
    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Remove')));
    await tester.pumpAndSettle();
    expect(find.byType(LanPasswordDialog), findsNothing);
    expect(model.calls, ['confirm wrong', 'confirm right', 'remove']);
    expect(
      find.text(serverChangeMessage(LocalServerChange.applied, made: false)),
      findsOneWidget,
    );

    // Cancel the pairing shown: the code goes.
    model.calls.clear();
    await tester.tap(find.text('Cancel this pairing'));
    await tester.pumpAndSettle();
    expect(model.calls, ['cancelServer']);
    expect(find.text('K7QH2MXA'), findsNothing);
    expect(find.text('No device is pairing right now.'), findsOneWidget);
    expect(find.text('Cancel this pairing'), findsNothing);
  });

  testWidgets('a desktop with no store server: make it the server after the '
      'password; cancelling or a wrong password changes nothing', (tester) async {
    final model = _FakeModel()
      ..isDesktop = true
      ..mayManage = true
      ..makeResult = LocalServerChange.liveServerFound;
    await pumpPage(tester, desktop, model);
    expect(find.text('No store server'), findsOneWidget);

    await tester.tap(find.text('Make this desktop the store server'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('Cancel')));
    await tester.pumpAndSettle();
    expect(model.calls, isEmpty);

    await tester.tap(find.text('Make this desktop the store server'));
    await tester.pumpAndSettle();
    await tester.tap(inDialog(find.text('Make server')));
    await tester.pumpAndSettle();
    expect(find.text('Type your password.'), findsOneWidget);
    await typePassword(tester, 'wrong');
    await tester.tap(inDialog(find.text('Make server')));
    await tester.pumpAndSettle();
    expect(find.text('That password isn\'t right.'), findsOneWidget);
    expect(model.calls, ['confirm wrong']);

    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Make server')));
    await tester.pumpAndSettle();
    expect(model.calls, ['confirm wrong', 'confirm right', 'make']);
    expect(
      find.text('Another desktop already serves this store.'),
      findsOneWidget,
    );

    model
      ..calls.clear()
      ..makeResult = LocalServerChange.applied;
    await tester.tap(find.text('Make this desktop the store server'));
    await tester.pumpAndSettle();
    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Make server')));
    await tester.pumpAndSettle();
    expect(model.calls, ['confirm right', 'make']);
    expect(
      find.text(serverChangeMessage(LocalServerChange.applied, made: true)),
      findsOneWidget,
    );
  });

  testWidgets('a phone with the permission and no store server: told to make '
      'one on a desktop; no button', (tester) async {
    final model = _FakeModel()..mayManage = true;
    await pumpPage(tester, phone, model);
    expect(find.textContaining('Make one on a desktop'), findsOneWidget);
    expect(find.text('Make this desktop the store server'), findsNothing);
    expect(find.text('Store server alerts'), findsOneWidget);
    expect(find.text('No store server alerts.'), findsOneWidget);
  });

  testWidgets('force-clear: counts down to a minute without an answer, then '
      'asks for the password; each result is said', (tester) async {
    final model = _FakeModel()
      ..status = const LanStatus(kind: LanStatusKind.serverUnreachable)
      ..mayManage = true
      ..record = LocalServerRecord(
        shopId: 7,
        epoch: 2,
        serverDeviceId: 'desk-1234567890',
      )
      ..unreachableFor = const Duration(seconds: 20)
      ..forceResult = LanForceClearResult.liveServerFound;
    await pumpPage(tester, phone, model);

    expect(find.text('Server not answering'), findsOneWidget);
    expect(find.textContaining('device desk-123'), findsOneWidget);
    expect(find.text('Remove the store server'), findsNothing);
    expect(find.text('Clear the store server (in 40 s)'), findsOneWidget);
    await tester.tap(find.text('Clear the store server (in 40 s)'));
    await tester.pumpAndSettle();
    expect(find.byType(LanPasswordDialog), findsNothing);

    // The page ticks each second.
    model.unreachableFor = const Duration(seconds: 59, milliseconds: 500);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Clear the store server (in 1 s)'), findsOneWidget);
    model.unreachableFor = const Duration(seconds: 61);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Clear the store server'), findsOneWidget);

    await tester.tap(find.text('Clear the store server'));
    await tester.pumpAndSettle();
    await typePassword(tester, 'wrong');
    await tester.tap(inDialog(find.text('Clear server')));
    await tester.pumpAndSettle();
    expect(model.calls, ['confirm wrong']);
    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Clear server')));
    await tester.pumpAndSettle();
    expect(model.calls, ['confirm wrong', 'confirm right', 'forceClear right']);
    expect(
      find.text('The store server is answering again. Nothing was cleared.'),
      findsOneWidget,
    );

    model
      ..calls.clear()
      ..forceResult = LanForceClearResult.applied;
    await tester.tap(find.text('Clear the store server'));
    await tester.pumpAndSettle();
    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Clear server')));
    await tester.pumpAndSettle();
    expect(model.calls, ['confirm right', 'forceClear right']);
    expect(
      find.text(forceClearMessage(LanForceClearResult.applied)),
      findsOneWidget,
    );
  });

  testWidgets('pairing by code: found, a wrong code saves nothing, the right '
      'one pairs; the stored password is refused, so it asks', (tester) async {
    final model = _FakeModel()
      ..found = const [
        LanFound(
          name: 'Stockall-desk1234',
          addresses: ['192.168.1.20'],
          port: 47811,
          txt: {},
        ),
      ];
    await pumpPage(tester, desktop, model);
    expect(find.text('Scan QR code'), findsNothing);

    await tester.tap(find.text('Find the store server'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Store server desk1234'));
    await tester.pumpAndSettle();
    expect(model.calls, ['browse', 'begin 192.168.1.20:47811']);

    await tester.enterText(find.byKey(const ValueKey('lan-pairing-code')), 'WRONG123');
    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();
    expect(model.calls.last, 'code WRONG123');
    expect(find.textContaining('The code doesn\'t match'), findsOneWidget);
    expect(find.byKey(const ValueKey('lan-pairing-code')), findsNothing);
    expect(model.calls.where((c) => c.startsWith('signIn')), isEmpty);

    // Again, with the right code.
    model.signInResult = LanAuthResult.invalidCredentials;
    await tester.tap(find.text('Find the store server'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Store server desk1234'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('lan-pairing-code')), 'K7QH2MXA');
    await tester.tap(find.text('Pair'));
    await tester.pumpAndSettle();
    expect(model.calls, contains('signIn desk-1234567890'));
    expect(find.text('Sign in on the store server'), findsOneWidget);
    await typePassword(tester, 'wrong');
    await tester.tap(inDialog(find.text('Sign in')));
    await tester.pumpAndSettle();
    expect(find.text('That password isn\'t right.'), findsOneWidget);
    await typePassword(tester, 'right');
    await tester.tap(inDialog(find.text('Sign in')));
    await tester.pumpAndSettle();
    expect(model.calls.last, 'signInWith right');
    expect(find.textContaining('Paired and signed in'), findsOneWidget);
  });

  testWidgets('pairing on a phone: scanning the QR code pairs and signs in; '
      'a typed address with a port', (tester) async {
    final model = _FakeModel()
      ..canScan = true
      ..scanned = 'stockall-pair:payload'
      ..beginResult = const LanPairOutcome(
        LanPairResult.failed,
        message: 'Server not reachable',
      );
    await pumpPage(tester, phone, model);

    await tester.tap(find.text('Scan QR code'));
    await tester.pumpAndSettle();
    expect(model.calls, ['qr stockall-pair:payload', 'signIn desk-1234567890']);
    expect(find.textContaining('Paired and signed in'), findsOneWidget);

    model.calls.clear();
    await tester.tap(find.text('Type its address'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('lan-pairing-address')),
      '192.168.1.30:47900',
    );
    await tester.tap(find.text('Connect'));
    await tester.pumpAndSettle();
    expect(model.calls, ['begin 192.168.1.30:47900']);
    expect(find.text('Couldn\'t pair: Server not reachable.'), findsOneWidget);
  });

  testWidgets('on the web: no store network', (tester) async {
    final model = _FakeModel()
      ..available = false
      ..mayManage = true
      ..isDesktop = true;
    await pumpPage(tester, desktop, model);
    expect(
      find.text('The store network isn\'t available on the web.'),
      findsOneWidget,
    );
    expect(find.text('Make this desktop the store server'), findsNothing);
    expect(find.text('Pair with the store server'), findsNothing);
    expect(find.text('Store server alerts'), findsNothing);
  });

  for (final (name, size) in [('phone', phone), ('desktop', desktop)]) {
    testWidgets('$name, away from the store network and signed in only '
        'through the store server: asked to sign in to sync; a server it '
        'must pair with again is said', (tester) async {
      final model = _FakeModel()
        ..status = const LanStatus(
          kind: LanStatusKind.offLan,
          needsCloudSignIn: true,
        );
      await pumpPage(tester, size, model);

      expect(find.text('Sign in to sync'), findsWidgets);
      await tester.tap(find.byKey(const Key('lan-cloud-sign-in')));
      await tester.pumpAndSettle();
      await typePassword(tester, 'right');
      await tester.tap(inDialog(find.text('Sign in')));
      await tester.pumpAndSettle();
      expect(model.calls, ['cloud:right']);

      model.status = const LanStatus(
        kind: LanStatusKind.serverUnreachable,
        mustPairAgain: true,
      );
      await pumpPage(tester, size, model);
      expect(find.text('Pair again'), findsOneWidget);
      expect(find.textContaining('Pair this device with it again'), findsOneWidget);
    });
  }
}
