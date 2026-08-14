import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/components/production_material_usage_tile.dart';

class ProductionMaterialTileWidget extends StatefulWidget {
  const ProductionMaterialTileWidget({
    super.key,
    required this.productionMaterial,
  });

  final ProductionRecordMaterials productionMaterial;

  @override
  State<ProductionMaterialTileWidget> createState() =>
      _ProductionMaterialTileWidgetState();
}

class _ProductionMaterialTileWidgetState
    extends State<ProductionMaterialTileWidget> {
  bool isOpen = false;
  bool isDeleteLoading = false;
  bool isPrinting = false;
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: EdgeInsetsGeometry.fromLTRB(5, 5, 15, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                Expanded(
                  child: Row(
                    // spacing: 2,
                    children: [
                      Icon(
                        size: 30,
                        isOpen
                            ? Icons.arrow_drop_down_rounded
                            : Icons.arrow_right_rounded,
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget
                            .productionMaterial
                            .materialName,
                      ),
                    ],
                  ),
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  formatLargeNumberDouble(
                    widget.productionMaterial.quantity,
                  ),
                ),
              ],
            ),
            Visibility(
              visible: isOpen,
              child: Column(
                children: [
                  Divider(thickness: 1),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 5,
                          children: [
                            SizedBox(width: 5),
                            Icon(
                              size: 14,
                              color: Colors.grey,
                              Icons.person,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              formatMoneyBig(
                                amount:
                                    widget
                                        .productionMaterial
                                        .getTotalCost(),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          // fontWeight: FontWeight.bold,
                        ),
                        widget.productionMaterial.getUnit(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 0.5),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    // spacing: 5,
                    children: [
                      ProductionPaymentButtonWidget(
                        action: () {
                          showDialog(
                            context: context,
                            builder: (firstContext) {
                              return DialogTemplate(
                                theme: theme,
                                message:
                                    'View Item History Details',
                                title: 'Usage Details',
                                action: () {},
                                showBottomActionButtons:
                                    false,
                                widget: SizedBox(
                                  height:
                                      screenHeight(
                                        context,
                                      ) -
                                      200,
                                  child: MaterialUsageDetailsWidget(
                                    productionRecordMaterials:
                                        widget
                                            .productionMaterial,
                                    fromDetails: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        title: 'View  More',
                        isLoading: isPrinting,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductionPaymentButtonWidget
    extends StatelessWidget {
  const ProductionPaymentButtonWidget({
    super.key,
    required this.action,
    required this.title,
    required this.isLoading,
    this.color,
  });

  final Function()? action;
  final String title;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3.0,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: action,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return SizedBox(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        strokeWidth: 2.5,
                      ),
                    );
                  } else {
                    return Text(
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            color ??
                            theme
                                .lightModeColor
                                .secColor100,
                      ),
                      title,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
