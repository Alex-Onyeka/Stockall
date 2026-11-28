import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// No SharedPreferences under `flutter test`.
class MemoryAsyncStorage extends GotrueAsyncStorage {
  final _items = <String, String>{};

  @override
  Future<String?> getItem({required String key}) async => _items[key];

  @override
  Future<void> setItem({required String key, required String value}) async {
    _items[key] = value;
  }

  @override
  Future<void> removeItem({required String key}) async {
    _items.remove(key);
  }
}

/// Routing through `backend()` must not change behaviour: with routing off, every
/// provider's `backend()` is the very same `Supabase.instance.client`.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://router.test',
      anonKey: 'test-anon-key',
      authOptions: FlutterAuthClientOptions(
        localStorage: const EmptyLocalStorage(),
        pkceAsyncStorage: MemoryAsyncStorage(),
        detectSessionInUri: false,
        autoRefreshToken: false,
      ),
    );
  });

  test('routing off: backend() is Supabase.instance.client itself', () {
    expect(RemoteRouter.usingLan, isFalse);
    expect(identical(backend(), Supabase.instance.client), isTrue);
  });

  test('switching LAN on and off again restores Supabase', () async {
    final other = SupabaseClient(
      'https://other.test',
      'k',
      accessToken: () async => 't',
    );
    addTearDown(other.dispose);

    RemoteRouter.debugUseLan(other);
    expect(identical(backend(), other), isTrue);

    RemoteRouter.useSupabase();
    expect(identical(backend(), Supabase.instance.client), isTrue);
  });
}
