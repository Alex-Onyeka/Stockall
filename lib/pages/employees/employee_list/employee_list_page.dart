import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/employee_list/platforms/employee_list_mobile.dart';
import 'package:stockall/pages/shop_setup/banner_screen/shop_banner_screen.dart';
import 'package:stockall/services/auth_service.dart';

class EmployeeListPage extends StatefulWidget {
  final String empId;
  const EmployeeListPage({super.key, required this.empId});

  @override
  State<EmployeeListPage> createState() =>
      _EmployeeListPageState();
}

class _EmployeeListPageState
    extends State<EmployeeListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userShop = await returnShopProvider(
        context,
        listen: false,
      ).getUserShop(AuthService().currentUser!.id);
      if (context.mounted && userShop == null) {
        Navigator.pushAndRemoveUntil(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => ShopBannerScreen(),
          ),
          (route) => false,
        );
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
        if (constraints.maxWidth < 550) {
          return EmployeeListMobile();
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
