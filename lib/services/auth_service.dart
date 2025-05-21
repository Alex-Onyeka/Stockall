import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_user_class.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccessLoading = false;

  void switchLoader() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void switchSuccessLoader() {
    isSuccessLoading = !isSuccessLoading;
    notifyListeners();
  }

  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  Future<AuthResponse> signUpAndCreateUser({
    required BuildContext context,
    required String email,
    required String password,
    required TempUserClass user,
  }) async {
    final signUpRes = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final userId = signUpRes.user?.id;

    if (userId == null) {
      throw Exception('Failed to sign up user.');
    }

    // Build user row
    final userRow = TempUserClass(
      userId: userId,
      createdAt: DateTime.now(),
      name: user.name,
      email: email,
      phone: user.phone,
      role: user.role,
      authUserId: userId,
      password: password,
    );

    try {
      await _client
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // if (existingUserResponse != null) {
      //   // print("User already exists, skipping insert.");
      //   return ;
      // }

      await _client.from('users').insert(userRow.toJson());
      return signUpRes;
    } catch (e) {
      throw Exception('User creation error: $e');
    }
  }

  Future<AuthResponse> signIn(
    String email,
    String password,
  ) {
    switchLoader();
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    notifyListeners();
  }

  User? get currentUser => _client.auth.currentUser;
}
