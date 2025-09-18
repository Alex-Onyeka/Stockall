import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/platforms/report_desktop.dart';
import 'package:stockall/pages/report/platforms/report_mobile.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(6);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!);
      if (context.mounted && userShop == null) {
        // ignore: use_build_context_synchronously
        NavProvider().nullShop(context);
      } else {
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ReportMobile();
        } else {
          return ReportDesktop();
        }
      },
    );
  }
}
