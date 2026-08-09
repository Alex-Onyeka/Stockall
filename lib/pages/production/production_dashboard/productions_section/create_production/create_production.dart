import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/create_production/platforms/create_production_desktop.dart';

class CreateProduction extends StatefulWidget {
  const CreateProduction({super.key});

  @override
  State<CreateProduction> createState() =>
      _CreateProductionState();
}

class _CreateProductionState
    extends State<CreateProduction> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionsActionProvider()
          .initProductionsCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          // return CreateProductionMobile();
          return Scaffold(appBar: AppBar());
        } else {
          return CreateProductionDesktop();
        }
      },
    );
  }
}
