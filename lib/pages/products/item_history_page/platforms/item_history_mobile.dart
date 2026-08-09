import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';

class ItemHistoryMobile extends StatefulWidget {
  final String? productUuid;
  final bool fromItemDetails;
  const ItemHistoryMobile({
    super.key,
    required this.productUuid,
    required this.fromItemDetails,
  });

  @override
  State<ItemHistoryMobile> createState() =>
      ItemHistoryMobileState();
}

class ItemHistoryMobileState
    extends State<ItemHistoryMobile> {
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
    List<ItemHistory>? itemHistories =
        returnItemHistoryProvider(
          context: context,
        ).returnItemHistories().where((history) {
          if (widget.productUuid != null) {
            return history.itemUuid == widget.productUuid &&
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
                if (returnItemHistoryProvider().dateSet !=
                        null ||
                    returnItemHistoryProvider()
                            .rangeStartDate !=
                        null) {
                  returnItemHistoryProvider().clearDate();
                } else {
                  mainDatePicker(
                    context: context,
                    theme: theme,
                    singleDate: (date) {
                      returnItemHistoryProvider().setDate(
                        date!,
                      );
                    },
                    rangeDate: (firstDate, lastDate) {
                      returnItemHistoryProvider().setRange(
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
                      returnItemHistoryProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnItemHistoryProvider(
                                    context: context,
                                  ).rangeStartDate !=
                                  null
                          ? 'Clear'
                          : 'Date',
                    ),
                    Icon(
                      size: 16,
                      returnItemHistoryProvider(
                                    context: context,
                                  ).dateSet !=
                                  null ||
                              returnItemHistoryProvider(
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
                  if (itemHistories.isEmpty) {
                    return Center(
                      child: EmptyWidgetDisplayOnly(
                        title: 'No Events Found',
                        subText:
                            'No event has been created for this date.',
                        theme: theme,
                        height: 30,
                        altAction: () {
                          returnItemHistoryProvider()
                              .getItemHistories();
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
                        return returnItemHistoryProvider()
                            .getItemHistories();
                      },
                      child: ListView(
                        children:
                            itemHistories
                                .map(
                                  (item) => Material(
                                    type:
                                        MaterialType
                                            .transparency,
                                    child: ItemHistoryTile(
                                      itemHistory: item,
                                      fromDetails:
                                          widget
                                              .fromItemDetails,
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
