import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/sales/search_receipt/platforms/search_receipt_desktop.dart';
import 'package:stockall/pages/sales/search_receipt/platforms/search_receipt_mobile.dart';

class SearchReceiptPage extends StatefulWidget {
  const SearchReceiptPage({super.key});

  @override
  State<SearchReceiptPage> createState() =>
      _SearchReceiptPageState();
}

class _SearchReceiptPageState
    extends State<SearchReceiptPage> {
  final TextEditingController searchController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SearchReceiptMobile(
            searchController: searchController,
          );
        } else {
          return SearchReceiptDesktop(
            searchController: searchController,
          );
        }
      },
    );
  }
}

void showSearchReceiptPage(BuildContext context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (
      pageContext,
      animation,
      secondaryAnimation,
    ) {
      return SearchReceiptPage();
    },
  );
}
