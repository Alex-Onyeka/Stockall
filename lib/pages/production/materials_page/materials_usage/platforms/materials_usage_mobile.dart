import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/components/materials_usage_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class MaterialsUsageMobile extends StatefulWidget {
  final String? productionRecordUuid;
  final bool fromMaterialUsagePage;
  const MaterialsUsageMobile({
    super.key,
    required this.productionRecordUuid,
    required this.fromMaterialUsagePage,
  });

  @override
  State<MaterialsUsageMobile> createState() =>
      MaterialsUsageMobileState();
}

class MaterialsUsageMobileState
    extends State<MaterialsUsageMobile> {
  TextEditingController searchController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

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
                    widget.productionRecordUuid;
              } else {
                return true;
              }
            })
            .toList();
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Materials Usage',
        widget: Visibility(
          visible:
              authorization(
                authorized: Authorizations().viewDate,
              ) &&
              widget.fromMaterialUsagePage,
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
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
                    rangeDate: (firstDate, lastDate) {
                      returnProductionRecordsProvider()
                          .setRange(
                            firstDate!,
                            lastDate ?? DateTime.now(),
                          );
                    },
                  );
                }
              },
              child: Container(
                margin: EdgeInsets.only(right: 5),
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
                        fontWeight: FontWeight.bold,
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                      ),
                      returnProductionRecordsProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnProductionRecordsProvider(
                                    context: context,
                                  ).rangeStartDate !=
                                  null
                          ? 'Clear'
                          : 'Date',
                    ),
                    Icon(
                      size: 16,
                      returnProductionRecordsProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnProductionRecordsProvider(
                                    context: context,
                                  ).rangeStartDate !=
                                  null
                          ? Icons.clear
                          : Icons.date_range_outlined,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          children: [
            Expanded(
              child: Builder(
                builder: (context) {
                  if (materialsUsageRecords.isEmpty) {
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
                    return RefreshIndicator(
                      backgroundColor: Colors.white,
                      color: Colors.amber,
                      displacement: 10,
                      strokeWidth: 1.5,
                      onRefresh: () {
                        return returnProductionRecordsProvider()
                            .getProductionRecords(shopId());
                      },
                      child: ListView(
                        children:
                            materialsUsageRecords
                                .map(
                                  (item) => Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: MaterialsUsageTile(
                                      productionRecordMaterials:
                                          item,
                                      fromDetails: false,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    );
                  }
                },
              ),
            ),
            SearchFilterWidgetHistory(
              searchController: searchController,
              text: 'Material Name and Produced Item Name',
              onChanged: (value) {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
