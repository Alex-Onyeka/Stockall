import 'package:flutter/foundation.dart';

// Google sign-in configuration.
// Only public client IDs belong here. The Google client SECRET is set in the
// Supabase dashboard (Auth > Providers > Google) and must never be in the app.

/// Google Cloud "Web application" OAuth client ID.
/// Used as `serverClientId` on Android so the ID token is issued for this
/// client, which Supabase verifies. Also the client Supabase uses for the
/// browser OAuth flow on Windows and web.
const String googleWebClientId =
    _googleWebClientIdPlaceholder;

const String _googleWebClientIdPlaceholder =
    'REPLACE_WITH_WEB_CLIENT_ID.apps.googleusercontent.com';

/// False until the real Web client ID replaces the placeholder above.
/// While false, the Google button is hidden everywhere.
bool get isGoogleClientIdConfigured =>
    googleWebClientId != _googleWebClientIdPlaceholder &&
    googleWebClientId.trim().isNotEmpty;

/// Port the Windows app listens on (loopback only) for the OAuth redirect.
const int googleDesktopRedirectPort = 43823;

/// Path of the Windows OAuth redirect.
const String googleDesktopRedirectPath = '/auth-callback';

/// Must be listed in Supabase > Auth > URL Configuration > Redirect URLs.
const String googleDesktopRedirectUrl =
    'http://127.0.0.1:$googleDesktopRedirectPort$googleDesktopRedirectPath';

/// How long the Windows flow waits for the browser before giving up.
const Duration googleDesktopSignInTimeout = Duration(minutes: 5);

bool get isGoogleSignInAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

bool get isGoogleSignInWindows =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

/// Google sign-in is offered on Android, Windows and web only, and only once
/// the Web client ID is configured.
bool get isGoogleSignInSupported =>
    isGoogleClientIdConfigured &&
    (kIsWeb || isGoogleSignInAndroid || isGoogleSignInWindows);
