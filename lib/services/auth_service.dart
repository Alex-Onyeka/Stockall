import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/users/user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthResult {
  final bool ok;
  final String code;
  final String message;
  final String? userId;

  const AuthResult({
    required this.ok,
    required this.code,
    this.message = '',
    this.userId,
  });
}

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

  SupabaseClient get client => _client;

  Future<AuthResult> signUpWithResult({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final account =
          await client
              .from('users')
              .select('user_id')
              .eq('email', cleanEmail)
              .maybeSingle();
      if (account != null) {
        return const AuthResult(
          ok: false,
          code: 'exists',
          message:
              'This email is already associated with an existing account. Please log in instead.',
        );
      }

      final signUpRes = await _client.auth.signUp(
        email: cleanEmail,
        password: password,
      );

      final user = signUpRes.user;
      final userId = user?.id;

      if (userId == null) {
        await mainLocalLog('Failed to sign up user.');
        return const AuthResult(
          ok: false,
          code: 'signup_failed',
          message: 'Failed to create user account. Please try again.',
        );
      }

      // Supabase returns a user with empty identities when the email already
      // exists in auth.users (e.g. an abandoned unconfirmed signup).
      if (user?.identities != null && user!.identities!.isEmpty) {
        try {
          await _client.auth.resend(
            type: OtpType.signup,
            email: cleanEmail,
          );
          return AuthResult(
            ok: true,
            code: 'unconfirmed_resent',
            userId: userId,
            message:
                'A verification code has been resent to your email.',
          );
        } catch (_) {
          return const AuthResult(
            ok: false,
            code: 'exists',
            message:
                'This email is already registered. Please log in to continue.',
          );
        }
      }

      return AuthResult(
        ok: true,
        code: 'ok',
        userId: userId,
      );
    } on AuthException catch (e) {
      await mainLocalLog('AuthException Creating User Account: ${e.message}');
      final msg = e.message.toLowerCase();
      if (e.statusCode == '422' || msg.contains('already registered')) {
        try {
          await _client.auth.resend(
            type: OtpType.signup,
            email: cleanEmail,
          );
          return const AuthResult(
            ok: false,
            code: 'unconfirmed_exists',
            message:
                'This email was already registered but not verified. A new verification code has been sent — please check your email or try logging in.',
          );
        } catch (_) {
          return const AuthResult(
            ok: false,
            code: 'exists',
            message:
                'User already exists. Please use a different email, or try to login.',
          );
        }
      }
      if (e.statusCode == null) {
        return const AuthResult(
          ok: false,
          code: 'network',
          message:
              'No internet connection. Please check your network and try again.',
        );
      }
      return AuthResult(
        ok: false,
        code: e.statusCode ?? 'auth_error',
        message: e.message.isNotEmpty
            ? e.message
            : 'An error occurred. Please try again later.',
      );
    } on SocketException catch (_) {
      return const AuthResult(
        ok: false,
        code: 'network',
        message:
            'No internet connection. Please check your network and try again.',
      );
    } catch (e) {
      await mainLocalLog('Error Creating User Account: ${e.toString()}');
      return const AuthResult(
        ok: false,
        code: 'unknown',
        message:
            'An error occurred while creating your account. Please try again.',
      );
    }
  }

  Future<String?> signUpAndCreateUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final res = await signUpWithResult(email: email, password: password);
    if (res.ok) {
      if (context.mounted) {
        returnNavProvider(context, listen: false).offLoading();
      }
      return res.userId;
    }
    if (res.code == 'exists') return 'exists';
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message: res.message,
            title: 'An Error Occurred',
          );
        },
      );
    }
    return null;
  }

  Future<AuthResult> resendVerificationLinkWithResult(
    String email,
  ) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim().toLowerCase(),
      );
      await mainLocalLog('Success');
      return const AuthResult(ok: true, code: 'ok');
    } on AuthException catch (e) {
      await mainLocalLog('Error: ${e.message}');
      return AuthResult(
        ok: false,
        code: e.statusCode ?? 'auth_error',
        message: e.message.isNotEmpty
            ? e.message
            : 'Could not resend verification code. Please try again.',
      );
    } on SocketException catch (_) {
      return const AuthResult(
        ok: false,
        code: 'network',
        message:
            'No internet connection. Please check your network and try again.',
      );
    } catch (e) {
      await mainLocalLog('Error: ${e.toString()}');
      return const AuthResult(
        ok: false,
        code: 'unknown',
        message: 'Could not resend verification code. Please try again.',
      );
    }
  }

  Future<void> resendVerificationLink(
    String email,
    String password,
  ) async {
    await resendVerificationLinkWithResult(email);
  }

  Future<AuthResult> verifyOtpWithResult({
    required String otp,
    required TempUserClass user,
    required BuildContext context,
    required String userId,
    String? newEmail,
  }) async {
    try {
      final cleanEmail = (newEmail ?? user.email).trim().toLowerCase();
      await _client.auth.verifyOTP(
        type:
            newEmail == null
                ? OtpType.signup
                : OtpType.emailChange,
        email: cleanEmail,
        token: otp.trim(),
      );

      // Build user row
      final userRow = TempUserClass(
        userId: userId,
        createdAt: user.createdAt,
        name: user.name,
        lastName: user.lastName,
        email: cleanEmail,
        pin: user.pin,
        phone: user.phone,
        role: user.role,
        authUserId: userId,
        password: user.password,
        departmentUuids: [],
        access: user.access,
      );

      if (newEmail == null) {
        // Insert into Supabase
        await _client
            .from('users')
            .upsert(userRow.toJson());
      } else {
        await _client
            .from('users')
            .update({'email': newEmail.trim().toLowerCase()})
            .eq('user_id', userId);
      }

      if (context.mounted) {
        returnNavProvider(context, listen: false).verify();
      }
      await mainLocalLog(
        newEmail != null
            ? 'Email Changed Successfully'
            : 'Email Verified Successfully',
      );
      return AuthResult(ok: true, code: 'ok', userId: userId);
    } on AuthException catch (e) {
      await mainLocalLog('OTP AuthException: ${e.message}');
      final msg = e.message.toLowerCase();
      final isInvalidOtp =
          msg.contains('expired') ||
          msg.contains('invalid') ||
          msg.contains('token') ||
          e.statusCode == '400' ||
          e.statusCode == '401' ||
          e.statusCode == '403';
      return AuthResult(
        ok: false,
        code: isInvalidOtp ? 'invalid_otp' : (e.statusCode ?? 'auth_error'),
        message:
            isInvalidOtp
                ? 'The PIN you entered is incorrect or expired. Please request a new code and try again.'
                : (e.message.isNotEmpty
                    ? e.message
                    : 'Verification failed. Please try again.'),
      );
    } on SocketException catch (_) {
      return const AuthResult(
        ok: false,
        code: 'network',
        message:
            'No internet connection. Please check your network and try again.',
      );
    } on PostgrestException catch (e) {
      await mainLocalLog('OTP PostgrestException: ${e.message}');
      return const AuthResult(
        ok: false,
        code: 'database',
        message:
            'Your email was verified, but saving your profile failed. Please try logging in or contact support.',
      );
    } catch (e) {
      await mainLocalLog('Error: ${e.toString()}');
      return const AuthResult(
        ok: false,
        code: 'unknown',
        message: 'Verification failed. Please try again.',
      );
    }
  }

  Future<int> verifyOtp({
    required String otp,
    required TempUserClass user,
    required BuildContext context,
    required String userId,
    String? newEmail,
  }) async {
    final res = await verifyOtpWithResult(
      otp: otp,
      user: user,
      context: context,
      userId: userId,
      newEmail: newEmail,
    );
    return res.ok ? 1 : 0;
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
      await mainLocalLog('Email reset OTP sent.');
    } catch (e) {
      await mainLocalLog('Error sending OTP to email: $e');
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
      await mainLocalLog('Email Change OTP Resent Success');
    } catch (e) {
      await mainLocalLog('Error: ${e.toString()}');
    }
  }

  Future<AuthResult> signInWithResult(
    String email,
    String password,
  ) async {
    final cleanEmail = email.trim().toLowerCase();
    final navProvider = NavProvider();
    final bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      try {
        final authResponse = await _client.auth
            .signInWithPassword(
              email: cleanEmail,
              password: password,
            );

        final user = authResponse.user;
        if (user == null) {
          return const AuthResult(
            ok: false,
            code: 'no_user',
            message: 'No user returned from sign-in.',
          );
        }

        final userId = user.id;

        final response =
            await _client
                .from('users')
                .select()
                .eq('user_id', userId)
                .maybeSingle();

        if (response == null) {
          return AuthResult(
            ok: false,
            code: 'missing_profile',
            userId: userId,
            message:
                'Your account profile was not found. Please complete registration or contact support.',
          );
        }

        final tempUser = TempUserClass.fromJson({
          ...response,
          'password': password,
        });

        await LoggedInUserFunc().insertLoggedInUser(
          LoggedInUser(loggedInUser: tempUser),
        );
        await mainLocalLog('Offline User Logged In');

        await UserFunc().insertUser(tempUser);
        await mainLocalLog('Offline User Insertted');

        navProvider.verify();
        navProvider.offLoading();

        await mainLocalLog(
          "✅ User signed in and saved locally: ${tempUser.email}",
        );

        return AuthResult(ok: true, code: 'ok', userId: userId);
      } on AuthException catch (e) {
        await mainLocalLog("❌ Sign-in AuthException: ${e.message}");
        final msg = e.message.toLowerCase();
        if (msg.contains('email not confirmed')) {
          return const AuthResult(
            ok: false,
            code: 'email_not_confirmed',
            message:
                'Your email has not been verified yet. We can resend a verification code to your email.',
          );
        }
        if (e.statusCode == '400' || e.statusCode == '401') {
          return const AuthResult(
            ok: false,
            code: 'invalid_credentials',
            message: 'Invalid email or password.',
          );
        }
        if (e.statusCode == '404') {
          return const AuthResult(
            ok: false,
            code: 'not_found',
            message:
                'User not found. Please check your email and try again.',
          );
        }
        if (e.statusCode == '500') {
          return const AuthResult(
            ok: false,
            code: 'server',
            message: 'An error occurred on the server. Please try again later.',
          );
        }
        if (e.statusCode == null) {
          return const AuthResult(
            ok: false,
            code: 'network',
            message:
                'No internet connection. Please check your network and try again.',
          );
        }
        return AuthResult(
          ok: false,
          code: e.statusCode ?? 'auth_error',
          message:
              e.message.isNotEmpty
                  ? e.message
                  : 'Login failed. Please check your credentials and try again.',
        );
      } on SocketException catch (_) {
        return const AuthResult(
          ok: false,
          code: 'network',
          message:
              'No internet connection. Please check your network and try again.',
        );
      } catch (e) {
        await mainLocalLog("❌ Sign-in failed: ${e.toString()}");
        return const AuthResult(
          ok: false,
          code: 'unknown',
          message:
              'Login failed. Please check your email, password, and internet connection.',
        );
      }
    } else {
      try {
        TempUserClass? user = UserFunc().offlineLoginByEmailandPassword(
          password,
          cleanEmail,
        );
        await mainLocalLog(user?.name);

        if (user != null) {
          await mainLocalLog('Offline User Found');
          await LoggedInUserFunc().insertLoggedInUser(
            LoggedInUser(loggedInUser: user),
          );
          await mainLocalLog('Offline User Logged In');
          navProvider.verify();
          navProvider.offLoading();
          return AuthResult(ok: true, code: 'ok', userId: user.userId);
        } else {
          await mainLocalLog('Offline User Not Found');
          return const AuthResult(
            ok: false,
            code: 'offline_not_found',
            message:
                'No internet connection, and no matching offline account was found on this device.',
          );
        }
      } catch (e) {
        await mainLocalLog('❌❌Offline Login Error: ${e.toString()}');
        return const AuthResult(
          ok: false,
          code: 'offline_error',
          message: 'Offline login failed. Please try again.',
        );
      }
    }
  }

  Future<int> signIn(
    String email,
    String password,
  ) async {
    final res = await signInWithResult(email, password);
    return res.ok ? 1 : 0;
  }

  Future<int> signOut({
    required BuildContext context,
    required bool allowLogout,
  }) async {
    try {
      if (returnData().isSynced() == 0 && !allowLogout) {
        showDialog(
          context: context,
          builder: (errorContext) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'You currently have some records that have not been backed up to the cloud. Please Proceed to Synchronize, before Logging out.',
              title: 'Unsyned Records Detected',
            );
          },
        );
        return 0;
      } else if (!returnSalesProvider().isEmptyCart() &&
          !allowLogout) {
        final sales = returnSalesProvider();
        final blocking = sales.firstNonEmptyCart()!;
        final cartNumber =
            blocking.mainCart.cartQueue.indexOf(
              blocking.cart,
            ) +
            1;
        showDialog(
          context: context,
          builder: (errorContext) {
            return ConfirmationAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'You currently have some Items in "${sales.mainCartLabel(blocking.mainCart)}" (Cart $cartNumber) that you have not checked out. Please complete the sale or clear the cart, before Logging out.',
              title: 'Cart Not Empty',
              actionButtonText: 'Go to Cart',
              action: () async {
                Navigator.of(errorContext).pop();
                await sales.jumpToCart(
                  mainCartId: blocking.mainCart.mainCartId!,
                  cartId: blocking.cart.id!,
                );
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MakeSalesPage(),
                    ),
                  );
                }
              },
            );
          },
        );
        return 0;
      } else if (!returnProductionsActionProvider()
              .isCartEmpty() &&
          !allowLogout) {
        showDialog(
          context: context,
          builder: (errorContext) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'You currently have some Items in your Productions cart. Please Proceed to complete the The Process clear all the carts, before Logging out.',
              title: 'Production Cart Not Empty',
            );
          },
        );
        return 0;
      } else if (!returnMaterialsUsageActionProvider()
              .isCartEmpty() &&
          !allowLogout) {
        showDialog(
          context: context,
          builder: (errorContext) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'You currently have some Items in your Materials Usage cart. Please Proceed to complete the The Process clear all the carts, before Logging out.',
              title: 'Materials Usage Cart Not Empty',
            );
          },
        );
        return 0;
      } else {
        final rootNav = Navigator.of(
          context,
          rootNavigator: true,
        );
        final navContext = rootNav.context;
        final nav = returnNavProvider(
          navContext,
          listen: false,
        );
        nav.navigateAuth(1);
        nav.navigate(0);

        // Navigate to AuthLanding before clearing shop/user providers so Home
        // never rebuilds ShopBannerScreen while logout cleanup runs.
        rootNav.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) {
              return const AuthScreensPage();
            },
          ),
          (_) => false,
        );

        await returnShopProvider().clearAll(
          navContext,
          includeAuthAndShop: true,
        );
        await CurrentShopFunc().clearCurrentShop();
        await returnMultiDisplayProvider()
            .closeAllWindows();
        bool isOnline = await ConnectivityProvider().isOnline();

        if (isOnline) {
          await _client.auth.signOut();
          await LoggedInUserFunc().logOut();
        } else {
          await LoggedInUserFunc().logOut();
        }
        returnShopProvider().clearShop();
        returnUserProviderSingle().clearUsers();

        notifyListeners();
        return 1;
      }
    } catch (e) {
      mainLocalLog('Error Logging Out: ${e.toString()}');
      return 0;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await Supabase.instance.client.auth
          .resetPasswordForEmail(
            email,
            redirectTo:
                'https://www.stockallapp.com/#/reset-password',
          );
      await mainLocalLog('Password reset email sent.');
    } catch (e) {
      await mainLocalLog('Error sending reset email: $e');
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

      await mainLocalLog(
        "🔐 Password successfully updated in Supabase Auth for ${user.email}",
      );

      await mainLocalLog(
        "Updating user with ID: ${user.id}",
      );

      // ✅ Step 2: Update password in your 'users' table
      await _client
          .from('users')
          .update({'password': newPassword})
          .eq('user_id', user.id);

      // 4. Store the user in local DB
      await mainLocalLog(
        "context.mounted = ${context.mounted}",
      );
      if (context.mounted) {
        await mainLocalLog(
          "✅ Inserting Users into the Local",
        );
        await returnUserProvider(
          context,
          listen: false,
        ).fetchCurrentUser(context, forceRefresh: true);
        return 'Success';
      } else {
        await mainLocalLog(
          "⚠️ Context no longer mounted, skipping local insert",
        );
      }

      await mainLocalLog(
        "✅ Password updated in 'users' table",
      );
      return 'Success';
    } on AuthException catch (e) {
      await mainLocalLog('Error Changing Password: $e');
      return e.statusCode!;
    } catch (e) {
      await mainLocalLog(e.toString());
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
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      await mainLocalLog('Online Auth Validated');
      return currentUserAuth?.id;
    } else {
      await mainLocalLog('Offline Auth Validated');
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
        await mainLocalLog(
          "No user is currently signed in.",
        );
        return 0;
      }

      final response = await _client.functions.invoke(
        'delete-user',
        body: {'userId': user.id},
      );

      if (response.status == 200) {
        await mainLocalLog(
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
        await signOut(context: context, allowLogout: true);
        return 1;
      } else {
        await mainLocalLog(
          "Error Deleting User Account: ${response.data}",
        );
        return 0;
      }
    } catch (e) {
      await mainLocalLog(
        "Error Deleting User Account: ${e.toString()}",
      );
      return 0;
    }
  }
}
