import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/production_details_page.dart';

class ProductionMaterialUsageTile extends StatefulWidget {
  const ProductionMaterialUsageTile({
    super.key,
    required this.fromDetails,
    required this.productionRecordMaterials,
  });
  final ProductionRecordMaterials productionRecordMaterials;
  final bool fromDetails;

  @override
  State<ProductionMaterialUsageTile> createState() =>
      ProductionMaterialUsageTileState();
}

class ProductionMaterialUsageTileState
    extends State<ProductionMaterialUsageTile> {
  String cutLongText(String text) {
    if (text.length >
        (screenWidth(context) > mobileScreen ? 25 : 15)) {
      return '${text.substring(0, (screenWidth(context) > mobileScreen ? 25 : 15))}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            showDialog(
              context: context,
              builder: (firstContext) {
                return DialogTemplate(
                  theme: theme,
                  message: 'View Item History Details',
                  title: 'Usage Details',
                  action: () {},
                  showBottomActionButtons: false,
                  widget: SizedBox(
                    height: screenHeight(context) - 200,
                    child: MaterialUsageDetailsWidget(
                      productionRecordMaterials:
                          widget.productionRecordMaterials,
                      fromDetails: widget.fromDetails,
                    ),
                  ),
                );
              },
            );
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Visibility(
                  visible:
                      screenWidth(context) >
                      mobileScreenSmall,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.lightModeColor.tertColor50,
                    ),
                    child: Icon(
                      color:
                          theme.lightModeColor.tertColor200,
                      size: 20,
                      Icons.border_horizontal_rounded,
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Row(
                        spacing: 15,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 5,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                    ),
                                    (widget
                                        .productionRecordMaterials
                                        .materialName),
                                  ),
                                ),
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                                  formatLargeNumberDouble(
                                    widget
                                        .productionRecordMaterials
                                        .quantity,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            size: 15,
                            color: Colors.grey.shade400,
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          // top: 5.0,
                          // bottom: 5,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                    'Produced:',
                                  ),
                                  Flexible(
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        color:
                                            theme
                                                .lightModeColor
                                                .prColor300,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      cutLongText(
                                        widget
                                                .productionRecordMaterials
                                                .productionRecordName ??
                                            'Not Set',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 3,
                              children: [
                                Visibility(
                                  visible:
                                      screenWidth(context) >
                                      mobileScreenSmall,
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                    'Date:',
                                  ),
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatDateTimeTime(
                                    widget
                                            .productionRecordMaterials
                                            .createdAt ??
                                        DateTime.now(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MaterialUsageDetailsWidget extends StatefulWidget {
  final ProductionRecordMaterials?
  productionRecordMaterials;
  final bool fromDetails;

  const MaterialUsageDetailsWidget({
    super.key,
    this.productionRecordMaterials,
    required this.fromDetails,
  });

  @override
  State<MaterialUsageDetailsWidget> createState() =>
      _MaterialUsageDetailsWidgetState();
}

class _MaterialUsageDetailsWidgetState
    extends State<MaterialUsageDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Column(
        spacing: 10,
        children: [
          Divider(height: 1),
          Expanded(
            child: ListView(
              children: [
                ItemHistorySectionWidget(
                  title: 'Material Name',
                  message:
                      widget
                          .productionRecordMaterials
                          ?.materialName ??
                      'Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Quantity',
                  message:
                      '${formatLargeNumberDouble(widget.productionRecordMaterials?.quantity ?? 0)} ${widget.productionRecordMaterials?.getUnit() ?? 'Unit(s)'}',
                ),
                ItemHistorySectionWidget(
                  title: 'Single Cost',
                  message: formatMoneyBig(
                    context: context,
                    amount:
                        widget
                            .productionRecordMaterials
                            ?.originalCostPerItem ??
                        0,
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Total Cost',
                  message: formatMoneyBig(
                    context: context,
                    amount:
                        widget.productionRecordMaterials
                            ?.getTotalCost() ??
                        0,
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Produced Item',
                  message:
                      widget
                          .productionRecordMaterials
                          ?.productionRecordName ??
                      'Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Created Date',
                  message: formatDateWithTime(
                    widget
                            .productionRecordMaterials
                            ?.createdAt ??
                        DateTime.now(),
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Creator',
                  message:
                      widget
                          .productionRecordMaterials
                          ?.staffName ??
                      'Not Set',
                ),
                Visibility(
                  visible:
                      (widget
                          .productionRecordMaterials
                          ?.departmentName) !=
                      null,
                  child: ItemHistorySectionWidget(
                    title: 'Department Name',
                    message:
                        widget
                            .productionRecordMaterials
                            ?.departmentName ??
                        'Not Set',
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible:
                !widget.fromDetails &&
                (widget
                        .productionRecordMaterials
                        ?.productionRecordId) !=
                    null,
            child: MainButtonP(
              themeProvider: theme,
              action: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ProductionDetailsPage(
                        productionRecordUuid:
                            widget
                                .productionRecordMaterials
                                ?.productionRecordId ??
                            '',
                      );
                    },
                  ),
                );
              },
              text: 'View Production Record',
            ),
          ),
          MainButtonTransparent(
            themeProvider: theme,
            constraints: BoxConstraints(),
            text: 'Cancel',
          ),
        ],
      ),
    );
  }
}

class ItemHistorySectionWidget extends StatelessWidget {
  final String title;
  final String message;
  const ItemHistorySectionWidget({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              7,
              10,
              5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Colors.grey.shade200,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    '$title:',
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsetsGeometry.fromLTRB(
              10,
              5,
              10,
              10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.shade700,
                    ),
                    message,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
