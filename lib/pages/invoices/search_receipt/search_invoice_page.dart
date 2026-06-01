import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/invoices/search_receipt/platforms/search_invoice_desktop.dart';
import 'package:stockall/pages/invoices/search_receipt/platforms/search_invoice_mobile.dart';

class SearchInvoicePage extends StatefulWidget {
  const SearchInvoicePage({super.key});

  @override
  State<SearchInvoicePage> createState() =>
      _SearchInvoicePageState();
}

class _SearchInvoicePageState
    extends State<SearchInvoicePage> {
  final TextEditingController searchController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return SearchInvoiceMobile(
            searchController: searchController,
          );
        } else {
          return SearchInvoiceDesktop(
            searchController: searchController,
          );
        }
      },
    );
  }
}

void showSearchInvoicePage(BuildContext context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (
      pageContext,
      animation,
      secondaryAnimation,
    ) {
      return SearchInvoicePage();
    },
  );
}
