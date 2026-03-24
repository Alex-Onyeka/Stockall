import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
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

  Future<String?> signUpAndCreateUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      var account =
          await client
              .from('users')
              .select()
              .eq('email', email)
              .maybeSingle();
      if (account == null) {
        final signUpRes = await _client.auth.signUp(
          email: email,
          password: password,
        );

        final userId = signUpRes.user?.id;

        if (userId == null) {
          print('Failed to sign up user.');
          return null;
        }

        returnNavProvider(
          context,
          listen: false,
        ).offLoading();

        return signUpRes.user?.id;
      } else {
        return 'exists';
      }
    } catch (e) {
      print('Error Creating User Account: ${e.toString()}');
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message:
                '${e.toString().split('(')[1].split(':')[1].split('.').first}.',
            title: 'An Error Occurred',
          );
        },
      );
      return null;
    }
  }

  Future<void> resendVerificationLink(
    String email,
    String password,
  ) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print('Success');
    } catch (e) {
      print('Error: ${e.toString()}');
    }
  }

  Future<int> verifyOtp({
    required String otp,
    required TempUserClass user,
    required BuildContext context,
    required String userId,
    String? newEmail,
  }) async {
    try {
      await _client.auth.verifyOTP(
        type:
            newEmail == null
                ? OtpType.signup
                : OtpType.emailChange,
        email: newEmail ?? user.email,
        token: otp,
      );

      // Build user row
      final userRow = TempUserClass(
        userId: userId,
        createdAt: user.createdAt,
        name: user.name,
        lastName: user.lastName,
        email: newEmail ?? user.email,
        pin: user.pin,
        phone: user.phone,
        role: user.role,
        authUserId: userId,
        password: user.password,
        departmentUuids: [],
        access: user.access,
      );

      // if (newEmail != null) {
      // Insert into Supabase
      await _client.from('users').upsert(userRow.toJson());
      // } else {
      //   await _client
      //       .from('users')
      //       .update({'email': newEmail})
      //       .eq('user_id', userId);
      // }

      if (context.mounted) {
        returnNavProvider(context, listen: false).verify();
      }
      print(
        newEmail != null
            ? 'Email Changed Successfully'
            : 'Email Verified Successfully',
      );
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }

  bool checkEmailVerified() {
    // await Supabase.instance.client.auth.refreshSession();

    final user = Supabase.instance.client.auth.currentUser;

    return user?.emailConfirmedAt != null;
  }

  Future<void> sendEmailResetOtp(String emaill) async {
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: emaill),
      );
      print('Email reset OTP sent.');
    } catch (e) {
      print('Error sending OTP to email: $e');
    }
  }

  Future<void> resendEmailChangeVerificationOTP(
    String email,
  ) async {
    try {
      await _client.auth.resend(
        type: OtpType.emailChange,
        email: email,
        // emailRedirectTo:
        //     "https://www.stockallapp.com/#/check-verification",
      );
      print('Email Change OTP Resent Success');
    } catch (e) {
      print('Error: ${e.toString()}');
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
        print('❌❌Offline Login Error: ${e.toString()}');
        return 0;
      }
    }
  }

  Future<void> signOut(BuildContext context) async {
    returnCustomers(
      context,
      listen: false,
    ).clearCustomers();
    returnData().clearProducts();
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenses();
    returnNotificationProvider(
      context,
      listen: false,
    ).clearNotifications();
    // returnSuggestionProvider(
    //   context,
    //   listen: false,
    // ).clearSuggestionsMain();
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceipts();
    returnReceiptProvider(
      context,
      listen: false,
    ).load(false);
    await CurrentShopFunc().clearCurrentShop();
    returnSalesProvider().clearCart();
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
      returnShopProvider().clearShop();
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

  Future<String> changePasswordAndUpdateLocal({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
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

  User? get currentUserAuth => _client.auth.currentUser;

  TempUserClass? get currentUserOffline =>
      LoggedInUserFunc().getLoggedInUser()?.loggedInUser;

  String? get currentUser =>
      _client.auth.currentUser?.id ??
      LoggedInUserFunc()
          .getLoggedInUser()
          ?.loggedInUser
          ?.userId;

  String? get currentUserEmail =>
      _client.auth.currentUser?.email ??
      LoggedInUserFunc()
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

  Future<int> deleteUserAccount(
    BuildContext context,
  ) async {
    try {
      // 1. Get the current user
      final user = _client.auth.currentUser;

      if (user == null) {
        print("No user is currently signed in.");
        return 0;
      }

      final response = await _client.functions.invoke(
        'delete-user',
        body: {'userId': user.id},
      );

      if (response.status == 200) {
        print(
          "User deleted successfully: ${response.data}",
        );
        await returnShopProvider().removeEmployeeFromShop(
          employeeIdToRemove:
              returnUserProvider(
                context,
                listen: false,
              ).currentUserMain!.userId!,
          context: context,
        );
        await returnUserProvider(
          context,
          listen: false,
        ).deleteUser(user.id);
        await signOut(context);
        return 1;
      } else {
        print(
          "Error Deleting User Account: ${response.data}",
        );
        return 0;
      }
    } catch (e) {
      print("Error Deleting User Account: ${e.toString()}");
      return 0;
    }
  }
}
