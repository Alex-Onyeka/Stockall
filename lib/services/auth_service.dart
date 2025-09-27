import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends ChangeNotifier {
  ConnectivityProvider connectivity =
      ConnectivityProvider();
  bool isLoading = false;
  bool isSuccessLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  final SupabaseClient _client = Supabase.instance.client;

  Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  SupabaseClient get client => _client;

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

  Future<int> signIn(
    String email,
    String password,
    // BuildContext context,
  ) async {
    NavProvider navProvider = NavProvider();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
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

        final response =
            await _client
                .from('users')
                .select()
                .eq('user_id', userId)
                .single();

        final tempUser = TempUserClass.fromJson({
          ...response,
          'password': password,
        });

        await LoggedInUserFunc().insertLoggedInUser(
          LoggedInUser(loggedInUser: tempUser),
        );
        print('Offline User Logged In');

        await UserFunc().insertUser(tempUser);
        print('Offline User Insertted');

        navProvider.verify();
        navProvider.offLoading();

        print(
          "✅ User signed in and saved locally: ${tempUser.email}",
        );

        return 1;
      } catch (e) {
        print("❌ Sign-in failed: ${e.toString()}");
        return 0;
      }
    } else {
      try {
        TempUserClass? user = UserFunc()
            .offlineLoginByEmailandPassword(
              password,
              email,
            );
        print(user?.name);

        if (user != null) {
          print('Offline User Found');
          LoggedInUserFunc().insertLoggedInUser(
            LoggedInUser(loggedInUser: user),
          );
          print('Offline User Logged In');

          return 1;
        } else {
          print('Offline User Not Found');
          return 0;
        }
      } catch (e) {
        print('Offline Login Error: ${e.toString()}');
        return 0;
      }
    }
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
    returnCustomers(
      context,
      listen: false,
    ).clearCustomers();
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
    returnReceiptProvider(
      context,
      listen: false,
    ).load(false);
    returnSalesProvider(context, listen: false).clearCart();
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      await _client.auth.signOut();
      await LoggedInUserFunc().logOut();
    } else {
      await LoggedInUserFunc().logOut();
    }
    if (context.mounted) {
      returnNavProvider(context, listen: false).navigate(0);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            return AuthScreensPage();
          },
        ),
      );
      returnShopProvider(
        context,
        listen: false,
      ).clearShop();
      returnUserProvider(
        context,
        listen: false,
      ).clearUsers();
    } else {
      print('Context is Not Mounted');
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

  User? get currentUserAuth => _client.auth.currentUser;

  TempUserClass? get currentUserOffline =>
      LoggedInUserFunc().getLoggedInUser()?.loggedInUser;

  String? get currentUser =>
      // connectivity.isConnected
      _client.auth.currentUser?.id ??
      LoggedInUserFunc()
          .getLoggedInUser()
          ?.loggedInUser
          ?.userId;

  String? get currentUserEmail =>
      connectivity.isConnected
          ? _client.auth.currentUser?.email
          : LoggedInUserFunc()
              .getLoggedInUser()
              ?.loggedInUser
              ?.email;

  Future<String?> checkAuth() async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print('Online Auth Validated');
      return currentUserAuth?.id;
    } else {
      print('Offline Auth Validated');
      return LoggedInUserFunc()
          .getLoggedInUser()
          ?.loggedInUser
          ?.userId;
    }
  }
}
