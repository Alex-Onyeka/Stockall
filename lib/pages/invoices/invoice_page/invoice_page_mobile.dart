import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/invoice_print_and_download.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/services/printing/printer_service_mobile.dart';

class InvoicePageMobile extends StatefulWidget {
  final String invoiceUuid;
  const InvoicePageMobile({
    super.key,
    required this.invoiceUuid,
  });

  @override
  State<InvoicePageMobile> createState() =>
      _InvoicePageMobileState();
}

class _InvoicePageMobileState
    extends State<InvoicePageMobile> {
  int? paymentSelected;

  void selectPayment(int index) {
    paymentController.clear();
    setState(() {
      if (paymentSelected == index) {
        paymentSelected = null;
      } else {
        paymentSelected = index;
        if (index == 2) {
          TempInvoice invoice = returnInvoicesProvider()
              .invoicesMain
              .firstWhere(
                (inv) => inv.uuid == widget.invoiceUuid,
              );
          paymentController.text = returnInvoicesProvider()
              .getBalance(invoice: invoice)
              .toStringAsFixed(0);
        }
        paymentNode.requestFocus();
      }
    });
  }

  final paymentController = TextEditingController();

  FocusNode paymentNode = FocusNode();

  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;
  bool isPrintingInvoice = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempProductSaleRecord> saleRecords =
        returnReceiptProvider(context, listen: false)
            .produtRecordSalesMain
            .where(
              (record) =>
                  record.invoiceUuid == widget.invoiceUuid,
            )
            .toList();
    var invs =
        returnInvoicesProvider().invoicesMain
            .where((inv) => inv.uuid == widget.invoiceUuid)
            .toList();

    TempInvoice? invoice =
        invs.isNotEmpty ? invs.first : null;
    var custs =
        returnCustomers(context, listen: false)
            .customersMain()
            .where(
              (cus) => cus.uuid == invoice?.customerUuid,
            )
            .toList();
    TempCustomersClass? customer =
        custs.isNotEmpty ? custs.first : null;
    return Builder(
      builder: (context) {
        if (invoice == null) {
          return SafeArea(
            child: Scaffold(
              body: Column(
                spacing: 15,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      // spacing: 10,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Material(
                              type:
                                  MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  if (Navigator.canPop(
                                    context,
                                  )) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BasePage();
                                        },
                                      ),
                                    );
                                  }
                                },
                                borderRadius:
                                    BorderRadius.circular(
                                      30,
                                    ),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    size: 16,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                    Icons
                                        .arrow_back_ios_new_outlined,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Invoice',
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
                                  'Customer Name',
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 15.0,
                          ),
                          child: PopupMenuButton(
                            offset: Offset(-20, 30),
                            color: Colors.white,
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {},
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Print',
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {},
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Edit',
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {},
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Download',
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {},
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    'Delete',
                                  ),
                                ),
                              ];
                            },
                            child: Icon(
                              Icons.more_vert_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: returnCompProvider(
                        context,
                      ).showLoader(message: ''),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          return SafeArea(
            child: Scaffold(
              backgroundColor: const Color.fromARGB(
                255,
                253,
                254,
                255,
              ),
              body: Column(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      // spacing: 10,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Material(
                              type:
                                  MaterialType.transparency,
                              child: InkWell(
                                onTap: () {
                                  if (Navigator.canPop(
                                    context,
                                  )) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return BasePage();
                                        },
                                      ),
                                    );
                                  }
                                },
                                borderRadius:
                                    BorderRadius.circular(
                                      30,
                                    ),
                                child: Container(
                                  padding: EdgeInsets.all(
                                    10,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    size: 16,
                                    color:
                                        Colors
                                            .grey
                                            .shade700,
                                    Icons
                                        .arrow_back_ios_new_outlined,
                                  ),
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              spacing: 2,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Invoice',
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
                                  customer?.name ??
                                      'Customer Name',
                                ),
                              ],
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 15.0,
                          ),
                          child: PopupMenuButton(
                            offset: Offset(-20, 30),
                            color: Colors.white,
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  enabled:
                                      returnReceiptProvider(
                                            context,
                                            listen: false,
                                          )
                                          .returnOwnReceiptsByDayOrWeek()
                                          .where(
                                            (rec) =>
                                                rec.invoiceUuid ==
                                                widget
                                                    .invoiceUuid,
                                          )
                                          .isEmpty,
                                  height: 35,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        return ConfirmationAlert(
                                          theme:
                                              returnTheme(
                                                context,
                                                listen:
                                                    false,
                                              ),
                                          message:
                                              'You are about to edit this Invoice. Are you sure you want to proceed?',
                                          title:
                                              'Edit Invoice',
                                          action: () {
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            returnInvoicesProvider()
                                                .onEditInvoice(
                                                  invoice:
                                                      invoice,
                                                  context:
                                                      context,
                                                );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Edit',
                                  ),
                                ),
                                PopupMenuItem(
                                  enabled: !kIsWeb,
                                  height: 35,
                                  onTap: () {
                                    SalesAuthAction().printReceiptAction(
                                      context: context,
                                      action: () async {
                                        var safeContext =
                                            context;
                                        showDialog(
                                          context: context,
                                          builder: (
                                            confirmDialog,
                                          ) {
                                            return ConfirmationAlert(
                                              theme: theme,
                                              message:
                                                  'You are about to Print This Invoice. Are you sure you want to Proceed?',
                                              title:
                                                  'Print Invoice',
                                              action: () async {
                                                setState(() {
                                                  isPrintingInvoice =
                                                      true;
                                                });
                                                scanBluetoothPrintersinvoice(
                                                  invoice:
                                                      invoice,
                                                  records:
                                                      saleRecords,
                                                  shop:
                                                      shopSingle()!,
                                                  context:
                                                      context,
                                                );
                                                Navigator.of(
                                                  confirmDialog,
                                                ).pop();
                                              },
                                            );
                                          },
                                        ).then((_) {
                                          if (safeContext
                                              .mounted) {
                                            setState(() {
                                              isPrintingInvoice =
                                                  false;
                                            });
                                          }
                                        });
                                      },
                                    );
                                  },
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    'Print',
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {
                                    SalesAuthAction().downloadReceiptAction(
                                      context: context,
                                      action: () async {
                                        var safeContext =
                                            context;
                                        if (!kIsWeb) {
                                          await generateAndPreviewPdfInvoice(
                                            invoice:
                                                invoice,
                                            staffName:
                                                invoice
                                                    .staffName,
                                            context:
                                                safeContext,
                                            receipts:
                                                returnReceiptProviderSingle()
                                                    .returnOwnReceiptsByDayOrWeek()
                                                    .where(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.invoiceUuid ==
                                                          widget.invoiceUuid,
                                                    )
                                                    .toList(),
                                            records:
                                                saleRecords,
                                          );
                                        } else {
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              confirmDialog,
                                            ) {
                                              return ConfirmationAlert(
                                                theme:
                                                    theme,
                                                message:
                                                    'You are about to download This Invoice. Are you sure you want to Proceed?',
                                                title:
                                                    'Download Invoice',
                                                action: () async {
                                                  setState(() {
                                                    isDownloadLoading =
                                                        true;
                                                  });
                                                  Navigator.of(
                                                    confirmDialog,
                                                  ).pop();
                                                  if (kIsWeb) {
                                                    downloadPdfWebInvoice(
                                                      invoice:
                                                          invoice,
                                                      staffName:
                                                          invoice.staffName,
                                                      filename:
                                                          'Stockall_Invoice_${invoice.uuid}.pdf',
                                                      context:
                                                          safeContext,
                                                      receipts:
                                                          returnReceiptProviderSingle()
                                                              .returnOwnReceiptsByDayOrWeek()
                                                              .where(
                                                                (
                                                                  rec,
                                                                ) =>
                                                                    rec.invoiceUuid ==
                                                                    widget.invoiceUuid,
                                                              )
                                                              .toList(),
                                                      records:
                                                          saleRecords,
                                                    );
                                                  }
                                                },
                                              );
                                            },
                                          );
                                        }
                                        if (safeContext
                                            .mounted) {
                                          setState(() {
                                            isDownloadLoading =
                                                false;
                                          });
                                        }
                                      },
                                    );
                                  },
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    kIsWeb
                                        ? 'Download'
                                        : 'Share',
                                  ),
                                ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (
                                        confirmDialog,
                                      ) {
                                        return ConfirmationAlert(
                                          theme: theme,
                                          message:
                                              'You are about to delete this Invoice, are you sure you want to proceed?',
                                          title:
                                              'Delete Invoice?',
                                          action: () async {
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            setState(() {
                                              isDeleteLoading =
                                                  true;
                                            });
                                            var res = await returnInvoicesProvider()
                                                .deleteInvoice(
                                                  invoice,
                                                  saleRecords
                                                      .map(
                                                        (
                                                          rec,
                                                        ) =>
                                                            rec.productName,
                                                      )
                                                      .toList(),
                                                );
                                            await actionResultDialog(
                                              // ignore: use_build_context_synchronously
                                              context:
                                                  context,
                                              message:
                                                  res == 1
                                                      ? 'Deleted Successfully'
                                                      : 'Failed',
                                              isSuccess:
                                                  res == 1
                                                      ? true
                                                      : false,
                                            );
                                            setState(() {
                                              isDeleteLoading =
                                                  false;
                                            });
                                            if (res == 1 &&
                                                context
                                                    .mounted) {
                                              if (Navigator.of(
                                                context,
                                              ).canPop()) {
                                                Navigator.of(
                                                  context,
                                                ).pop();
                                              } else {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return InvoiceListPage();
                                                    },
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                    'Delete',
                                  ),
                                ),
                              ];
                            },
                            child: Icon(
                              Icons.more_vert_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      if (isDeleteLoading ||
                          isDownloadLoading ||
                          isLoading ||
                          isPrintLoading) {
                        return Expanded(
                          child: Center(
                            child: returnCompProvider(
                              context,
                            ).showLoader(message: ''),
                          ),
                        );
                      } else {
                        return Expanded(
                          child: ListView(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                child: Column(
                                  spacing: 15,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal: 18,
                                            vertical: 30,
                                          ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade100,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(
                                              3,
                                            ),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                const Color.fromARGB(
                                                  20,
                                                  0,
                                                  0,
                                                  0,
                                                ),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                        color: Colors.white,
                                      ),
                                      child: Column(
                                        spacing: 5,
                                        children: [
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            spacing: 5,
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  spacing:
                                                      5,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      'Cashier:',
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      invoice
                                                          .staffName,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  spacing:
                                                      5,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      'Date:',
                                                    ),
                                                    Row(
                                                      spacing:
                                                          5,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            "${formatDateTime(invoice.createdAt)}  |  ${formatTime(invoice.createdAt)}",
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 50,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            spacing: 10,
                                            children: [
                                              Expanded(
                                                flex: 10,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Items',
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Price',
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                            height: 5,
                                          ),
                                          Column(
                                            children:
                                                saleRecords
                                                    .map(
                                                      (
                                                        record,
                                                      ) => Padding(
                                                        padding: const EdgeInsets.only(
                                                          top:
                                                              15.0,
                                                        ),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.spaceBetween,
                                                          spacing:
                                                              10,
                                                          children: [
                                                            Expanded(
                                                              flex:
                                                                  10,
                                                              child: Column(
                                                                spacing:
                                                                    2,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    record.productName,
                                                                  ),
                                                                  Row(
                                                                    spacing:
                                                                        3,
                                                                    children: [
                                                                      Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b3.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.normal,
                                                                        ),
                                                                        'Qtty: ',
                                                                      ),
                                                                      Text(
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              theme.mobileTexts.b3.fontSize,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                        '[ ${formatLargeNumberDouble(record.quantity)} ]',
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex:
                                                                  5,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b3.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    formatMoneyBig(
                                                                      amount:
                                                                          (invoice.fixedDiscount ==
                                                                                          null &&
                                                                                      invoice.generalDiscount ==
                                                                                          null) &&
                                                                                  record.discount !=
                                                                                      null
                                                                              ? ((record.originalCost ??
                                                                                      0) -
                                                                                  (record.discountedAmount ??
                                                                                      0))
                                                                              : (record.originalCost ??
                                                                                  0),
                                                                      context:
                                                                          context,
                                                                    ),
                                                                  ),
                                                                  Visibility(
                                                                    visible:
                                                                        record.discount !=
                                                                            null &&
                                                                        !record.customPriceSet &&
                                                                        (invoice.fixedDiscount ==
                                                                                null &&
                                                                            invoice.generalDiscount ==
                                                                                null),
                                                                    child: Text(
                                                                      style: TextStyle(
                                                                        decoration:
                                                                            TextDecoration.lineThrough,
                                                                        fontSize:
                                                                            theme.mobileTexts.b4.fontSize,
                                                                        fontWeight:
                                                                            FontWeight.normal,
                                                                      ),
                                                                      formatMoneyMid(
                                                                        amount:
                                                                            record.originalCost!,
                                                                        context:
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
                                                    )
                                                    .toList(),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                            height: 5,
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            spacing: 3,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                spacing: 20,
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      'Subtotal:',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      formatMoneyBig(
                                                        amount:
                                                            invoice.originalCost ??
                                                            0,
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible:
                                                    invoice
                                                        .vat !=
                                                    null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end,
                                                  spacing:
                                                      20,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            'VAT: ',
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            '[ ${invoice.vat ?? 0}% ]',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          5,
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        formatMoneyBig(
                                                          amount: returnInvoicesProvider().getVATInvoice(
                                                            invoice:
                                                                invoice,
                                                          ),
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    invoice.fixedDiscount !=
                                                        null ||
                                                    invoice.generalDiscount !=
                                                        null,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .end,
                                                  spacing:
                                                      20,
                                                  children: [
                                                    Expanded(
                                                      flex:
                                                          6,
                                                      child: Row(
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            'Discount: ',
                                                          ),
                                                          Visibility(
                                                            visible:
                                                                invoice.generalDiscount !=
                                                                null,
                                                            child: Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.normal,
                                                              ),
                                                              '[ ${invoice.generalDiscount}% ]',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                          5,
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        formatMoneyBig(
                                                          amount: returnInvoicesProvider().getDiscountAmountForInvoice(
                                                            invoice,
                                                          ),
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Divider(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade200,
                                                height: 5,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                spacing: 20,
                                                children: [
                                                  Expanded(
                                                    flex: 6,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      'Total:',
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b2.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      formatMoneyBig(
                                                        amount: returnInvoicesProvider().getTotalMainRevenueInvoice(
                                                          invoice:
                                                              invoice,
                                                        ),
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          // SizedBox(height: 20),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      // width: 300,
                                      padding:
                                          EdgeInsets.symmetric(
                                            // horizontal: 20,
                                            vertical: 10,
                                          ),
                                      child: Column(
                                        spacing: 5,
                                        children: [
                                          Container(
                                            width:
                                                double
                                                    .infinity,
                                            padding:
                                                EdgeInsets.all(
                                                  15,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    5,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    const Color.fromARGB(
                                                      118,
                                                      134,
                                                      155,
                                                      173,
                                                    ),
                                              ),
                                              color:
                                                  const Color.fromARGB(
                                                    31,
                                                    173,
                                                    182,
                                                    209,
                                                  ),
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  50,
                                                              child: Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                  // color:
                                                                  //     Colors
                                                                  //         .green,
                                                                ),
                                                                'Amount:',
                                                              ),
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              formatMoneyMid(
                                                                amount: returnInvoicesProvider().getTotalMainRevenueInvoice(
                                                                  invoice:
                                                                      invoice,
                                                                ),
                                                                context:
                                                                    context,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  50,
                                                              child: Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                  // color:
                                                                  //     Colors
                                                                  //         .green,
                                                                ),
                                                                'Paid:',
                                                              ),
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              formatMoneyMid(
                                                                amount: returnInvoicesProvider().getAmountPaid(
                                                                  invoice:
                                                                      invoice,
                                                                ),
                                                                context:
                                                                    context,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  50,
                                                              child: Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                  // color:
                                                                  //     Colors
                                                                  //         .green,
                                                                ),
                                                                'Balance:',
                                                              ),
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              formatMoneyMid(
                                                                amount: returnInvoicesProvider().getBalance(
                                                                  invoice:
                                                                      invoice,
                                                                ),
                                                                context:
                                                                    context,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical:
                                                            3,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          3,
                                                        ),
                                                        border: Border.all(
                                                          color:
                                                              returnInvoicesProvider(
                                                                        context:
                                                                            context,
                                                                      ).getInvoiceStatus(
                                                                        invoice:
                                                                            invoice,
                                                                      ) ==
                                                                      0
                                                                  ? Colors.red
                                                                  : returnInvoicesProvider(
                                                                        context:
                                                                            context,
                                                                      ).getInvoiceStatus(
                                                                        invoice:
                                                                            invoice,
                                                                      ) ==
                                                                      1
                                                                  ? const Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    223,
                                                                    126,
                                                                  )
                                                                  : Colors.green,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              returnInvoicesProvider(
                                                                        context:
                                                                            context,
                                                                      ).getInvoiceStatus(
                                                                        invoice:
                                                                            invoice,
                                                                      ) ==
                                                                      0
                                                                  ? Colors.red
                                                                  : returnInvoicesProvider(
                                                                        context:
                                                                            context,
                                                                      ).getInvoiceStatus(
                                                                        invoice:
                                                                            invoice,
                                                                      ) ==
                                                                      1
                                                                  ? const Color.fromARGB(
                                                                    255,
                                                                    245,
                                                                    185,
                                                                    6,
                                                                  )
                                                                  : Colors.green,
                                                        ),
                                                        returnInvoicesProvider(
                                                                  context:
                                                                      context,
                                                                ).getInvoiceStatus(
                                                                  invoice:
                                                                      invoice,
                                                                ) ==
                                                                0
                                                            ? 'Unpaid'
                                                            : returnInvoicesProvider(
                                                                  context:
                                                                      context,
                                                                ).getInvoiceStatus(
                                                                  invoice:
                                                                      invoice,
                                                                ) ==
                                                                1
                                                            ? 'Partial'
                                                            : 'Paid',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                                Divider(
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade300,
                                                  height: 1,
                                                ),
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                                Column(
                                                  spacing:
                                                      7,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Row(
                                                      spacing:
                                                          10,
                                                      children: [
                                                        Icon(
                                                          size:
                                                              16,
                                                          color:
                                                              Colors.grey.shade600,
                                                          Icons.person,
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          customer?.name ??
                                                              'Name',
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      spacing:
                                                          10,
                                                      children: [
                                                        Icon(
                                                          size:
                                                              16,
                                                          color:
                                                              Colors.grey,
                                                          Icons.phone,
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.normal,
                                                          ),
                                                          customer?.phone ??
                                                              'Phone Number',
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          customer?.email !=
                                                          null,
                                                      child: Row(
                                                        spacing:
                                                            10,
                                                        children: [
                                                          Icon(
                                                            size:
                                                                16,
                                                            color:
                                                                Colors.grey,
                                                            Icons.email_outlined,
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                            customer?.email ??
                                                                'Email',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            spacing: 4,
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
                                                'Make Payment',
                                              ),
                                              Row(
                                                spacing: 5,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      selectPayment(
                                                        1,
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Row(
                                                        spacing:
                                                            4,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  paymentSelected ==
                                                                          1
                                                                      ? FontWeight.bold
                                                                      : null,
                                                            ),
                                                            'Part',
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                              1.5,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey.shade400,
                                                              ),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                3,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                color:
                                                                    paymentSelected ==
                                                                            1
                                                                        ? theme.lightModeColor.prColor250
                                                                        : null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      selectPayment(
                                                        2,
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Row(
                                                        spacing:
                                                            4,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b4.fontSize,
                                                              fontWeight:
                                                                  paymentSelected ==
                                                                          2
                                                                      ? FontWeight.bold
                                                                      : null,
                                                            ),
                                                            'Full',
                                                          ),
                                                          Container(
                                                            padding: EdgeInsets.all(
                                                              1.5,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              border: Border.all(
                                                                color:
                                                                    Colors.grey.shade400,
                                                              ),
                                                            ),
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                3,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                color:
                                                                    paymentSelected ==
                                                                            2
                                                                        ? theme.lightModeColor.prColor250
                                                                        : null,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                  top: 10.0,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
                                              spacing: 5,
                                              children: [
                                                Expanded(
                                                  child: MoneyTextfield(
                                                    onChanged: (
                                                      value,
                                                    ) {
                                                      if ((double.tryParse(
                                                                value.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0) >=
                                                          returnInvoicesProvider().getBalance(
                                                            invoice:
                                                                invoice,
                                                          )) {
                                                        paymentController.text = returnInvoicesProvider()
                                                            .getBalance(
                                                              invoice:
                                                                  invoice,
                                                            )
                                                            .toStringAsFixed(0);
                                                        setState(() {
                                                          paymentSelected =
                                                              2;
                                                        });
                                                      }
                                                      if ((double.tryParse(
                                                                value.replaceAll(
                                                                  ',',
                                                                  '',
                                                                ),
                                                              ) ??
                                                              0) <
                                                          returnInvoicesProvider().getBalance(
                                                            invoice:
                                                                invoice,
                                                          )) {
                                                        setState(() {
                                                          paymentSelected =
                                                              1;
                                                        });
                                                      }
                                                    },
                                                    showTitle:
                                                        false,
                                                    title:
                                                        'Amount',
                                                    hint:
                                                        'Enter Amount',
                                                    controller:
                                                        paymentController,
                                                    theme:
                                                        theme,
                                                    focusNode:
                                                        paymentNode,
                                                  ),
                                                ),
                                                Ink(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          2,
                                                        ),

                                                    gradient:
                                                        theme.lightModeColor.prGradient,
                                                  ),
                                                  child: InkWell(
                                                    onTap: () {
                                                      if (paymentController.text.isNotEmpty &&
                                                          paymentController.text !=
                                                              '0' &&
                                                          !isLoading) {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            confirmDialog,
                                                          ) {
                                                            return ConfirmationAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'You are about to pay for an invoice. Are you sure you want to proceed?',
                                                              title:
                                                                  'Make Payment',
                                                              action: () async {
                                                                Navigator.of(
                                                                  confirmDialog,
                                                                ).pop();
                                                                setState(
                                                                  () {
                                                                    isLoading =
                                                                        true;
                                                                  },
                                                                );
                                                                var tempInvoice = TempInvoice(
                                                                  departmentUuidNew:
                                                                      invoice.departmentUuidNew,
                                                                  uuid:
                                                                      invoice.uuid,
                                                                  createdAt:
                                                                      invoice.createdAt,
                                                                  shopId:
                                                                      invoice.shopId,
                                                                  staffId:
                                                                      invoice.staffId,
                                                                  staffName:
                                                                      invoice.staffName,
                                                                  paymentMethod:
                                                                      invoice.paymentMethod,
                                                                  bank:
                                                                      (invoice.bank),
                                                                  cashAlt:
                                                                      (invoice.cashAlt),
                                                                  customerName:
                                                                      invoice.customerName,
                                                                  customerUuid:
                                                                      invoice.customerUuid,
                                                                  departmentName:
                                                                      invoice.departmentName,
                                                                  departmentUuid:
                                                                      invoice.departmentUuid,
                                                                  fixedDiscount:
                                                                      invoice.fixedDiscount,
                                                                  generalDiscount:
                                                                      invoice.generalDiscount,
                                                                  originalCost:
                                                                      invoice.originalCost,
                                                                  vat:
                                                                      invoice.vat,
                                                                  subStaffUuid:
                                                                      invoice.subStaffUuid,
                                                                );

                                                                var res = await returnInvoicesProvider().makeInvoicePayment(
                                                                  invoice:
                                                                      tempInvoice,
                                                                  salesRecords:
                                                                      saleRecords,
                                                                  currentPayment:
                                                                      (double.tryParse(
                                                                            paymentController.text.replaceAll(
                                                                              ',',
                                                                              '',
                                                                            ),
                                                                          ) ??
                                                                          0),
                                                                );

                                                                if (res ==
                                                                    0) {
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          false;
                                                                    },
                                                                  );
                                                                  showDialog(
                                                                    // ignore: use_build_context_synchronously
                                                                    context:
                                                                        context,
                                                                    builder: (
                                                                      popDialog,
                                                                    ) {
                                                                      return InfoAlert(
                                                                        theme:
                                                                            theme,
                                                                        message:
                                                                            'An Error Occoured while making this payment. Please try again.',
                                                                        title:
                                                                            'An Error Occoured',
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          false;
                                                                    },
                                                                  );
                                                                  actionResultDialog(
                                                                    // ignore: use_build_context_synchronously
                                                                    context:
                                                                        context,
                                                                    isSuccess:
                                                                        res ==
                                                                                0
                                                                            ? false
                                                                            : true,
                                                                    message:
                                                                        res ==
                                                                                0
                                                                            ? 'An error Occoured'
                                                                            : 'Payment Successful',
                                                                  );
                                                                  if (context.mounted) {
                                                                    paymentController.clear();
                                                                  }
                                                                  setState(
                                                                    () {
                                                                      paymentSelected =
                                                                          null;
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                            );
                                                          },
                                                        );
                                                      } else {
                                                        paymentNode.requestFocus();
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(
                                                        vertical:
                                                            7.5,
                                                        horizontal:
                                                            25,
                                                      ),
                                                      child: Builder(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          if (!isLoading) {
                                                            return Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b3.fontSize,
                                                                color:
                                                                    Colors.white,
                                                              ),
                                                              'Pay',
                                                            );
                                                          } else {
                                                            return SizedBox(
                                                              height:
                                                                  15,
                                                              width:
                                                                  15,
                                                              child: CircularProgressIndicator(
                                                                color:
                                                                    Colors.white,
                                                                strokeWidth:
                                                                    2,
                                                              ),
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                paymentSelected !=
                                                null,
                                            child: SizedBox(
                                              height: 5,
                                            ),
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Row(
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
                                                'Payment Records',
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade200,
                                            height: 10,
                                          ),
                                          Builder(
                                            builder: (
                                              context,
                                            ) {
                                              if (returnReceiptProvider(
                                                    context,
                                                  )
                                                  .returnOwnReceiptsByDayOrWeek()
                                                  .where(
                                                    (rec) =>
                                                        rec.invoiceUuid ==
                                                        widget.invoiceUuid,
                                                  )
                                                  .isEmpty) {
                                                return SizedBox(
                                                  height:
                                                      100,
                                                  child: Center(
                                                    child: Column(
                                                      spacing:
                                                          5,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.all(
                                                            15,
                                                          ),
                                                          decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color:
                                                                Colors.grey.shade100,
                                                          ),
                                                          child: Icon(
                                                            Icons.clear,
                                                            color:
                                                                Colors.grey,
                                                          ),
                                                        ),
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.grey.shade600,
                                                          ),
                                                          'No Records Found',
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }
                                              return Column(
                                                spacing: 4,
                                                children:
                                                    returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
                                                        .where(
                                                          (
                                                            rec,
                                                          ) =>
                                                              rec.invoiceUuid ==
                                                              widget.invoiceUuid,
                                                        )
                                                        .map(
                                                          (
                                                            receipt,
                                                          ) => InkWell(
                                                            onTap: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return ReceiptPage(
                                                                      response: CheckoutResponse(
                                                                        resUuid:
                                                                            receipt.uuid!,
                                                                        isReceipt:
                                                                            true,
                                                                      ),
                                                                      isMain:
                                                                          false,
                                                                      isComingFromInvoice:
                                                                          true,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                            child: Padding(
                                                              padding: EdgeInsetsGeometry.symmetric(
                                                                vertical:
                                                                    5,
                                                                horizontal:
                                                                    10,
                                                              ),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.spaceBetween,
                                                                spacing:
                                                                    5,
                                                                children: [
                                                                  Expanded(
                                                                    child: Row(
                                                                      spacing:
                                                                          2,
                                                                      children: [
                                                                        RotatedBox(
                                                                          quarterTurns:
                                                                              90,
                                                                          child: Icon(
                                                                            size:
                                                                                30,
                                                                            Icons.arrow_left_rounded,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          style: TextStyle(
                                                                            fontSize:
                                                                                theme.mobileTexts.b3.fontSize,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          formatMoneyBig(
                                                                            amount: returnReceiptProvider(
                                                                              context,
                                                                            ).getTotalMainRevenueReceipt(
                                                                              receipt,
                                                                            ),
                                                                            context:
                                                                                context,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          theme.mobileTexts.b4.fontSize,
                                                                      fontWeight:
                                                                          FontWeight.bold,
                                                                    ),
                                                                    formatDateTime(
                                                                      receipt.createdAt,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<dynamic> actionResultDialog({
    required BuildContext context,
    required String message,
    required bool isSuccess,
  }) async {
    await showDialog(
      barrierDismissible: false,
      // ignore: use_build_context_synchronously
      context: context,
      builder: (dialogContext) {
        Future.delayed(const Duration(seconds: 3), () {
          if (dialogContext.mounted) {
            if (Navigator.of(dialogContext).canPop()) {
              Navigator.of(dialogContext).pop();
            }
          }
        });

        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          backgroundColor: Colors.white,
          content: Container(
            height: 400,
            width: 400,
            color: Colors.white,
            child: Builder(
              builder: (context) {
                if (!isSuccess) {
                  return returnCompProvider(
                    context,
                    listen: false,
                  ).showError(message);
                } else {
                  return returnCompProvider(
                    context,
                    listen: false,
                  ).showSuccess(message);
                }
              },
            ),
          ),
        );
      },
    );
  }
}
