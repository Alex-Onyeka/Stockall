import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/product_summary_class.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

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
      context,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReportProvider(
        context,
        listen: false,
      ).clearDate(context);
    });
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
            toolbarHeight: 50,
            scrolledUnderElevation: 0,
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
            title: Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'General Report',
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
                      Visibility(
                        visible: false,
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
                                              .mounted) {}
                                        }

                                        if (safeContext
                                            .mounted) {
                                          returnSalesProvider(
                                            safeContext,
                                            listen: false,
                                          ).toggleIsLoading(
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
                                      'Pdf',
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
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                          context: context,
                        ),
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
                                                  10,
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
                                                        .b3
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

                                                                  '#${returnReceiptProvider(context).returnOwnReceiptsByDayOrWeek(context, receiptSnapshot.data!).length}',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          3,
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
                                                                    );
                                                                  } else if (receiptSnapshot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
                                                                    );
                                                                  } else if (receiptSnapshot.data ==
                                                                      null) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                      ),
                                                                      formatMoneyMid(
                                                                        total,
                                                                        context,
                                                                      ),
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
                                                        .b3
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
                                                                : '#${returnExpensesProvider(context, listen: false).returnExpensesByDayOrWeek(context, expensesSnapshot.data!).length}',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          3,
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      '${currencySymbol(context)} 0',
                                                                    );
                                                                  } else if (expensesSnapshot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      '${currencySymbol(context)} 0',
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            Colors.redAccent,
                                                                      ),
                                                                      formatMoneyMid(
                                                                        getTotal(),
                                                                        context,
                                                                      ),
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
                                            SizedBox(
                                              height: 10,
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
                                                        .b3
                                                        .fontSize,
                                              ),
                                              'Revenue Minus Expenses',
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
                                                            '(Total Revenue - Expenses)',
                                                          ),
                                                          Builder(
                                                            builder: (
                                                              context,
                                                            ) {
                                                              if (receiptSnapshot.connectionState ==
                                                                      ConnectionState.waiting ||
                                                                  expensesSnapshot.connectionState ==
                                                                      ConnectionState.waiting) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
                                                                );
                                                              } else if (receiptSnapshot.hasError ||
                                                                  expensesSnapshot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
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

                                                                double totalExpenses() {
                                                                  double temp =
                                                                      0;
                                                                  for (var item in returnExpensesProvider(
                                                                    context,
                                                                    listen:
                                                                        false,
                                                                  ).returnExpensesByDayOrWeek(
                                                                    context,
                                                                    expensesSnapshot.data!,
                                                                  )) {
                                                                    temp +=
                                                                        item.amount;
                                                                  }
                                                                  return temp;
                                                                }

                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${formatMoneyMid(total, context)} - ${formatMoneyMid(totalExpenses(), context)}',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          3,
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
                                                                          ConnectionState.waiting) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
                                                                    );
                                                                  } else if (receiptSnapshot.hasError ||
                                                                      expensesSnapshot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        color:
                                                                            Colors.grey.shade700,
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
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

                                                                    double totalExpenses() {
                                                                      double temp =
                                                                          0;
                                                                      for (var item in returnExpensesProvider(
                                                                        context,
                                                                        listen:
                                                                            false,
                                                                      ).returnExpensesByDayOrWeek(
                                                                        context,
                                                                        expensesSnapshot.data!,
                                                                      )) {
                                                                        temp +=
                                                                            item.amount;
                                                                      }
                                                                      return temp;
                                                                    }

                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color:
                                                                            (total -
                                                                                        totalExpenses())
                                                                                    .isNegative
                                                                                ? Colors.redAccent
                                                                                : total -
                                                                                        totalExpenses() ==
                                                                                    0
                                                                                ? Colors.grey
                                                                                : const Color.fromARGB(
                                                                                  255,
                                                                                  45,
                                                                                  137,
                                                                                  48,
                                                                                ),
                                                                      ),
                                                                      formatMoneyMid(
                                                                        total -
                                                                            totalExpenses(),
                                                                        context,
                                                                      ),
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
                                            SizedBox(
                                              height: 10,
                                            ),

                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Standard Product Sales Profit',
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                  ),
                                                  '(Products with both Cost Price and Selling Price)',
                                                ),
                                              ],
                                            ),
                                            // SizedBox(
                                            //   height: 20,
                                            // ),
                                            Divider(
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade300,
                                              height: 20,
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
                                                        .b3
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
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
                                                                );
                                                              } else if (productRecordSnapShot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
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
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
                                                                  );
                                                                } else if (productRecordSnapShot.hasError) {
                                                                  return Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
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
                                                                        : productRecordSnapShot.data!
                                                                            .where(
                                                                              (
                                                                                record,
                                                                              ) =>
                                                                                  record.costPrice !=
                                                                                  0,
                                                                            )
                                                                            .toList(),
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
                                                                        : productRecordSnapShot.data!
                                                                            .where(
                                                                              (
                                                                                record,
                                                                              ) =>
                                                                                  record.costPrice !=
                                                                                  0,
                                                                            )
                                                                            .toList(),
                                                                  );
                                                                  return Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      color:
                                                                          Colors.grey.shade700,
                                                                      fontWeight:
                                                                          FontWeight.w700,
                                                                    ),
                                                                    '${formatMoneyMid(total, context)} - ${formatMoneyMid(totalCostPrice, context)}',
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
                                                          3,
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
                                                                    );
                                                                  } else if (productRecordSnapShot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
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
                                                                              theme.mobileTexts.b3.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: const Color.fromARGB(
                                                                            255,
                                                                            45,
                                                                            137,
                                                                            48,
                                                                          ),
                                                                        ),
                                                                        '${currencySymbol(context)} 0.0',
                                                                      );
                                                                    } else if (productRecordSnapShot.hasError) {
                                                                      return Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b3.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: const Color.fromARGB(
                                                                            255,
                                                                            45,
                                                                            137,
                                                                            48,
                                                                          ),
                                                                        ),
                                                                        '${currencySymbol(context)} 0.0',
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
                                                                            : productRecordSnapShot.data!
                                                                                .where(
                                                                                  (
                                                                                    record,
                                                                                  ) =>
                                                                                      record.costPrice !=
                                                                                      0,
                                                                                )
                                                                                .toList(),
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
                                                                            : productRecordSnapShot.data!
                                                                                .where(
                                                                                  (
                                                                                    record,
                                                                                  ) =>
                                                                                      record.costPrice !=
                                                                                      0,
                                                                                )
                                                                                .toList(),
                                                                      );

                                                                      return Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b3.fontSize,
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
                                                                        formatMoneyMid(
                                                                          total -
                                                                              totalCostPrice,
                                                                          context,
                                                                        ),
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
                                                      .shade300,
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
                                                        .b3
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
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
                                                                );
                                                              } else if (productRecordSnapShot.hasError ||
                                                                  expensesSnapshot.hasError ||
                                                                  productRecordSnapShot.hasError) {
                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${currencySymbol(context)} 0.0 - ${currencySymbol(context)} 0.0',
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
                                                                      : productRecordSnapShot.data!
                                                                          .where(
                                                                            (
                                                                              record,
                                                                            ) =>
                                                                                record.costPrice !=
                                                                                0,
                                                                          )
                                                                          .toList(),
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
                                                                      : productRecordSnapShot.data!
                                                                          .where(
                                                                            (
                                                                              record,
                                                                            ) =>
                                                                                record.costPrice !=
                                                                                0,
                                                                          )
                                                                          .toList(),
                                                                );

                                                                return Text(
                                                                  style: TextStyle(
                                                                    fontSize:
                                                                        theme.mobileTexts.b3.fontSize,
                                                                    color:
                                                                        Colors.grey.shade700,
                                                                    fontWeight:
                                                                        FontWeight.w700,
                                                                  ),
                                                                  '${formatMoneyMid(total - totalCostPrice, context)} - (-${formatMoneyMid(getExpensesTotal(), context)})',
                                                                );
                                                              }
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          3,
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
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
                                                                    );
                                                                  } else if (productRecordSnapShot.hasError ||
                                                                      expensesSnapshot.hasError ||
                                                                      productRecordSnapShot.hasError) {
                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: const Color.fromARGB(
                                                                          255,
                                                                          45,
                                                                          137,
                                                                          48,
                                                                        ),
                                                                      ),
                                                                      '${currencySymbol(context)} 0.0',
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
                                                                          : productRecordSnapShot.data!
                                                                              .where(
                                                                                (
                                                                                  record,
                                                                                ) =>
                                                                                    record.costPrice !=
                                                                                    0,
                                                                              )
                                                                              .toList(),
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
                                                                          : productRecordSnapShot.data!
                                                                              .where(
                                                                                (
                                                                                  record,
                                                                                ) =>
                                                                                    record.costPrice !=
                                                                                    0,
                                                                              )
                                                                              .toList(),
                                                                    );

                                                                    return Text(
                                                                      style: TextStyle(
                                                                        fontSize:
                                                                            theme.mobileTexts.b3.fontSize,
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
                                                                      formatMoneyMid(
                                                                        (total -
                                                                                totalCostPrice) -
                                                                            getExpensesTotal(),
                                                                        context,
                                                                      ),
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
                                              leastThree:
                                                  [],
                                              topThree: [],
                                            );
                                          } else if (snapshot
                                                  .hasError ||
                                              productRecordSnapShot
                                                  .hasError) {
                                            return StockSummaryContainer(
                                              leastThree:
                                                  [],
                                              topThree: [],
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
                                                          product.quantity !=
                                                              null &&
                                                          product.quantity! >
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

                                            var productRecord =
                                                returnReceiptProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).returnproductsRecordByDayOrWeek(
                                                  context,
                                                  productRecordSnapShot
                                                      .data!,
                                                );

                                            List<
                                              ProductSummaryClass
                                            >
                                            getProducts() {
                                              List<
                                                ProductSummaryClass
                                              >
                                              tempProducts =
                                                  [];
                                              for (var item
                                                  in productRecord) {
                                                tempProducts.add(
                                                  ProductSummaryClass(
                                                    name:
                                                        item.productName,
                                                    quantity:
                                                        item.quantity,
                                                  ),
                                                );
                                              }
                                              return tempProducts;
                                            }

                                            List<
                                              ProductSummaryClass
                                            >
                                            groupProductSummaries() {
                                              final Map<
                                                String,
                                                double
                                              >
                                              groupedMap =
                                                  {};

                                              for (var product
                                                  in getProducts()) {
                                                groupedMap.update(
                                                  product
                                                      .name,
                                                  (
                                                    existing,
                                                  ) =>
                                                      existing +
                                                      product
                                                          .quantity,
                                                  ifAbsent:
                                                      () =>
                                                          product.quantity,
                                                );
                                              }

                                              return groupedMap
                                                  .entries
                                                  .map(
                                                    (
                                                      entry,
                                                    ) => ProductSummaryClass(
                                                      name:
                                                          entry.key,
                                                      quantity:
                                                          entry.value,
                                                    ),
                                                  )
                                                  .toList();
                                            }

                                            groupProductSummaries().sort(
                                              (a, b) => b
                                                  .quantity
                                                  .compareTo(
                                                    a.quantity,
                                                  ),
                                            );

                                            List<
                                              ProductSummaryClass
                                            >
                                            getTopThreeProducts(
                                              List<
                                                ProductSummaryClass
                                              >
                                              groupedList,
                                            ) {
                                              if (groupedList
                                                  .isEmpty) {
                                                return [];
                                              }

                                              final sorted = List<
                                                ProductSummaryClass
                                              >.from(
                                                groupedList,
                                              )..sort(
                                                (a, b) => b
                                                    .quantity
                                                    .compareTo(
                                                      a.quantity,
                                                    ),
                                              );

                                              return sorted
                                                  .take(3)
                                                  .toList();
                                            }

                                            List<
                                              ProductSummaryClass
                                            >
                                            getBottomThreeProducts(
                                              List<
                                                ProductSummaryClass
                                              >
                                              groupedList,
                                            ) {
                                              if (groupedList
                                                  .isEmpty) {
                                                return [];
                                              }

                                              final sorted = List<
                                                ProductSummaryClass
                                              >.from(
                                                groupedList,
                                              )..sort(
                                                (a, b) => a
                                                    .quantity
                                                    .compareTo(
                                                      b.quantity,
                                                    ),
                                              );

                                              return sorted
                                                  .take(3)
                                                  .toList();
                                            }

                                            return Column(
                                              children: [
                                                StockSummaryContainer(
                                                  leastThree:
                                                      getBottomThreeProducts(
                                                        groupProductSummaries(),
                                                      ),
                                                  topThree:
                                                      getTopThreeProducts(
                                                        groupProductSummaries(),
                                                      ),
                                                  theme:
                                                      theme,
                                                  inStock:
                                                      inStock,
                                                  outOfStock:
                                                      outOfStock,
                                                  total:
                                                      products
                                                          .length,
                                                ),
                                              ],
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
  final List<ProductSummaryClass> topThree;
  final List<ProductSummaryClass> leastThree;

  const StockSummaryContainer({
    super.key,
    required this.theme,
    this.inStock,
    this.outOfStock,
    this.total,
    required this.topThree,
    required this.leastThree,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10,
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
              fontSize: theme.mobileTexts.b3.fontSize,
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
                          "#${total != null ? total!.toString() : '0'}",
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
                              "#${inStock != null ? inStock!.toString() : '0'}",
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
                              "#${outOfStock != null ? outOfStock?.toString() : '0'}",
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(height: 20),
              Column(
                spacing: 10,
                children: [
                  BestAndLeastSellingRow(
                    index: 0,
                    leastThree:
                        leastThree.length < 3
                            ? []
                            : leastThree,
                    topThree: topThree,
                    theme: theme,
                  ),
                  BestAndLeastSellingRow(
                    index: 1,
                    leastThree:
                        leastThree.length < 3
                            ? []
                            : leastThree,
                    topThree:
                        topThree.length < 2 ? [] : topThree,
                    theme: theme,
                  ),
                  BestAndLeastSellingRow(
                    index: 2,
                    leastThree:
                        leastThree.length < 3
                            ? []
                            : leastThree,
                    topThree:
                        topThree.length < 3 ? [] : topThree,
                    theme: theme,
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

class BestAndLeastSellingRow extends StatelessWidget {
  const BestAndLeastSellingRow({
    super.key,
    required this.theme,
    required this.topThree,
    required this.leastThree,
    required this.index,
  });

  final ThemeProvider theme;
  final List<ProductSummaryClass> topThree;
  final List<ProductSummaryClass> leastThree;
  final int index;

  // int number() {
  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                'Top Three Selling Items:',
              ),
              SizedBox(height: 5),
              Builder(
                builder: (context) {
                  return Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    spacing: 0,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                        topThree.isEmpty
                            ? 'Not Set'
                            : topThree[index].name,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                color: Colors.grey.shade700,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Sold ',
                            ),
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              fontWeight: FontWeight.w700,
                            ),
                            '(${topThree.isEmpty ? 0 : topThree[index].quantity.toStringAsFixed(0)})',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.normal,
                            ),
                            ' Items',
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                    'Least Selling Items',
                  ),
                  SizedBox(height: 5),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    spacing: 0,
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w700,
                        ),
                        leastThree.isEmpty
                            ? 'Not Set'
                            : leastThree[index].name,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                color: Colors.grey.shade700,
                                fontWeight:
                                    FontWeight.normal,
                              ),
                              'Sold ',
                            ),
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              fontWeight: FontWeight.w700,
                            ),
                            '(${leastThree.isEmpty ? 0 : leastThree[index].quantity.toStringAsFixed(0)})',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.normal,
                            ),
                            ' Items',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
