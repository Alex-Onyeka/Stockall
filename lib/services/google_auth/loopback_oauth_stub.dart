// Used on web, where the browser OAuth flow redirects the page itself.
import 'package:stockall/services/google_auth/auth_routing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoopbackOAuth {
  Future<GoogleAuthOutcome> signInWithGoogle(
    SupabaseClient client,
  ) async {
    return GoogleAuthOutcome.error(
      'Google sign-in through a local redirect is not available on this platform.',
    );
  }

  Future<void> cancel() async {}
}
