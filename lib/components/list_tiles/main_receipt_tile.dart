import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainReceiptTile extends StatelessWidget {
  final TempMainReceipt mainReceipt;
  final Function()? action;
  const MainReceiptTile({
    super.key,
    required this.mainReceipt,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) < mobileScreen) {
      return MainReceiptTileMobile(
        mainReceipt: mainReceipt,
        action: action,
      );
    } else {
      return MainReceiptTileDesktop(
        mainReceipt: mainReceipt,
        action: action,
      );
    }
  }
}

class MainReceiptTileMobile extends StatefulWidget {
  final TempMainReceipt mainReceipt;
  final Function()? action;
  const MainReceiptTileMobile({
    super.key,
    required this.mainReceipt,
    required this.action,
  });

  @override
  State<MainReceiptTileMobile> createState() =>
      _MainReceiptTileMobileState();
}

class _MainReceiptTileMobileState
    extends State<MainReceiptTileMobile> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  late Future<TempCustomersClass?> customerFuture;

  Future<TempCustomersClass?> getCustomer() async {
    if (widget.mainReceipt.customerId != null) {
      var tempCustomer = await returnCustomers(
        context,
        listen: false,
      ).fetchCustomers(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
      return tempCustomer.firstWhere(
        (customer) =>
            customer.id != null &&
            customer.id == widget.mainReceipt.customerId!,
      );
    } else {
      return null;
    }
  }

  List<TempProductSaleRecord> getProductRecord() {
    var tempRecords =
        returnReceiptProvider(
          context,
          listen: false,
        ).produtRecordSalesMain;

    return tempRecords
        .where(
          (record) =>
              record.recepitId == widget.mainReceipt.id!,
        )
        .toList();
  }

  late Future<List<TempProductSaleRecord>> productFuture;
  @override
  void initState() {
    super.initState();
    // productFuture = getProductRecord();
    customerFuture = getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    double getTotal() {
      double totalAmount = 0;
      for (var element
          in getProductRecord()
              .where(
                (test) =>
                    test.recepitId == widget.mainReceipt.id,
              )
              .toList()) {
        totalAmount += element.revenue;
      }
      return totalAmount;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(receiptIconSvg),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.mainReceipt.createdAt,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),
                      '${widget.mainReceipt.paymentMethod} Payment',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      '${getProductRecord().length} Item(s) Sold',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Item Name',
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
                              cutLongText(
                                getProductRecord()
                                        .isNotEmpty
                                    ? getProductRecord()
                                        .first
                                        .productName
                                    : '',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Total',
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
                              formatMoneyMid(
                                amount: getTotal(),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    FutureBuilder<TempCustomersClass?>(
                      future: customerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            'Customer',
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),
                            'Customer: Not Set',
                          );
                        } else {
                          TempCustomersClass? customer =
                              snapshot.data;
                          return Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                            ),

                            "Customer: ${cutLongText2(customer != null ? customer.name.split(' ').first : 'Not Set')}",
                          );
                        }
                      },
                    ),
                    SizedBox(width: 10),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Cashier: ${cutLongText2(widget.mainReceipt.staffName.split(' ')[0])} ${widget.mainReceipt.staffName.split(' ').length > 1 ? widget.mainReceipt.staffName.split(' ')[1].split('')[0] : ''}.',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainReceiptTileDesktop extends StatefulWidget {
  final TempMainReceipt mainReceipt;
  final Function()? action;
  const MainReceiptTileDesktop({
    super.key,
    required this.mainReceipt,
    required this.action,
  });

  @override
  State<MainReceiptTileDesktop> createState() =>
      _MainReceiptTileDesktopState();
}

class _MainReceiptTileDesktopState
    extends State<MainReceiptTileDesktop> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  late Future<TempCustomersClass?> customerFuture;

  Future<TempCustomersClass?> getCustomer() async {
    if (widget.mainReceipt.customerId != null) {
      var tempCustomer = await returnCustomers(
        context,
        listen: false,
      ).fetchCustomers(
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!,
      );
      return tempCustomer.firstWhere(
        (customer) =>
            customer.id != null &&
            customer.id == widget.mainReceipt.customerId!,
      );
    } else {
      return null;
    }
  }

  List<TempProductSaleRecord> getProductRecord() {
    var tempRecords =
        returnReceiptProvider(
          context,
          listen: false,
        ).produtRecordSalesMain;

    return tempRecords
        .where(
          (record) =>
              record.recepitId == widget.mainReceipt.id!,
        )
        .toList();
  }

  late Future<List<TempProductSaleRecord>> productFuture;
  @override
  void initState() {
    super.initState();
    // productFuture = getProductRecord();
    customerFuture = getCustomer();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    double getTotal() {
      double totalAmount = 0;
      for (var element
          in getProductRecord()
              .where(
                (test) =>
                    test.recepitId == widget.mainReceipt.id,
              )
              .toList()) {
        totalAmount += element.revenue;
      }
      return totalAmount;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          height: 18,
                          receiptIconSvg,
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
                          formatDateWithDay(
                            widget.mainReceipt.createdAt,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 15,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      ReceicptTileSectionDesktop(
                        flex: 5,
                        subTitle: 'First Item Name',
                        title: cutLongText(
                          getProductRecord().isNotEmpty
                              ? getProductRecord()
                                  .first
                                  .productName
                              : '',
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 4,
                        subTitle: 'Total',
                        title: formatMoneyMid(
                          amount: getTotal(),
                          context: context,
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Quantity',
                        title:
                            '${getProductRecord().length} Item(s)',
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Payment Type',
                        title:
                            widget
                                .mainReceipt
                                .paymentMethod,
                        theme: theme,
                      ),
                      FutureBuilder<TempCustomersClass?>(
                        future: customerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return ReceicptTileSectionDesktop(
                              flex: 3,
                              subTitle: 'Customer',
                              title: 'Loading',
                              theme: theme,
                            );
                          } else if (snapshot.hasError) {
                            return ReceicptTileSectionDesktop(
                              flex: 3,
                              subTitle: 'Customer',
                              title: 'Not Set',
                              theme: theme,
                            );
                          } else {
                            TempCustomersClass? customer =
                                snapshot.data;
                            return ReceicptTileSectionDesktop(
                              flex: 3,
                              subTitle: 'Customer',
                              title: cutLongText(
                                customer?.name ?? 'Not Set',
                              ),
                              theme: theme,
                            );
                          }
                        },
                      ),

                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Cashier',
                        title:
                            '${cutLongText2(widget.mainReceipt.staffName.split(' ')[0])} ${widget.mainReceipt.staffName.split(' ').length > 1 ? widget.mainReceipt.staffName.split(' ')[1].split('')[0] : ''}.',
                        theme: theme,
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

class ReceicptTileSectionDesktop extends StatelessWidget {
  final String title;
  final String subTitle;
  final int flex;
  const ReceicptTileSectionDesktop({
    super.key,
    required this.theme,
    required this.title,
    required this.subTitle,
    required this.flex,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        spacing: 3,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
            subTitle,
          ),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
        ],
      ),
    );
  }
}
