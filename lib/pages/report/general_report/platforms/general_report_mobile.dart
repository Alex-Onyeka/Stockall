import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_expenses_class.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/providers/theme_provider.dart';

class GeneralReportMobile extends StatefulWidget {
  const GeneralReportMobile({super.key});

  @override
  State<GeneralReportMobile> createState() =>
      _GeneralReportMobileState();
}

class _GeneralReportMobileState
    extends State<GeneralReportMobile> {
  late Future<List<TempMainReceipt>> receiptFuture;
  Future<List<TempMainReceipt>> getReceipts() async {
    var tempRece = await returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );
    return tempRece;
  }

  late Future<List<TempExpensesClass>> expensesFuture;
  Future<List<TempExpensesClass>> getExpenses() async {
    var tempEx = await returnExpensesProvider(
      context,
      listen: false,
    ).getExpenses(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempEx;
  }

  late Future<List<TempProductSaleRecord>>
  productRecordFuture;
  Future<List<TempProductSaleRecord>>
  getProductRecord() async {
    var tempEx = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempEx;
  }

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
    receiptFuture = getReceipts();
    expensesFuture = getExpenses();
    productRecordFuture = getProductRecord();
    productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Padding(
                padding: const EdgeInsets.only(
                  left: 20.0,
                  right: 10,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                ),
              ),
            ),
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'General Report',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  'Summary of General Report',
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        returnReportProvider(
                              context,
                            ).dateSet ??
                            'For Today',
                      ),
                      // Visibility(
                      //   visible:
                      //       returnLocalDatabase(
                      //         context,
                      //       ).currentEmployee!.role !=
                      //       'Owner',
                      //   child: SizedBox(height: 30),
                      // ),
                      Visibility(
                        visible:
                            returnLocalDatabase(
                              context,
                            ).currentEmployee!.role ==
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
                FutureBuilder(
                  future: receiptFuture,
                  builder: (context, snapshot) {
                    var receiptSnapshot = snapshot;
                    return FutureBuilder(
                      future: productRecordFuture,
                      builder: (context, snapshot) {
                        var productRecordSnapShot =
                            snapshot;
                        return FutureBuilder(
                          future: expensesFuture,
                          builder: (context, snapshot) {
                            var expensesSnapshot = snapshot;
                            return Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 5.0,
                                      ),
                                  child: Column(
                                    children: [
                                      SizedBox(height: 5),
                                      Container(
                                        padding:
                                            EdgeInsets.symmetric(
                                              horizontal:
                                                  20,
                                              vertical: 20,
                                            ),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(
                                                5,
                                              ),
                                          color:
                                              Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  const Color.fromARGB(
                                                    20,
                                                    0,
                                                    0,
                                                    0,
                                                  ),
                                              blurRadius:
                                                  10,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                              ),
                                              'Sales',
                                            ),
                                            Divider(
                                              height: 10,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  spacing:
                                                      10,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            'No. of Sales:',
                                                          ),
                                                          Builder(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              if (receiptSnapshot.connectionState ==
                                                                  ConnectionState.waiting) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b1.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),

                                                                  '0',
                                                                );
                                                              } else if (receiptSnapshot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b1.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),

                                                                  '0',
                                                                );
                                                              } else if (receiptSnapshot.data ==
                                                                  null) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b1.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),

                                                                  '0',
                                                                );
                                                              } else {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b1.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),

                                                                  '${returnReceiptProvider(context).returnOwnReceiptsByDayOrWeek(context, receiptSnapshot.data!).length}',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          4,
                                                      child: Column(
                                                        spacing:
                                                            10,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                ),
                                                                'Total Revenue:',
                                                              ),
                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (receiptSnapshot.connectionState ==
                                                                      ConnectionState.waiting) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else if (receiptSnapshot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else if (receiptSnapshot.data ==
                                                                      null) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else {
                                                                    var total = returnReceiptProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).getTotalRevenueForSelectedDay(
                                                                      context,
                                                                      receiptSnapshot.data!,
                                                                      productRecordSnapShot.connectionState ==
                                                                              ConnectionState.waiting
                                                                          ? []
                                                                          : productRecordSnapShot.data!,
                                                                    );
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '$nairaSymbol ${formatLargeNumberDoubleWidgetDecimal(total)}',
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade500,
                                              height: 30,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                              ),
                                              'Expenses',
                                            ),
                                            Divider(
                                              height: 10,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  spacing:
                                                      10,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            'No. of Expenses:',
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b1.fontSize,
                                                              color:
                                                                  Colors.grey.shade700,
                                                              fontWeight:
                                                                  FontWeight.w700,
                                                            ),
                                                            expensesSnapshot.connectionState ==
                                                                    ConnectionState.waiting
                                                                ? '0'
                                                                : expensesSnapshot.hasError
                                                                ? '0'
                                                                : '${returnExpensesProvider(context, listen: false).returnExpensesByDayOrWeek(context, expensesSnapshot.data!).length}',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          4,
                                                      child: Column(
                                                        spacing:
                                                            10,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                ),
                                                                'Total Amount:',
                                                              ),
                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (expensesSnapshot.connectionState ==
                                                                      ConnectionState.waiting) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      '$nairaSymbol 0',
                                                                    );
                                                                  } else if (expensesSnapshot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      '$nairaSymbol 0',
                                                                    );
                                                                  } else {
                                                                    var expenses = returnExpensesProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).returnExpensesByDayOrWeek(
                                                                      context,
                                                                      expensesSnapshot.data!,
                                                                    );
                                                                    double getTotal() {
                                                                      double temp =
                                                                          0;
                                                                      for (var item in expenses) {
                                                                        temp +=
                                                                            item.amount;
                                                                      }
                                                                      return temp;
                                                                    }

                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      '$nairaSymbol ${formatLargeNumberDoubleWidgetDecimal(getTotal())}',
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade500,
                                              height: 30,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                              ),
                                              'Gross Profit/Loss',
                                            ),
                                            Divider(
                                              height: 10,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  spacing:
                                                      10,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            '(Total Revenue - Total Cost Price)',
                                                          ),
                                                          Builder(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              if (receiptSnapshot.connectionState ==
                                                                  ConnectionState.waiting) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b2.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                );
                                                              } else if (productRecordSnapShot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b2.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                );
                                                              } else {
                                                                var receipts = returnReceiptProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).returnOwnReceiptsByDayOrWeek(
                                                                  context,
                                                                  receiptSnapshot.data!,
                                                                );
                                                                if (productRecordSnapShot.connectionState ==
                                                                    ConnectionState.waiting) {
                                                                  return Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b2.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                  );
                                                                } else if (productRecordSnapShot.hasError) {
                                                                  return Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b2.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                  );
                                                                } else {
                                                                  var total = returnReceiptProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).getTotalRevenueForSelectedDay(
                                                                    context,
                                                                    receipts,
                                                                    productRecordSnapShot.connectionState ==
                                                                            ConnectionState.waiting
                                                                        ? []
                                                                        : productRecordSnapShot.data!,
                                                                  );

                                                                  var totalCostPrice = returnReceiptProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).getTotalCostPriceForSelectedDay(
                                                                    context,
                                                                    receipts,
                                                                    productRecordSnapShot.connectionState ==
                                                                            ConnectionState.waiting
                                                                        ? []
                                                                        : productRecordSnapShot.data!,
                                                                  );
                                                                  return Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b2.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(total)} - $nairaSymbol${formatLargeNumberDoubleWidgetDecimal(totalCostPrice)}',
                                                                  );
                                                                }
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          4,
                                                      child: Column(
                                                        spacing:
                                                            10,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                ),
                                                                'Total Amount:',
                                                              ),

                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (receiptSnapshot.connectionState ==
                                                                      ConnectionState.waiting) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else if (productRecordSnapShot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else {
                                                                    var receipts = returnReceiptProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).returnOwnReceiptsByDayOrWeek(
                                                                      context,
                                                                      receiptSnapshot.data!,
                                                                    );
                                                                    if (productRecordSnapShot.connectionState ==
                                                                        ConnectionState.waiting) {
                                                                      return Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b1.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: const Color.fromARGB(
                                                                            255,
                                                                            45,
                                                                            137,
                                                                            48,
                                                                          ),
                                                                        ),
                                                                        '$nairaSymbol 0.0',
                                                                      );
                                                                    } else if (productRecordSnapShot.hasError) {
                                                                      return Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b1.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: const Color.fromARGB(
                                                                            255,
                                                                            45,
                                                                            137,
                                                                            48,
                                                                          ),
                                                                        ),
                                                                        '$nairaSymbol 0.0',
                                                                      );
                                                                    } else {
                                                                      var total = returnReceiptProvider(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ).getTotalRevenueForSelectedDay(
                                                                        context,
                                                                        receipts,
                                                                        productRecordSnapShot.connectionState ==
                                                                                ConnectionState.waiting
                                                                            ? []
                                                                            : productRecordSnapShot.data!,
                                                                      );

                                                                      var totalCostPrice = returnReceiptProvider(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ).getTotalCostPriceForSelectedDay(
                                                                        context,
                                                                        receipts,
                                                                        productRecordSnapShot.connectionState ==
                                                                                ConnectionState.waiting
                                                                            ? []
                                                                            : productRecordSnapShot.data!,
                                                                      );

                                                                      return Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b1.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              (total -
                                                                                          totalCostPrice)
                                                                                      .isNegative
                                                                                  ? Colors.redAccent
                                                                                  : total -
                                                                                          totalCostPrice ==
                                                                                      0
                                                                                  ? Colors.grey
                                                                                  : const Color.fromARGB(
                                                                                    255,
                                                                                    45,
                                                                                    137,
                                                                                    48,
                                                                                  ),
                                                                        ),
                                                                        '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(total - totalCostPrice)}',
                                                                      );
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Divider(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade500,
                                              height: 30,
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                              ),
                                              'Net Profit/Loss',
                                            ),
                                            Divider(
                                              height: 10,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                            ),
                                            Column(
                                              children: [
                                                Row(
                                                  spacing:
                                                      10,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            '(Gross Profit - Expenses)',
                                                          ),
                                                          Builder(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              if (receiptSnapshot.connectionState ==
                                                                      ConnectionState.waiting ||
                                                                  expensesSnapshot.connectionState ==
                                                                      ConnectionState.waiting ||
                                                                  productRecordSnapShot.connectionState ==
                                                                      ConnectionState.waiting) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b2.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                );
                                                              } else if (productRecordSnapShot.hasError ||
                                                                  expensesSnapshot.hasError ||
                                                                  productRecordSnapShot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b2.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '$nairaSymbol 0.0 - $nairaSymbol 0.0',
                                                                );
                                                              } else {
                                                                var receipts = returnReceiptProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).returnOwnReceiptsByDayOrWeek(
                                                                  context,
                                                                  receiptSnapshot.data!,
                                                                );

                                                                var expenses = returnExpensesProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).returnExpensesByDayOrWeek(
                                                                  context,
                                                                  expensesSnapshot.data!,
                                                                );

                                                                double getExpensesTotal() {
                                                                  double tempTotal =
                                                                      0;
                                                                  for (var item in expenses) {
                                                                    tempTotal +=
                                                                        item.amount;
                                                                  }

                                                                  return tempTotal;
                                                                }

                                                                var total = returnReceiptProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).getTotalRevenueForSelectedDay(
                                                                  context,
                                                                  receipts,
                                                                  productRecordSnapShot.connectionState ==
                                                                          ConnectionState.waiting
                                                                      ? []
                                                                      : productRecordSnapShot.data!,
                                                                );

                                                                var totalCostPrice = returnReceiptProvider(
                                                                  context,
                                                                  listen:
                                                                      false,
                                                                ).getTotalCostPriceForSelectedDay(
                                                                  context,
                                                                  receipts,
                                                                  productRecordSnapShot.connectionState ==
                                                                          ConnectionState.waiting
                                                                      ? []
                                                                      : productRecordSnapShot.data!,
                                                                );

                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b2.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(total - totalCostPrice)} - (-$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(getExpensesTotal())})',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          4,
                                                      child: Column(
                                                        spacing:
                                                            10,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                ),
                                                                'Total Amount:',
                                                              ),
                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (receiptSnapshot.connectionState ==
                                                                          ConnectionState.waiting ||
                                                                      expensesSnapshot.connectionState ==
                                                                          ConnectionState.waiting ||
                                                                      productRecordSnapShot.connectionState ==
                                                                          ConnectionState.waiting) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else if (productRecordSnapShot.hasError ||
                                                                      expensesSnapshot.hasError ||
                                                                      productRecordSnapShot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '$nairaSymbol 0.0',
                                                                    );
                                                                  } else {
                                                                    var receipts = returnReceiptProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).returnOwnReceiptsByDayOrWeek(
                                                                      context,
                                                                      receiptSnapshot.data!,
                                                                    );

                                                                    var expenses = returnExpensesProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).returnExpensesByDayOrWeek(
                                                                      context,
                                                                      expensesSnapshot.data!,
                                                                    );

                                                                    double getExpensesTotal() {
                                                                      double tempTotal =
                                                                          0;
                                                                      for (var item in expenses) {
                                                                        tempTotal +=
                                                                            item.amount;
                                                                      }

                                                                      return tempTotal;
                                                                    }

                                                                    var total = returnReceiptProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).getTotalRevenueForSelectedDay(
                                                                      context,
                                                                      receipts,
                                                                      productRecordSnapShot.connectionState ==
                                                                              ConnectionState.waiting
                                                                          ? []
                                                                          : productRecordSnapShot.data!,
                                                                    );

                                                                    var totalCostPrice = returnReceiptProvider(
                                                                      context,
                                                                      listen:
                                                                          false,
                                                                    ).getTotalCostPriceForSelectedDay(
                                                                      context,
                                                                      receipts,
                                                                      productRecordSnapShot.connectionState ==
                                                                              ConnectionState.waiting
                                                                          ? []
                                                                          : productRecordSnapShot.data!,
                                                                    );

                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b1.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            ((total -
                                                                                            totalCostPrice) -
                                                                                        getExpensesTotal())
                                                                                    .isNegative
                                                                                ? Colors.redAccent
                                                                                : (total -
                                                                                            totalCostPrice) -
                                                                                        getExpensesTotal() ==
                                                                                    0
                                                                                ? Colors.grey
                                                                                : const Color.fromARGB(
                                                                                  255,
                                                                                  45,
                                                                                  137,
                                                                                  48,
                                                                                ),
                                                                      ),
                                                                      '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal((total - totalCostPrice) - getExpensesTotal())}',
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      FutureBuilder(
                                        future:
                                            productsFuture,
                                        builder: (
                                          context,
                                          snapshot,
                                        ) {
                                          if (snapshot.connectionState ==
                                                  ConnectionState
                                                      .waiting ||
                                              productRecordSnapShot
                                                      .connectionState ==
                                                  ConnectionState
                                                      .waiting) {
                                            return StockSummaryContainer(
                                              theme: theme,
                                            );
                                          } else if (snapshot
                                                  .hasError ||
                                              productRecordSnapShot
                                                  .hasError) {
                                            return StockSummaryContainer(
                                              theme: theme,
                                            );
                                          } else {
                                            var products =
                                                snapshot
                                                    .data!;
                                            var inStock =
                                                products
                                                    .where(
                                                      (
                                                        product,
                                                      ) =>
                                                          product.quantity >
                                                          0,
                                                    )
                                                    .length;
                                            var outOfStock =
                                                products
                                                    .where(
                                                      (
                                                        product,
                                                      ) =>
                                                          product.quantity ==
                                                          0,
                                                    )
                                                    .length;
                                            // var productRecord =
                                            //     productRecordSnapShot
                                            //         .data!;
                                            return StockSummaryContainer(
                                              theme: theme,
                                              inStock:
                                                  inStock,
                                              outOfStock:
                                                  outOfStock,
                                              total:
                                                  products
                                                      .length,
                                            );
                                          }
                                        },
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
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
                            0.2,
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
                                      // border: Border.all(
                                      //   color:
                                      //       Colors
                                      //           .grey,
                                      // ),
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

class StockSummaryContainer extends StatelessWidget {
  final ThemeProvider theme;
  final int? inStock;
  final int? outOfStock;
  final int? total;

  const StockSummaryContainer({
    super.key,
    required this.theme,
    this.inStock,
    this.outOfStock,
    this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.lightModeColor.secColor200,
              fontSize: theme.mobileTexts.b2.fontSize,
            ),
            'Stock Summary',
          ),
          Divider(height: 10, color: Colors.grey.shade300),
          Column(
            children: [
              Row(
                spacing: 10,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                            fontWeight: FontWeight.normal,
                          ),
                          'Total Stock:',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                          total?.toString() ?? '0',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Column(
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
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Total in Stock',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              inStock?.toString() ?? '0',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Column(
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
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Out of Stock',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              outOfStock?.toString() ?? '0',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 20),
              Row(
                spacing: 10,
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
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
                            fontWeight: FontWeight.normal,
                          ),
                          'Best Selling Product:',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w700,
                          ),
                          '0',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Column(
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
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Least Selling Product',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                              '0',
                            ),
                          ],
                        ),
                      ],
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

class ReportContainer extends StatelessWidget {
  final ThemeProvider theme;
  final Color? color;
  final String mainTitle;
  final String subTitle1;
  final String subTitle2;
  final double value1;
  final double value2;
  final String? nameOfProduct;

  const ReportContainer({
    super.key,
    required this.theme,
    required this.mainTitle,
    required this.subTitle1,
    required this.subTitle2,
    required this.value1,
    required this.value2,
    this.color,
    this.nameOfProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.lightModeColor.secColor200,
            ),
            mainTitle,
          ),
          Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle1:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      formatLargeNumberDouble(value1),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle2:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color:
                            color ?? Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      nameOfProduct ??
                          '$nairaSymbol ${formatLargeNumberDouble(value2)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportProfitContainer extends StatelessWidget {
  final ThemeProvider theme;
  final Color? color;
  final String mainTitle;
  final String subTitle1;
  final String subTitle2;
  final double costValue1;
  final double costValue2;
  final double value2;

  const ReportProfitContainer({
    super.key,
    required this.theme,
    required this.mainTitle,
    required this.subTitle1,
    required this.subTitle2,
    required this.costValue1,
    required this.costValue2,
    required this.value2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(20, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.lightModeColor.secColor200,
            ),
            mainTitle,
          ),
          Divider(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle1:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b1.fontSize,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      '$nairaSymbol${formatLargeNumberDouble(costValue1)} - $nairaSymbol${formatLargeNumberDouble(costValue2)}',
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      '$subTitle2:',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        color:
                            color ?? Colors.grey.shade600,
                        fontWeight: FontWeight.w700,
                      ),
                      '$nairaSymbol ${formatLargeNumberDoubleWidgetDecimal(value2)}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
