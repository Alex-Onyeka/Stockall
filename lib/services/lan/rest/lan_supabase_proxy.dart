import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/hive_rest_engine.dart';
import 'package:stockall/services/lan/rest/lan_delta_rpcs.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Forwards a request that names other stores to Supabase, through
/// the server device's own Supabase client: its REST URL, and its HTTP
/// client, which adds the server user's session token and the anon key.
/// Nothing here reads or logs a key.
///
/// Before forwarding, the LAN user must be a member (owner or employee) of
/// every other store the request names, as in the app, which only offers
/// stores the user belongs to.
class LanSupabaseProxy implements LanProxy {
  LanSupabaseProxy({
    required String Function() restUrl,
    required Map<String, String> Function() headers,
    required http.Client client,
    this.timeout = const Duration(seconds: 30),
  }) : _restUrl = restUrl,
       _headers = headers,
       _client = client;

  /// The server device's Supabase client.
  factory LanSupabaseProxy.of(SupabaseClient Function() supabase) {
    return LanSupabaseProxy(
      restUrl: () => supabase().rest.url,
      headers: () => supabase().rest.headers,
      client: _LazyClient(() => supabase().rest.httpClient ?? http.Client()),
    );
  }

  final String Function() _restUrl;
  final Map<String, String> Function() _headers;
  final http.Client _client;
  final Duration timeout;

  @override
  Future<PgResponse> forward(
    PgRequest request,
    LanPrincipal principal,
    Set<int> otherShops,
  ) async {
    final wire = request.wire;
    if (wire == null) {
      throw const PgError(500, 'LAN500', 'Request cannot be forwarded');
    }
    await _requireMembership(principal, otherShops);
    final body = request.body;
    final response = await _send(
      wire.method,
      wire.path,
      wire.query,
      headers: wire.headers,
      body: body == null ? null : jsonEncode(body),
    );
    return PgResponse(
      response.statusCode,
      headers: {
        if (response.headers['content-range'] != null)
          'content-range': response.headers['content-range']!,
      },
      body: _decode(response),
    );
  }

  /// What Supabase's [table] holds for [uuid]: the row's store, no such
  /// row (an answer with no rows), or unknown (unreachable, an error, any
  /// other reply).
  Future<LanRemoteRow> lookup(String table, String uuid) async {
    try {
      final response = await _send(
        'GET',
        table,
        'select=shop_id&uuid=eq.${Uri.encodeQueryComponent(uuid)}',
      );
      if (response.statusCode != 200) return LanRemoteRow.unknown;
      final rows = _decode(response);
      if (rows is! List) return LanRemoteRow.unknown;
      if (rows.isEmpty) return LanRemoteRow.missing;
      if (rows.length != 1 || rows.single is! Map) return LanRemoteRow.unknown;
      final shop = (rows.single as Map)['shop_id'];
      return LanRemoteRow(
        LanRemoteAnswer.found,
        shopId: shop is int ? shop : null,
      );
    } catch (_) {
      return LanRemoteRow.unknown;
    }
  }

  Future<void> _requireMembership(
    LanPrincipal principal,
    Set<int> shops,
  ) async {
    if (shops.isEmpty) return;
    final ids = (shops.toList()..sort()).join(',');
    final response = await _send(
      'GET',
      'shops',
      'select=shop_id,user_id,employees&shop_id=in.($ids)',
    );
    if (response.statusCode != 200) {
      throw PgError(
        503,
        'LAN01',
        'Could not check your access to the other store',
        details: 'Supabase answered ${response.statusCode}',
      );
    }
    final rows = _decode(response);
    final byShop = <int, Map<String, dynamic>>{
      if (rows is List)
        for (final row in rows.whereType<Map<String, dynamic>>())
          if (row['shop_id'] is int) row['shop_id'] as int: row,
    };
    for (final shop in shops) {
      final row = byShop[shop];
      final employees = row?['employees'];
      final member =
          row != null &&
          (row['user_id'] == principal.userId ||
              (employees is List && employees.contains(principal.userId)));
      if (!member) {
        throw PgError(403, 'LAN03', 'You are not a member of store $shop');
      }
    }
  }

  Future<http.Response> _send(
    String method,
    String path,
    String query, {
    Map<String, String> headers = const {},
    String? body,
  }) async {
    final uri = Uri.parse(
      '${_restUrl()}/$path${query.isEmpty ? '' : '?$query'}',
    );
    final request = http.Request(method, uri)
      ..headers.addAll(_headers())
      ..headers['Content-Type'] = 'application/json'
      ..headers.addAll(headers);
    if (body != null) request.body = body;
    try {
      final streamed = await _client.send(request).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on PgError {
      rethrow;
    } catch (e) {
      throw PgError(
        503,
        'LAN01',
        'Supabase could not be reached from the store server',
        details: '$e',
      );
    }
  }

  Object? _decode(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      return null;
    }
  }
}

/// Resolves the client on first use, so building the proxy never touches
/// Supabase (it may not be initialised in tests or on a fresh start).
class _LazyClient extends http.BaseClient {
  _LazyClient(this._resolve);

  final http.Client Function() _resolve;
  http.Client? _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return (_inner ??= _resolve()).send(request);
  }
}
