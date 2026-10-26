import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_item_summary.dart';
import 'package:stockall/pages/products/item_history_page/components/item_history_tile.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/components/item_history_report_view.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_main_view.dart';

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
  ItemHistoryViewMode _mode = ItemHistoryViewMode.list;
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
        widget: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Visibility(
              visible:
                  _mode == ItemHistoryViewMode.list &&
                  authorization(
                    authorized: Authorizations().viewDate,
                  ),
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    if (returnItemHistoryProvider()
                                .dateSet !=
                            null ||
                        returnItemHistoryProvider()
                                .rangeStartDate !=
                            null) {
                      returnItemHistoryProvider()
                          .clearDate();
                    } else {
                      mainDatePicker(
                        context: context,
                        theme: theme,
                        singleDate: (date) {
                          returnItemHistoryProvider()
                              .setDate(date!);
                        },
                        rangeDate: (firstDate, lastDate) {
                          returnItemHistoryProvider()
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
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
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
            if (widget.productUuid != null)
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: PopupMenuButton<ItemHistoryViewMode>(
                  offset: const Offset(0, 35),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  onSelected: (mode) {
                    setState(() {
                      _mode = mode;
                    });
                  },
                  itemBuilder:
                      (context) => [
                        PopupMenuItem(
                          value: ItemHistoryViewMode.list,
                          child: Row(
                            children: [
                              Icon(
                                Icons.list_rounded,
                                size: 18,
                                color:
                                    _mode ==
                                            ItemHistoryViewMode
                                                .list
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'List',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .list
                                            ? FontWeight
                                                .bold
                                            : FontWeight
                                                .normal,
                                    color:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .list
                                            ? theme
                                                .lightModeColor
                                                .prColor300
                                            : Colors
                                                .black87,
                                  ),
                                ),
                              ),
                              if (_mode ==
                                  ItemHistoryViewMode.list)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ItemHistoryViewMode.table,
                          child: Row(
                            children: [
                              Icon(
                                Icons.table_chart_outlined,
                                size: 18,
                                color:
                                    _mode ==
                                            ItemHistoryViewMode
                                                .table
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Table',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .table
                                            ? FontWeight
                                                .bold
                                            : FontWeight
                                                .normal,
                                    color:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .table
                                            ? theme
                                                .lightModeColor
                                                .prColor300
                                            : Colors
                                                .black87,
                                  ),
                                ),
                              ),
                              if (_mode ==
                                  ItemHistoryViewMode.table)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: ItemHistoryViewMode.sales,
                          child: Row(
                            children: [
                              Icon(
                                Icons.point_of_sale_outlined,
                                size: 18,
                                color:
                                    _mode ==
                                            ItemHistoryViewMode
                                                .sales
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Sales',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        _mode ==
                                                ItemHistoryViewMode
                                                      .sales
                                            ? FontWeight
                                                .bold
                                            : FontWeight
                                                .normal,
                                    color:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .sales
                                            ? theme
                                                .lightModeColor
                                                .prColor300
                                            : Colors
                                                .black87,
                                  ),
                                ),
                              ),
                              if (_mode ==
                                  ItemHistoryViewMode.sales)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value:
                              ItemHistoryViewMode.summary,
                          child: Row(
                            children: [
                              Icon(
                                Icons.summarize_outlined,
                                size: 18,
                                color:
                                    _mode ==
                                            ItemHistoryViewMode
                                                .summary
                                        ? theme
                                            .lightModeColor
                                            .prColor300
                                        : Colors
                                            .grey
                                            .shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Summary',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .summary
                                            ? FontWeight
                                                .bold
                                            : FontWeight
                                                .normal,
                                    color:
                                        _mode ==
                                                ItemHistoryViewMode
                                                    .summary
                                            ? theme
                                                .lightModeColor
                                                .prColor300
                                            : Colors
                                                .black87,
                                  ),
                                ),
                              ),
                              if (_mode ==
                                  ItemHistoryViewMode
                                      .summary)
                                Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                            ],
                          ),
                        ),
                      ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        6,
                      ),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      spacing: 3,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _mode == ItemHistoryViewMode.table
                              ? Icons.table_chart_outlined
                              : _mode ==
                                  ItemHistoryViewMode.sales
                              ? Icons.point_of_sale_outlined
                              : _mode ==
                                  ItemHistoryViewMode
                                      .summary
                              ? Icons.summarize_outlined
                              : Icons.list_rounded,
                          size: 16,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                        ),
                        Text(
                          _mode == ItemHistoryViewMode.table
                              ? 'Table'
                              : _mode ==
                                  ItemHistoryViewMode.sales
                              ? 'Sales'
                              : _mode ==
                                  ItemHistoryViewMode
                                      .summary
                              ? 'Summary'
                              : 'List',
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down,
                          size: 16,
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      body:
          _mode == ItemHistoryViewMode.table
              ? ItemHistoryReportView(
                isDesktop: false,
                lockedItemUuid: widget.productUuid,
                embedded: true,
              )
              : _mode == ItemHistoryViewMode.sales
              ? ItemSalesReportMainView(
                isDesktop: false,
                lockedItemUuid: widget.productUuid,
                embedded: true,
              )
              : _mode == ItemHistoryViewMode.summary
              ? Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  0,
                ),
                child: ItemHistoryItemSummary(
                  productUuid: widget.productUuid!,
                  isDesktop: false,
                ),
              )
              : Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  20,
                ),
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
                                      .getItemHistories(productUuid: widget.productUuid);
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
                                    .getItemHistories(productUuid: widget.productUuid);
                              },
                              child: ListView(
                                children:
                                    itemHistories
                                        .map(
                                          (
                                            item,
                                          ) => Material(
                                            type:
                                                MaterialType
                                                    .transparency,
                                            child: ItemHistoryTile(
                                              itemHistory:
                                                  item,
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
