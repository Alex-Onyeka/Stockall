import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/orders/search_order/platforms/search_order_desktop.dart';
import 'package:stockall/pages/orders/search_order/platforms/search_order_mobile.dart';

class SearchOrderPage extends StatefulWidget {
  const SearchOrderPage({super.key});

  @override
  State<SearchOrderPage> createState() =>
      _SearchOrderPageState();
}

class _SearchOrderPageState extends State<SearchOrderPage> {
  final TextEditingController searchController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SearchOrderMobile(
            searchController: searchController,
          );
        } else {
          return SearchOrderDesktop(
            searchController: searchController,
          );
        }
      },
    );
  }
}

void showSearchOrderPage(BuildContext context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (
      pageContext,
      animation,
      secondaryAnimation,
    ) {
      return SearchOrderPage();
    },
  );
}
