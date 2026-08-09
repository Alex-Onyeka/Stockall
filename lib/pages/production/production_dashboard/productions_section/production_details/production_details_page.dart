import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/platforms/production_details_desktop.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/platforms/production_details_mobile.dart';

class ProductionDetailsPage extends StatefulWidget {
  final String productionRecordUuid;
  const ProductionDetailsPage({
    super.key,
    required this.productionRecordUuid,
  });

  @override
  State<ProductionDetailsPage> createState() =>
      _ProductionDetailsPageState();
}

class _ProductionDetailsPageState
    extends State<ProductionDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionRecordsProvider()
          .getProductionRecords(shopId());
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ProductionDetailsMobile(
            productionRecordUuid:
                widget.productionRecordUuid,
          );
        } else {
          return ProductionDetailsDesktop(
            productionRecordUuid:
                widget.productionRecordUuid,
          );
        }
      },
    );
  }
}
