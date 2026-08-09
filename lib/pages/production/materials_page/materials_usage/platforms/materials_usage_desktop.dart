import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/components/materials_usage_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class MaterialsUsageDesktop extends StatefulWidget {
  final String? productionRecordUuid;
  final bool fromMaterialUsagePage;
  const MaterialsUsageDesktop({
    super.key,
    this.productionRecordUuid,
    required this.fromMaterialUsagePage,
  });

  @override
  State<MaterialsUsageDesktop> createState() =>
      _MaterialsUsageDesktopState();
}

class _MaterialsUsageDesktopState
    extends State<MaterialsUsageDesktop> {
  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;
  TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    List<ProductionRecordMaterials>? materialsUsageRecords =
        returnProductionRecordsProvider(context: context)
            .returnAllProductionRecordMaterials(
              productionRecords: null,
            )
            .where((materialRecord) {
              if (widget.productionRecordUuid != null) {
                return materialRecord.productionRecordId ==
                            widget.productionRecordUuid &&
                        (materialRecord.materialName
                            .toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            )) ||
                    (materialRecord.productionRecordName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            )) ==
                        true;
              } else {
                return (materialRecord.materialName
                        .toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        )) ||
                    (materialRecord.productionRecordName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            )) ==
                        true;
              }
            })
            .toList();
    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        spacing: 15,
        children: [
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      39,
                      4,
                      1,
                      41,
                    ),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Scaffold(
                appBar: appBar(
                  context: context,
                  title: 'Materials Usage',
                  widget: Row(
                    spacing: 3,
                    children: [
                      InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          returnProductionRecordsProvider()
                              .getProductionRecords(
                                shopId(),
                              );
                        },
                        child: Container(
                          padding: EdgeInsets.only(
                            right: 10,
                            left: 10,
                            top: 5,
                            bottom: 5,
                          ),
                          decoration: BoxDecoration(),
                          child: Row(
                            spacing: 3,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                'Refresh',
                              ),
                              Icon(size: 17, Icons.refresh),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible:
                            authorization(
                              authorized:
                                  Authorizations().viewDate,
                            ) &&
                            widget.fromMaterialUsagePage,
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            if (returnProductionRecordsProvider()
                                        .dateSet !=
                                    null ||
                                returnProductionRecordsProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnProductionRecordsProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnProductionRecordsProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnProductionRecordsProvider()
                                      .setRange(
                                        firstDate!,
                                        lastDate ??
                                            DateTime.now(),
                                      );
                                },
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                              right: 5,
                            ),
                            padding: EdgeInsets.only(
                              right: 10,
                              left: 10,
                              top: 5,
                              bottom: 5,
                            ),
                            decoration: BoxDecoration(),
                            child: Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  returnProductionRecordsProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnProductionRecordsProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? 'Clear'
                                      : 'Date',
                                ),
                                Icon(
                                  size: 16,
                                  returnProductionRecordsProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnProductionRecordsProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? Icons.clear
                                      : Icons
                                          .date_range_outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                body: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            if (materialsUsageRecords
                                .isEmpty) {
                              return Center(
                                child: EmptyWidgetDisplayOnly(
                                  title: 'No Events Found',
                                  subText:
                                      'No event has been created for this date.',
                                  theme: theme,
                                  height: 30,
                                  altAction: () {
                                    returnProductionRecordsProvider()
                                        .getProductionRecords(
                                          shopId(),
                                        );
                                  },
                                  altActionText: 'Reload',
                                  icon: Icons.clear,
                                ),
                              );
                            } else {
                              return ListView(
                                children:
                                    materialsUsageRecords
                                        .map(
                                          (
                                            item,
                                          ) => MaterialsUsageTile(
                                            productionRecordMaterials:
                                                item,
                                            fromDetails:
                                                false,
                                          ),
                                        )
                                        .toList(),
                              );
                            }
                          },
                        ),
                      ),
                      SearchFilterWidgetHistory(
                        searchController: searchController,
                        text:
                            'Material Name and Produced Item Name',
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width:
                screenWidth(context) < tabletScreenSmall
                    ? 50
                    : (screenWidth(context) >
                            tabletScreenSmall &&
                        screenWidth(context) <
                            tabletScreen + 100)
                    ? 100
                    : 230,
          ),
        ],
      ),
    );
  }
}

// }
