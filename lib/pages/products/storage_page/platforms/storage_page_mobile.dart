import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/report/events_log/platforms/events_log_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

class StoragePageMobile extends StatefulWidget {
  const StoragePageMobile({super.key});

  @override
  State<StoragePageMobile> createState() =>
      _StoragePageMobileState();
}

class _StoragePageMobileState
    extends State<StoragePageMobile> {
  int sortIndex = 1;

  Future<void> getProducts() async {
    await RefreshFunctions(
      context,
    ).refreshProducts(context);
  }

  int start = 0;
  int end = 50;
  int count = 1;

  void navigate(bool isIncrease, int length) {
    setState(() {
      if (length > 50) {
        if (isIncrease) {
          if (length != end) {
            if (length < (end + 50)) {
              start = length - (length - end);
              end = length;
            } else {
              if ((end - start) < 50) {
                end += 50;
                start = end - 50;
              } else {
                start += 50;
                end += 50;
              }
            }
            count++;
          }
        } else {
          if (start != 0) {
            if ((start - 50) <= 0) {
              start = 0;
              end = length > 50 ? 50 : length;
            } else {
              if ((end - start) < 50) {
                end -= 50;
                start = end - 50;
              } else {
                start -= 50;
                end -= 50;
              }
            }
            count--;
          }
        }
      }
    });
  }

  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products =
        searchController.text.isNotEmpty
            ? returnData(context: context).productList
                .where(
                  (pr) =>
                      pr.name.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ) ||
                      pr.barcode == searchController.text,
                )
                .toList()
                .sublist(
                  0,
                  returnData(context: context).productList
                              .where(
                                (pr) =>
                                    pr.name
                                        .toLowerCase()
                                        .contains(
                                          searchController
                                              .text
                                              .toLowerCase(),
                                        ) ||
                                    pr.barcode ==
                                        searchController
                                            .text,
                              )
                              .toList()
                              .length >
                          100
                      ? 100
                      : returnData(context: context)
                          .productList
                          .where(
                            (pr) =>
                                pr.name
                                    .toLowerCase()
                                    .contains(
                                      searchController.text
                                          .toLowerCase(),
                                    ) ||
                                pr.barcode ==
                                    searchController.text,
                          )
                          .toList()
                          .length,
                )
            : returnData(
              context: context,
            ).productList.sublist(
              start,
              returnData(
                        context: context,
                      ).productList.length >
                      50
                  ? end
                  : returnData(
                    context: context,
                  ).productList.length,
            );

    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            backAction: () {
              if (sortIndex != 1) {
                setState(() {
                  sortIndex = 1;
                });
              } else {
                Navigator.of(context).pop();
              }
            },
            context: context,
            title:
                sortIndex == 1
                    ? 'Items'
                    : sortIndex == 2
                    ? 'Summary'
                    : 'History',
            widget: Visibility(
              visible: authorization(
                authorized:
                    Authorizations().viewItemsSummary,
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: PopupMenuButton(
                  offset: Offset(-20, 30),
                  color: Colors.white,
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () {
                          setState(() {
                            sortIndex = 1;
                          });
                        },
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight:
                                sortIndex == 1
                                    ? FontWeight.bold
                                    : null,
                          ),
                          'View Table',
                        ),
                      ),
                      PopupMenuItem(
                        enabled: authorization(
                          authorized:
                              Authorizations()
                                  .viewAllTransactionRecords,
                        ),
                        onTap: () {
                          setState(() {
                            sortIndex = 2;
                          });
                        },
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight:
                                sortIndex == 2
                                    ? FontWeight.bold
                                    : null,
                          ),
                          'View Total Summary',
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          setState(() {
                            sortIndex = 3;
                          });
                        },
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight:
                                sortIndex == 3
                                    ? FontWeight.bold
                                    : null,
                          ),
                          'View History',
                        ),
                      ),
                    ];
                  },
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),
                            'View:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            sortIndex == 1
                                ? 'Table'
                                : sortIndex == 2
                                ? 'Summary'
                                : 'History',
                          ),
                        ],
                      ),
                      Icon(Icons.more_vert_rounded),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                      ),
                      child: Builder(
                        builder: (context) {
                          if (sortIndex == 1) {
                            return SingleChildScrollView(
                              primary: false,
                              scrollDirection:
                                  Axis.horizontal,
                              child: SizedBox(
                                width:
                                    products.isEmpty
                                        ? MediaQuery.of(
                                              context,
                                            ).size.width +
                                            100
                                        : MediaQuery.of(
                                              context,
                                            ).size.width <
                                            555
                                        ? MediaQuery.of(
                                              context,
                                            ).size.width +
                                            650
                                        : MediaQuery.of(
                                                  context,
                                                ).size.width >
                                                555 &&
                                            MediaQuery.of(
                                                  context,
                                                ).size.width <
                                                850
                                        ? MediaQuery.of(
                                              context,
                                            ).size.width +
                                            450
                                        : MediaQuery.of(
                                          context,
                                        ).size.width,
                                child: RefreshIndicator(
                                  onRefresh: () {
                                    return getProducts();
                                  },
                                  backgroundColor:
                                      Colors.white,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                  displacement: 10,
                                  child: ListView(
                                    children: [
                                      SummaryTableHeadingBar(
                                        isHeading: true,
                                        theme: theme,
                                        product: products,
                                      ),
                                      Builder(
                                        builder: (context) {
                                          if (products
                                              .isEmpty) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    top:
                                                        100.0,
                                                  ),
                                              child: EmptyWidgetDisplayOnly(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'No Item has been recorded yet',
                                                theme:
                                                    theme,
                                                height: 35,
                                                icon:
                                                    Icons
                                                        .clear,
                                              ),
                                            );
                                          } else {
                                            return RefreshIndicator(
                                              onRefresh: () {
                                                return getProducts();
                                              },
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              displacement:
                                                  10,
                                              child: SingleChildScrollView(
                                                primary:
                                                    true,
                                                child: Column(
                                                  children: [
                                                    ListView.builder(
                                                      shrinkWrap:
                                                          true,
                                                      itemCount:
                                                          products.length,
                                                      physics:
                                                          NeverScrollableScrollPhysics(),

                                                      itemBuilder: (
                                                        context,
                                                        index,
                                                      ) {
                                                        var product =
                                                            products[index];
                                                        return TableRowRecordWidget(
                                                          theme:
                                                              theme,
                                                          product:
                                                              product,
                                                        );
                                                      },
                                                    ),
                                                    SummaryTableHeadingBar(
                                                      isHeading:
                                                          false,
                                                      theme:
                                                          theme,
                                                      product:
                                                          products,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          20,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else if (sortIndex == 2) {
                            return SizedBox(
                              child: Column(
                                children: [
                                  Visibility(
                                    visible:
                                        !isStoreKeeper(),
                                    child: Column(
                                      children: [
                                        Container(
                                          width:
                                              double
                                                  .infinity,
                                          height: 1.5,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade200,
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'FINANCE',
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Column(
                                              spacing: 10,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TabContainer(
                                                        priceTextSize:
                                                            theme.mobileTexts.h4.fontSize,
                                                        isMoney:
                                                            true,
                                                        text:
                                                            'Total Cost Value',
                                                        price:
                                                            returnData(
                                                              context:
                                                                  context,
                                                            ).getTotalCostPrice(),
                                                        theme:
                                                            theme,
                                                        backGround: const Color.fromARGB(
                                                          11,
                                                          15,
                                                          4,
                                                          114,
                                                        ),
                                                        border: const Color.fromARGB(
                                                          32,
                                                          45,
                                                          3,
                                                          255,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TabContainer(
                                                        priceTextSize:
                                                            theme.mobileTexts.h4.fontSize,
                                                        isMoney:
                                                            true,
                                                        text:
                                                            'Total Sales Value',
                                                        price:
                                                            returnData(
                                                              context:
                                                                  context,
                                                            ).getTotalSellingPrice(),
                                                        theme:
                                                            theme,
                                                        backGround: const Color.fromARGB(
                                                          18,
                                                          2,
                                                          163,
                                                          31,
                                                        ),
                                                        border: const Color.fromARGB(
                                                          63,
                                                          2,
                                                          163,
                                                          31,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 1.5,
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                  ),
                                  SizedBox(height: 20),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'ITEMS',
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        spacing: 0,
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Expanded(
                                            child: TabContainer(
                                              isMoney:
                                                  false,
                                              text:
                                                  'Total Items',
                                              price:
                                                  returnData(
                                                        context:
                                                            context,
                                                      )
                                                      .productList
                                                      .length
                                                      .toDouble(),
                                              theme: theme,
                                              backGround:
                                                  const Color.fromARGB(
                                                    11,
                                                    15,
                                                    4,
                                                    114,
                                                  ),
                                              border:
                                                  const Color.fromARGB(
                                                    32,
                                                    45,
                                                    3,
                                                    255,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Column(
                                        spacing: 10,
                                        children: [
                                          Row(
                                            spacing: 10,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                            children: [
                                              Expanded(
                                                child: TabContainer(
                                                  isMoney:
                                                      false,
                                                  text:
                                                      'In Stock',
                                                  price:
                                                      returnData(
                                                            context:
                                                                context,
                                                          )
                                                          .productList
                                                          .where(
                                                            (
                                                              item,
                                                            ) =>
                                                                item.quantity !=
                                                                    null &&
                                                                item.quantity !=
                                                                    0,
                                                          )
                                                          .length
                                                          .toDouble(),
                                                  theme:
                                                      theme,
                                                  backGround:
                                                      const Color.fromARGB(
                                                        18,
                                                        2,
                                                        163,
                                                        31,
                                                      ),
                                                  border:
                                                      const Color.fromARGB(
                                                        63,
                                                        2,
                                                        163,
                                                        31,
                                                      ),
                                                ),
                                              ),
                                              Expanded(
                                                child: TabContainer(
                                                  isMoney:
                                                      false,
                                                  text:
                                                      'Out Of Stock',
                                                  price:
                                                      returnData(
                                                            context:
                                                                context,
                                                          )
                                                          .productList
                                                          .where(
                                                            (
                                                              item,
                                                            ) =>
                                                                item.quantity !=
                                                                    null &&
                                                                item.quantity ==
                                                                    0,
                                                          )
                                                          .length
                                                          .toDouble(),
                                                  theme:
                                                      theme,
                                                  backGround:
                                                      const Color.fromARGB(
                                                        25,
                                                        235,
                                                        150,
                                                        3,
                                                      ),
                                                  border:
                                                      const Color.fromARGB(
                                                        74,
                                                        232,
                                                        148,
                                                        3,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TabContainer(
                                                  isMoney:
                                                      false,
                                                  text:
                                                      'Un-Managed Items',
                                                  price:
                                                      returnData(
                                                            context:
                                                                context,
                                                          )
                                                          .productList
                                                          .where(
                                                            (
                                                              item,
                                                            ) =>
                                                                !item.isManaged,
                                                          )
                                                          .length
                                                          .toDouble(),
                                                  theme:
                                                      theme,
                                                  backGround:
                                                      const Color.fromARGB(
                                                        141,
                                                        245,
                                                        245,
                                                        245,
                                                      ),
                                                  border:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SizedBox(
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 1.5,
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                  ),
                                  SizedBox(height: 15),
                                  Builder(
                                    builder: (context) {
                                      if (returnInventoryUpdatesProvider(
                                            context:
                                                context,
                                          )
                                          .returnInventoryUpdates()
                                          .isEmpty) {
                                        return Padding(
                                          padding:
                                              EdgeInsetsGeometry.only(
                                                top: 100,
                                              ),
                                          child: EmptyWidgetDisplayOnly(
                                            title:
                                                'No History Recorded',
                                            subText:
                                                'No History Has been recorded for this day.',
                                            theme: theme,
                                            height: 30,
                                            altIcon:
                                                Icons
                                                    .refresh,
                                            altActionText:
                                                'Refresh History',
                                            icon:
                                                Icons.clear,
                                            altAction:
                                                () async {
                                                  await getProducts();
                                                },
                                          ),
                                        );
                                      }
                                      return ListView(
                                        shrinkWrap: true,
                                        children:
                                            returnInventoryUpdatesProvider(
                                                  context:
                                                      context,
                                                )
                                                .returnInventoryUpdates()
                                                .map(
                                                  (
                                                    update,
                                                  ) => InventoryUpdateWidgetMobile(
                                                    update:
                                                        update,
                                                  ),
                                                )
                                                .toList(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Visibility(
                    visible: sortIndex == 3,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 20.0,
                      ),
                      child: Row(
                        spacing: 3,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              returnInventoryUpdatesProvider()
                                          .dateSet ==
                                      null
                                  ? showDatePicker(
                                    context: context,
                                    firstDate: DateTime(
                                      2017,
                                      9,
                                      7,
                                      17,
                                      30,
                                    ),
                                    lastDate: DateTime(
                                      2027,
                                      9,
                                      7,
                                      17,
                                      30,
                                    ),
                                  ).then((value) {
                                    value != null
                                        ? returnInventoryUpdatesProvider()
                                            .setDate(value)
                                        : {};
                                  })
                                  : returnInventoryUpdatesProvider()
                                      .clearDate();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                10.0,
                              ),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Icon(
                                    size: 22,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                    returnInventoryUpdatesProvider(
                                              context:
                                                  context,
                                            ).dateSet ==
                                            null
                                        ? Icons
                                            .calendar_month
                                        : Icons.clear,
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                    ),
                                    returnInventoryUpdatesProvider(
                                              context:
                                                  context,
                                            ).dateSet !=
                                            null
                                        ? formatDateTime(
                                          returnInventoryUpdatesProvider(
                                                context:
                                                    context,
                                              ).dateSet ??
                                              DateTime.now(),
                                        )
                                        : 'Set Date',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Visibility(
                    visible: sortIndex == 1,
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 30,
                          width: 150,
                          child: TextField(
                            focusNode:
                                returnData().searchNode,
                            controller: searchController,
                            onChanged: (value) async {
                              setState(() {
                                start = 0;
                                end =
                                    returnData()
                                                .productList
                                                .length >
                                            50
                                        ? 50
                                        : returnData()
                                            .productList
                                            .length;
                                count = 1;
                              });
                            },
                            style: TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              suffixIcon: InkWell(
                                onTap: () {
                                  if (searchController
                                      .text
                                      .isNotEmpty) {
                                    searchController
                                        .clear();
                                    setState(() {
                                      count = 1;
                                    });
                                  }
                                },
                                child: Icon(
                                  size: 16,
                                  Icons.clear,
                                ),
                              ),
                              hintText: 'Search Name',
                              contentPadding:
                                  EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 5,
                                  ),
                              fillColor:
                                  Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color:
                                      Colors.grey.shade200,
                                  width: 2,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                              ),
                              focusedBorder:
                                  OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color:
                                          Colors
                                              .grey
                                              .shade400,
                                      width: 2,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(
                                          3,
                                        ),
                                  ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity:
                              searchController
                                      .text
                                      .isNotEmpty
                                  ? 0
                                  : 1,
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            spacing: 0,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (start != 0) {
                                    navigate(
                                      false,
                                      returnData()
                                          .productList
                                          .length,
                                    );
                                  }
                                },
                                icon: Icon(
                                  size: 16,
                                  color:
                                      start == 0
                                          ? Colors
                                              .grey
                                              .shade400
                                          : Colors
                                              .grey
                                              .shade800,
                                  Icons.arrow_back_sharp,
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                spacing: 3,
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
                                    count.toString(),
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                    '/',
                                  ),
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.grey,
                                    ),
                                    "${returnData(context: context).productList.length > 50 ? (returnData(context: context).productList.length / 50).ceil() : 1}",
                                  ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {
                                  if (end !=
                                      returnData()
                                          .productList
                                          .length) {
                                    navigate(
                                      true,
                                      returnData()
                                          .productList
                                          .length,
                                    );
                                  }
                                },
                                icon: Icon(
                                  size: 16,
                                  color:
                                      end ==
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).productList.length ||
                                              returnData(
                                                    context:
                                                        context,
                                                  ).productList.length <=
                                                  50
                                          ? Colors
                                              .grey
                                              .shade400
                                          : Colors
                                              .grey
                                              .shade800,
                                  Icons.arrow_forward_sharp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              Visibility(
                visible: returnData().isLoading,
                child: returnCompProvider(
                  context,
                  listen: false,
                ).showLoader(message: 'Generating Record'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SummaryTableHeadingBar extends StatefulWidget {
  const SummaryTableHeadingBar({
    super.key,
    required this.theme,
    required this.product,
    required this.isHeading,
  });

  final ThemeProvider theme;
  final List<TempProductClass> product;
  final bool isHeading;
  @override
  State<SummaryTableHeadingBar> createState() =>
      _SummaryTableHeadingBarState();
}

class _SummaryTableHeadingBarState
    extends State<SummaryTableHeadingBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            widget.isHeading
                ? Border(
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                  top: BorderSide(color: Colors.grey),
                )
                : Border(
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
        color:
            widget.isHeading
                ? Colors.grey.shade100
                : Colors.grey.shade200,
      ),
      child: Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 10,
              ),
              child: Center(
                child: Text(
                  style: TextStyle(
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b3
                            .fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.isHeading ? 'S/N' : '',
                ),
              ),
            ),
          ),
          Expanded(
            flex: widget.product.isNotEmpty ? 9 : 4,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget.isHeading
                                  ? widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize
                                  : widget
                                      .theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Item Name'
                            : 'TOTAL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Total Qtty'
                            : returnData(context: context)
                                .getTotalOverallQuantity(
                                  products: widget.product,
                                )
                                .toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Qtty In Storage'
                            : returnData(context: context)
                                .getTotalQuantityInStorage(
                                  products: widget.product,
                                )
                                .toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Qtty'
                            : returnData(context: context)
                                .getTotalQuantity(
                                  products: widget.product,
                                )
                                .toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.product.isNotEmpty,
            child: Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isHeading
                              ? 'Selling-Price'
                              : formatMoneyMid(
                                amount: returnData(
                                  context: context,
                                ).getTotalSellingPrice(
                                  products: widget.product,
                                ),
                                context: context,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.product.isNotEmpty,
            child: Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isHeading
                              ? 'Cost-Price'
                              : formatMoneyBig(
                                amount: returnData(
                                  context: context,
                                ).getTotalCostPrice(
                                  products: widget.product,
                                ),
                                context: context,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: widget.product.isNotEmpty,
            child: Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    // right: BorderSide(color: Colors.grey),
                    // left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isHeading
                              ? 'Is Managed'
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableRowRecordWidget extends StatefulWidget {
  const TableRowRecordWidget({
    super.key,
    required this.theme,
    required this.product,
  });

  final ThemeProvider theme;
  final TempProductClass product;

  @override
  State<TableRowRecordWidget> createState() =>
      _TableRowRecordWidgetState();
}

class _TableRowRecordWidgetState
    extends State<TableRowRecordWidget> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailsPage(
                productUuid: widget.product.uuid!,
              );
            },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey),
            left: BorderSide(color: Colors.grey),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Row(
          spacing: 0,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          (returnData(
                                    context: context,
                                  ).productList.indexWhere(
                                    (item) =>
                                        item.uuid ==
                                        widget.product.uuid,
                                  ) +
                                  1)
                              .toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.product.name,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          ((widget.product.totalQttyInStorage ??
                                      0) +
                                  (widget
                                          .product
                                          .quantity ??
                                      0))
                              .toString(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: QuantityEditWidget(
                isTotal: true,
                product: widget.product,
              ),
            ),
            Expanded(
              flex: 7,
              child: QuantityEditWidget(
                isTotal: false,
                product: widget.product,
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                widget
                                    .product
                                    .sellingPrice ??
                                0,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                widget.product.costPrice,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      IsManagedToggleWidget(
                        product: widget.product,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class IsManagedToggleWidget extends StatefulWidget {
  final TempProductClass product;
  const IsManagedToggleWidget({
    super.key,
    required this.product,
  });

  @override
  State<IsManagedToggleWidget> createState() =>
      _IsManagedToggleWidgetState();
}

class _IsManagedToggleWidgetState
    extends State<IsManagedToggleWidget> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return InkWell(
      onTap: () {
        ItemsAuthAction().allowStockallToManageItemAction(
          context: context,
          action: () async {
            var dataProvider = returnData();
            showDialog(
              context: context,
              builder: (confirmDialog) {
                return ConfirmationAlert(
                  theme: theme,
                  message:
                      widget.product.isManaged
                          ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                          : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                  title: 'Proceed with Action?',
                  action: () async {
                    Navigator.of(confirmDialog).pop();
                    setState(() {
                      isLoading = true;
                    });
                    await dataProvider.updateProduct(
                      product: TempProductClass(
                        updatedAt: DateTime.now(),
                        setCustomPrice:
                            widget.product.setCustomPrice,
                        isManaged:
                            widget.product.isManaged
                                ? false
                                : true,
                        name: widget.product.name,
                        totalQttyInStorage:
                            widget
                                .product
                                .totalQttyInStorage,
                        unit: widget.product.unit,
                        isRefundable:
                            widget.product.isRefundable,
                        costPrice: widget.product.costPrice,
                        sellingPrice:
                            widget.product.sellingPrice,
                        quantity:
                            !widget.product.isManaged &&
                                    widget
                                            .product
                                            .quantity ==
                                        null
                                ? 0
                                : widget.product.quantity,
                        shopId: widget.product.shopId,
                        barcode: widget.product.barcode,
                        category: widget.product.category,
                        createdAt: widget.product.createdAt,
                        discount: widget.product.discount,
                        endDate: widget.product.endDate,
                        expiryDate:
                            widget.product.expiryDate,
                        lowQtty: widget.product.lowQtty,
                        sizeType: widget.product.sizeType,
                        startDate: widget.product.startDate,
                        uuid: widget.product.uuid,
                      ),
                      oldProduct: widget.product,
                    );
                    setState(() {
                      isLoading = false;
                    });
                  },
                );
              },
            );
          },
        );
      },
      child: SubWrapper(
        isVisible:
            !ItemsAuthAction()
                .allowStockallToManageItemAction(
                  context: context,
                ),
        mainWidget: Stack(
          children: [
            Visibility(
              visible: !isLoading,
              child: Container(
                width: 38,
                padding: EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3.5,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        widget.product.isManaged
                            ? theme
                                .lightModeColor
                                .prColor300
                            : Colors.grey,
                  ),
                  color:
                      widget.product.isManaged
                          ? theme.lightModeColor.prColor300
                          : Colors.grey.shade200,
                ),
                child: Row(
                  mainAxisAlignment:
                      widget.product.isManaged
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            widget.product.isManaged
                                ? Colors.white
                                : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: isLoading,
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: theme.lightModeColor.secColor200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuantityEditWidget extends StatefulWidget {
  final TempProductClass product;
  final bool isTotal;
  const QuantityEditWidget({
    super.key,
    required this.product,
    required this.isTotal,
  });

  @override
  State<QuantityEditWidget> createState() =>
      _QuantityEditWidgetState();
}

class _QuantityEditWidgetState
    extends State<QuantityEditWidget> {
  bool isActive = false;
  final node = FocusNode();
  final controller = TextEditingController();

  final NumberFormat _formatter =
      NumberFormat.decimalPattern('en_NG');

  String _rawValue = '';
  bool _isEditing = false;
  bool isLoading = false;

  bool errorUpdating = false;

  void saveEdit() async {
    showDialog(
      context: context,
      builder: (newC) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are about to permanently Save this update, are you sure you want to proceed?',
          title: 'Save Update',
          action: () async {
            Navigator.of(newC).pop();
            node.unfocus();
            setState(() {
              isActive = false;
              errorUpdating = false;
              isLoading = true;
            });

            if (widget.isTotal) {
              var tempPro = TempProductClass(
                id: widget.product.id,
                uuid: widget.product.uuid,
                barcode: widget.product.barcode,
                brand: widget.product.brand,
                category: widget.product.category,
                color: widget.product.color,
                createdAt: widget.product.createdAt,
                departmentName:
                    widget.product.departmentName,
                departmentUuid:
                    widget.product.departmentUuid,
                discount: widget.product.discount,
                endDate: widget.product.endDate,
                expiryDate: widget.product.expiryDate,
                lowQtty: widget.product.lowQtty,
                sellingPrice: widget.product.sellingPrice,
                size: widget.product.size,
                sizeType: widget.product.sizeType,
                startDate: widget.product.startDate,
                updatedAt: widget.product.updatedAt,
                quantity: widget.product.quantity,
                totalQttyInStorage: int.tryParse(
                  controller.text,
                ),
                name: widget.product.name,
                unit: widget.product.unit,
                isRefundable: widget.product.isRefundable,
                costPrice: widget.product.costPrice,
                shopId: widget.product.shopId,
                setCustomPrice:
                    widget.product.setCustomPrice,
                isManaged: widget.product.isManaged,
              );
              var res = await returnData().updateProduct(
                product: tempPro,
                oldProduct: widget.product,
              );
              setState(() {
                isLoading = false;
              });
              if (res == null) {
                controller.text = formatLargeNumber(
                  widget.product.totalQttyInStorage
                          ?.toStringAsFixed(0) ??
                      '0',
                );
                setState(() {
                  errorUpdating = true;
                });
              } else {
                controller.text = (res.totalQttyInStorage ??
                        0)
                    .toStringAsFixed(0);
              }
            } else {
              var tempPro = TempProductClass(
                id: widget.product.id,
                uuid: widget.product.uuid,
                barcode: widget.product.barcode,
                brand: widget.product.brand,
                category: widget.product.category,
                color: widget.product.color,
                createdAt: widget.product.createdAt,
                departmentName:
                    widget.product.departmentName,
                departmentUuid:
                    widget.product.departmentUuid,
                discount: widget.product.discount,
                endDate: widget.product.endDate,
                expiryDate: widget.product.expiryDate,
                lowQtty: widget.product.lowQtty,
                sellingPrice: widget.product.sellingPrice,
                size: widget.product.size,
                sizeType: widget.product.sizeType,
                startDate: widget.product.startDate,
                updatedAt: widget.product.updatedAt,
                quantity: double.tryParse(controller.text),
                totalQttyInStorage:
                    (widget.product.totalQttyInStorage ??
                                    0) -
                                ((double.tryParse(
                                              controller
                                                  .text,
                                            ) ??
                                            0) -
                                        (widget
                                                .product
                                                .quantity ??
                                            0))
                                    .toInt() >=
                            0
                        ? (widget
                                    .product
                                    .totalQttyInStorage ??
                                0) -
                            ((double.tryParse(
                                          controller.text,
                                        ) ??
                                        0) -
                                    (widget
                                            .product
                                            .quantity ??
                                        0))
                                .toInt()
                        : 0,
                name: widget.product.name,
                unit: widget.product.unit,
                isRefundable: widget.product.isRefundable,
                costPrice: widget.product.costPrice,
                shopId: widget.product.shopId,
                setCustomPrice:
                    widget.product.setCustomPrice,
                isManaged: widget.product.isManaged,
              );
              var res = await returnData().updateProduct(
                product: tempPro,
                oldProduct: widget.product,
              );
              setState(() {
                isLoading = false;
              });
              if (res == null) {
                controller.text = formatLargeNumber(
                  widget.product.quantity?.toStringAsFixed(
                        0,
                      ) ??
                      '0',
                );
                setState(() {
                  errorUpdating = true;
                });
              } else {
                controller.text = (res.quantity ?? 0)
                    .toStringAsFixed(0);
              }
            }
          },
        );
      },
    );
  }

  void cancelEdit() async {
    showDialog(
      context: context,
      builder: (newC) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are about to cancel this edit. Are you sure you want to proceed?',
          title: 'Cancel Edit',
          action: () async {
            Navigator.of(newC).pop();
            node.unfocus();
            setState(() {
              isActive = false;
              errorUpdating = false;
            });
            if (widget.isTotal) {
              controller.text =
                  (widget.product.totalQttyInStorage ?? '0')
                      .toString();
            } else {
              controller.text =
                  (widget.product.quantity ?? '0')
                      .toString();
            }
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isTotal) {
      controller.text = formatLargeNumber(
        widget.product.totalQttyInStorage?.toStringAsFixed(
              0,
            ) ??
            '0',
      );
    } else {
      controller.text = formatLargeNumber(
        widget.product.quantity?.toStringAsFixed(0) ?? '0',
      );
    }

    controller.addListener(() {
      if (_isEditing) return;

      final rawText = controller.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      final cleaned = rawText.replaceFirst(
        RegExp(r'^0+'),
        '',
      );

      if (cleaned != _rawValue) {
        _rawValue = cleaned;

        final int amount =
            int.tryParse(
              _rawValue.isEmpty ? '0' : _rawValue,
            ) ??
            0;
        final formatted =
            amount == 0 ? '' : _formatter.format(amount);

        _isEditing = true;
        controller.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(
            offset: formatted.length,
          ),
        );
        _isEditing = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    node.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade500),
        ),
      ),
      child: Stack(
        // alignment: Alignment(1, 0),
        children: [
          Builder(
            builder: (context) {
              if (isActive) {
                return TextFormField(
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.number,
                  focusNode: node,
                  controller: controller,
                  readOnly: !isActive,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                  decoration: InputDecoration(
                    hintText: '',
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                    isCollapsed: true,
                  ),
                  onFieldSubmitted: (value) {
                    saveEdit();
                  },
                  onTap: () {
                    returnData().removeSearchNodeListener();
                  },
                  onChanged: (value) {
                    if (!widget.isTotal &&
                        value.isNotEmpty &&
                        widget.product.isManaged) {
                      if (((widget
                                      .product
                                      .totalQttyInStorage ??
                                  0) +
                              (widget.product.quantity ??
                                  0)) <
                          int.parse(
                            controller.text.replaceAll(
                              RegExp(r','),
                              '',
                            ),
                          )) {
                        controller.text =
                            (widget.product.quantity ?? 0)
                                .toStringAsFixed(0);
                      }
                    }
                  },
                );
              }
              return Container();
            },
          ),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Opacity(
                opacity: isActive ? 0 : 1,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 13.0,
                  ),
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                    "${widget.isTotal ? widget.product.totalQttyInStorage ?? 0 : widget.product.quantity ?? 0}",
                  ),
                ),
              ),
              Stack(
                children: [
                  Visibility(
                    visible: !isLoading && !errorUpdating,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2,
                      children: [
                        Visibility(
                          visible: isActive,
                          child: InkWell(
                            onTap: () {
                              cancelEdit();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    vertical: 9.0,
                                    horizontal: 5,
                                  ),
                              child: Icon(
                                size: 15,
                                Icons.clear,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            if (isActive) {
                              saveEdit();
                            } else {
                              setState(() {
                                isActive = true;
                              });
                              node.requestFocus();
                              if (widget.isTotal) {
                                controller
                                    .text = formatLargeNumber(
                                  widget
                                          .product
                                          .totalQttyInStorage
                                          ?.toStringAsFixed(
                                            0,
                                          ) ??
                                      '0',
                                );
                              } else {
                                controller
                                    .text = formatLargeNumber(
                                  widget.product.quantity
                                          ?.toStringAsFixed(
                                            0,
                                          ) ??
                                      '0',
                                );
                              }
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              9.0,
                            ),
                            child: Icon(
                              size: !isActive ? 12 : 15,
                              !isActive
                                  ? Icons.edit
                                  : Icons.check,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isLoading && !errorUpdating,
                    child: Padding(
                      padding: const EdgeInsets.all(9.0),
                      child: SizedBox(
                        height: 15,
                        width: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: errorUpdating,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          isActive = true;
                          errorUpdating = false;
                        });
                        node.requestFocus();
                        if (widget.isTotal) {
                          controller
                              .text = formatLargeNumber(
                            widget
                                    .product
                                    .totalQttyInStorage
                                    ?.toStringAsFixed(0) ??
                                '0',
                          );
                        } else {
                          controller
                              .text = formatLargeNumber(
                            widget.product.quantity
                                    ?.toStringAsFixed(0) ??
                                '0',
                          );
                        }
                      },
                      child: Padding(
                        padding: EdgeInsetsGeometry.all(9),
                        child: Icon(
                          size: 18,
                          color: Colors.red,
                          Icons.error_outline_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class InventoryUpdateWidgetMobile extends StatefulWidget {
  final TempInventoryUpdateClass update;
  const InventoryUpdateWidgetMobile({
    super.key,
    required this.update,
  });

  @override
  State<InventoryUpdateWidgetMobile> createState() =>
      _InventoryUpdateWidgetMobileState();
}

class _InventoryUpdateWidgetMobileState
    extends State<InventoryUpdateWidgetMobile> {
  String formatValue(String value, String title) {
    double? parsed = double.tryParse(value);
    if (parsed == null) {
      return value;
    } else {
      if (title.split(' ')[1] == 'Selling') {
        return formatMoneyMid(
          amount: parsed,
          context: context,
        );
      } else {
        return value;
      }
    }
  }

  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(2),
          onTap: () {
            setState(() {
              isOpen = !isOpen;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  spacing: 6,
                  children: [
                    Icon(
                      size: 15,
                      color:
                          theme.lightModeColor.secColor200,
                      Icons.receipt,
                    ),
                    MyDividerMobile(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Update:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              // fontWeight: FontWeight.bold,
                            ),
                            widget.update.title,
                          ),
                        ],
                      ),
                    ),
                    MyDividerMobile(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        spacing: 1,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            'Item Name:',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              // fontWeight: FontWeight.bold,
                            ),
                            widget.update.itemName ?? '',
                          ),
                        ],
                      ),
                    ),
                    MyDividerMobile(),
                    Icon(
                      size: 18,
                      color: Colors.grey.shade500,
                      isOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons
                              .keyboard_arrow_down_rounded,
                    ),
                  ],
                ),
                Visibility(
                  visible: isOpen,
                  child: SizedBox(height: 3),
                ),
                Visibility(
                  visible: isOpen,
                  child: Divider(
                    color: Colors.grey.shade300,
                    height: 20,
                    thickness: 0.8,
                  ),
                ),
                Visibility(
                  visible: isOpen,
                  child: Column(
                    spacing: 10,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Row(
                        spacing: 10,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Column(
                              spacing: 1,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Old Value:',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    // fontWeight:
                                    //     FontWeight.bold,
                                  ),
                                  formatValue(
                                    widget
                                            .update
                                            .oldValue ??
                                        '',
                                    widget.update.title,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          MyDividerMobile(),
                          Expanded(
                            child: Column(
                              spacing: 1,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'New Value:',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    // fontWeight:
                                    //     FontWeight.bold,
                                  ),
                                  formatValue(
                                    widget
                                            .update
                                            .newValue ??
                                        '',
                                    widget.update.title,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Visibility(
                            visible:
                                widget.update.uuid !=
                                    null &&
                                returnData().productList
                                    .where(
                                      (pr) =>
                                          pr.uuid ==
                                          widget
                                              .update
                                              .itemUuid,
                                    )
                                    .isNotEmpty,
                            child: Material(
                              type:
                                  MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ProductDetailsPage(
                                          productUuid:
                                              widget
                                                  .update
                                                  .itemUuid!,
                                          comingFromInventoryUpdatesPage:
                                              true,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 8,
                                      ),
                                  child: Row(
                                    spacing: 4,
                                    children: [
                                      MyDividerMobile(),
                                      SizedBox(width: 5),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b4
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'View Item',
                                      ),
                                      Icon(
                                        size: 15,
                                        color:
                                            const Color.fromARGB(
                                              255,
                                              255,
                                              176,
                                              7,
                                            ),
                                        Icons
                                            .arrow_forward_ios_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey.shade300,
                        height: 0,
                        thickness: 0.8,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          spacing: 10,
                          children: [
                            Row(
                              spacing: 5,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Creator:',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                  ),
                                  widget.update.staffName ??
                                      '',
                                ),
                              ],
                            ),
                            MyDividerMobile(),
                            Row(
                              spacing: 5,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Date:',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                  ),
                                  formatDateTimeTime(
                                    widget
                                            .update
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
