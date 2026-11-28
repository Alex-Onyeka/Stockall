import 'dart:convert';

import 'package:hive/hive.dart';

part 'lan_user_credential.g.dart';

/// A shop member the LAN server can sign in: a PBKDF2 hash of their
/// password plus what the server needs to authorize them. Never holds a
/// plaintext password. Built from Supabase `users` by the user backfill.
@HiveType(typeId: 162)
class LanUserCredential extends HiveObject {
  @HiveField(0)
  final int shopId;

  @HiveField(1)
  final String userId;

  /// Lower case.
  @HiveField(2)
  final String email;

  /// Hex.
  @HiveField(3)
  final String salt;

  /// Hex PBKDF2-HMAC-SHA256 output.
  @HiveField(4)
  final String hash;

  @HiveField(5)
  final int iterations;

  @HiveField(6)
  final String role;

  /// The same permission strings `authorization()` checks.
  @HiveField(7)
  final List<String> access;

  @HiveField(8)
  final List<String> departmentUuids;

  @HiveField(9)
  final bool isOwner;

  /// The user's `TempUserClass` JSON without the password, returned at login.
  @HiveField(10)
  final String profileJson;

  @HiveField(11)
  final DateTime updatedAt;

  LanUserCredential({
    required this.shopId,
    required this.userId,
    required this.email,
    required this.salt,
    required this.hash,
    required this.iterations,
    required this.role,
    this.access = const [],
    this.departmentUuids = const [],
    required this.isOwner,
    required this.profileJson,
    required this.updatedAt,
  });

  static String keyFor(int shopId, String userId) => '$shopId:$userId';

  String get storageKey => keyFor(shopId, userId);

  Map<String, dynamic> profile() {
    final decoded = jsonDecode(profileJson);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }
}
