import 'package:http/http.dart' as http;
import 'package:stockall/services/lan/lan_connection.dart';
import 'package:stockall/services/lan/lan_constants.dart';
import 'package:stockall/services/remote/lan_http_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A `SupabaseClient` whose REST, RPC and storage calls go to the paired
/// LAN server instead of Supabase. The providers' query code runs on it
/// unchanged, and server errors arrive as the same `PostgrestException`s.
///
/// io only: import it from io code (the transport) and tests, never from
/// code compiled for web. `auth` is not available on it (LAN login is
/// `LocalServerProvider.loginViaLan`). Make one per connection and call
/// `dispose()` when the connection ends: each client runs its own
/// JSON-decoding isolate.
SupabaseClient createLanRemote({
  required LanConnection connection,
  required String token,
  required String deviceId,
  Future<void> Function(
    http.BaseRequest request,
    List<int> body,
    http.StreamedResponse response,
  )?
  onAnswer,
}) {
  return SupabaseClient(
    'https://${LanConstants.tlsHost}:${connection.current.port}',
    // Not a Supabase key: the LAN server authorizes by session token.
    'stockall-lan',
    httpClient: LanHttpClient(
      connection,
      deviceId: deviceId,
      onAnswer: onAnswer,
    ),
    accessToken: () async => token,
  );
}
