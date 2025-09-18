import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';
import 'package:stockall/providers/nav_provider.dart';
import 'package:stockall/services/auth_service.dart';

class MakeSalesPage extends StatefulWidget {
  final bool? isMain;
  final bool? isInvoice;
  const MakeSalesPage({
    super.key,
    this.isMain,
    this.isInvoice,
  });

  @override
  State<MakeSalesPage> createState() =>
      _MakeSalesPageState();
}

class _MakeSalesPageState extends State<MakeSalesPage> {
  TextEditingController searchController =
      TextEditingController();

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
          return MakeSalesMobile(
            isInvoice: widget.isInvoice,
            isMain: widget.isMain,
            searchController: searchController,
          );
        } else {
          return MakeSalesDesktop(
            isInvoice: widget.isInvoice,
            isMain: widget.isMain,
            searchController: searchController,
          );
        }
      },
    );
  }
}
