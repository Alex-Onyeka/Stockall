import 'package:flutter/material.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/authentication/translations/general.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/services/auth_service.dart';

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
    print(user?.email);
    return user;
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
      // getUserAuthId();
      if (returnUserProviderSingle().currentUserMain ==
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
    if (returnNavProvider(context).isLoadingMain) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: General().loadingText),
      );
    } else {
      if (AuthService().currentUser != null) {
        return const Home();
      } else {
        return const AuthScreensPage();
      }
    }
  }
}
