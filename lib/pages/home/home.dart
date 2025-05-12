import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/pages/products/products_page.dart';
import 'package:stockitt/pages/dashboard/dashboard.dart';
import 'package:stockitt/pages/sales/sales_page/sales_page.dart';
import 'package:stockitt/providers/nav_provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    var navProv = Provider.of<NavProvider>(context);

    if (navProv.currentPage == 0) {
      return Dashboard();
    } else if (navProv.currentPage == 1) {
      return ProductsPage();
    } else if (navProv.currentPage == 2) {
      return SalesPage();
    } else {
      return Dashboard();
    }
  }
}
