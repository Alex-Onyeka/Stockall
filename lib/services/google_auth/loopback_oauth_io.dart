import 'dart:async';
import 'dart:io';

import 'package:stockall/constants/google_auth_config.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/google_auth/auth_routing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

/// Desktop (Windows) Google sign-in through Supabase's browser OAuth flow.
///
/// The app listens on a loopback-only port, opens the browser, and waits for
/// Supabase to redirect back to [googleDesktopRedirectUrl] with a PKCE code,
/// which it then exchanges for a session.
class LoopbackOAuth {
  HttpServer? _server;
  Completer<OAuthCallbackResult?>? _pending;

  Future<GoogleAuthOutcome> signInWithGoogle(
    SupabaseClient client,
  ) async {
    await cancel();

    final HttpServer server;
    try {
      server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        googleDesktopRedirectPort,
      );
    } on SocketException catch (e) {
      await mainLocalLog(
        'Google sign-in: could not bind port $googleDesktopRedirectPort: $e',
      );
      return GoogleAuthOutcome.error(
        'Google sign-in could not start because port $googleDesktopRedirectPort is being used by another program. Close that program and try again.',
      );
    }
    _server = server;
    final pending = Completer<OAuthCallbackResult?>();
    _pending = pending;

    server.listen((request) async {
      if (request.uri.path != googleDesktopRedirectPath) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      final result = parseOAuthCallback(request.uri);
      request.response.headers.contentType = ContentType.html;
      request.response.write(
        _callbackPage(
          result.status == OAuthCallbackStatus.code,
        ),
      );
      await request.response.close();
      if (!pending.isCompleted) pending.complete(result);
    });

    try {
      final res = await client.auth.getOAuthSignInUrl(
        provider: OAuthProvider.google,
        redirectTo: googleDesktopRedirectUrl,
        queryParams: {'prompt': 'select_account'},
      );
      final launched = await launchUrl(
        Uri.parse(res.url),
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        return GoogleAuthOutcome.error(
          'Could not open your web browser to sign in with Google.',
        );
      }

      final result = await pending.future.timeout(
        googleDesktopSignInTimeout,
        onTimeout:
            () => const OAuthCallbackResult(
              OAuthCallbackStatus.error,
              message:
                  'Google sign-in timed out. Please try again.',
            ),
      );

      // null means cancel() was called from the UI.
      if (result == null) return GoogleAuthOutcome.cancelled;

      switch (result.status) {
        case OAuthCallbackStatus.cancelled:
          return GoogleAuthOutcome.cancelled;
        case OAuthCallbackStatus.error:
          await mainLocalLog(
            'Google sign-in callback error: ${result.message}',
          );
          return GoogleAuthOutcome.error(
            result.message ??
                'Google sign-in failed. Please try again.',
          );
        case OAuthCallbackStatus.code:
          await client.auth.exchangeCodeForSession(
            result.code!,
          );
          await _bringAppToFront();
          return GoogleAuthOutcome.success;
      }
    } on AuthRetryableFetchException catch (e) {
      await mainLocalLog('Google sign-in network error: $e');
      return GoogleAuthOutcome.noNetwork;
    } on SocketException catch (e) {
      await mainLocalLog('Google sign-in network error: $e');
      return GoogleAuthOutcome.noNetwork;
    } on AuthException catch (e) {
      await mainLocalLog('Google sign-in auth error: $e');
      return GoogleAuthOutcome.error(e.message);
    } catch (e) {
      await mainLocalLog('Google sign-in error: $e');
      return GoogleAuthOutcome.error(e.toString());
    } finally {
      // Only clear state that still belongs to this attempt.
      if (identical(_server, server)) {
        _server = null;
        _pending = null;
      }
      await server.close(force: true);
    }
  }

  /// Stops waiting for the browser. The pending sign-in returns cancelled.
  Future<void> cancel() async {
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.complete(null);
    }
    await _close();
  }

  Future<void> _close() async {
    _pending = null;
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<void> _bringAppToFront() async {
    try {
      await windowManager.show();
      await windowManager.focus();
    } catch (e) {
      await mainLocalLog('Could not focus window: $e');
    }
  }

  String _callbackPage(bool success) {
    final message =
        success
            ? 'You are signed in. You can close this tab and return to Stockall.'
            : 'Sign-in was not completed. You can close this tab and return to Stockall.';
    return '<!doctype html><html><head><meta charset="utf-8">'
        '<title>Stockall</title></head>'
        '<body style="font-family:sans-serif;text-align:center;padding-top:80px">'
        '<h2>Stockall</h2><p>$message</p></body></html>';
  }
}
