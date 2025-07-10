import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/top_banner_two.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/home/home.dart';
// import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ReceiptPageMobile extends StatefulWidget {
  final bool isMain;
  final int receiptId;
  const ReceiptPageMobile({
    super.key,
    required this.receiptId,
    required this.isMain,
  });

  @override
  State<ReceiptPageMobile> createState() =>
      _ReceiptPageMobileState();
}

class _ReceiptPageMobileState
    extends State<ReceiptPageMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    });
    if (widget.isMain) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnReceiptProvider(
          context,
          listen: false,
        ).loadReceipts(
          returnShopProvider(
            context,
            listen: false,
          ).userShop!.shopId!,
          context,
        );
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider(context).userShop;
    var theme = returnTheme(context);
    TempMainReceipt mainReceipt = returnReceiptProvider(
      context,
    ).receipts.firstWhere(
      (rec) => rec.id! == widget.receiptId,
      orElse:
          () => TempMainReceipt(
            createdAt: DateTime.now(),
            id: 1,
            shopId: shopId(context),
            staffId: AuthService().currentUser!.id,
            staffName: 'Staff Name',
            paymentMethod: 'Cash',
            bank: 0,
            cashAlt: 0,
            isInvoice: false,
          ),
    );
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height:
                    MediaQuery.of(context).size.height - 50,
                child: Stack(
                  alignment: Alignment(0, 1),
                  children: [
                    Align(
                      alignment: Alignment(0, -1),
                      child: TopBannerTwo(
                        isMain: widget.isMain,
                        title:
                            mainReceipt.isInvoice == true
                                ? 'Invoice'
                                : 'Receipt',
                        theme: theme,
                        bottomSpace: 200,
                        topSpace: 10,
                      ),
                    ),
                    Positioned(
                      top: 70,
                      child: SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height -
                            50,
                        child: ReceiptDetailsContainer(
                          isMain: widget.isMain,
                          shop: shop!,
                          mainReceipt: mainReceipt,
                          theme: theme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptDetailsContainer extends StatefulWidget {
  final bool isMain;
  final TempShopClass shop;
  final TempMainReceipt mainReceipt;
  final ThemeProvider theme;
  const ReceiptDetailsContainer({
    super.key,
    required this.theme,
    required this.mainReceipt,
    required this.shop,
    required this.isMain,
  });

  @override
  State<ReceiptDetailsContainer> createState() =>
      _ReceiptDetailsContainerState();
}

class _ReceiptDetailsContainerState
    extends State<ReceiptDetailsContainer> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var records =
        returnReceiptProvider(context).produtRecordSalesMain
            .where(
              (record) =>
                  record.recepitId ==
                  widget.mainReceipt.id!,
            )
            .toList();
    TempCustomersClass? customer;

    try {
      customer = returnCustomers(
        context,
      ).customersMain.firstWhere(
        (c) => c.id == widget.mainReceipt.customerId,
      );
    } catch (e) {
      customer = null; // not found
    }

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height:
                  MediaQuery.of(context).size.height - 180,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      32,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(height: 5),
                            Image.asset(
                              mainLogoIcon,
                              height: 40,
                            ),
                            SizedBox(height: 15),
                            Column(
                              spacing: 8,
                              children: [
                                Text(
                                  textAlign:
                                      TextAlign.center,
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .h4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  widget.shop.name,
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
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
                                  widget.shop.email,
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                  ),
                                  widget.shop.shopAddress ??
                                      'Address Not Set',
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Casheir',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        widget
                                            .mainReceipt
                                            .staffName,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Customer Name',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        customer?.name ??
                                            'Not Saved',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Payment Method',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        widget
                                            .mainReceipt
                                            .paymentMethod,
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Amount(s)',
                                      ),
                                      Column(
                                        children: [
                                          Visibility(
                                            visible:
                                                widget
                                                        .mainReceipt
                                                        .paymentMethod ==
                                                    'Split' ||
                                                widget
                                                        .mainReceipt
                                                        .paymentMethod ==
                                                    'Cash',
                                            child: Row(
                                              spacing: 5,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  'Cash:',
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    widget
                                                        .mainReceipt
                                                        .cashAlt,
                                                    context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                widget
                                                        .mainReceipt
                                                        .paymentMethod ==
                                                    'Split' ||
                                                widget
                                                        .mainReceipt
                                                        .paymentMethod ==
                                                    'Bank',
                                            child: Row(
                                              spacing: 5,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  'Bank:',
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  formatMoneyMid(
                                                    widget
                                                        .mainReceipt
                                                        .bank,
                                                    context,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              spacing: 10,
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Date',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        formatDateTime(
                                          widget
                                              .mainReceipt
                                              .createdAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Time',
                                      ),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        formatTime(
                                          widget
                                              .mainReceipt
                                              .createdAt,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Product Record',
                                ),
                              ],
                            ),
                            ListView.builder(
                              physics:
                                  NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: records.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                var productRecord =
                                    records[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                  child: SizedBox(
                                    child: Row(
                                      spacing: 10,
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Column(
                                            spacing: 3,
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      widget
                                                          .theme
                                                          .mobileTexts
                                                          .b1
                                                          .fontSize,
                                                ),
                                                productRecord
                                                    .productName,
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      widget
                                                          .theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                ),
                                                'Qty: ${productRecord.quantity.toStringAsFixed(0)} Item(s)',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      widget
                                                          .theme
                                                          .mobileTexts
                                                          .b1
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                formatMoneyMid(
                                                  productRecord
                                                      .revenue,
                                                  context,
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    productRecord.discount !=
                                                        null &&
                                                    !productRecord
                                                        .customPriceSet,
                                                child: Text(
                                                  style: TextStyle(
                                                    decoration:
                                                        TextDecoration.lineThrough,
                                                    fontSize:
                                                        widget.theme.mobileTexts.b2.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  formatMoneyMid(
                                                    productRecord
                                                        .originalCost!,
                                                    context,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                ),
                                'Subtotal',
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatMoneyMid(
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).getSubTotalRevenueForReceipt(
                                    context,
                                    records,
                                  ),
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                ),
                                'Discount',
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatMoneyMid(
                                  returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).getTotalMainRevenueReceipt(
                                        records,
                                        context,
                                      ) -
                                      returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).getSubTotalRevenueForReceipt(
                                        context,
                                        records,
                                      ),
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                ),
                                'Total',
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                                formatMoneyMid(
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).getTotalMainRevenueReceipt(
                                    records,
                                    context,
                                  ),
                                  context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 10,
              children: [
                // BottomActionButton(
                //   text:
                //       widget.isMain
                //           ? 'Finish Sale'
                //           : 'Go Back',
                //   color: Colors.grey.shade600,
                //   iconSize: 20,
                //   theme: widget.theme,
                //   icon:
                //       widget.isMain
                //           ? Icons.check
                //           : Icons
                //               .arrow_back_ios_new_rounded,
                //   action: () {
                //     if (widget.isMain) {
                //       Navigator.pushReplacement(
                //         context,
                //         MaterialPageRoute(
                //           builder:
                //               (context) => MakeSalesPage(
                //                 isMain: true,
                //               ),
                //         ),
                //       );
                //       returnNavProvider(
                //         context,
                //         listen: false,
                //       ).navigate(2);
                //     } else {
                //       Navigator.of(context).pop();
                //     }
                //   },
                // ),
                Visibility(
                  visible: authorization(
                    authorized: Authorizations().deleteSale,
                    context: context,
                  ),
                  child: BottomActionButton(
                    text:
                        widget.mainReceipt.isInvoice
                            ? 'Pay Credit'
                            : 'Delete',
                    color:
                        widget.mainReceipt.isInvoice
                            ? widget
                                .theme
                                .lightModeColor
                                .secColor200
                            : widget
                                .theme
                                .lightModeColor
                                .errorColor200,
                    iconSize: 20,
                    theme: widget.theme,
                    icon:
                        widget.mainReceipt.isInvoice
                            ? Icons.check
                            : Icons.delete_outline_rounded,
                    action: () {
                      final receiptP =
                          returnReceiptProvider(
                            context,
                            listen: false,
                          );
                      final shopId =
                          returnShopProvider(
                            context,
                            listen: false,
                          ).userShop!.shopId!;
                      var safeContext = context;
                      if (!widget.mainReceipt.isInvoice) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: widget.theme,
                              message:
                                  'This action cannot be recovered. Are you sure you want to delete this sale receipt?',
                              title: 'Delete Receipt?',
                              action: () async {
                                Navigator.of(
                                  safeContext,
                                ).pop();
                                setState(() {
                                  isLoading = true;
                                });

                                await receiptP
                                    .deleteReceipt(
                                      widget
                                          .mainReceipt
                                          .id!,
                                      context,
                                    );

                                if (safeContext.mounted) {
                                  await receiptP
                                      .loadReceipts(
                                        shopId,
                                        context,
                                      );
                                }

                                setState(() {
                                  isLoading = false;
                                  showSuccess = true;
                                });

                                await Future.delayed(
                                  Duration(
                                    milliseconds: 1500,
                                  ),
                                );

                                if (safeContext.mounted) {
                                  Navigator.pushReplacement(
                                    safeContext,
                                    MaterialPageRoute(
                                      builder:
                                          (safeContext) =>
                                              Home(),
                                    ),
                                  );
                                  returnNavProvider(
                                    safeContext,
                                    listen: false,
                                  ).navigate(2);
                                }
                              },
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: widget.theme,
                              message:
                                  'Are you sure you want to proceed with action? This action cannot be reverted.',
                              title: 'Record as Paid?',
                              action: () async {
                                Navigator.of(
                                  safeContext,
                                ).pop();
                                setState(() {
                                  isLoading = true;
                                });

                                await receiptP.payCredit(
                                  widget.mainReceipt.id!,
                                );

                                if (safeContext.mounted) {
                                  await receiptP
                                      .loadReceipts(
                                        shopId,
                                        context,
                                      );
                                }

                                setState(() {
                                  isLoading = false;
                                  showSuccess = true;
                                });

                                await Future.delayed(
                                  Duration(
                                    milliseconds: 1500,
                                  ),
                                );

                                setState(() {
                                  showSuccess = false;
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                BottomActionButton(
                  action: () {
                    var safeContext = context;
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ConfirmationAlert(
                          theme: widget.theme,
                          message:
                              'You are about to download This Receipt. Are you sure you want to Proceed?',
                          title: 'Download Receipt',
                          action: () async {
                            Navigator.of(context).pop();
                            // generateAndPreviewPdf(
                            //   context: safeContext,
                            //   records: records,
                            //   receipt: widget.mainReceipt,
                            //   shop:
                            //       returnShopProvider(
                            //         safeContext,
                            //         listen: false,
                            //       ).userShop!,
                            // );
                            final pdfBytes = await buildPdf(
                              widget.mainReceipt,
                              records,
                              returnShopProvider(
                                safeContext,
                                listen: false,
                              ).userShop!,
                              context,
                            );
                            downloadPdfWeb(
                              pdfBytes,
                              'receipt.pdf',
                            );
                          },
                        );
                      },
                    );
                  },
                  text: 'Download',
                  color: Colors.grey,
                  icon: Icons.print,
                  iconSize: 20,
                  theme: widget.theme,
                ),
              ],
            ),
          ],
        ),
        Visibility(
          visible: returnReceiptProvider(context).isLoading,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Generating Receipt'),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader('Loading'),
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Completed Successfully'),
          ),
        ),
      ],
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;

  const BottomActionButton({
    super.key,
    required this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 40,
          width: 150,
          padding: EdgeInsets.symmetric(
            vertical: 7,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Center(
            child: Row(
              spacing: 15,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                  text,
                ),
                Stack(
                  children: [
                    Visibility(
                      visible: icon != null,
                      child: Icon(
                        size: iconSize,
                        color: color,
                        icon ??
                            Icons.delete_outline_rounded,
                      ),
                    ),
                    Visibility(
                      visible: svg != null,
                      child: SvgPicture.asset(
                        svg ?? '',
                        height: iconSize,
                      ),
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
