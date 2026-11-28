import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/components/lan_status_indicator.dart';
import 'package:stockall/components/online_only.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Where this device stands, and whether screens that
/// need the internet are shown, on every route; `OnlineOnly` and the
/// status indicator follow the route as it changes. (The server's own
/// `online` flag reaching a till is in `lan_server_status_test.dart`.)
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => RemoteRouter.useSupabase());

  test('the rule on every route: as before away from a store server; on '
      'its network only while it is known to reach the internet', () {
    final provider = LocalServerProvider();
    final table = <(void Function(), LanStatusKind, bool)>[
      (() => RemoteRouter.useSupabase(), LanStatusKind.standalone, true),
      (
        () => RemoteRouter.useSupabase(LanRoute.offLan),
        LanStatusKind.offLan,
        true,
      ),
      (
        () => RemoteRouter.useSupabase(LanRoute.server),
        LanStatusKind.server,
        true,
      ),
      (RemoteRouter.useNothing, LanStatusKind.serverUnreachable, false),
      // Connected, but the server hasn't said it reaches the internet.
      (
        () => RemoteRouter.useLan(
          SupabaseClient('https://stockall-lan:47000', 'stockall-lan'),
        ),
        LanStatusKind.connected,
        false,
      ),
    ];
    for (final (route, kind, available) in table) {
      route();
      expect(provider.status.kind, kind);
      expect(provider.onlineFeaturesAvailable, available, reason: '$kind');
    }
  });

  Future<void> pumpAt(WidgetTester tester, double width, Widget child) async {
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>.value(value: ThemeProvider()),
          ChangeNotifierProvider<LocalServerProvider>.value(
            value: LocalServerProvider(),
          ),
        ],
        child: MaterialApp(home: Scaffold(body: child)),
      ),
    );
  }

  testWidgets('OnlineOnly hides its child while the store server is away, '
      'and shows it again', (tester) async {
    RemoteRouter.useSupabase();
    await pumpAt(
      tester,
      1200,
      const Column(
        children: [
          OnlineOnly(child: Text('Notifications')),
          OnlineOnly.withNote(child: Text('Renew Subscription')),
        ],
      ),
    );
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Renew Subscription'), findsOneWidget);

    RemoteRouter.useNothing();
    await tester.pump();
    expect(find.text('Notifications'), findsNothing);
    expect(find.text('Renew Subscription'), findsNothing);
    expect(
      find.text('Available when the store server is back online.'),
      findsOneWidget,
    );

    RemoteRouter.useSupabase(LanRoute.offLan);
    await tester.pump();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Renew Subscription'), findsOneWidget);
  });

  testWidgets('the indicator: nothing without a store server; a labelled '
      'chip on a desktop, a dot on a phone; the full form explains',
      (tester) async {
    RemoteRouter.useSupabase();
    await pumpAt(tester, 1200, const LanStatusIndicator());
    expect(find.byType(Tooltip), findsNothing);
    expect(find.textContaining('store server', findRichText: true), findsNothing);

    RemoteRouter.useNothing();
    await tester.pump();
    expect(find.text('Server not answering'), findsOneWidget);

    await pumpAt(tester, 400, const LanStatusIndicator());
    expect(find.text('Server not answering'), findsNothing);
    expect(find.byType(Tooltip), findsOneWidget);

    await pumpAt(tester, 1200, const LanStatusIndicator(compact: false));
    expect(find.text('Server not answering'), findsOneWidget);
    expect(
      find.textContaining('Sales are kept on this device'),
      findsOneWidget,
    );
  });
}
