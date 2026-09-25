import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_item_history_page/components/storage_item_history_tile.dart';

class StorageItemHistoryDesktop extends StatefulWidget {
  final String? productUuid;
  final bool fromItemDetails;
  const StorageItemHistoryDesktop({
    super.key,
    this.productUuid,
    required this.fromItemDetails,
  });

  @override
  State<StorageItemHistoryDesktop> createState() =>
      _StorageItemHistoryDesktopState();
}

class _StorageItemHistoryDesktopState
    extends State<StorageItemHistoryDesktop> {
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
    List<StorageItemHistory>? itemHistories =
        returnStorageItemHistoryProvider(
          context: context,
        ).storageItemHistories.where((history) {
          if (widget.productUuid != null) {
            return history.storageItemUuid ==
                    widget.productUuid &&
                (history.storageItemName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    history.storageDepartmentName
                            ?.toLowerCase()
                            .contains(
                              searchController.text
                                  .toLowerCase(),
                            ) ==
                        true ||
                    history.storageStaffName
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
            return (history.storageItemName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                history.storageDepartmentName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
                        ) ==
                    true ||
                history.storageStaffName
                        ?.toLowerCase()
                        .contains(
                          searchController.text
                              .toLowerCase(),
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
                          returnStorageItemHistoryProvider()
                              .getItemHistories();
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
                            if (returnStorageItemHistoryProvider()
                                        .dateSet !=
                                    null ||
                                returnStorageItemHistoryProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnStorageItemHistoryProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnStorageItemHistoryProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnStorageItemHistoryProvider()
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
                                  returnStorageItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnStorageItemHistoryProvider(
                                                context:
                                                    context,
                                              ).rangeStartDate !=
                                              null
                                      ? 'Clear'
                                      : 'Date',
                                ),
                                Icon(
                                  size: 16,
                                  returnStorageItemHistoryProvider(
                                                context:
                                                    context,
                                              ).dateSet !=
                                              null ||
                                          returnStorageItemHistoryProvider(
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
                            if (itemHistories.isEmpty) {
                              return Center(
                                child: EmptyWidgetDisplayOnly(
                                  title: 'No Events Found',
                                  subText:
                                      'No event has been created for this date.',
                                  theme: theme,
                                  height: 30,
                                  altAction: () {
                                    returnStorageItemHistoryProvider()
                                        .getItemHistories();
                                  },
                                  altActionText: 'Reload',
                                  icon: Icons.clear,
                                ),
                              );
                            } else {
                              return ListView(
                                children:
                                    itemHistories
                                        .map(
                                          (
                                            item,
                                          ) => StorageItemHistoryTile(
                                            itemHistory:
                                                item,
                                            fromDetails:
                                                widget
                                                    .fromItemDetails,
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

class SearchFilterWidgetHistory extends StatefulWidget {
  final TextEditingController searchController;
  final Function(String value)? onChanged;
  final String? text;
  const SearchFilterWidgetHistory({
    super.key,
    required this.searchController,
    required this.onChanged,
    this.text,
  });

  @override
  State<SearchFilterWidgetHistory> createState() =>
      _SearchFilterWidgetHistoryState();
}

class _SearchFilterWidgetHistoryState
    extends State<SearchFilterWidgetHistory> {
  bool isSearchFilterOn = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
            right: 10,
          ),
          child: Builder(
            builder: (context) {
              if (isSearchFilterOn) {
                return Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth:
                          screenWidth(context) >
                                  mobileScreenSmall
                              ? 430
                              : screenWidth(context) - 40,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            34,
                            0,
                            0,
                            0,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      spacing: 5,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.end,
                      children: [
                        Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: GeneralTextfieldOnly(
                                hint: 'Enter Search Text',
                                controller:
                                    widget.searchController,
                                lines: 1,
                                theme: theme,
                                onChanged: widget.onChanged,
                              ),
                            ),
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                                onTap: () {
                                  setState(() {
                                    isSearchFilterOn =
                                        false;
                                  });
                                  widget.searchController
                                      .clear();
                                  widget.onChanged!(
                                    'value',
                                  );
                                },
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        8.0,
                                      ),
                                  child: Icon(
                                    size: 20,
                                    color:
                                        Colors
                                            .grey
                                            .shade600,
                                    Icons.clear,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                          ),
                          'NB: You Can Search ${widget.text ?? 'Title, Item name, Staff Name, Department Name.'}',
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          50,
                          0,
                          0,
                          0,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                      ),
                      child: InkWell(
                        mouseCursor:
                            SystemMouseCursors.click,
                        onTap: () {
                          setState(() {
                            isSearchFilterOn = true;
                          });
                        },
                        borderRadius: BorderRadius.circular(
                          3,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),

                          child: Row(
                            spacing: 5,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Search Filter',
                              ),
                              Icon(
                                size: 20,
                                color:
                                    theme
                                        .lightModeColor
                                        .secColor200,
                                Icons.search,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
