import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/lan/lan_sent_marks.dart';

/// The `http.Client` a LAN `SupabaseClient` uses: every request goes to
/// the paired server over its pinned TLS connection (`connectionFactory`,
/// fixed name `stockall-lan`), on whichever address currently works, with
/// this device's id attached. A connection failure fails over once.
class LanHttpClient extends http.BaseClient {
  LanHttpClient(this.connection, {required this.deviceId, this.onAnswer});

  final LanConnection connection;
  final String deviceId;

  /// Awaited with every answer before it is returned (a handoff for a
  /// write the server acknowledged must exist before the caller deletes
  /// its queue entry).
  final Future<void> Function(
    http.BaseRequest request,
    List<int> body,
    http.StreamedResponse response,
  )?
  onAnswer;

  /// Asked when the server refuses a write for permission (403
  /// `LAN02`). True: it was set aside to be sent to Supabase, and the
  /// caller is answered as if the server took it, so its queue moves on.
  /// Set by the transport; null: refusals are returned as they are.
  static Future<bool> Function(http.BaseRequest request, List<int> body)?
  setAsideRefused;

  static const Set<String> _writes = {'POST', 'PATCH', 'PUT', 'DELETE'};

  /// A refused write's answer, or the success it is replaced with.
  Future<http.StreamedResponse> _refusedOrAccepted(
    http.BaseRequest request,
    List<int> body,
    http.StreamedResponse response,
  ) async {
    final setAside = setAsideRefused;
    if (setAside == null ||
        response.statusCode != 403 ||
        !_writes.contains(request.method.toUpperCase())) {
      return response;
    }
    final answer = await response.stream.toBytes();
    String? code;
    try {
      final decoded = jsonDecode(utf8.decode(answer));
      if (decoded is Map) code = decoded['code'] as String?;
    } catch (_) {}
    if (code == 'LAN02' && await setAside(request, body)) {
      return _accepted(request, body);
    }
    return http.StreamedResponse(
      Stream.value(answer),
      response.statusCode,
      contentLength: answer.length,
      request: response.request,
      headers: response.headers,
      reasonPhrase: response.reasonPhrase,
    );
  }

  /// What PostgREST answers a write it took: the rows sent back when the
  /// caller asked for them (`Prefer: return=representation`), as an object
  /// when it asked for one.
  static http.StreamedResponse _accepted(
    http.BaseRequest request,
    List<int> body,
  ) {
    final method = request.method.toUpperCase();
    final prefer = request.headers['prefer'] ?? '';
    final wantsRows = prefer.contains('return=representation');
    List<int> out = const [];
    if (wantsRows) {
      // The rows sent (a delete sends none: no rows back).
      Object? rows = const [];
      if (body.isNotEmpty) {
        try {
          rows = jsonDecode(utf8.decode(body));
        } catch (_) {}
      }
      final accept = request.headers['accept'] ?? '';
      if (accept.contains('vnd.pgrst.object')) {
        rows = rows is List ? (rows.isEmpty ? null : rows.first) : rows;
      } else if (rows is! List) {
        rows = [rows];
      }
      out = utf8.encode(jsonEncode(rows));
    }
    return http.StreamedResponse(
      Stream.value(out),
      method == 'POST' ? 201 : (out.isEmpty ? 204 : 200),
      contentLength: out.length,
      request: request,
      headers: {if (out.isNotEmpty) 'content-type': 'application/json'},
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Buffered, so the request can be sent again after a failover.
    final bytes = await request.finalize().toBytes();

    Future<http.StreamedResponse> attempt() {
      final copy = http.Request(
        request.method,
        request.url.replace(
          scheme: 'https',
          host: LanConstants.tlsHost,
          port: connection.current.port,
        ),
      )
        ..headers.addAll(request.headers)
        ..followRedirects = false
        ..bodyBytes = bytes;
      copy.headers[LanConstants.deviceHeader] = deviceId;
      // Not closed: the IOClient wraps the connection's shared client.
      return IOClient(
        connection.httpClient,
      ).send(copy).timeout(LanConstants.restTimeout);
    }

    Future<http.StreamedResponse> answered(
      Future<http.StreamedResponse> pending,
    ) async {
      final response = await pending;
      // Tells a stock or account send whether the server answered, and how.
      LanSentMarks.noteStatus(response.statusCode);
      await onAnswer?.call(request, bytes, response);
      return _refusedOrAccepted(request, bytes, response);
    }

    try {
      return await answered(attempt());
    } on http.ClientException {
      if (!await connection.failover()) rethrow;
    } on SocketException {
      if (!await connection.failover()) rethrow;
    } on TlsException {
      if (!await connection.failover()) rethrow;
    } on TimeoutException {
      if (!await connection.failover()) rethrow;
    }
    return answered(attempt());
  }
}
