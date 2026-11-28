import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// A Supabase answer the puller can't use (an HTTP error, or not a list).
class LanPullError implements Exception {
  const LanPullError(this.message, {this.status});
  final String message;
  final int? status;

  @override
  String toString() => 'LanPullError($status: $message)';
}

/// Reads pages of rows from Supabase for the LAN server's puller,
/// through the server device's own Supabase client (its REST URL, and its
/// HTTP client, which adds the anon key and the signed-in user's session).
/// Nothing here reads or logs a key.
class LanSupabaseReader {
  LanSupabaseReader({
    required String Function() restUrl,
    required Map<String, String> Function() headers,
    required http.Client client,
    this.timeout = const Duration(seconds: 30),
  }) : _restUrl = restUrl,
       _headers = headers,
       _client = client;

  factory LanSupabaseReader.of(SupabaseClient Function() supabase) {
    return LanSupabaseReader(
      restUrl: () => supabase().rest.url,
      headers: () => supabase().rest.headers,
      client: _LazyClient(() => supabase().rest.httpClient ?? http.Client()),
    );
  }

  final String Function() _restUrl;
  final Map<String, String> Function() _headers;
  final http.Client _client;
  final Duration timeout;

  /// `GET /rest/v1/<table>?<params>`; params keep their order.
  Future<List<Map<String, dynamic>>> rows(
    String table,
    List<(String, String)> params,
  ) async {
    final query = [
      for (final (k, v) in params)
        '${Uri.encodeQueryComponent(k)}=${Uri.encodeQueryComponent(v)}',
    ].join('&');
    final response = await _client
        .get(
          Uri.parse('${_restUrl()}/$table?$query'),
          headers: {..._headers(), 'accept': 'application/json'},
        )
        .timeout(timeout);
    if (response.statusCode != 200) {
      throw LanPullError(
        '$table: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}',
        status: response.statusCode,
      );
    }
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) throw LanPullError('$table: not a list');
    return [
      for (final row in decoded)
        if (row is Map<String, dynamic>) row,
    ];
  }
}

/// Resolves the Supabase HTTP client on first use (Supabase may not be
/// initialised when the server is set up).
class _LazyClient extends http.BaseClient {
  _LazyClient(this._make);
  final http.Client Function() _make;
  http.Client? _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      (_client ??= _make()).send(request);
}
