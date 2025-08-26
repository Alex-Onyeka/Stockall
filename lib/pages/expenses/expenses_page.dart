import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/platforms/expenses_desktop.dart';
import 'package:stockall/pages/expenses/platforms/expenses_moblie.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class ExpensesPage extends StatefulWidget {
  final bool? turnOn;
  final bool? isMain;
  const ExpensesPage({
    super.key,
    required this.isMain,
    this.turnOn,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(4);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!.id);
      if (context.mounted && userShop == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => ShopBannerScreen(),
          ),
          (route) => false,
        );
      } else {
        if (context.mounted) {
          final provider = returnUserProvider(
            context,
            listen: false,
          );

          if (context.mounted) {
            await provider.fetchCurrentUser(context);
          }
        }
      }

      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ExpensesMoblie(isMain: widget.isMain);
        } else {
          return ExpensesDesktop(
            isMain: widget.isMain,
            turnOn: widget.turnOn,
          );
        }
      },
    );
  }
}
