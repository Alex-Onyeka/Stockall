import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/navigation_service.dart';

/// What happened to the store server: two servers met, this
/// device stopped serving, its changes reached the new server, the server
/// was cleared. Its table, when it has one (items now below zero, stock
/// changes still held for a cleared server), is a table on a desktop and
/// one card per row on a phone. One widget for every width, laid out like
/// `StockConflictAlert`.
class LanServerAlertDialog extends StatelessWidget {
  const LanServerAlertDialog({
    super.key,
    required this.theme,
    required this.alert,
  });

  final ThemeProvider theme;
  final LanAlert alert;

  IconData get _icon => switch (alert.kind) {
    LanAlertKind.conflict => Icons.compare_arrows_rounded,
    LanAlertKind.demoted => Icons.swap_horiz_rounded,
    LanAlertKind.merged => Icons.cloud_done_outlined,
    LanAlertKind.forceCleared => Icons.dns_outlined,
    LanAlertKind.otherStoreServed => Icons.storefront_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final isMobile = screenWidth(context) < mobileScreen;
    final hasTable = alert.columns.isNotEmpty && alert.rows.isNotEmpty;
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      contentPadding: const EdgeInsets.all(15),
      backgroundColor: Colors.white,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SizedBox(
          width: 620,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const SizedBox(height: 5),
              CircleAvatar(
                radius: 32,
                backgroundColor: theme.lightModeColor.prColor300,
                child: Icon(_icon, color: Colors.white, size: 32),
              ),
              Text(
                alert.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.h3.fontSize,
                  fontWeight: theme.mobileTexts.h3.fontWeightBold,
                ),
              ),
              Text(
                alert.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  color: Colors.grey.shade700,
                ),
              ),
              if (hasTable)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: SingleChildScrollView(
                    child: isMobile ? _cards() : _table(),
                  ),
                ),
              const SizedBox(height: 4),
              if (isMobile)
                SizedBox(width: double.infinity, child: _ok(context))
              else
                Row(
                  children: [
                    const Spacer(),
                    Expanded(child: _ok(context)),
                  ],
                ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle get _cell => TextStyle(fontSize: theme.mobileTexts.b3.fontSize);

  TextStyle get _head => TextStyle(
    fontSize: theme.mobileTexts.b3.fontSize,
    fontWeight: FontWeight.bold,
    color: Colors.grey.shade700,
  );

  String _at(List<String> row, int i) => i < row.length ? row[i] : '';

  Widget _table() {
    final n = alert.columns.length;
    Widget row(List<String> cells, TextStyle style) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        children: [
          for (var i = 0; i < n; i++)
            Expanded(
              flex: i == 0 ? 4 : 2,
              child: Text(
                _at(cells, i),
                style: style,
                textAlign: i == 0 ? TextAlign.start : TextAlign.end,
              ),
            ),
        ],
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            color: Colors.grey.shade100,
            child: row(alert.columns, _head),
          ),
          for (final r in alert.rows) ...[
            Divider(height: 1, color: Colors.grey.shade200),
            row(r, _cell),
          ],
        ],
      ),
    );
  }

  Widget _cards() => Column(
    spacing: 8,
    children: [
      for (final r in alert.rows)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                _at(r, 0),
                style: _cell.copyWith(fontWeight: FontWeight.bold),
              ),
              for (var i = 1; i < alert.columns.length; i++)
                Text('${alert.columns[i]}: ${_at(r, i)}', style: _cell),
            ],
          ),
        ),
    ],
  );

  Widget _ok(BuildContext context) => Ink(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: theme.lightModeColor.prColor300,
    ),
    child: InkWell(
      mouseCursor: SystemMouseCursors.click,
      borderRadius: BorderRadius.circular(5),
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Center(
          child: Text(
            'OK',
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Shows each store server alert once, through [navigatorKey], to a
/// signed-in user with `Manage Local Server` in the alert's shop: those
/// kept from before at start, then each as it is raised; one dialog at a
/// time. An alert raised while someone without the permission is signed
/// in waits for the next start or alert.
class LanServerAlertPresenter {
  static final LanServerAlertPresenter _instance =
      LanServerAlertPresenter._internal();
  factory LanServerAlertPresenter() => _instance;
  LanServerAlertPresenter._internal();

  StreamSubscription<LanAlert>? _sub;
  bool _showing = false;

  /// Replaceable in tests.
  bool Function() mayManage = _mayManage;
  int? Function() shopId = () => ShopProvider().userShop()?.shopId;
  Future<int?> Function() otherStoreServed = () =>
      LocalServerProvider().otherStoreServedHere();
  String? Function(int shopId) storeName = _storeName;

  static String? _storeName(int shopId) {
    try {
      for (final shop in ShopProvider().userShops) {
        if (shop.shopId == shopId) return shop.name;
      }
    } catch (_) {}
    return null;
  }

  /// Shows [alert]; completes when it is closed. False when there is no
  /// page to show it on yet (it stays unshown). Replaceable in tests.
  Future<bool> Function(LanAlert alert) show = _showDialog;

  static Future<bool> _showDialog(LanAlert alert) async {
    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) return false;
    await showDialog<void>(
      context: context,
      builder: (c) => LanServerAlertDialog(
        theme: returnTheme(c, listen: false),
        alert: alert,
      ),
    );
    return true;
  }

  static bool _mayManage() {
    try {
      return authorization(authorized: Authorizations().manageLocalServer);
    } catch (_) {
      return false;
    }
  }

  /// Main window only.
  void start() {
    _sub ??= LanAlerts().raised.listen((_) => unawaited(showPending()));
    unawaited(showPending());
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
  }

  /// How long [signedIn] waits at most for the app to open.
  @visibleForTesting
  Duration signInWait = const Duration(seconds: 30);

  /// After a successful sign-in: the alerts waiting for this
  /// user are shown once the page on top changes (the login page opens the
  /// app a few seconds after it succeeds), so the login page's own
  /// navigation doesn't close them unseen.
  Future<void> signedIn() async {
    final before = _topRoute();
    if (before != null) {
      final end = DateTime.now().add(signInWait);
      while (identical(_topRoute(), before) && DateTime.now().isBefore(end)) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
      }
      // Let the new page build.
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    await showPending();
    await warnOtherStoreServed();
  }

  /// After a sign-in to a store other than the one this desktop serves:
  /// told (whatever their permissions) that its tills are without a server
  /// until someone signs in to it here or removes the server role. The
  /// sign-in itself goes ahead.
  Future<void> warnOtherStoreServed() async {
    try {
      final other = await otherStoreServed();
      if (other == null) return;
      final name = storeName(other);
      final store = name == null ? 'another store' : 'the store $name';
      await show(
        LanAlert(
          id: 'other-store-served-$other',
          shopId: other,
          kind: LanAlertKind.otherStoreServed,
          title: 'This Desktop Serves Another Store',
          message:
              'This desktop is the store server for $store. Its tills work '
              'offline until someone signs in to that store on this desktop, '
              'or removes the store server role there (Settings › Store '
              'Network).',
          createdAt: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      await mainLocalLog('LAN: server role warning failed: $e');
    }
  }

  static Route<dynamic>? _topRoute() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return null;
    Route<dynamic>? top;
    navigator.popUntil((route) {
      top = route;
      return true;
    });
    return top;
  }

  /// Shows the alerts not shown yet, oldest first, if a user who may see
  /// them is signed in.
  Future<void> showPending() async {
    if (_showing) return;
    final shop = shopId();
    if (shop == null || !mayManage()) return;
    _showing = true;
    var noPage = false;
    try {
      for (final alert in LanAlerts().unshown(shop)) {
        if (!await show(alert)) {
          noPage = true;
          return;
        }
        await LanAlerts().markShown(alert);
      }
    } catch (e) {
      await mainLocalLog('LAN server alert dialog failed: $e');
    } finally {
      _showing = false;
    }
    // Raised while one was showing.
    if (!noPage &&
        shop == shopId() &&
        LanAlerts().unshown(shop).isNotEmpty) {
      unawaited(showPending());
    }
  }
}
