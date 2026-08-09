import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class MaterialsItemHistoryDesktop extends StatefulWidget {
  final String? materialsItemUuid;
  final bool fromMaterialsItemDetails;
  const MaterialsItemHistoryDesktop({
    super.key,
    this.materialsItemUuid,
    required this.fromMaterialsItemDetails,
  });

  @override
  State<MaterialsItemHistoryDesktop> createState() =>
      _MaterialsItemHistoryDesktopState();
}

class _MaterialsItemHistoryDesktopState
    extends State<MaterialsItemHistoryDesktop> {
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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

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
                  title: 'Item History',
                  widget: Row(
                    spacing: 3,
                    children: [
                      InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          returnMaterialsItemHistoryProvider()
                              .getMaterialsItemHistories();
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
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
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
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnMaterialsItemHistoryProvider()
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
                                  returnMaterialsItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnMaterialsItemHistoryProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? 'Clear'
                                      : 'Date',
                                ),
                                Icon(
                                  size: 16,
                                  returnMaterialsItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnMaterialsItemHistoryProvider(
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
                            if (materialsItemHistories
                                .isEmpty) {
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
                              return ListView(
                                children:
                                    materialsItemHistories
                                        .map(
                                          (
                                            item,
                                          ) => ItemHistoryTile(
                                            materialsItemHistory:
                                                item,
                                            fromDetails:
                                                widget
                                                    .fromMaterialsItemDetails,
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
