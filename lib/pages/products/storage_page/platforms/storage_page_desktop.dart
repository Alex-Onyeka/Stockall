import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/add_storage_item.dart';
import 'package:stockall/pages/products/storage_page/components/inventory_update_widget.dart';
import 'package:stockall/pages/products/storage_page/components/summary_table_heading_bar.dart';
import 'package:stockall/pages/products/storage_page/components/table_row_widget.dart';

class StoragePageDesktop extends StatefulWidget {
  const StoragePageDesktop({super.key});

  @override
  State<StoragePageDesktop> createState() =>
      StoragePageDesktopState();
}

class StoragePageDesktopState
    extends State<StoragePageDesktop> {
  int sortIndex = 1;

  bool viewUpdateSummary = false;

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().requestFocusSearchNode();
      returnData().addSearchNodeListener();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnData().removeSearchNodeListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products =
        searchController.text.isNotEmpty
            ? returnStorageProductProvider(context: context)
                .storageProductListMain
                .where(
                  (pr) => pr.name.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .toList()
                .sublist(
                  0,
                  returnStorageProductProvider(
                                context: context,
                              ).storageProductListMain
                              .where(
                                (pr) => pr.name
                                    .toLowerCase()
                                    .contains(
                                      searchController.text
                                          .toLowerCase(),
                                    ),
                              )
                              .toList()
                              .length >
                          100
                      ? 100
                      : returnStorageProductProvider(
                            context: context,
                          ).storageProductListMain
                          .where(
                            (pr) => pr.name
                                .toLowerCase()
                                .contains(
                                  searchController.text
                                      .toLowerCase(),
                                ),
                          )
                          .toList()
                          .length,
                )
            : returnStorageProductProvider(
              context: context,
            ).storageProductListMain.sublist(
              start,
              returnStorageProductProvider(
                        context: context,
                      ).storageProductListMain.length >
                      50
                  ? end
                  : returnStorageProductProvider(
                    context: context,
                  ).storageProductListMain.length,
            );

    return Stack(
      children: [
        DesktopCenterContainer(
          width: double.infinity,
          mainWidget: Scaffold(
            appBar: appBar(
              backAction: () {
                if (sortIndex != 1) {
                  setState(() {
                    sortIndex = 1;
                    searchController.clear();
                    viewUpdateSummary = false;
                  });
                  returnInventoryUpdatesProvider()
                      .clearDate();
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
              widget: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      borderRadius: BorderRadius.circular(
                        10,
                      ),
                      onTap: () async {
                        await getProducts();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          spacing: 5,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Refresh',
                            ),
                            Icon(
                              size: 18,
                              Icons.refresh_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().viewItemsSummary,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 15.0,
                      ),
                      child: PopupMenuButton(
                        offset: Offset(-20, 30),
                        color: Colors.white,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                setState(() {
                                  sortIndex = 1;
                                  viewUpdateSummary = false;
                                });
                                returnData()
                                    .requestFocusSearchNode();
                                returnData()
                                    .addSearchNodeListener();
                                searchController.clear();
                                returnInventoryUpdatesProvider()
                                    .clearDate();
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
                                  viewUpdateSummary = false;
                                });
                                searchController.clear();
                                returnInventoryUpdatesProvider()
                                    .clearDate();
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
                                  viewUpdateSummary = false;
                                });
                                searchController.clear();
                                returnInventoryUpdatesProvider()
                                    .clearDate();
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
                              mainAxisSize:
                                  MainAxisSize.min,
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
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
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
                ],
              ),
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Builder(
                              builder: (context) {
                                if (sortIndex == 1) {
                                  return ListView(
                                    primary: false,
                                    scrollDirection:
                                        Axis.horizontal,
                                    children: [
                                      SizedBox(
                                        width:
                                            screenWidth(
                                              context,
                                            ) -
                                            120,
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
                                                isHeading:
                                                    true,
                                                theme:
                                                    theme,
                                                product:
                                                    products,
                                              ),
                                              Builder(
                                                builder: (
                                                  context,
                                                ) {
                                                  if (products
                                                      .isEmpty) {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(
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
                                                        height:
                                                            35,
                                                        icon:
                                                            Icons.clear,
                                                      ),
                                                    );
                                                  } else {
                                                    return RefreshIndicator(
                                                      onRefresh: () {
                                                        return getProducts();
                                                      },
                                                      backgroundColor:
                                                          Colors.white,
                                                      color:
                                                          theme.lightModeColor.prColor300,
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
                                    ],
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
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b2.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        'Finance',
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        8,
                                                  ),
                                                  Row(
                                                    spacing:
                                                        10,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Expanded(
                                                        child: TabContainer(
                                                          priceTextSize:
                                                              theme.mobileTexts.h3.fontSize,
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
                                                      Expanded(
                                                        child: TabContainer(
                                                          priceTextSize:
                                                              theme.mobileTexts.h3.fontSize,
                                                          isMoney:
                                                              true,
                                                          text:
                                                              'Total Selling Value',
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
                                              SizedBox(
                                                height: 20,
                                              ),
                                            ],
                                          ),
                                        ),
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
                                          height: 20,
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
                                                  'ITEMS',
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
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
                                                        ).productList().length.toDouble(),
                                                    theme:
                                                        theme,
                                                    backGround:
                                                        const Color.fromARGB(
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
                                            SizedBox(
                                              height: 10,
                                            ),
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
                                                            .productList()
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
                                                    border: const Color.fromARGB(
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
                                                            .productList()
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
                                                    backGround: const Color.fromARGB(
                                                      25,
                                                      235,
                                                      150,
                                                      3,
                                                    ),
                                                    border: const Color.fromARGB(
                                                      74,
                                                      232,
                                                      148,
                                                      3,
                                                    ),
                                                  ),
                                                ),
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
                                                            .productList()
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
                                                    backGround: const Color.fromARGB(
                                                      141,
                                                      245,
                                                      245,
                                                      245,
                                                    ),
                                                    border:
                                                        Colors.grey.shade300,
                                                  ),
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
                                        Expanded(
                                          child: Builder(
                                            builder: (
                                              context,
                                            ) {
                                              if (returnInventoryUpdatesProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnInventoryUpdates()
                                                  .where(
                                                    (
                                                      update,
                                                    ) =>
                                                        update.itemName?.toLowerCase().contains(
                                                              searchController.text.toLowerCase(),
                                                            ) ==
                                                            true ||
                                                        update.title.toLowerCase().contains(
                                                          searchController.text.toLowerCase(),
                                                        ),
                                                  )
                                                  .isEmpty) {
                                                return Padding(
                                                  padding:
                                                      EdgeInsetsGeometry.only(
                                                        top:
                                                            100,
                                                      ),
                                                  child: EmptyWidgetDisplayOnly(
                                                    title:
                                                        'No History Recorded',
                                                    subText:
                                                        'No History Has been recorded for this day.',
                                                    theme:
                                                        theme,
                                                    height:
                                                        30,
                                                    altIcon:
                                                        Icons.refresh,
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
                                                shrinkWrap:
                                                    true,
                                                children:
                                                    returnInventoryUpdatesProvider(
                                                          context:
                                                              context,
                                                        )
                                                        .returnInventoryUpdates()
                                                        .where(
                                                          (
                                                            update,
                                                          ) =>
                                                              update.itemName?.toLowerCase().contains(
                                                                    searchController.text.toLowerCase(),
                                                                  ) ==
                                                                  true ||
                                                              update.title.toLowerCase().contains(
                                                                searchController.text.toLowerCase(),
                                                              ),
                                                        )
                                                        .map(
                                                          (
                                                            update,
                                                          ) => InventoryUpdateWidget(
                                                            update:
                                                                update,
                                                          ),
                                                        )
                                                        .toList(),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Visibility(
                            visible: viewUpdateSummary,
                            child: Align(
                              alignment:
                                  AlignmentGeometry.xy(
                                    0,
                                    1,
                                  ),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    EdgeInsets.fromLTRB(
                                      20,
                                      10,
                                      20,
                                      20,
                                    ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(
                                        5,
                                      ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          const Color.fromARGB(
                                            30,
                                            0,
                                            0,
                                            0,
                                          ),
                                      offset: Offset(0, 1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  spacing: 5,
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Opacity(
                                          opacity: 0,
                                          child: IconButton(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onPressed:
                                                () {},
                                            icon: Icon(
                                              Icons.clear,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Update Summary',
                                        ),
                                        IconButton(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onPressed: () {
                                            setState(() {
                                              viewUpdateSummary =
                                                  false;
                                            });
                                          },
                                          icon: Icon(
                                            size: 20,
                                            Icons.clear,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
                                      spacing: 5,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            spacing: 1,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      8,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Total Stock In:',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                returnTotalStockIn(
                                                  updates:
                                                      returnInventoryUpdatesProvider(
                                                            context:
                                                                context,
                                                          )
                                                          .returnInventoryUpdates()
                                                          .where(
                                                            (
                                                              update,
                                                            ) =>
                                                                update.itemName?.toLowerCase().contains(
                                                                      searchController.text.toLowerCase(),
                                                                    ) ==
                                                                    true ||
                                                                update.title.toLowerCase().contains(
                                                                  searchController.text.toLowerCase(),
                                                                ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            spacing: 1,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      8,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Total Stock Out:',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                returnTotalStockOut(
                                                  updates:
                                                      returnInventoryUpdatesProvider(
                                                            context:
                                                                context,
                                                          )
                                                          .returnInventoryUpdates()
                                                          .where(
                                                            (
                                                              update,
                                                            ) =>
                                                                update.itemName?.toLowerCase().contains(
                                                                      searchController.text.toLowerCase(),
                                                                    ) ==
                                                                    true ||
                                                                update.title.toLowerCase().contains(
                                                                  searchController.text.toLowerCase(),
                                                                ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            spacing: 1,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .center,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      8,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Net:',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                returnNet(
                                                  updates:
                                                      returnInventoryUpdatesProvider(
                                                            context:
                                                                context,
                                                          )
                                                          .returnInventoryUpdates()
                                                          .where(
                                                            (
                                                              update,
                                                            ) =>
                                                                update.itemName?.toLowerCase().contains(
                                                                      searchController.text.toLowerCase(),
                                                                    ) ==
                                                                    true ||
                                                                update.title.toLowerCase().contains(
                                                                  searchController.text.toLowerCase(),
                                                                ),
                                                          )
                                                          .toList(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Visibility(
                      visible: sortIndex != 2,
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible: sortIndex == 1,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                borderRadius:
                                    BorderRadius.circular(
                                      3,
                                    ),
                                onTap: () {
                                  if (screenWidth(context) >
                                      mobileScreen) {
                                    returnData()
                                        .unFocusSearchNode();
                                    returnData()
                                        .removeSearchNodeListener();
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return AddStorageItem();
                                      },
                                    ),
                                  ).then((_) {
                                    if (screenWidth(
                                          context,
                                        ) >
                                        mobileScreen) {
                                      returnData()
                                          .requestFocusSearchNode();
                                      returnData()
                                          .addSearchNodeListener();
                                    }
                                  });
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.all(
                                        7.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    mainAxisSize:
                                        MainAxisSize.min,
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
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Add New',
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons.add,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: sortIndex == 3,
                            child: IconButton(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onPressed: () {
                                setState(() {
                                  viewUpdateSummary =
                                      !viewUpdateSummary;
                                });
                              },
                              icon: Icon(
                                viewUpdateSummary
                                    ? Icons
                                        .keyboard_arrow_up_outlined
                                    : Icons
                                        .keyboard_arrow_down_outlined,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                            width: 200,
                            child: TextField(
                              focusNode:
                                  returnData().searchNode,
                              controller: searchController,
                              onChanged: (value) async {
                                if (sortIndex == 1) {
                                  if (value.isNotEmpty) {
                                    if (value.length > 20) {
                                      searchController
                                          .clear();
                                    } else {
                                      var allPrs =
                                          returnData()
                                              .productList()
                                              .where(
                                                (pr) =>
                                                    pr.barcode ==
                                                    searchController
                                                        .text,
                                              )
                                              .toList();
                                      if (allPrs
                                          .isNotEmpty) {
                                        await playBeep();
                                      }
                                    }
                                  }
                                  setState(() {
                                    start = 0;
                                    end =
                                        returnData()
                                                    .productList()
                                                    .length >
                                                50
                                            ? 50
                                            : returnData()
                                                .productList()
                                                .length;
                                    count = 1;
                                  });
                                  // setState(() {});
                                } else {
                                  setState(() {});
                                }
                              },
                              style: TextStyle(
                                fontSize: 12,
                              ),
                              decoration: InputDecoration(
                                suffixIcon: InkWell(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
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
                                hintText:
                                    sortIndex == 1
                                        ? 'Search Name or Scan'
                                        : 'Search Event or Item Name',
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
                                        Colors
                                            .grey
                                            .shade200,
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
                          Visibility(
                            visible: sortIndex == 1,
                            child: Opacity(
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
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onPressed: () {
                                      if (start != 0) {
                                        navigate(
                                          false,
                                          returnStorageProductProvider()
                                              .storageProductListMain
                                              .length,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      size: 20,
                                      color:
                                          start == 0
                                              ? Colors
                                                  .grey
                                                  .shade400
                                              : Colors
                                                  .grey
                                                  .shade800,
                                      Icons
                                          .arrow_back_sharp,
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
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        count.toString(),
                                      ),
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
                                          color:
                                              Colors.grey,
                                        ),
                                        '/',
                                      ),
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
                                          color:
                                              Colors.grey,
                                        ),
                                        "${returnStorageProductProvider(context: context).storageProductListMain.length > 50 ? (returnStorageProductProvider(context: context).storageProductListMain.length / 50).ceil() : 1}",
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onPressed: () {
                                      if (end !=
                                          returnStorageProductProvider()
                                              .storageProductListMain
                                              .length) {
                                        navigate(
                                          true,
                                          returnStorageProductProvider()
                                              .storageProductListMain
                                              .length,
                                        );
                                      }
                                    },
                                    icon: Icon(
                                      size: 20,
                                      color:
                                          end ==
                                                      returnStorageProductProvider(
                                                        context:
                                                            context,
                                                      ).storageProductListMain.length ||
                                                  returnStorageProductProvider(
                                                        context:
                                                            context,
                                                      ).storageProductListMain.length <=
                                                      50
                                              ? Colors
                                                  .grey
                                                  .shade400
                                              : Colors
                                                  .grey
                                                  .shade800,
                                      Icons
                                          .arrow_forward_sharp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: sortIndex == 3,
                            child: Container(
                              color: Colors.white,
                              child: Row(
                                spacing: 3,
                                mainAxisAlignment:
                                    MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onTap: () {
                                      returnInventoryUpdatesProvider()
                                                      .dateSet ==
                                                  null &&
                                              returnInventoryUpdatesProvider()
                                                      .rangeStartDate ==
                                                  null
                                          ? mainDatePicker(
                                            context:
                                                context,
                                            theme: theme,
                                            singleDate: (
                                              date,
                                            ) {
                                              returnInventoryUpdatesProvider()
                                                  .setDate(
                                                    date!,
                                                  );
                                            },
                                            rangeDate: (
                                              firstDate,
                                              lastDate,
                                            ) {
                                              returnInventoryUpdatesProvider().setRange(
                                                firstDate!,
                                                lastDate ??
                                                    DateTime.now(),
                                              );
                                            },
                                          )
                                          : returnInventoryUpdatesProvider()
                                              .clearDate();
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.all(
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
                                                        null &&
                                                    returnInventoryUpdatesProvider(
                                                          context:
                                                              context,
                                                        ).rangeStartDate ==
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
                                                        null ||
                                                    returnInventoryUpdatesProvider(
                                                          context:
                                                              context,
                                                        ).rangeStartDate !=
                                                        null
                                                ? 'Clear'
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
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: returnData().isLoading,
                  child: returnCompProvider(
                    context,
                    listen: false,
                  ).showLoader(
                    message: 'Generating Record',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String returnTotalStockIn({
  required List<TempInventoryUpdateClass> updates,
}) {
  List<TempInventoryUpdateClass> tempUpdates = [];
  for (var up in updates) {
    if ((double.tryParse(up.oldValue ?? '0') ?? 0) <=
        (double.tryParse(up.newValue ?? '0') ?? 0)) {
      tempUpdates.add(up);
    }
  }
  double tempTotal = 0;
  for (var temp in tempUpdates) {
    tempTotal +=
        double.parse((temp.newValue ?? '0')) -
        double.parse((temp.oldValue ?? '0'));
  }
  return formatLargeNumberDouble(tempTotal);
}

String returnTotalStockOut({
  required List<TempInventoryUpdateClass> updates,
}) {
  List<TempInventoryUpdateClass> tempUpdates = [];
  for (var up in updates) {
    if ((double.tryParse(up.oldValue ?? '0') ?? 0) >
        (double.tryParse(up.newValue ?? '0') ?? 0)) {
      tempUpdates.add(up);
    }
  }
  double tempTotal = 0;
  for (var temp in tempUpdates) {
    tempTotal +=
        double.parse((temp.newValue ?? '0')) -
        double.parse((temp.oldValue ?? '0'));
  }
  return formatLargeNumberDouble(tempTotal);
}

String returnNet({
  required List<TempInventoryUpdateClass> updates,
}) {
  return formatLargeNumberDouble(
    ((double.tryParse(
              returnTotalStockIn(updates: updates),
            ) ??
            0) -
        (double.tryParse(
              returnTotalStockOut(
                updates: updates,
              ).replaceAll('-', ''),
            ) ??
            0)),
  );
}
