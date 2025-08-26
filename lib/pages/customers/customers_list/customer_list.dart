import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customers_list/platforms/customer_list_desktop.dart';
import 'package:stockall/pages/customers/customers_list/platforms/customer_list_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class CustomerList extends StatefulWidget {
  final bool? isSales;
  const CustomerList({super.key, this.isSales});

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  TextEditingController searchContoller =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(3);
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
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return CustomerListMobile(
              searchController: searchContoller,
              isSales: widget.isSales,
            );
          } else {
            return CustomerListDesktop(
              searchController: searchContoller,
              isSales: widget.isSales,
            );
          }
        },
      ),
    );
  }
}
