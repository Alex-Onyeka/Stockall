import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class ProductionItemHistoryDesktop extends StatefulWidget {
  final String? productionItemUuid;
  final bool fromProductionItemDetails;
  final bool? viewTransferedOut;
  const ProductionItemHistoryDesktop({
    super.key,
    this.productionItemUuid,
    required this.fromProductionItemDetails,
    this.viewTransferedOut,
  });

  @override
  State<ProductionItemHistoryDesktop> createState() =>
      _ProductionItemHistoryDesktopState();
}

class _ProductionItemHistoryDesktopState
    extends State<ProductionItemHistoryDesktop> {
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
    List<ProductionItemHistory>? productionItemHistory =
        returnProductionItemHistoryProvider(
              context: context,
            )
            .returnProductionItemHistories()
            .where((history) {
              if (widget.productionItemUuid != null) {
                return history.itemUuid ==
                        widget.productionItemUuid &&
                    (history.itemName
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
                        history.staffName
                                ?.toLowerCase()
                                .contains(
                                  searchController.text
                                      .toLowerCase(),
                                ) ==
                            true ||
                        history.title
                                .toLowerCase()
                                .contains(
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
              }
            })
            .where(
              (item) =>
                  widget.viewTransferedOut == true
                      ? item.title == 'Transfered Out'
                      : true,
            )
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
                  title: 'Item History',
                  widget: Row(
                    spacing: 3,
                    children: [
                      InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          returnProductionItemHistoryProvider()
                              .getProductionItemHistories();
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
                            if (returnProductionItemHistoryProvider()
                                        .dateSet !=
                                    null ||
                                returnProductionItemHistoryProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnProductionItemHistoryProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnProductionItemHistoryProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnProductionItemHistoryProvider()
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
                                  returnProductionItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnProductionItemHistoryProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? 'Clear'
                                      : 'Date',
                                ),
                                Icon(
                                  size: 16,
                                  returnProductionItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnProductionItemHistoryProvider(
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
                            if (productionItemHistory
                                .isEmpty) {
                              return Center(
                                child: EmptyWidgetDisplayOnly(
                                  title: 'No Events Found',
                                  subText:
                                      'No event has been created for this date.',
                                  theme: theme,
                                  height: 30,
                                  altAction: () {
                                    returnProductionItemHistoryProvider()
                                        .getProductionItemHistories();
                                  },
                                  altActionText: 'Reload',
                                  icon: Icons.clear,
                                ),
                              );
                            } else {
                              return ListView(
                                children:
                                    productionItemHistory
                                        .map(
                                          (
                                            item,
                                          ) => ItemHistoryTile(
                                            productionItemHistory:
                                                item,
                                            fromDetails:
                                                widget
                                                    .fromProductionItemDetails,
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
