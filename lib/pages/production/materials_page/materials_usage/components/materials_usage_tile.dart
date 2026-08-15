import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_details/materials_details_page.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/materials_details_mobile.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/create_materials_usage_page.dart';

class MaterialsUsageTile extends StatefulWidget {
  const MaterialsUsageTile({
    super.key,
    required this.fromDetails,
    required this.materialsUsage,
  });
  final ProductionMaterialsUsage materialsUsage;
  final bool fromDetails;

  @override
  State<MaterialsUsageTile> createState() =>
      MaterialsUsageTileState();
}

class MaterialsUsageTileState
    extends State<MaterialsUsageTile> {
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
                  topRightWidget: IconButton(
                    mouseCursor: SystemMouseCursors.click,
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.of(firstContext).pop();
                    },
                    icon: Icon(size: 26, Icons.clear),
                  ),
                  widget: SizedBox(
                    height: screenHeight(context) - 200,
                    child: MaterialUsageDetailsWidget(
                      materialsUsage: widget.materialsUsage,
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
                                        .materialsUsage
                                        .materialName),
                                  ),
                                ),
                                Row(
                                  children: [
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
                                            .materialsUsage
                                            .quantity,
                                      ),
                                    ),
                                    Visibility(
                                      visible:
                                          screenWidth(
                                            context,
                                          ) >
                                          mobileScreenSmall,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(
                                              left: 5.0,
                                            ),
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
                                          widget
                                              .materialsUsage
                                              .getUnit(),
                                        ),
                                      ),
                                    ),
                                  ],
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
                                    'Cost:',
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
                                      formatMoneyBig(
                                        amount:
                                            widget
                                                .materialsUsage
                                                .getTotalCost(),
                                        context: context,
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
                                            .materialsUsage
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
  final ProductionMaterialsUsage? materialsUsage;
  final bool fromDetails;

  const MaterialUsageDetailsWidget({
    super.key,
    this.materialsUsage,
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
                      widget.materialsUsage?.materialName ??
                      'Not Set',
                ),
                ItemHistorySectionWidget(
                  title: 'Quantity',
                  message:
                      "${formatLargeNumberDouble(widget.materialsUsage?.quantity ?? 0)} ${widget.materialsUsage?.getUnit()}",
                ),
                ItemHistorySectionWidget(
                  title: 'Single Cost',
                  message: formatMoneyBig(
                    context: context,
                    amount:
                        widget
                            .materialsUsage
                            ?.originalCostPerItem ??
                        0,
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Total Cost',
                  message: formatMoneyBig(
                    context: context,
                    amount:
                        widget.materialsUsage
                            ?.getTotalCost() ??
                        0,
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Created Date',
                  message: formatDateWithTime(
                    widget.materialsUsage?.createdAt ??
                        DateTime.now(),
                  ),
                ),
                ItemHistorySectionWidget(
                  title: 'Creator',
                  message:
                      widget.materialsUsage?.staffName ??
                      'Not Set',
                ),
                Visibility(
                  visible:
                      (widget
                          .materialsUsage
                          ?.departmentName) !=
                      null,
                  child: ItemHistorySectionWidget(
                    title: 'Department Name',
                    message:
                        widget
                            .materialsUsage
                            ?.departmentName ??
                        'Not Set',
                  ),
                ),
              ],
            ),
          ),
          Row(
            spacing: 10,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: EditButton(
                  action: () {
                    showDialog(
                      context: context,
                      builder: (confirmDialog) {
                        bool updateInventory = false;
                        return StatefulBuilder(
                          builder:
                              (
                                newContext,
                                setStatee,
                              ) => DialogTemplate(
                                theme: theme,
                                message:
                                    'You are about to delete this Usage Record, are you sure you want to proceed?',
                                title:
                                    'Delete Usage Record?',
                                action: () async {
                                  Navigator.of(
                                    confirmDialog,
                                  ).pop();
                                  var res = await returnMaterialsUsageProvider()
                                      .deleteProductionMaterialsUsage(
                                        widget
                                            .materialsUsage!,
                                        updateInventory,
                                        true,
                                      );
                                  if (res == 1) {
                                    await returnMaterialsUsageProvider()
                                        .getProductionMaterialsUsageOffline();
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  }
                                },
                                widget: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Update Item Quantity?',
                                      ),
                                      MyToggleButton(
                                        boolValue:
                                            updateInventory,
                                        toggle: () {
                                          setStatee(() {
                                            updateInventory =
                                                !updateInventory;
                                          });
                                        },
                                        theme: theme,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                        );
                      },
                    );
                  },
                  text: 'Delete',
                  theme: theme,
                  icon: Icons.delete_forever_outlined,
                  color: Colors.redAccent,
                ),
              ),
              Expanded(
                child: EditButton(
                  action: () {
                    if (returnMaterialsUsageActionProvider()
                        .isCartEmpty()) {
                      showDialog(
                        context: context,
                        builder: (confirmContext) {
                          return ConfirmationAlert(
                            action: () async {
                              var res = await returnMaterialsUsageActionProvider()
                                  .editMaterialsUsageRecord(
                                    record:
                                        widget
                                            .materialsUsage!,
                                  );
                              if (res == 1) {
                                Navigator.of(
                                  confirmContext,
                                ).pop();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (navContext) {
                                      return CreateMaterialsUsagePage();
                                    },
                                  ),
                                );
                              }
                            },
                            message:
                                'Are you sure you want to Proceed to Edit this Usage Record?',
                            theme: theme,
                            title: 'Edit Usage Record',
                          );
                        },
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InfoAlert(
                            theme: theme,
                            message:
                                'Materials Cart it Not Empty.',
                            title: 'Cart Not Empty',
                          );
                        },
                      );
                    }
                  },
                  text: 'Edit',
                  theme: theme,
                  icon: Icons.edit,
                ),
              ),
            ],
          ),
          Visibility(
            visible:
                !widget.fromDetails &&
                (widget.materialsUsage?.materialUuid) !=
                    null,
            child: MainButtonP(
              themeProvider: theme,
              action: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return MaterialsDetailsPage(
                        materialUuid:
                            widget
                                .materialsUsage
                                ?.materialUuid ??
                            '',
                      );
                    },
                  ),
                );
              },
              text: 'View Material',
            ),
          ),
          // MainButtonTransparent(
          //   themeProvider: theme,
          //   constraints: BoxConstraints(),
          //   text: 'Cancel',
          // ),
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
