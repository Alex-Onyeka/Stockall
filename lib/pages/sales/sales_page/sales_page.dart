import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_desktop.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_mobile.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!);
      if (context.mounted && userShop == null) {
        // ignore: use_build_context_synchronously
        NavProvider().nullShop(context);
      } else {
        clearDate();
        if (context.mounted) {
          final provider = returnUserProvider(
            context,
            listen: false,
          );

          await provider.fetchCurrentUser(context);
        }
      }

      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(0);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return SalesPageMobile();
          } else {
            return SalesPageDesktop();
          }
        },
      ),
    );
  }
}
