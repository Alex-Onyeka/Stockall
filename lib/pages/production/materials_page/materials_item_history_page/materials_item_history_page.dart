import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_item_history_page/platforms/materials_item_history_desktop.dart';
import 'package:stockall/pages/production/materials_page/materials_item_history_page/platforms/materials_item_history_mobile.dart';

class MaterialsItemHistoryPage extends StatefulWidget {
  final String? materialsItemUuid;
  final bool fromMaterialsItemDetails;
  const MaterialsItemHistoryPage({
    super.key,
    this.materialsItemUuid,
    required this.fromMaterialsItemDetails,
  });

  @override
  State<MaterialsItemHistoryPage> createState() =>
      _MaterialsItemHistoryPageState();
}

class _MaterialsItemHistoryPageState
    extends State<MaterialsItemHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnMaterialsItemHistoryProvider()
          .getMaterialsItemHistories();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnMaterialsItemHistoryProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return MaterialsItemHistoryMobile(
            materialsItemUuid: widget.materialsItemUuid,
            fromMaterialsItemDetails:
                widget.fromMaterialsItemDetails,
          );
        } else {
          return MaterialsItemHistoryDesktop(
            materialsItemUuid: widget.materialsItemUuid,
            fromMaterialsItemDetails:
                widget.fromMaterialsItemDetails,
          );
        }
      },
    );
  }
}
