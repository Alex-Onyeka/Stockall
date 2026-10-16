import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/helpers/clean_up_url/clean_up_url.dart';
import 'package:stockall/local_database/logged_in_user/logged_in_user_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/complete_details/complete_details_page.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/google_auth/auth_routing.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  bool isLoading = true;
  void switchLoading() {
    Future.delayed(Duration(seconds: 2), () {
      if (context.mounted) {
        returnNavProvider(
          context,
          listen: false,
        ).offLoading();
      }
    });
  }

  Future<TempUserClass?> getUser() async {
    var user = await returnUserProvider(
      context,
      listen: false,
    ).fetchCurrentUser(context);
    await mainLocalLog(user?.email);
    return user;
  }

  bool checkingProfile = false;
  bool needsDetails = false;

  /// A session with no locally saved user only happens right after a
  /// sign-in: the web Google redirect, a Google user who never completed
  /// their details, or just after OTP. Check the profile before Home, which
  /// can't load a user without one.
  Future<void> resolveFreshSession() async {
    if (AuthService().currentUserAuth == null ||
        LoggedInUserFunc().getLoggedInUser() != null ||
        !returnConnectivityProvider().isConnected) {
      return;
    }
    setState(() {
      checkingProfile = true;
    });
    AuthDestination destination;
    String? emailInUse;
    try {
      destination = await AuthService().resolveSignedInUser();
    } on EmailInUseException catch (e) {
      destination = AuthDestination.authScreens;
      emailInUse = e.email;
    }
    if (kIsWeb && Uri.base.queryParameters.containsKey('code')) {
      cleanUpUrl();
    }
    if (!mounted) return;
    setState(() {
      checkingProfile = false;
      needsDetails =
          destination == AuthDestination.completeDetails;
    });
    if (emailInUse != null) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message:
                'The email $emailInUse is already used by another Stockall account. Please log in with your email and password.',
            title: 'Email Already Registered',
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnConnectivityProvider().isOnlineAction();
      switchLoading();
      returnCompProvider(
        context,
        listen: false,
      ).setVisible();
      await resolveFreshSession();
      // getUserAuthId();
      if (!needsDetails &&
          returnUserProviderSingle().currentUserMain ==
              null) {
        await getUser();
      }
      await returnCountryProvider().fetchCountries();
      var cartId =
          await returnSalesProvider().fetchMainCart();
      await returnMultiDisplayProvider().createWindow(
        cartId: cartId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (returnNavProvider(context).isLoadingMain ||
        checkingProfile) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: General().loadingText),
      );
    } else {
      if (AuthService().currentUser != null) {
        if (needsDetails) return const CompleteDetailsPage();
        return const Home();
      } else {
        return const AuthScreensPage();
      }
    }
  }
}
