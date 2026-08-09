import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/platforms/productions_dashboard_desktop.dart';
import 'package:stockall/pages/production/production_dashboard/platforms/productions_dashboard_mobile.dart';

class ProductionsDashboard extends StatefulWidget {
  const ProductionsDashboard({super.key});

  @override
  State<ProductionsDashboard> createState() =>
      _ProductionsDashboardState();
}

class _ProductionsDashboardState
    extends State<ProductionsDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshProductionDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductionsDashboardMobile();
        } else {
          return ProductionsDashboardDesktop();
        }
      },
    );
  }
}

Future<void> refreshProductionDashboard() async {
  returnProductionRecordsProvider().getProductionRecords(
    shopId(),
  );
  returnProductionItemHistoryProvider()
      .getProductionItemHistories();
  returnProductionRecordsProvider().getProductionRecords(
    shopId(),
  );
  returnMaterialsProvider().getMaterials();
  returnMaterialsItemHistoryProvider()
      .getMaterialsItemHistories();
}
