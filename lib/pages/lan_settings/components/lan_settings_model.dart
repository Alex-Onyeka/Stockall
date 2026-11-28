import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/lan/local_server_record.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/lan_settings/components/pairing_scan_page.dart';
import 'package:stockall/providers/local_server_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/services/lan/lan_alerts.dart';
import 'package:stockall/services/lan/lan_routing.dart';
import 'package:stockall/services/lan/lan_transport.dart';
import 'package:stockall/services/lan/stock/lan_stock_client.dart';

/// What the Store Network page shows and does. The app's one
/// reads [LocalServerProvider] and the LAN services; widget tests pass a
/// fake. Every section reads only this.
class LanSettingsModel {
  /// Rebuilds the page when it fires.
  Listenable get changes => LocalServerProvider();

  LocalServerProvider get _provider => LocalServerProvider();

  /// Whether this device can use a store network at all (not on web).
  bool get available => LanTransport().isAvailable;

  LanStatus get status => _provider.status;

  /// Signs in to the cloud with [password] (away from the store's network,
  /// signed in only through the store server). An error message, or null.
  Future<String?> signInToCloud(String password) =>
      _provider.signInToCloud(password);

  /// Only a desktop can be the store server.
  bool get isDesktop => ShopProvider().isDesktop();

  /// A phone or tablet with a camera to scan the server's QR code.
  bool get canScan =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// The signed-in user has `Manage Local Server`.
  bool get mayManage {
    try {
      return authorization(authorized: Authorizations().manageLocalServer);
    } catch (_) {
      return false;
    }
  }

  int? get shopId => ShopProvider().userShop()?.shopId;

  String? get userId {
    try {
      return currentUser().userId;
    } catch (_) {
      return null;
    }
  }

  LocalServerRecord? get record {
    final shop = shopId;
    return shop == null ? null : _provider.record(shopId: shop);
  }

  /// This device serves the signed-in store.
  bool get isServing {
    final transport = LanTransport();
    return transport.isServing && transport.servingShopId == shopId;
  }

  /// The code to show while a device pairs with this server.
  String? get pendingPairingCode => _provider.pendingPairingCode;

  /// How long no store server has answered (while it isn't answering).
  Duration? get unreachableFor => LanRouting().unreachableFor;

  List<LanConnectedDevice> get devices => _provider.connectedDevices();

  /// Stock this device's carts hold on the store server.
  int get ownHolds => LanStockClient().own.length;

  /// The store's alerts on this device, newest first.
  List<LanAlert> get alerts => [
    for (final a in LanAlerts().all())
      if (a.shopId == shopId) a,
  ];

  String productName(String uuid) {
    try {
      final name = ProductsFunc().productBox.get(uuid)?.name;
      if (name != null && name.isNotEmpty) return name;
    } catch (_) {}
    return uuid.length > 8 ? uuid.substring(0, 8) : uuid;
  }

  // ---------------------------------------------------------------- actions

  Future<LanAuthResult> confirmPassword(String password) {
    final shop = shopId;
    final user = userId;
    if (shop == null || user == null) {
      return Future.value(LanAuthResult.invalidCredentials);
    }
    return _provider.confirmPassword(
      shopId: shop,
      userId: user,
      password: password,
    );
  }

  Future<LocalServerChange> makeServer() {
    final shop = shopId;
    final user = userId;
    if (shop == null || user == null) {
      return Future.value(LocalServerChange.notAvailable);
    }
    return _provider.setThisDeviceAsServer(shopId: shop, userId: user);
  }

  Future<LocalServerChange> removeServer() {
    final shop = shopId;
    final user = userId;
    if (shop == null || user == null) {
      return Future.value(LocalServerChange.notAvailable);
    }
    return _provider.clearServer(shopId: shop, userId: user);
  }

  Future<LanForceClearResult> forceClear(String password) {
    final shop = shopId;
    if (shop == null) return Future.value(LanForceClearResult.notAvailable);
    return _provider.forceClearServer(shopId: shop, password: password);
  }

  Future<String?> pairingQrPayload() => _provider.pairingQrPayload();

  /// The QR code is hidden: what it shows stops working.
  void cancelPairingQr() => _provider.cancelPairingQr();

  /// Goes up each time a device pairs with the QR code (which it uses up).
  int get qrPairings => _provider.qrPairings;

  /// On the server: ends the pairing session it shows.
  void cancelServerPairing() => _provider.cancelServerPairing();

  Future<List<LanFound>> browseServers() => _provider.browseServers();

  Future<LanPairOutcome> beginPairing(List<String> addresses, int port) =>
      _provider.beginPairing(addresses: addresses, port: port);

  Future<LanPairOutcome> submitPairingCode(String code) =>
      _provider.submitPairingCode(code);

  Future<LanPairOutcome> pairFromQr(String payload) =>
      _provider.pairFromQr(payload);

  Future<void> cancelPairing() => _provider.cancelPairing();

  /// The server's QR code, scanned on this phone; null when closed.
  Future<String?> scanQr(BuildContext context) => Navigator.of(context)
      .push<String>(MaterialPageRoute(builder: (_) => const PairingScanPage()));

  /// Signs in on the server just paired with the password kept here.
  Future<LanAuthResult> signInAfterPairing(String serverDeviceId) {
    final shop = shopId;
    if (shop == null) return Future.value(LanAuthResult.failed);
    return _provider.signInAfterPairing(
      shopId: shop,
      serverDeviceId: serverDeviceId,
    );
  }

  /// Signs in on the paired server with a password typed now.
  Future<LanAuthResult> signInWithPassword(String password) {
    String? email;
    try {
      email = currentUser().email;
    } catch (_) {}
    if (email == null || email.isEmpty) {
      return Future.value(LanAuthResult.invalidCredentials);
    }
    return _provider.loginViaLan(email: email, password: password);
  }

  Future<int> releaseDeviceHolds(String deviceId) =>
      _provider.releaseDeviceHolds(deviceId);

  Future<void> releaseOwnHolds() => LanStockClient().releaseAll();
}
