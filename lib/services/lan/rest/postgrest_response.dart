/// PostgREST-shaped responses and errors, so postgrest-dart on a LAN
/// client parses them exactly as it parses Supabase's. Pure Dart.
library;

import 'package:stockall/services/lan/rest/postgrest_request.dart';

/// An error in PostgREST's JSON shape. postgrest-dart turns it into a
/// `PostgrestException` with the same `code`.
class PgError implements Exception {
  const PgError(
    this.status,
    this.code,
    this.message, {
    this.details,
    this.hint,
  });

  final int status;
  final String code;
  final String message;
  final String? details;
  final String? hint;

  /// A duplicate key, as Postgres reports it.
  factory PgError.duplicate(String table, String key) {
    return PgError(
      409,
      '23505',
      'duplicate key value violates unique constraint "${table}_pkey"',
      details: 'Key ($key) already exists.',
    );
  }

  /// No or bad LAN session (PostgREST's JWT error).
  factory PgError.unauthorized() {
    return const PgError(401, 'PGRST301', 'LAN session missing or invalid');
  }

  factory PgError.unknownTable(String table) {
    return PgError(
      404,
      'PGRST205',
      "Could not find the table 'public.$table' in the schema cache",
    );
  }

  /// A delta for an item the store server doesn't hold yet. Retryable: no
  /// sync in the app treats it as "drop this entry", so the client keeps
  /// the entry queued and sends it again later.
  factory PgError.itemNotHereYet(String rpc, List<String> items) {
    return PgError(
      503,
      'LAN06',
      'The store server does not have this item yet; the change stays '
          'queued and is sent again',
      details: '$rpc: ${items.join(', ')}',
      hint: 'retry',
    );
  }

  factory PgError.unknownFunction(String name) {
    return PgError(
      404,
      'PGRST202',
      'Could not find the function public.$name in the schema cache',
    );
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'message': message,
    'details': details,
    'hint': hint,
  };

  @override
  String toString() => 'PgError($status $code: $message)';
}

/// What the server sends back: a status, headers, and a JSON body (or
/// none).
class PgResponse {
  const PgResponse(this.status, {this.headers = const {}, this.body});

  final int status;
  final Map<String, String> headers;

  /// JSON-encodable, or null for no body.
  final Object? body;

  factory PgResponse.error(PgError error) {
    return PgResponse(error.status, body: error.toJson());
  }
}

/// The response to a read, given the rows of the requested page and, for
/// `count=exact` or `count()`, the total before paging.
PgResponse pgReadResponse(
  PgRequest request,
  List<Map<String, dynamic>> page, {
  int? total,
}) {
  final headers = <String, String>{};
  if (request.countExact || request.op == PgOp.count) {
    headers['content-range'] = _contentRange(
      request.offset ?? 0,
      page.length,
      total ?? page.length,
    );
  }
  if (request.op == PgOp.count) {
    return PgResponse(200, headers: headers);
  }
  if (request.single) {
    if (page.length != 1) return PgResponse.error(_notOneRow(page.length));
    return PgResponse(200, headers: headers, body: page.single);
  }
  return PgResponse(200, headers: headers, body: page);
}

/// The response to a write, given the rows written (after the change).
PgResponse pgWriteResponse(
  PgRequest request,
  List<Map<String, dynamic>> written,
) {
  final status = request.op == PgOp.insert || request.op == PgOp.upsert
      ? 201
      : 200;
  if (!request.returnRepresentation) {
    return PgResponse(status == 201 ? 201 : 204);
  }
  if (request.single) {
    if (written.length != 1) {
      return PgResponse.error(_notOneRow(written.length));
    }
    return PgResponse(status, body: written.single);
  }
  return PgResponse(status, body: written);
}

String _contentRange(int offset, int length, int total) {
  if (length == 0) return '*/$total';
  return '$offset-${offset + length - 1}/$total';
}

/// postgrest-dart maps "Results contain 0 rows" to `null` for
/// `maybeSingle()`, and anything else to an exception.
PgError _notOneRow(int count) {
  return PgError(
    406,
    'PGRST116',
    'JSON object requested, multiple (or no) rows returned',
    details:
        'Results contain $count rows, application/vnd.pgrst.object+json '
        'requires 1 row',
  );
}
