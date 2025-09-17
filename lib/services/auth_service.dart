import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  bool isLoading = false;
  bool isSuccessLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
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
      lastName: user.lastName,
      email: email,
      phone: user.phone,
      role: user.role,
      authUserId: userId,
      password: password,
    );

    try {
      // Check if user exists remotely (optional)
      await _client
          .from('users')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      // Insert into Supabase
      await _client.from('users').insert(userRow.toJson());

      // ✅ Insert into local SQLite
      if (context.mounted) {
        returnNavProvider(context, listen: false).verify();
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
        // await returnLocalDatabase(
        //   context,
        //   listen: false,
        // ).insertUser(userRow);
      }

      return signUpRes;
    } catch (e) {
      throw Exception('User creation error: $e');
    }
  }

  Future<AuthResponse> signIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      // 1. Sign in via Supabase Auth
      final authResponse = await _client.auth
          .signInWithPassword(
            email: email,
            password: password,
          );

      final user = authResponse.user;
      if (user == null) {
        throw Exception("No user returned from sign-in.");
      }

      final userId = user.id;

      // 2. Query the 'users' table using the auth_user_id
      final response =
          await _client
              .from('users')
              .select()
              .eq('user_id', userId)
              .single();

      // 3. Convert Supabase response into TempUserClass
      final tempUser = TempUserClass.fromJson({
        ...response,
        'password':
            password, // Optional: if you're keeping it
      });

      if (context.mounted) {
        returnNavProvider(context, listen: false).verify();
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
      }

      print(
        "✅ User signed in and saved locally: ${tempUser.email}",
      );
      return authResponse;
    } catch (e) {
      print("❌ Sign-in failed: $e");
      rethrow;
    } finally {}
  }

  Future<String> changePasswordAndUpdateLocal({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      // 🔐 Step 1: Change in Supabase Auth
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      final user = response.user;
      if (user == null) {
        throw Exception(
          "Password update failed: No user returned.",
        );
      }

      print(
        "🔐 Password successfully updated in Supabase Auth for ${user.email}",
      );

      print("Updating user with ID: ${user.id}");

      // ✅ Step 2: Update password in your 'users' table
      final updateResponse =
          await _client
              .from('users')
              .update({'password': newPassword})
              .eq('user_id', user.id)
              .select()
              .maybeSingle();

      // 4. Store the user in local DB
      print("context.mounted = ${context.mounted}");
      if (context.mounted) {
        print("✅ Inserting Users into the Local");
        await returnUserProvider(
          context,
          listen: false,
        ).fetchCurrentUser(context);
        return 'Success';
      } else {
        print(
          "⚠️ Context no longer mounted, skipping local insert",
        );
      }

      print(
        "✅ Password updated in 'users' table: $updateResponse",
      );
      return 'Success';
    } on AuthException catch (e) {
      print('Error Changing Password: $e');
      return e.statusCode!;
    } catch (e) {
      print(e);
      return e.toString();
    }
  }

  Future<void> signOut(BuildContext context) async {
    await _client.auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AuthScreensPage();
          },
        ),
      );
      returnNavProvider(context, listen: false).navigate(0);
      returnShopProvider(
        context,
        listen: false,
      ).clearShop();
      returnCustomers(
        context,
        listen: false,
      ).clearCustomers();
      returnUserProvider(
        context,
        listen: false,
      ).clearUsers();
      returnData(context, listen: false).clearProducts();
      returnExpensesProvider(
        context,
        listen: false,
      ).clearExpenses();
      returnNotificationProvider(
        context,
        listen: false,
      ).clearNotifications();
      returnSuggestionProvider(
        context,
        listen: false,
      ).clearSuggestionsMain();
      returnReceiptProvider(
        context,
        listen: false,
      ).clearReceipts();
      returnSalesProvider(
        context,
        listen: false,
      ).clearCart();
    }

    notifyListeners();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
            email,
            redirectTo:
                'https://www.stockallapp.com/#/reset-password',
          );
      print('Password reset email sent.');
    } catch (e) {
      print('Error sending reset email: $e');
    }
  }

  TempUserClass? get currentUser =>
      LoggedInUserFunc().getUser()?.loggedInUser;

  User? get currentUserAuth => _client.auth.currentUser;
}
