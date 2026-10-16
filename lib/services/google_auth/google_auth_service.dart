import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stockall/constants/google_auth_config.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/google_auth/auth_routing.dart';
import 'package:stockall/services/google_auth/loopback_oauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// "Continue with Google".
/// - Android: native account picker (google_sign_in), then Supabase
///   `signInWithIdToken`.
/// - Windows: Supabase browser OAuth with a loopback redirect.
/// - Web: Supabase browser OAuth with a full-page redirect.
class GoogleAuthService {
  static final GoogleAuthService _instance =
      GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  SupabaseClient get _client => Supabase.instance.client;

  final LoopbackOAuth _loopback = LoopbackOAuth();
  Future<void>? _androidInit;

  Future<void> _ensureAndroidInitialized() {
    return _androidInit ??= GoogleSignIn.instance.initialize(
      serverClientId: googleWebClientId,
    );
  }

  Future<GoogleAuthOutcome> signIn() async {
    if (!isGoogleSignInSupported) {
      return GoogleAuthOutcome.error(
        'Google sign-in is not available on this device.',
      );
    }
    if (!await ConnectivityProvider().isOnline()) {
      return GoogleAuthOutcome.noNetwork;
    }

    if (kIsWeb) return _signInWeb();
    if (isGoogleSignInAndroid) return _signInAndroid();
    return _loopback.signInWithGoogle(_client);
  }

  /// Stops a pending Windows browser sign-in.
  Future<void> cancelPending() => _loopback.cancel();

  Future<GoogleAuthOutcome> _signInAndroid() async {
    try {
      await _ensureAndroidInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        return GoogleAuthOutcome.error(
          'Google did not return an ID token. Please try again.',
        );
      }
      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );
      return GoogleAuthOutcome.success;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return GoogleAuthOutcome.cancelled;
      }
      await mainLocalLog('Google sign-in error: $e');
      return GoogleAuthOutcome.error(
        e.description ?? 'Google sign-in failed. Please try again.',
      );
    } on AuthRetryableFetchException catch (e) {
      await mainLocalLog('Google sign-in network error: $e');
      return GoogleAuthOutcome.noNetwork;
    } on AuthException catch (e) {
      await mainLocalLog('Google sign-in auth error: $e');
      return GoogleAuthOutcome.error(e.message);
    } catch (e) {
      await mainLocalLog('Google sign-in error: $e');
      return GoogleAuthOutcome.error(e.toString());
    }
  }

  Future<GoogleAuthOutcome> _signInWeb() async {
    try {
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: '${Uri.base.origin}/',
        queryParams: {'prompt': 'select_account'},
      );
      return const GoogleAuthOutcome(
        GoogleAuthStatus.redirecting,
      );
    } catch (e) {
      await mainLocalLog('Google sign-in error: $e');
      return GoogleAuthOutcome.error(e.toString());
    }
  }

  /// Signs out of Google so the account picker shows next time.
  /// Only Android keeps a Google session in the app; Windows and web always
  /// ask with `prompt=select_account`.
  Future<void> signOut() async {
    if (!isGoogleSignInAndroid || !isGoogleClientIdConfigured) {
      return;
    }
    try {
      await _ensureAndroidInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      await mainLocalLog('Google sign-out error: $e');
    }
  }
}
