/// The subset of PostgREST's HTTP API that the app's postgrest-dart calls
/// produce, parsed into a [PgRequest]. Pure Dart. Anything outside the
/// subset is a `400 PGRST100`, so an unsupported query fails loudly
/// instead of silently returning the wrong rows.
library;

import 'package:stockall/services/lan/rest/postgrest_response.dart';

enum PgOp { select, count, insert, upsert, update, delete, rpc }

enum PgFilterOp { eq, neq, gt, gte, lt, lte, inList, contains, isValue }

class PgFilter {
  const PgFilter(this.column, this.op, this.value);

  final String column;
  final PgFilterOp op;

  /// The value as text for scalar ops; a `List<String>` for `in` and
  /// `cs`; `null`, `true` or `false` for `is`.
  final Object? value;

  @override
  String toString() => 'PgFilter($column ${op.name} $value)';

  @override
  bool operator ==(Object other) =>
      other is PgFilter &&
      other.column == column &&
      other.op == op &&
      _valueEquals(other.value, value);

  @override
  int get hashCode => Object.hash(column, op, value?.toString());

  static bool _valueEquals(Object? a, Object? b) {
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i] != b[i]) return false;
      }
      return true;
    }
    return a == b;
  }
}

class PgOrder {
  const PgOrder(this.column, {required this.ascending, required this.nullsFirst});

  final String column;
  final bool ascending;
  final bool nullsFirst;

  @override
  bool operator ==(Object other) =>
      other is PgOrder &&
      other.column == column &&
      other.ascending == ascending &&
      other.nullsFirst == nullsFirst;

  @override
  int get hashCode => Object.hash(column, ascending, nullsFirst);

  @override
  String toString() =>
      'PgOrder($column ${ascending ? 'asc' : 'desc'}'
      '${nullsFirst ? ' nullsfirst' : ''})';
}

/// The request as it arrived, so the server can forward it to Supabase
/// unchanged instead of re-encoding the parsed form.
class PgWire {
  const PgWire({
    required this.method,
    required this.path,
    required this.query,
    required this.headers,
  });

  final String method;

  /// What follows `/rest/v1/` (`products`, `rpc/update_x`).
  final String path;

  /// The raw query string, without the `?`.
  final String query;

  /// `prefer` and `accept`, lower-case keys.
  final Map<String, String> headers;
}

class PgRequest {
  const PgRequest({
    required this.table,
    required this.op,
    this.columns,
    this.filters = const [],
    this.orGroups = const [],
    this.order = const [],
    this.offset,
    this.limit,
    this.single = false,
    this.countExact = false,
    this.returnRepresentation = false,
    this.onConflict,
    this.ignoreDuplicates = false,
    this.body,
    this.wire,
  });

  /// The table, or the function name for [PgOp.rpc].
  final String table;
  final PgOp op;

  /// The `select` columns; null means `*`.
  final List<String>? columns;

  /// All must match.
  final List<PgFilter> filters;

  /// Each `or=(…)` parameter: a row passes it if any of its filters match.
  final List<List<PgFilter>> orGroups;
  final List<PgOrder> order;
  final int? offset;
  final int? limit;

  /// `Accept: application/vnd.pgrst.object+json` (`single()`, and
  /// `maybeSingle()` after a write).
  final bool single;

  /// `Prefer: count=exact`.
  final bool countExact;

  /// `Prefer: return=representation` (a `.select()` after a write).
  final bool returnRepresentation;

  /// `on_conflict` for upserts; null means the primary key.
  final String? onConflict;
  final bool ignoreDuplicates;

  /// The decoded JSON body: a map, a list of maps, or null.
  final Object? body;

  /// The original request, when it came over HTTP.
  final PgWire? wire;

  /// This request with one more `column=eq.value` filter, in [filters] and,
  /// when it came over HTTP, in the query string forwarded to Supabase.
  PgRequest withEq(String column, String value) => PgRequest(
    table: table,
    op: op,
    columns: columns,
    filters: [...filters, PgFilter(column, PgFilterOp.eq, value)],
    orGroups: orGroups,
    order: order,
    offset: offset,
    limit: limit,
    single: single,
    countExact: countExact,
    returnRepresentation: returnRepresentation,
    onConflict: onConflict,
    ignoreDuplicates: ignoreDuplicates,
    body: body,
    wire: wire == null
        ? null
        : PgWire(
            method: wire!.method,
            path: wire!.path,
            query: [
              if (wire!.query.isNotEmpty) wire!.query,
              '${Uri.encodeQueryComponent(column)}='
                  'eq.${Uri.encodeQueryComponent(value)}',
            ].join('&'),
            headers: wire!.headers,
          ),
  );

  /// The rows a write sends, as a list.
  List<Map<String, dynamic>> get rows {
    final b = body;
    if (b is Map<String, dynamic>) return [b];
    if (b is List) return [for (final r in b) r as Map<String, dynamic>];
    return const [];
  }
}

/// Columns postgrest-dart can't put in a filter key without quoting, and
/// that this app never uses.
final RegExp _columnName = RegExp(r'^[a-zA-Z_][a-zA-Z0-9_]*$');

const Set<String> _reservedParams = {
  'select',
  'order',
  'offset',
  'limit',
  'on_conflict',
  'columns',
  'or',
};

/// Parses one request to `/rest/v1/<path>`.
///
/// [path] is what follows `/rest/v1/` (`products`, `rpc/update_x`).
/// [headers] keys must be lower case. [rawQuery] is kept for forwarding.
PgRequest parsePgRequest({
  required String method,
  required String path,
  required Map<String, List<String>> query,
  required Map<String, String> headers,
  Object? body,
  String? rawQuery,
}) {
  final verb = method.toUpperCase();
  final wire = PgWire(
    method: verb,
    path: path,
    query: rawQuery ?? '',
    headers: Map.unmodifiable(headers),
  );
  final prefer = _preferOf(headers['prefer']);
  final single =
      (headers['accept'] ?? '').contains('application/vnd.pgrst.object+json');

  if (path.startsWith('rpc/')) {
    final name = path.substring(4);
    if (verb != 'POST' || !_columnName.hasMatch(name)) {
      throw _bad('Unsupported RPC request: $verb $path');
    }
    if (body != null && body is! Map<String, dynamic>) {
      throw _bad('RPC parameters must be a JSON object');
    }
    return PgRequest(table: name, op: PgOp.rpc, body: body, wire: wire);
  }
  if (!_columnName.hasMatch(path)) {
    throw _bad('Unsupported path: $path');
  }

  final PgOp op;
  switch (verb) {
    case 'GET':
      op = PgOp.select;
    case 'HEAD':
      op = PgOp.count;
    case 'POST':
      op = prefer.containsKey('resolution') ? PgOp.upsert : PgOp.insert;
    case 'PATCH':
      op = PgOp.update;
    case 'DELETE':
      op = PgOp.delete;
    default:
      throw _bad('Unsupported method: $method');
  }

  if (op == PgOp.insert || op == PgOp.upsert || op == PgOp.update) {
    final ok =
        body is Map<String, dynamic> ||
        (op != PgOp.update &&
            body is List &&
            body.every((r) => r is Map<String, dynamic>));
    if (!ok) throw _bad('Missing or malformed JSON body');
  }

  final filters = <PgFilter>[];
  final orGroups = <List<PgFilter>>[];
  for (final entry in query.entries) {
    final key = entry.key;
    if (_reservedParams.contains(key)) continue;
    if (!_columnName.hasMatch(key)) throw _bad('Unsupported filter key: $key');
    for (final raw in entry.value) {
      filters.add(_parseFilter(key, raw));
    }
  }
  for (final raw in query['or'] ?? const <String>[]) {
    orGroups.add(_parseOr(raw));
  }

  final resolution = prefer['resolution'];
  return PgRequest(
    table: path,
    op: op,
    columns: _parseColumns(_one(query, 'select')),
    filters: filters,
    orGroups: orGroups,
    order: _parseOrder(_one(query, 'order')),
    offset: _int(query, 'offset'),
    limit: _int(query, 'limit'),
    single: single,
    countExact: prefer['count'] == 'exact',
    returnRepresentation: prefer['return'] == 'representation',
    onConflict: _one(query, 'on_conflict'),
    ignoreDuplicates: resolution == 'ignore-duplicates',
    body: body,
    wire: wire,
  );
}

PgError _bad(String message) {
  return PgError(400, 'PGRST100', message);
}

Map<String, String> _preferOf(String? header) {
  final out = <String, String>{};
  for (final part in (header ?? '').split(',')) {
    final kv = part.trim();
    final eq = kv.indexOf('=');
    if (eq <= 0) continue;
    out[kv.substring(0, eq)] = kv.substring(eq + 1);
  }
  return out;
}

String? _one(Map<String, List<String>> query, String key) {
  final values = query[key];
  if (values == null || values.isEmpty) return null;
  if (values.length > 1) throw _bad('Repeated parameter: $key');
  return values.single;
}

int? _int(Map<String, List<String>> query, String key) {
  final text = _one(query, key);
  if (text == null) return null;
  final value = int.tryParse(text);
  if (value == null || value < 0) throw _bad('Bad $key: $text');
  return value;
}

List<String>? _parseColumns(String? select) {
  if (select == null || select == '*') return null;
  final columns = select.split(',').map((c) => c.trim()).toList();
  for (final c in columns) {
    if (!_columnName.hasMatch(c)) {
      // Embedded resources (joins), renames and casts are not supported.
      throw _bad('Unsupported select: $select');
    }
  }
  return columns;
}

List<PgOrder> _parseOrder(String? order) {
  if (order == null || order.isEmpty) return const [];
  return [
    for (final term in order.split(','))
      () {
        final parts = term.split('.');
        if (parts.isEmpty || !_columnName.hasMatch(parts.first)) {
          throw _bad('Unsupported order: $order');
        }
        var ascending = true;
        var nullsFirst = false;
        for (final modifier in parts.skip(1)) {
          switch (modifier) {
            case 'asc':
              ascending = true;
            case 'desc':
              ascending = false;
            case 'nullsfirst':
              nullsFirst = true;
            case 'nullslast':
              nullsFirst = false;
            default:
              throw _bad('Unsupported order: $order');
          }
        }
        return PgOrder(
          parts.first,
          ascending: ascending,
          nullsFirst: nullsFirst,
        );
      }(),
  ];
}

PgFilter _parseFilter(String column, String raw) {
  final dot = raw.indexOf('.');
  if (dot <= 0) throw _bad('Unsupported filter: $column=$raw');
  final opText = raw.substring(0, dot);
  final value = raw.substring(dot + 1);
  switch (opText) {
    case 'eq':
      return PgFilter(column, PgFilterOp.eq, value);
    case 'neq':
      return PgFilter(column, PgFilterOp.neq, value);
    case 'gt':
      return PgFilter(column, PgFilterOp.gt, value);
    case 'gte':
      return PgFilter(column, PgFilterOp.gte, value);
    case 'lt':
      return PgFilter(column, PgFilterOp.lt, value);
    case 'lte':
      return PgFilter(column, PgFilterOp.lte, value);
    case 'in':
      if (!value.startsWith('(') || !value.endsWith(')')) {
        throw _bad('Unsupported filter: $column=$raw');
      }
      return PgFilter(
        column,
        PgFilterOp.inList,
        _splitList(value.substring(1, value.length - 1)),
      );
    case 'cs':
      if (!value.startsWith('{') || !value.endsWith('}')) {
        throw _bad('Unsupported filter: $column=$raw');
      }
      return PgFilter(
        column,
        PgFilterOp.contains,
        _splitList(value.substring(1, value.length - 1)),
      );
    case 'is':
      switch (value) {
        case 'null':
          return PgFilter(column, PgFilterOp.isValue, null);
        case 'true':
          return PgFilter(column, PgFilterOp.isValue, true);
        case 'false':
          return PgFilter(column, PgFilterOp.isValue, false);
      }
  }
  throw _bad('Unsupported filter: $column=$raw');
}

/// `(a.gt.0,b.is.null)`: each term is `column.op.value`.
List<PgFilter> _parseOr(String raw) {
  if (!raw.startsWith('(') || !raw.endsWith(')')) {
    throw _bad('Unsupported or: $raw');
  }
  final terms = _splitTopLevel(raw.substring(1, raw.length - 1));
  return [
    for (final term in terms)
      () {
        final dot = term.indexOf('.');
        if (dot <= 0) throw _bad('Unsupported or: $raw');
        final column = term.substring(0, dot);
        if (!_columnName.hasMatch(column)) throw _bad('Unsupported or: $raw');
        return _parseFilter(column, term.substring(dot + 1));
      }(),
  ];
}

/// Splits `"a","b,c",3` into `[a, b,c, 3]`: postgrest-dart quotes every
/// string value and leaves numbers bare.
List<String> _splitList(String inner) {
  if (inner.isEmpty) return const [];
  final out = <String>[];
  final current = StringBuffer();
  var quoted = false;
  var wasQuoted = false;
  for (var i = 0; i < inner.length; i++) {
    final c = inner[i];
    if (c == '"') {
      quoted = !quoted;
      wasQuoted = true;
      continue;
    }
    if (c == ',' && !quoted) {
      out.add(current.toString());
      current.clear();
      wasQuoted = false;
      continue;
    }
    current.write(c);
  }
  if (quoted) throw _bad('Unterminated quote in list: $inner');
  if (current.isNotEmpty || wasQuoted) out.add(current.toString());
  return out;
}

List<String> _splitTopLevel(String inner) {
  final out = <String>[];
  final current = StringBuffer();
  var depth = 0;
  var quoted = false;
  for (var i = 0; i < inner.length; i++) {
    final c = inner[i];
    if (c == '"') quoted = !quoted;
    if (!quoted) {
      if (c == '(' || c == '{') depth++;
      if (c == ')' || c == '}') depth--;
      if (c == ',' && depth == 0) {
        out.add(current.toString());
        current.clear();
        continue;
      }
    }
    current.write(c);
  }
  if (current.isNotEmpty) out.add(current.toString());
  return out;
}
