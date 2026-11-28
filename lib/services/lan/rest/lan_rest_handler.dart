import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/postgrest_request.dart';
import 'package:stockall/services/lan/rest/postgrest_response.dart';

/// Answers `/rest/v1/*` for a signed-in member. `HiveRestEngine`
/// implements it; tests use fakes. Throw [PgError] for PostgREST errors.
abstract class LanRestHandler {
  Future<PgResponse> handle(PgRequest request, LanPrincipal principal);
}
