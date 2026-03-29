import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductReportDesktop extends StatefulWidget {
  const ProductReportDesktop({super.key});

  @override
  State<ProductReportDesktop> createState() =>
      ProductReportDesktopState();
}

class ProductReportDesktopState
    extends State<ProductReportDesktop> {
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
  // final searchNode = FocusNode();

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
            ? returnData(context: context)
                .productList()
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
                  returnData(context: context)
                              .productList()
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
                          .productList()
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
            ).productList().sublist(
              start,
              returnData(
                        context: context,
                      ).productList().length >
                      50
                  ? end
                  : returnData(
                    context: context,
                  ).productList().length,
            );

    return Stack(
      children: [
        DesktopCenterContainer(
          width: screenWidth(context) - 50,
          mainWidget: Scaffold(
            appBar: appBar(
              context: context,
              title: sortIndex == 1 ? 'Items' : 'Summary',
              widget: Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
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
                            // PopupMenuItem(
                            //   onTap: () {
                            //     setState(() {
                            //       sortIndex = 1;
                            //     });
                            //   },
                            //   child: Text(
                            //     style: TextStyle(
                            //       fontSize:
                            //           theme
                            //               .mobileTexts
                            //               .b2
                            //               .fontSize,
                            //       fontWeight:
                            //           sortIndex == 1
                            //               ? FontWeight.bold
                            //               : null,
                            //     ),
                            //     'Sort By Name',
                            //   ),
                            // ),
                            // PopupMenuItem(
                            //   onTap: () {
                            //     setState(() {
                            //       sortIndex = 2;
                            //     });
                            //   },
                            //   child: Text(
                            //     style: TextStyle(
                            //       fontSize:
                            //           theme
                            //               .mobileTexts
                            //               .b2
                            //               .fontSize,
                            //       fontWeight:
                            //           sortIndex == 2
                            //               ? FontWeight.bold
                            //               : null,
                            //     ),
                            //     'Sort By Quantity',
                            //   ),
                            // ),
                            // PopupMenuItem(
                            //   onTap: () {
                            //     setState(() {
                            //       sortIndex = 3;
                            //     });
                            //   },
                            //   child: Text(
                            //     style: TextStyle(
                            //       fontSize:
                            //           theme
                            //               .mobileTexts
                            //               .b2
                            //               .fontSize,
                            //       fontWeight:
                            //           sortIndex == 3
                            //               ? FontWeight.bold
                            //               : null,
                            //     ),
                            //     'Sort By Created Date',
                            //   ),
                            // ),
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
                                            .b2
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  sortIndex == 1
                                      ? 'Table'
                                      : sortIndex == 2
                                      ? 'Summary'
                                      : 'Table',
                                ),
                                // Text(
                                //   style: TextStyle(
                                //     fontSize:
                                //         theme
                                //             .mobileTexts
                                //             .b4
                                //             .fontSize,
                                //   ),
                                //   'Sorted by:',
                                // ),
                                // Text(
                                //   style: TextStyle(
                                //     fontSize:
                                //         theme
                                //             .mobileTexts
                                //             .b2
                                //             .fontSize,
                                //     fontWeight: FontWeight.bold,
                                //   ),
                                //   sortIndex == 1
                                //       ? 'Name'
                                //       : sortIndex == 2
                                //       ? 'Quantity'
                                //       // : sortIndex == 2
                                //       // ? 'Price'
                                //       : sortIndex == 3
                                //       ? 'Date/Time'
                                //       : 'Name',
                                // ),
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
                    Visibility(
                      visible: false,
                      // products.isEmpty,
                      child: SizedBox(height: 20),
                    ),
                    Visibility(
                      visible: false,
                      // products.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                var safeContext = context;
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to convert all your product records to pdf, are you sure you want to proceed?',
                                      title:
                                          'Are you sure?',
                                      action: () async {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                        if (kIsWeb) {
                                          if (safeContext
                                              .mounted) {
                                            downloadPdfWebProducts(
                                              products:
                                                  products,
                                              shop:
                                                  returnShopProvider()
                                                      .userShop()!,
                                              context:
                                                  safeContext,
                                              filename:
                                                  'Stockall_Items Record ${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}.pdf',
                                            );
                                          }
                                        }
                                        await generateAndPreviewPdfProducts(
                                          context:
                                              safeContext,
                                          products:
                                              products,
                                          shop:
                                              returnShopProvider()
                                                  .userShop()!,
                                        );

                                        if (safeContext
                                            .mounted) {
                                          returnData()
                                              .toggleIsLoading(
                                                false,
                                              );
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                              child: Container(
                                padding:
                                    EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
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
                                        color:
                                            Colors
                                                .grey
                                                .shade700,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Downalod Pdf',
                                    ),
                                    Icon(
                                      color: Colors.grey,
                                      Icons.print,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
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
                                      products.isEmpty &&
                                              screenWidth(
                                                    context,
                                                  ) <
                                                  tabletScreen
                                          ? screenWidth(
                                            context,
                                          )
                                          : products
                                                  .isEmpty &&
                                              screenWidth(
                                                    context,
                                                  ) >
                                                  tabletScreen
                                          ? screenWidth(
                                                context,
                                              ) -
                                              100
                                          : products
                                                  .isNotEmpty &&
                                              screenWidth(
                                                    context,
                                                  ) <=
                                                  750
                                          ? screenWidth(
                                                context,
                                              ) +
                                              130
                                          : screenWidth(
                                                context,
                                              ) -
                                              200,
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
                                          builder: (
                                            context,
                                          ) {
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
                                                  height:
                                                      35,
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
                                                          // num
                                                          // returnNum(
                                                          //   num?
                                                          //   number,
                                                          // ) {
                                                          //   if (number ==
                                                          //       null) {
                                                          //     return 0;
                                                          //   } else {
                                                          //     return number;
                                                          //   }
                                                          // }

                                                          // products.sort(
                                                          //   (
                                                          //     a,
                                                          //     b,
                                                          //   ) {
                                                          //     switch (sortIndex) {
                                                          //       case 1:
                                                          //         return a.name.compareTo(
                                                          //           b.name,
                                                          //         );
                                                          //       case 2:
                                                          //         return returnNum(
                                                          //           b.quantity,
                                                          //         ).compareTo(
                                                          //           returnNum(
                                                          //             a.quantity,
                                                          //           ),
                                                          //         );
                                                          //       default:
                                                          //         return b.createdAt!.compareTo(
                                                          //           a.createdAt!,
                                                          //         );
                                                          //     }
                                                          //   },
                                                          // );
                                                          var product =
                                                              products[index];
                                                          // var productIndex =
                                                          //     products.indexOf(
                                                          //       product,
                                                          //     ) +
                                                          //     1;
                                                          return TableRowRecordWidget(
                                                            theme:
                                                                theme,
                                                            // productIndex:
                                                            //     productIndex,
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
                            } else {
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
                                              Row(
                                                spacing: 10,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
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
                                          double.infinity,
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
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Opacity(
                      opacity: sortIndex == 2 ? 0 : 1,
                      child: Row(
                        spacing: 5,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            height: 30,
                            width: 200,
                            child: TextField(
                              focusNode:
                                  returnData().searchNode,
                              controller: searchController,
                              onChanged: (value) async {
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
                                    if (allPrs.isNotEmpty) {
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
                              },
                              style: TextStyle(
                                fontSize: 12,
                              ),
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
                                hintText:
                                    'Search Name or Scan',
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
                                            .productList()
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
                                                .b2
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
                                                .b2
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
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                        color: Colors.grey,
                                      ),
                                      "${returnData(context: context).productList().length > 50 ? (returnData(context: context).productList().length / 50).ceil() : 1}",
                                    ),
                                  ],
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (end !=
                                        returnData()
                                            .productList()
                                            .length) {
                                      navigate(
                                        true,
                                        returnData()
                                            .productList()
                                            .length,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    size: 20,
                                    color:
                                        end ==
                                                    returnData(
                                                      context:
                                                          context,
                                                    ).productList().length ||
                                                returnData(
                                                      context:
                                                          context,
                                                    ).productList().length <=
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
  double getTotal() {
    double tempTotal = 0;
    for (var item in widget.product) {
      tempTotal +=
          ((item.sellingPrice ?? 0) * (item.quantity ?? 0));
    }
    return tempTotal;
  }

  double getTotalCostPrice() {
    double tempTotal = 0;
    for (var item in widget.product) {
      tempTotal += item.costPrice * (item.quantity ?? 0);
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in widget.product) {
      tempTotal += item.quantity ?? 0;
    }
    return tempTotal;
  }

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
            flex: 6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  // right: BorderSide(
                  //   color: Colors.grey,
                  // ),
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
            flex: 3,
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
                            : getTotalQuantity().toString(),
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
                              amount: getTotal(),
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
                            ? 'Total-Value'
                            : '',
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
              flex: 5,
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
                                amount: getTotalCostPrice(),
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
              flex: 3,
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
                          widget.isHeading ? 'Barcode' : '',
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
              flex: 4,
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
                              ? 'Qtty Alert'
                              : '',
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
              flex: 3,
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
                          widget.isHeading ? 'Unit' : '',
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
              flex: 3,
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
                              ? 'Size Type'
                              : '',
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
              flex: 4,
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
                              ? 'Category'
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: false,
            // widget.product.isNotEmpty,
            child: Expanded(
              flex: 3,
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
                              ? 'Discount'
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: false,
            // widget.product.isNotEmpty,
            child: Expanded(
              flex: 5,
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
                              ? 'Discount Start'
                              : '',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: false,
            // widget.product.isNotEmpty,
            child: Expanded(
              flex: 5,
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
                              ? 'Discount End'
                              : '',
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
                              ? 'Expiry Date'
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
    // required this.productIndex,
    required this.product,
  });

  final ThemeProvider theme;
  // final int productIndex;
  final TempProductClass product;

  @override
  State<TableRowRecordWidget> createState() =>
      _TableRowRecordWidgetState();
}

class _TableRowRecordWidgetState
    extends State<TableRowRecordWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                                ).productList().indexWhere(
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
            flex: 6,
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
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(5),
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
                        widget.product.quantity.toString(),
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
                              widget.product.sellingPrice ??
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
            flex: 5,
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
                          amount: widget.product.costPrice,
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
            flex: 3,
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

                        widget.product.barcode != null
                            ? 'true'
                            : 'false',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
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

                        (widget.product.lowQtty ?? 0)
                            .toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
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

                        widget.product.unit,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
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

                        widget.product.sizeType ??
                            'Not Set',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
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

                        returnCategoriesProvider(
                                  context: context,
                                )
                                .categories()
                                .where(
                                  (cat) =>
                                      cat.uuid ==
                                      widget
                                          .product
                                          .categoryUuid,
                                )
                                .isNotEmpty
                            ? returnCategoriesProvider(
                                  context: context,
                                )
                                .categories()
                                .where(
                                  (cat) =>
                                      cat.uuid ==
                                      widget
                                          .product
                                          .categoryUuid,
                                )
                                .first
                                .name
                            : 'Not Set',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Expanded(
          //   flex: 3,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border(
          //         right: BorderSide(color: Colors.grey),
          //         left: BorderSide(color: Colors.grey),
          //       ),
          //     ),
          //     padding: EdgeInsets.all(5),
          //     child: Center(
          //       child: Row(
          //         children: [
          //           Flexible(
          //             child: Text(
          //               style: TextStyle(
          //                 fontSize:
          //                     widget
          //                         .theme
          //                         .mobileTexts
          //                         .b3
          //                         .fontSize,
          //                 fontWeight: FontWeight.bold,
          //               ),

          //               (widget.product.discount ?? 0)
          //                   .toString(),
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   flex: 5,
          //   child: Container(
          //     padding: EdgeInsets.all(5),
          //     child: Center(
          //       child: Row(
          //         children: [
          //           Flexible(
          //             child: Text(
          //               style: TextStyle(
          //                 fontSize:
          //                     widget
          //                         .theme
          //                         .mobileTexts
          //                         .b3
          //                         .fontSize,
          //                 fontWeight: FontWeight.bold,
          //               ),

          //               widget.product.discount != null
          //                   ? formatDateWithoutYear(
          //                     widget.product.startDate ??
          //                         DateTime.now(),
          //                   )
          //                   : 'Not Set',
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          // Expanded(
          //   flex: 5,
          //   child: Container(
          //     decoration: BoxDecoration(
          //       border: Border(
          //         right: BorderSide(color: Colors.grey),
          //         left: BorderSide(color: Colors.grey),
          //       ),
          //     ),
          //     padding: EdgeInsets.all(5),
          //     child: Center(
          //       child: Row(
          //         children: [
          //           Flexible(
          //             child: Text(
          //               style: TextStyle(
          //                 fontSize:
          //                     widget
          //                         .theme
          //                         .mobileTexts
          //                         .b3
          //                         .fontSize,
          //                 fontWeight: FontWeight.bold,
          //               ),

          //               widget.product.discount != null
          //                   ? formatDateWithoutYear(
          //                     widget.product.endDate ??
          //                         DateTime.now(),
          //                   )
          //                   : 'Not Set',
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  // right: BorderSide(color: Colors.grey),
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
                          color:
                              getDayDifference(
                                            widget
                                                    .product
                                                    .expiryDate ??
                                                DateTime.now(),
                                          ) <
                                          1 &&
                                      widget
                                              .product
                                              .expiryDate !=
                                          null
                                  ? widget
                                      .theme
                                      .lightModeColor
                                      .errorColor200
                                  : null,
                        ),

                        widget.product.expiryDate != null
                            ? getDayDifference(
                                      widget
                                              .product
                                              .expiryDate ??
                                          DateTime.now(),
                                    ) >=
                                    1
                                ? formatDateTime(
                                  widget
                                          .product
                                          .expiryDate ??
                                      DateTime.now(),
                                )
                                : 'Item Expired'
                            : 'Not Set',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
