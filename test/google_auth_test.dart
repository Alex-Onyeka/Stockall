import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/google_auth/auth_routing.dart';

TempUserClass details({
  String email = '',
  String password = '',
}) {
  return TempUserClass(
    access: [],
    userId: 'ignored',
    createdAt: DateTime(2026, 10, 16),
    name: 'Ada',
    lastName: 'Obi',
    email: email,
    phone: '+2348000000000',
    role: 'Cashier',
    password: password,
    departmentUuids: ['should-be-dropped'],
  );
}

void main() {
  group('resolveAuthDestination', () {
    test('no session goes to the auth screens', () {
      expect(
        resolveAuthDestination(
          hasSession: false,
          profileExists: null,
        ),
        AuthDestination.authScreens,
      );
      expect(
        resolveAuthDestination(
          hasSession: false,
          profileExists: true,
        ),
        AuthDestination.authScreens,
      );
    });

    test('existing user (profile exists) continues like a normal login', () {
      expect(
        resolveAuthDestination(
          hasSession: true,
          profileExists: true,
        ),
        AuthDestination.home,
      );
    });

    test('new user (no profile) goes to Complete your details', () {
      expect(
        resolveAuthDestination(
          hasSession: true,
          profileExists: false,
        ),
        AuthDestination.completeDetails,
      );
    });

    test(
      'incomplete user on next launch/login (session, still no profile) is sent back to details',
      () {
        // First sign-in, then the user quits; next resolve sees the same state.
        for (var i = 0; i < 2; i++) {
          expect(
            resolveAuthDestination(
              hasSession: true,
              profileExists: false,
            ),
            AuthDestination.completeDetails,
          );
        }
      },
    );

    test('unknown profile (offline/error) keeps the old Home behaviour', () {
      expect(
        resolveAuthDestination(
          hasSession: true,
          profileExists: null,
        ),
        AuthDestination.home,
      );
    });
  });

  group('buildUserProfileRow', () {
    test('Google user: uses the Google email and an empty password', () {
      final row = buildUserProfileRow(
        details: details(),
        userId: 'auth-123',
        email: 'ada@gmail.com',
      );
      expect(row.userId, 'auth-123');
      expect(row.authUserId, 'auth-123');
      expect(row.email, 'ada@gmail.com');
      expect(row.password, '');
      expect(row.role, 'Cashier');
      expect(row.name, 'Ada');
      expect(row.lastName, 'Obi');
      expect(row.phone, '+2348000000000');
      expect(row.departmentUuids, isEmpty);

      final json = row.toJson();
      expect(json['email'], 'ada@gmail.com');
      expect(json['user_id'], 'auth-123');
      expect(json['auth_user_id'], 'auth-123');
    });

    test('email/password user: same row as before the refactor', () {
      final input = details(
        email: 'ada@example.com',
        password: 'secret1',
      );
      final row = buildUserProfileRow(
        details: input,
        userId: 'auth-456',
        email: input.email,
      );
      expect(row.toJson(), {
        'name': 'Ada',
        'last_name': 'Obi',
        'email': 'ada@example.com',
        'phone': '+2348000000000',
        'role': 'Cashier',
        'password': 'secret1',
        'auth_user_id': 'auth-456',
        'department_uuid': null,
        'department_name': null,
        'pin': null,
        'department_uuids': <String>[],
        'access': <String>[],
        'user_id': 'auth-456',
        'created_at': DateTime(2026, 10, 16).toIso8601String(),
      });
    });
  });

  group('parseOAuthCallback', () {
    test('code is returned', () {
      final r = parseOAuthCallback(
        Uri.parse('http://127.0.0.1:43823/auth-callback?code=abc'),
      );
      expect(r.status, OAuthCallbackStatus.code);
      expect(r.code, 'abc');
    });

    test('user cancelled on Google', () {
      final r = parseOAuthCallback(
        Uri.parse(
          'http://127.0.0.1:43823/auth-callback?error=access_denied',
        ),
      );
      expect(r.status, OAuthCallbackStatus.cancelled);
    });

    test('other errors carry the description', () {
      final r = parseOAuthCallback(
        Uri.parse(
          'http://127.0.0.1:43823/auth-callback?error=server_error&error_description=Bad+config',
        ),
      );
      expect(r.status, OAuthCallbackStatus.error);
      expect(r.message, 'Bad config');
    });

    test('nothing in the URL is an error', () {
      final r = parseOAuthCallback(
        Uri.parse('http://127.0.0.1:43823/auth-callback'),
      );
      expect(r.status, OAuthCallbackStatus.error);
    });
  });
}
