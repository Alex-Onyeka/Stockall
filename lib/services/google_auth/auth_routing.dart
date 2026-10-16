// Pure routing helpers for sign-in. Kept free of Flutter/Supabase so they can
// be unit tested.

enum AuthDestination { authScreens, completeDetails, home }

/// Where to send the user after a sign-in, or on startup with a session.
///
/// [profileExists] is null when it could not be checked (offline or error).
/// In that case we fall back to [AuthDestination.home], which is how the app
/// behaved before Google sign-in existed.
AuthDestination resolveAuthDestination({
  required bool hasSession,
  required bool? profileExists,
}) {
  if (!hasSession) return AuthDestination.authScreens;
  if (profileExists == false) {
    return AuthDestination.completeDetails;
  }
  return AuthDestination.home;
}

/// The Google account's email already belongs to a different Stockall
/// profile, and Supabase did not link the two.
class EmailInUseException implements Exception {
  final String email;
  const EmailInUseException(this.email);

  @override
  String toString() => 'EmailInUseException: $email';
}

/// [redirecting]: web only. The page is navigating to Google and the flow
/// continues when the app reloads (BasePage picks up the session).
enum GoogleAuthStatus {
  success,
  redirecting,
  cancelled,
  noNetwork,
  error,
}

class GoogleAuthOutcome {
  final GoogleAuthStatus status;
  final String? message;

  const GoogleAuthOutcome(this.status, {this.message});

  static const success = GoogleAuthOutcome(
    GoogleAuthStatus.success,
  );
  static const cancelled = GoogleAuthOutcome(
    GoogleAuthStatus.cancelled,
  );
  static const noNetwork = GoogleAuthOutcome(
    GoogleAuthStatus.noNetwork,
  );

  factory GoogleAuthOutcome.error(String message) =>
      GoogleAuthOutcome(
        GoogleAuthStatus.error,
        message: message,
      );
}

enum OAuthCallbackStatus { code, cancelled, error }

class OAuthCallbackResult {
  final OAuthCallbackStatus status;
  final String? code;
  final String? message;

  const OAuthCallbackResult(
    this.status, {
    this.code,
    this.message,
  });
}

/// Reads the redirect Supabase sends back after the browser OAuth flow.
OAuthCallbackResult parseOAuthCallback(Uri uri) {
  final params = uri.queryParameters;
  final code = params['code'];
  if (code != null && code.isNotEmpty) {
    return OAuthCallbackResult(
      OAuthCallbackStatus.code,
      code: code,
    );
  }
  final error = params['error'];
  if (error == 'access_denied') {
    return const OAuthCallbackResult(
      OAuthCallbackStatus.cancelled,
    );
  }
  return OAuthCallbackResult(
    OAuthCallbackStatus.error,
    message:
        params['error_description'] ??
        error ??
        'No authorization code returned.',
  );
}
