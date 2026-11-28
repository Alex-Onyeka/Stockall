import 'dart:convert';

import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/lan/lan_credentials_func.dart';
import 'package:stockall/local_database/lan/lan_server_sessions_func.dart';
import 'package:stockall/local_database/lan/lan_shop_keys_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_password_hash.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Who belongs to a shop, and its LAN key, as the backfill reads them.
class LanBackfillShop {
  const LanBackfillShop({
    required this.ownerId,
    required this.employees,
    this.lanKey,
  });

  factory LanBackfillShop.fromRow(Map<String, dynamic> row) {
    final key = row['lan_key'];
    return LanBackfillShop(
      ownerId: (row['user_id'] as String?) ?? '',
      employees: [
        for (final e in (row['employees'] as List<dynamic>?) ?? const [])
          if (e is String) e,
      ],
      lanKey: key is String && key.isNotEmpty ? key : null,
    );
  }

  final String ownerId;
  final List<String> employees;
  final String? lanKey;

  /// The owner plus every employee (whether or not `employees` already
  /// lists the owner).
  Set<String> get members => {
    if (ownerId.isNotEmpty) ownerId,
    ...employees.where((e) => e.isNotEmpty),
  };
}

/// Turns Supabase-shaped users into credentials for the shop's members.
/// A member whose stored hash still matches keeps its salt and hash; a
/// changed password is hashed again with a new salt. Non-members, and
/// users with no email or password, get no credential.
Future<List<LanUserCredential>> planCredentials({
  required int shopId,
  required LanBackfillShop shop,
  required List<TempUserClass> users,
  required Map<String, LanUserCredential> existing,
  required DateTime now,
  int iterations = LanConstants.pbkdf2Iterations,
}) async {
  final members = shop.members;
  final seen = <String>{};
  final out = <LanUserCredential>[];
  for (final user in users) {
    final userId = user.userId;
    if (userId == null || !members.contains(userId) || !seen.add(userId)) {
      continue;
    }
    if (user.password.isEmpty || user.email.trim().isEmpty) continue;

    final previous = existing[userId];
    LanPasswordHash? hash;
    if (previous != null) {
      final stored = LanPasswordHash(
        salt: previous.salt,
        hash: previous.hash,
        iterations: previous.iterations,
      );
      if (await verifyPassword(user.password, stored)) hash = stored;
    }
    hash ??= await hashPassword(user.password, iterations: iterations);

    final profile = user.toJson()..remove('password');
    out.add(
      LanUserCredential(
        shopId: shopId,
        userId: userId,
        email: user.email.trim().toLowerCase(),
        salt: hash.salt,
        hash: hash.hash,
        iterations: hash.iterations,
        role: user.role,
        access: List.of(user.access),
        departmentUuids: List.of(user.departmentUuids ?? const <String>[]),
        isOwner: userId == shop.ownerId,
        profileJson: jsonEncode(profile),
        updatedAt: now,
      ),
    );
  }
  return out;
}

/// Fills the LAN server's user store from Supabase (when online) or, the
/// first time and offline, from the users this desktop already holds.
class LanUserBackfill {
  static final LanUserBackfill _instance = LanUserBackfill._internal();
  factory LanUserBackfill() => _instance;
  LanUserBackfill._internal();

  static const Duration _networkTimeout = Duration(seconds: 20);

  /// Whether this device can serve [shopId]: it has credentials and the
  /// shop key.
  bool isReady(int shopId) {
    return LanCredentialsFunc().forShop(shopId).isNotEmpty &&
        LanShopKeysFunc().get(shopId) != null;
  }

  /// Refreshes from Supabase if possible, seeds from local users if there
  /// are still no credentials, and returns [isReady].
  Future<bool> ensure(int shopId) async {
    if (ConnectivityProvider().isConnected) {
      try {
        await refreshFromSupabase(shopId);
      } catch (e) {
        await mainLocalLog('LAN user backfill from Supabase failed: $e');
      }
    }
    if (LanCredentialsFunc().forShop(shopId).isEmpty) {
      try {
        await seedFromLocal(shopId);
      } catch (e) {
        await mainLocalLog('LAN user backfill from local users failed: $e');
      }
    }
    return isReady(shopId);
  }

  Future<void> refreshFromSupabase(int shopId) async {
    final client = Supabase.instance.client;
    final row = await client
        .from('shops')
        .select('user_id, employees, lan_key')
        .eq('shop_id', shopId)
        .single()
        .timeout(_networkTimeout);
    final shop = LanBackfillShop.fromRow(row);
    final rows = await client
        .from('users')
        .select()
        .inFilter('user_id', shop.members.toList())
        .timeout(_networkTimeout);
    await apply(shopId, shop, [
      for (final r in rows) TempUserClass.fromJson(r),
    ]);
    if (shop.lanKey != null) {
      await LanShopKeysFunc().put(shopId, shop.lanKey!);
    } else {
      await mainLocalLog('LAN user backfill: shop $shopId has no lan_key');
    }
  }

  /// Offline: members from the stored shop, users from `UserFunc` (which
  /// `fetchUsersByShop` filled from Supabase while online).
  Future<void> seedFromLocal(int shopId) async {
    final stored = ShopFunc().shopBox.get(shopId);
    if (stored == null) return;
    await apply(
      shopId,
      LanBackfillShop(
        ownerId: stored.userId,
        employees: stored.employees ?? const [],
      ),
      UserFunc().getUsers(),
    );
  }

  /// Replaces the shop's credentials. Users who left the shop, or whose
  /// password changed, lose their LAN sessions.
  Future<void> apply(
    int shopId,
    LanBackfillShop shop,
    List<TempUserClass> users, {
    int iterations = LanConstants.pbkdf2Iterations,
  }) async {
    final existing = {
      for (final c in LanCredentialsFunc().forShop(shopId)) c.userId: c,
    };
    final next = await planCredentials(
      shopId: shopId,
      shop: shop,
      users: users,
      existing: existing,
      now: DateTime.now().toUtc(),
      iterations: iterations,
    );
    final nextById = {for (final c in next) c.userId: c};
    await LanCredentialsFunc().replaceForShop(shopId, next);
    for (final previous in existing.values) {
      final kept = nextById[previous.userId];
      if (kept == null || kept.hash != previous.hash) {
        await LanServerSessionsFunc().deleteForUser(
          shopId: shopId,
          userId: previous.userId,
        );
      }
    }
    await mainLocalLog(
      'LAN user backfill: ${next.length} credentials for shop $shopId',
    );
  }
}
