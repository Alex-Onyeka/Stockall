import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductReportMobile extends StatefulWidget {
  const ProductReportMobile({super.key});

  @override
  State<ProductReportMobile> createState() =>
      _ProductReportMobileState();
}

class _ProductReportMobileState
    extends State<ProductReportMobile> {
  int sortIndex = 1;

  late Future<List<TempProductClass>> productsFuture;
  Future<List<TempProductClass>> getProducts() async {
    var tempEx = await returnData(
      context,
      listen: false,
    ).getProducts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempEx;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReportProvider(
        context,
        listen: false,
      ).clearDate(context);
    });
    productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products = returnData(context).productList;

    return Stack(
      children: [
        Scaffold(
          appBar: appBar(
            context: context,
            title: 'Products',
            widget: Padding(
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
                              theme.mobileTexts.b2.fontSize,
                          fontWeight:
                              sortIndex == 1
                                  ? FontWeight.bold
                                  : null,
                        ),
                        'Sort By Name',
                      ),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          sortIndex = 2;
                        });
                      },
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b2.fontSize,
                          fontWeight:
                              sortIndex == 2
                                  ? FontWeight.bold
                                  : null,
                        ),
                        'Sort By Quantity',
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
                              theme.mobileTexts.b2.fontSize,
                          fontWeight:
                              sortIndex == 3
                                  ? FontWeight.bold
                                  : null,
                        ),
                        'Sort By Created Date',
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
                          'Sorted by:',
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
                              ? 'Name'
                              : sortIndex == 2
                              ? 'Quantity'
                              // : sortIndex == 2
                              // ? 'Price'
                              : sortIndex == 3
                              ? 'Date/Time'
                              : 'Name',
                        ),
                      ],
                    ),
                    Icon(Icons.more_vert_rounded),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              SizedBox(height: 20),
              Visibility(
                visible: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 10),
                          Text(
                            returnReportProvider(
                                  context,
                                ).dateSet ??
                                'For Today',
                          ),
                        ],
                      ),
                      Visibility(
                        visible:
                            userGeneral(context).role ==
                            'Owner',
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.end,
                          children: [
                            MaterialButton(
                              onPressed: () {
                                if (returnReportProvider(
                                      context,
                                      listen: false,
                                    ).isDateSet ||
                                    returnReportProvider(
                                      context,
                                      listen: false,
                                    ).setDate) {
                                  returnReportProvider(
                                    context,
                                    listen: false,
                                  ).clearDate(context);
                                } else {
                                  returnReportProvider(
                                    context,
                                    listen: false,
                                  ).openDatePicker();
                                }
                              },
                              child: Row(
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
                                      color:
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                                    returnReportProvider(
                                              context,
                                            ).isDateSet ||
                                            returnReportProvider(
                                              context,
                                            ).setDate
                                        ? 'Clear Date'
                                        : 'Set Date',
                                  ),
                                  Icon(
                                    size: 20,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor100,
                                    returnReportProvider(
                                              context,
                                            ).isDateSet ||
                                            returnReportProvider(
                                              context,
                                            ).setDate
                                        ? Icons.clear
                                        : Icons
                                            .date_range_outlined,
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:
                          products.isEmpty
                              ? MediaQuery.of(
                                context,
                              ).size.width
                              : MediaQuery.of(
                                    context,
                                  ).size.width <
                                  555
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  850
                              : MediaQuery.of(
                                        context,
                                      ).size.width >
                                      555 &&
                                  MediaQuery.of(
                                        context,
                                      ).size.width <
                                      755
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  650
                              : MediaQuery.of(
                                context,
                              ).size.width,
                      child: RefreshIndicator(
                        onRefresh: () {
                          return returnReceiptProvider(
                            context,
                            listen: false,
                          ).loadProductSalesRecord(
                            returnShopProvider(
                              context,
                              listen: false,
                            ).userShop!.shopId!,
                          );
                        },
                        backgroundColor: Colors.white,
                        color:
                            theme.lightModeColor.prColor300,
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
                                if (products.isEmpty) {
                                  return EmptyWidgetDisplayOnly(
                                    title: 'Empty List',
                                    subText:
                                        'No Product has been recorded yet',
                                    theme: theme,
                                    height: 35,
                                    icon: Icons.clear,
                                  );
                                } else {
                                  return RefreshIndicator(
                                    onRefresh: () {
                                      return returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).loadProductSalesRecord(
                                        returnShopProvider(
                                          context,
                                          listen: false,
                                        ).userShop!.shopId!,
                                      );
                                    },
                                    backgroundColor:
                                        Colors.white,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    displacement: 10,
                                    child: SingleChildScrollView(
                                      primary: true,
                                      child: Column(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap:
                                                true,
                                            itemCount:
                                                products
                                                    .length,
                                            physics:
                                                NeverScrollableScrollPhysics(),

                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              products.sort((
                                                a,
                                                b,
                                              ) {
                                                switch (sortIndex) {
                                                  case 1:
                                                    return a
                                                        .name
                                                        .compareTo(
                                                          b.name,
                                                        );
                                                  case 2:
                                                    return b
                                                        .quantity
                                                        .compareTo(
                                                          a.quantity,
                                                        );
                                                  default:
                                                    return b
                                                        .createdAt!
                                                        .compareTo(
                                                          a.createdAt!,
                                                        );
                                                }
                                              });
                                              var product =
                                                  products[index];
                                              var productIndex =
                                                  products.indexOf(
                                                    product,
                                                  ) +
                                                  1;
                                              return TableRowRecordWidget(
                                                theme:
                                                    theme,
                                                productIndex:
                                                    productIndex,
                                                product:
                                                    product,
                                              );
                                            },
                                          ),
                                          SummaryTableHeadingBar(
                                            isHeading:
                                                false,
                                            theme: theme,
                                            product:
                                                products,
                                          ),
                                          SizedBox(
                                            height: 20,
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
                  ),
                ),
              ),
            ],
          ),
        ),
        if (returnReportProvider(context).setDate)
          Material(
            color: const Color.fromARGB(75, 0, 0, 0),
            child: GestureDetector(
              onTap: () {
                returnReportProvider(
                  context,
                  listen: false,
                ).clearDate(context);
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.15,
                      ),
                      Ink(
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors
                                              .grey
                                              .shade400,
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    height: 480,
                                    width: 380,
                                    padding: EdgeInsets.all(
                                      15,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                      color: Colors.white,
                                    ),
                                    child: CalendarWidget(
                                      onDaySelected: (
                                        selectedDay,
                                        focusedDay,
                                      ) {
                                        returnReportProvider(
                                          context,
                                          listen: false,
                                        ).setDay(
                                          context,
                                          selectedDay,
                                        );
                                      },
                                      actionWeek: (
                                        startOfWeek,
                                        endOfWeek,
                                      ) {
                                        returnReportProvider(
                                          context,
                                          listen: false,
                                        ).setWeek(
                                          context,
                                          startOfWeek,
                                          endOfWeek,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.4,
                      ),
                    ],
                  ),
                ),
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
      tempTotal += item.sellingPrice ?? 0;
    }
    return tempTotal;
  }

  double getTotalCostPrice() {
    double tempTotal = 0;
    for (var item in widget.product) {
      tempTotal += item.costPrice;
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in widget.product) {
      tempTotal += item.quantity;
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
                            : formatMoneyMid(getTotal()),
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
                                getTotalCostPrice(),
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
            visible: widget.product.isNotEmpty,
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
                    right: BorderSide(color: Colors.grey),
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
    required this.productIndex,
    required this.product,
  });

  final ThemeProvider theme;
  final int productIndex;
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
                        widget.productIndex.toString(),
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
                          widget.product.sellingPrice ?? 0,
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
                          widget.product.costPrice,
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
              // decoration: BoxDecoration(
              //   border: Border(
              //     right: BorderSide(color: Colors.grey),
              //     left: BorderSide(color: Colors.grey),
              //   ),
              // ),
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
              // decoration: BoxDecoration(
              //   border: Border(
              //     right: BorderSide(color: Colors.grey),
              //     left: BorderSide(color: Colors.grey),
              //   ),
              // ),
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

                        widget.product.category ??
                            'Not Set',
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

                        (widget.product.discount ?? 0)
                            .toString(),
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
              // decoration: BoxDecoration(
              //   border: Border(
              //     right: BorderSide(color: Colors.grey),
              //     left: BorderSide(color: Colors.grey),
              //   ),
              // ),
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

                        widget.product.discount != null
                            ? formatDateWithoutYear(
                              widget.product.startDate ??
                                  DateTime.now(),
                            )
                            : 'Not Set',
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

                        widget.product.discount != null
                            ? formatDateWithoutYear(
                              widget.product.endDate ??
                                  DateTime.now(),
                            )
                            : 'Not Set',
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
