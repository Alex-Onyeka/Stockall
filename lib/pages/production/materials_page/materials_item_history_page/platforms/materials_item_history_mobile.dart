import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class MaterialsItemHistoryMobile extends StatefulWidget {
  final String? materialsItemUuid;
  final bool fromMaterialsItemDetails;
  const MaterialsItemHistoryMobile({
    super.key,
    required this.materialsItemUuid,
    required this.fromMaterialsItemDetails,
  });

  @override
  State<MaterialsItemHistoryMobile> createState() =>
      MaterialsItemHistoryMobileState();
}

class MaterialsItemHistoryMobileState
    extends State<MaterialsItemHistoryMobile> {
  late Future<TempProductClass> productFuture;

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    List<MaterialsItemHistory>? materialsItemHistories =
        returnMaterialsItemHistoryProvider(
          context: context,
        ).returnMaterialsItemHistories().where((history) {
          if (widget.materialsItemUuid != null) {
            return history.itemUuid ==
                    widget.materialsItemUuid &&
                (history.itemName?.toLowerCase().contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                        true ||
                    history.departmentName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    history.staffName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    history.title.toLowerCase().contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                        true);
          } else {
            return (history.itemName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                history.departmentName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                history.staffName?.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ) ==
                    true ||
                history.title.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    ) ==
                    true);
          }
        }).toList();
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Item History',
        widget: Visibility(
          visible: authorization(
            authorized: Authorizations().viewDate,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                if (returnMaterialsItemHistoryProvider()
                            .dateSet !=
                        null ||
                    returnMaterialsItemHistoryProvider()
                            .rangeStartDate !=
                        null) {
                  returnMaterialsItemHistoryProvider()
                      .clearDate();
                } else {
                  mainDatePicker(
                    context: context,
                    theme: theme,
                    singleDate: (date) {
                      returnMaterialsItemHistoryProvider()
                          .setDate(date!);
                    },
                    rangeDate: (firstDate, lastDate) {
                      returnMaterialsItemHistoryProvider()
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
                      returnMaterialsItemHistoryProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnMaterialsItemHistoryProvider(
                                    context: context,
                                  ).rangeStartDate !=
                                  null
                          ? 'Clear'
                          : 'Date',
                    ),
                    Icon(
                      size: 16,
                      returnMaterialsItemHistoryProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnMaterialsItemHistoryProvider(
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
                  if (materialsItemHistories.isEmpty) {
                    return Center(
                      child: EmptyWidgetDisplayOnly(
                        title: 'No Events Found',
                        subText:
                            'No event has been created for this date.',
                        theme: theme,
                        height: 30,
                        altAction: () {
                          returnMaterialsItemHistoryProvider()
                              .getMaterialsItemHistories();
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
                        return returnMaterialsItemHistoryProvider()
                            .getMaterialsItemHistories();
                      },
                      child: ListView(
                        children:
                            materialsItemHistories
                                .map(
                                  (item) => Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: ItemHistoryTile(
                                      materialsItemHistory:
                                          item,
                                      fromDetails:
                                          widget
                                              .fromMaterialsItemDetails,
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
