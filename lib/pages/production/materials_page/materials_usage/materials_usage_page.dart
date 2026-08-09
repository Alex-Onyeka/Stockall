import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/platforms/materials_usage_mobile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/platforms/materials_usage_desktop.dart';

class MaterialsUsagePage extends StatefulWidget {
  final String? productionRecordUuid;
  final bool fromMaterialUsagePage;
  const MaterialsUsagePage({
    super.key,
    this.productionRecordUuid,
    required this.fromMaterialUsagePage,
  });

  @override
  State<MaterialsUsagePage> createState() =>
      _MaterialsUsagePageState();
}

class _MaterialsUsagePageState
    extends State<MaterialsUsagePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionRecordsProvider()
          .getProductionRecords(shopId());
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionRecordsProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return MaterialsUsageMobile(
            productionRecordUuid:
                widget.productionRecordUuid,
            fromMaterialUsagePage:
                widget.fromMaterialUsagePage,
          );
        } else {
          return MaterialsUsageDesktop(
            productionRecordUuid:
                widget.productionRecordUuid,
            fromMaterialUsagePage:
                widget.fromMaterialUsagePage,
          );
        }
      },
    );
  }
}
