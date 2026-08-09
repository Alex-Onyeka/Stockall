import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/platforms/production_records_list_desktop.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/platforms/production_records_list_mobile.dart';

class ProductionRecordsList extends StatefulWidget {
  final String? productionItemUuid;
  const ProductionRecordsList({
    super.key,
    this.productionItemUuid,
  });

  @override
  State<ProductionRecordsList> createState() =>
      _ProductionRecordsListState();
}

class _ProductionRecordsListState
    extends State<ProductionRecordsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getProductionRecords();
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
        if (constraints.maxWidth < mobileScreen) {
          return ProductionRecordsListMobile(
            productionItemUuid: widget.productionItemUuid,
          );
        } else {
          return ProductionRecordsListDesktop(
            productionItemUuid: widget.productionItemUuid,
          );
        }
      },
    );
  }
}
