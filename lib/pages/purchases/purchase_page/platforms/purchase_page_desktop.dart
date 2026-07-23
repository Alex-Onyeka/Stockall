import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/purchase_payment_print_and_download.dart';
import 'package:stockall/constants/purchase_print_and_download.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';

class PurchasePageDesktop extends StatefulWidget {
  final String purchaseUuid;
  const PurchasePageDesktop({
    super.key,
    required this.purchaseUuid,
  });

  @override
  State<PurchasePageDesktop> createState() =>
      _PurchasePageDesktopState();
}

class _PurchasePageDesktopState
    extends State<PurchasePageDesktop> {
  final paymentController = TextEditingController();

  FocusNode paymentNode = FocusNode();

  int paymentSelected = 1;

  void selectPayment({
    required int value,
    required TempPurchase purchase,
  }) {
    setState(() {
      paymentSelected = value;
      if (value == 2) {
        paymentController.text =
            returnPurchaseProvider()
                .getPurchasePaymentBalance(purchase)
                .toString();
      } else {
        paymentController.clear();
        paymentNode.requestFocus();
      }
    });
  }

  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempItemPurchaseRecord> saleRecords =
        returnPurchaseProvider(context: context)
            .itemPurchaseRecords
            .where(
              (record) =>
                  record.purchaseId == widget.purchaseUuid,
            )
            .toList();
    var purchs =
        returnPurchaseProvider(context: context).purchases
            .where(
              (purchase) =>
                  purchase.uuid == widget.purchaseUuid,
            )
            .toList();

    TempPurchase? purchase =
        purchs.isNotEmpty ? purchs.first : null;
    var supps =
        returnSuppliersProvider(context: context).suppliers
            .where(
              (sup) => sup.uuid == purchase?.supplierId,
            )
            .toList();
    SuppliersClass? supplier =
        supps.isNotEmpty ? supps.first : null;
    return Builder(
      builder: (context) {
        if (purchase == null) {
          return Scaffold(
            body: Column(
              spacing: 15,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
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
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
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
                                BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                size: 18,
                                color: Colors.grey.shade700,
                                Icons
                                    .arrow_back_ios_new_outlined,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                'Purchase',
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
                                'Supplier Name',
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          ActionButtonSmall(
                            action: () {},
                            text: 'Refresh',
                          ),
                          ActionButtonSmall(
                            action: () {},
                            text: 'Print',
                          ),
                          ActionButtonSmall(
                            action: () {},
                            text: 'Edit',
                          ),
                          ActionButtonSmall(
                            action: () {},
                            text: 'Dowmload',
                          ),
                          ActionButtonSmall(
                            action: () {},
                            text: 'Delete',
                            textColor: Colors.red.shade300,
                          ),
                        ],
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
          );
        } else {
          return Scaffold(
            backgroundColor: const Color.fromARGB(
              255,
              253,
              254,
              255,
            ),
            body: Column(
              spacing: 15,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
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
                    spacing: 10,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
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
                                BorderRadius.circular(30),
                            child: Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      Colors.grey.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                size: 18,
                                color: Colors.grey.shade700,
                                Icons
                                    .arrow_back_ios_new_outlined,
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            spacing: 5,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                ),
                                'Purchase',
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
                                supplier?.name ??
                                    'Supplier Name',
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          ActionButtonSmall(
                            isLoading: isPrintLoading,
                            action: () async {
                              await returnPurchaseProvider()
                                  .loadPurchases(shopId());
                              setState(() {});
                            },
                            text: 'Refresh',
                          ),
                          ActionButtonSmall(
                            isLoading: isPrintLoading,
                            action: () {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to Print This Purchase Receipt. Are you sure you want to Proceed?',
                                    title:
                                        'Print Purchase Receipt',
                                    action: () async {
                                      setState(() {
                                        isPrintLoading =
                                            true;
                                      });
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      if (kIsWeb) {
                                        downloadPdfWebRollPurchase(
                                          purchase:
                                              purchase,
                                          filename:
                                              'Stockall_Purchase_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                          context: context,
                                          records:
                                              saleRecords,
                                          shop:
                                              returnShopProvider()
                                                  .userShop()!,
                                          printType:
                                              returnShopProvider()
                                                  .userShop()!
                                                  .printType!,
                                        );
                                      } else {
                                        await generateAndPreviewPdfRollPurchase(
                                          purchase:
                                              purchase,
                                          printerType:
                                              returnShopProvider()
                                                  .userShop()!
                                                  .printType ??
                                              1,
                                          context: context,
                                          records:
                                              saleRecords,

                                          shop:
                                              returnShopProvider()
                                                  .userShop()!,
                                        );
                                      }
                                      setState(() {
                                        isPrintLoading =
                                            false;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Print',
                          ),
                          ActionButtonSmall(
                            isLoading: isDownloadLoading,
                            action: () {
                              SalesAuthAction().downloadReceiptAction(
                                context: context,
                                action: () async {
                                  // var safeContext = context;

                                  showDialog(
                                    context: context,
                                    builder: (
                                      confirmDialog,
                                    ) {
                                      return ConfirmationAlert(
                                        theme: theme,
                                        message:
                                            'You are about to download This purchase. Are you sure you want to Proceed?',
                                        title:
                                            'Download Purchase',
                                        action: () async {
                                          setState(() {
                                            isDownloadLoading =
                                                true;
                                          });
                                          Navigator.of(
                                            confirmDialog,
                                          ).pop();
                                          if (kIsWeb) {
                                            downloadPdfWebPurchase(
                                              purchase:
                                                  purchase,
                                              filename:
                                                  'Stockall_Purchase_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                              context:
                                                  context,
                                              records:
                                                  saleRecords,
                                            );
                                          }
                                          if (!kIsWeb) {
                                            await generateAndPreviewPdfPurchase(
                                              purchase:
                                                  purchase,
                                              context:
                                                  context,
                                              records:
                                                  saleRecords,
                                            );
                                          }
                                          await Future.delayed(
                                            Duration(
                                              seconds: 1,
                                            ),
                                          );
                                          if (context
                                              .mounted) {
                                            actionResultDialog(
                                              context:
                                                  context,
                                              message:
                                                  'Purchase Downloaded',
                                              isSuccess:
                                                  true,
                                            );
                                          }
                                          setState(() {
                                            isDownloadLoading =
                                                false;
                                          });
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Download',
                          ),
                          ActionButtonSmall(
                            action: () {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to edit this purchase. Are you sure you want to proceed?',
                                    title: 'Edit Purchase',
                                    action: () {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      returnPurchaseActionProvider()
                                          .editPurchase(
                                            purchase:
                                                purchase,
                                            context:
                                                context,
                                          );
                                    },
                                  );
                                },
                              );
                            },
                            text: 'Edit',
                          ),
                          ActionButtonSmall(
                            isLoading: isDeleteLoading,
                            action: () {
                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  bool updateInventory =
                                      false;
                                  return StatefulBuilder(
                                    builder:
                                        (
                                          newContext,
                                          setStatee,
                                        ) => DialogTemplate(
                                          theme: theme,
                                          message:
                                              'You are about to delete this Purchase Receipt, are you sure you want to proceed?',
                                          title:
                                              'Delete Purchase Receipt?',
                                          action: () async {
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            setState(() {
                                              isDeleteLoading =
                                                  true;
                                            });
                                            var res = await returnPurchaseProvider()
                                                .deletePurchase(
                                                  purchase,
                                                  updateInventory,
                                                  true,
                                                );
                                            if (res == 1) {
                                              await returnPurchaseProvider()
                                                  .loadPurchases(
                                                    shopId(),
                                                  );
                                            }
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
                                                      return PurchaseList();
                                                    },
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          widget: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      20.0,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Update Inventory?',
                                                ),
                                                MyToggleButton(
                                                  boolValue:
                                                      updateInventory,
                                                  toggle: () {
                                                    setStatee(() {
                                                      updateInventory =
                                                          !updateInventory;
                                                    });
                                                  },
                                                  theme:
                                                      theme,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  );
                                },
                              );
                            },
                            text: 'Delete',
                            textColor: Colors.red.shade300,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 20,
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(30),
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
                                            10,
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
                                            spacing: 5,
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
                                                'Staff:',
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
                                                          .normal,
                                                ),
                                                purchase.staffName ??
                                                    'Staff Name',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            spacing: 5,
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
                                                'Date:',
                                              ),
                                              Row(
                                                spacing: 5,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      "${formatDateTime(purchase.createdAt)}  |  ${formatTime(purchase.createdAt)}",
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
                                                  theme
                                                      .mobileTexts
                                                      .b3
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Items',
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Text(
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                                                              record.itemName ??
                                                                  'Item Name',
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
                                                                  '[ ${formatLargeNumberDouble(record.quantity ?? 0)} ]',
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
                                                                    record.total ??
                                                                    0,
                                                                context:
                                                                    context,
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
                                    SizedBox(height: 15),
                                    Divider(
                                      color:
                                          Colors
                                              .grey
                                              .shade400,
                                      height: 5,
                                    ),
                                    SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .end,
                                      children: [
                                        SizedBox(
                                          width: 240,
                                          child: Column(
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
                                                    flex: 4,
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
                                                            purchase.total ??
                                                            0,
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                    flex: 4,
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
                                                        amount: returnPurchaseProvider().getTotalMainRevenuePurchase(
                                                          purchase,
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
                                        ),
                                      ],
                                    ),
                                    // SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              width: 300,
                              padding: EdgeInsets.symmetric(
                                // horizontal: 20,
                                vertical: 10,
                              ),
                              child: Column(
                                spacing: 5,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(
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
                                                  CrossAxisAlignment
                                                      .start,
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
                                                        amount: returnPurchaseProvider().getTotalMainRevenuePurchase(
                                                          purchase,
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
                                                        amount: returnPurchaseProvider(
                                                          context:
                                                              context,
                                                        ).getTotalPurchasePayments(
                                                          purchase,
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
                                                        amount: returnPurchaseProvider(
                                                          context:
                                                              context,
                                                        ).getPurchasePaymentBalance(
                                                          purchase,
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
                                              padding:
                                                  EdgeInsets.symmetric(
                                                    vertical:
                                                        3,
                                                    horizontal:
                                                        10,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      3,
                                                    ),
                                                border: Border.all(
                                                  color:
                                                      returnPurchaseProvider(
                                                                context:
                                                                    context,
                                                              ).getPurchaseStatus(
                                                                purchase,
                                                              ) ==
                                                              0
                                                          ? Colors.red
                                                          : returnPurchaseProvider(
                                                                context:
                                                                    context,
                                                              ).getPurchaseStatus(
                                                                purchase,
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
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  color:
                                                      returnPurchaseProvider(
                                                                context:
                                                                    context,
                                                              ).getPurchaseStatus(
                                                                purchase,
                                                              ) ==
                                                              0
                                                          ? Colors.red
                                                          : returnPurchaseProvider(
                                                                context:
                                                                    context,
                                                              ).getPurchaseStatus(
                                                                purchase,
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
                                                returnPurchaseProvider(
                                                          context:
                                                              context,
                                                        ).getPurchaseStatus(
                                                          purchase,
                                                        ) ==
                                                        0
                                                    ? 'Unpaid'
                                                    : returnPurchaseProvider(
                                                          context:
                                                              context,
                                                        ).getPurchaseStatus(
                                                          purchase,
                                                        ) ==
                                                        1
                                                    ? 'Partial'
                                                    : 'Paid',
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Divider(
                                          color:
                                              Colors
                                                  .grey
                                                  .shade300,
                                          height: 1,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Column(
                                          spacing: 7,
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Row(
                                              spacing: 10,
                                              children: [
                                                Icon(
                                                  size: 16,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade600,
                                                  Icons
                                                      .person,
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  supplier?.name ??
                                                      'Supplier Name',
                                                ),
                                              ],
                                            ),
                                            Row(
                                              spacing: 10,
                                              children: [
                                                Icon(
                                                  size: 16,
                                                  color:
                                                      Colors
                                                          .grey,
                                                  Icons
                                                      .phone,
                                                ),
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        theme.mobileTexts.b4.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  supplier?.phone ??
                                                      'Supplier Phone',
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible:
                                                  supplier?.email !=
                                                      null &&
                                                  supplier!
                                                      .email!
                                                      .isNotEmpty,
                                              child: Row(
                                                spacing: 10,
                                                children: [
                                                  Icon(
                                                    size:
                                                        16,
                                                    color:
                                                        Colors.grey,
                                                    Icons
                                                        .email_outlined,
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b4.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    supplier?.email ??
                                                        'Supplier Email',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  supplier?.address !=
                                                      null &&
                                                  supplier
                                                          ?.address
                                                          ?.isNotEmpty ==
                                                      true,
                                              child: Row(
                                                spacing: 10,
                                                children: [
                                                  Icon(
                                                    size:
                                                        16,
                                                    color:
                                                        Colors.grey,
                                                    Icons
                                                        .pin_drop_outlined,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b4.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                      ),
                                                      supplier?.address !=
                                                                  null &&
                                                              supplier?.address?.isNotEmpty ==
                                                                  true
                                                          ? "${supplier?.address} | ${supplier?.city ?? "City"} | ${supplier?.state ?? "State"} | ${supplier?.country ?? 'Country'}"
                                                          : 'Supplier Address',
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
                                  SizedBox(height: 15),
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
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              selectPayment(
                                                value: 1,
                                                purchase:
                                                    purchase,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(
                                                    4,
                                                  ),
                                              child: Row(
                                                spacing: 4,
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
                                                    padding:
                                                        EdgeInsets.all(
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
                                                      padding:
                                                          EdgeInsets.all(
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
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              selectPayment(
                                                value: 2,
                                                purchase:
                                                    purchase,
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(
                                                    4,
                                                  ),
                                              child: Row(
                                                spacing: 4,
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
                                                    padding:
                                                        EdgeInsets.all(
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
                                                      padding:
                                                          EdgeInsets.all(
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
                                                      0) <
                                                  returnPurchaseProvider()
                                                      .getPurchasePaymentBalance(
                                                        purchase,
                                                      )) {
                                                setState(() {
                                                  paymentSelected =
                                                      1;
                                                });
                                              }
                                              if ((double.tryParse(
                                                        value.replaceAll(
                                                          ',',
                                                          '',
                                                        ),
                                                      ) ??
                                                      0) >=
                                                  returnPurchaseProvider()
                                                      .getPurchasePaymentBalance(
                                                        purchase,
                                                      )) {
                                                paymentController
                                                    .text = returnPurchaseProvider()
                                                    .getPurchasePaymentBalance(
                                                      purchase,
                                                    )
                                                    .toStringAsFixed(
                                                      0,
                                                    );
                                                setState(() {
                                                  paymentSelected =
                                                      2;
                                                });
                                              }
                                            },
                                            showTitle:
                                                false,
                                            title: 'Amount',
                                            hint:
                                                'Enter Amount',
                                            controller:
                                                paymentController,
                                            theme: theme,
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
                                                theme
                                                    .lightModeColor
                                                    .prGradient,
                                          ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              if (paymentController
                                                      .text
                                                      .isNotEmpty &&
                                                  paymentController
                                                          .text !=
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
                                                          'You are about to pay for an purchase. Are you sure you want to proceed?',
                                                      title:
                                                          'Make Payment',
                                                      action: () async {
                                                        Navigator.of(
                                                          confirmDialog,
                                                        ).pop();
                                                        setState(() {
                                                          isLoading =
                                                              true;
                                                        });
                                                        var tempPurchase =
                                                            purchase.copyWith();
                                                        tempPurchase.purchasePayments.add(
                                                          PurchasePayments(
                                                            uuid:
                                                                uuidGen(),
                                                            purchaseId:
                                                                purchase.uuid!,
                                                            createdAt:
                                                                DateTime.now(),
                                                            amount:
                                                                double.tryParse(
                                                                  paymentController.text.replaceAll(
                                                                    ',',
                                                                    '',
                                                                  ),
                                                                ) ??
                                                                0,
                                                            userId:
                                                                currentUser().userId!,
                                                            staffName:
                                                                currentUser().name,
                                                            paymentMethod:
                                                                'Cash',
                                                          ),
                                                        );

                                                        var res = await returnPurchaseProvider().updatePurchase(
                                                          tempPurchase,
                                                        );

                                                        if (res ==
                                                            null) {
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
                                                                true,
                                                            message:
                                                                'Payment Successful',
                                                          );
                                                          if (context.mounted) {
                                                            paymentController.clear();
                                                          }
                                                          setState(
                                                            () {
                                                              paymentSelected =
                                                                  1;
                                                            },
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                );
                                              } else {
                                                paymentNode
                                                    .requestFocus();
                                              }
                                            },
                                            child: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                    visible: true,
                                    // paymentSelected !=
                                    // null,
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
                                  SizedBox(height: 5),
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
                                  Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                      border: Border.all(
                                        color:
                                            Colors
                                                .grey
                                                .shade200,
                                      ),
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        if (purchase
                                            .purchasePayments
                                            .isEmpty) {
                                          return SizedBox(
                                            height: 100,
                                            child: Center(
                                              child: Column(
                                                spacing: 5,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(
                                                          15,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      color:
                                                          Colors.grey.shade100,
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .clear,
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
                                          spacing: 8,
                                          children:
                                              purchase
                                                  .purchasePayments
                                                  .reversed
                                                  .map(
                                                    (
                                                      payment,
                                                    ) => PurchasePaymentWidget(
                                                      payment:
                                                          payment,
                                                    ),
                                                  )
                                                  .toList(),
                                        );
                                      },
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
                ),
                SizedBox(height: 30),
              ],
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

class PurchasePaymentWidget extends StatefulWidget {
  const PurchasePaymentWidget({
    super.key,
    required this.payment,
  });

  final PurchasePayments payment;

  @override
  State<PurchasePaymentWidget> createState() =>
      _PurchasePaymentWidgetState();
}

class _PurchasePaymentWidgetState
    extends State<PurchasePaymentWidget> {
  bool isOpen = false;
  bool isDeleteLoading = false;
  bool isPrinting = false;
  bool isDownloading = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        setState(() {
          isOpen = !isOpen;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: EdgeInsetsGeometry.fromLTRB(5, 5, 15, 5),
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              spacing: 5,
              children: [
                Expanded(
                  child: Row(
                    // spacing: 2,
                    children: [
                      Icon(
                        size: 30,
                        isOpen
                            ? Icons.arrow_drop_down_rounded
                            : Icons.arrow_right_rounded,
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        formatMoneyBig(
                          amount: widget.payment.amount,
                          context: context,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  formatDateTime(widget.payment.createdAt),
                ),
              ],
            ),
            Visibility(
              visible: isOpen,
              child: Column(
                children: [
                  Divider(thickness: 1),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    spacing: 5,
                    children: [
                      Expanded(
                        child: Row(
                          spacing: 5,
                          children: [
                            SizedBox(width: 5),
                            Icon(
                              size: 14,
                              color: Colors.grey,
                              Icons.person,
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b4
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              widget
                                      .payment
                                      .staffName
                                      .isEmpty
                                  ? 'Not Set'
                                  : widget
                                      .payment
                                      .staffName,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          // fontWeight: FontWeight.bold,
                        ),
                        formatTime(
                          widget.payment.createdAt,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 0.5),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    // spacing: 5,
                    children: [
                      Visibility(
                        visible:
                            screenWidth(context) >
                            mobileScreen,
                        child: PurchasePaymentButtonWidget(
                          action: () {
                            showDialog(
                              context: context,
                              builder: (confirmDialog) {
                                return ConfirmationAlert(
                                  theme: theme,
                                  message:
                                      'You are about to Print This Purchase Payment Receipt. Are you sure you want to Proceed?',
                                  title:
                                      'Print Purchase Payment',
                                  action: () async {
                                    setState(() {
                                      isPrinting = true;
                                    });
                                    Navigator.of(
                                      confirmDialog,
                                    ).pop();
                                    var newPurchase =
                                        returnPurchaseProvider()
                                            .purchases
                                            .firstWhere(
                                              (purch) =>
                                                  purch
                                                      .uuid ==
                                                  widget
                                                      .payment
                                                      .purchaseId,
                                            )
                                            .copyWith();
                                    if (kIsWeb) {
                                      downloadPdfWebRollPurchasePayment(
                                        purchase:
                                            newPurchase,
                                        filename:
                                            'Stockall_Purchase_Payment_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                        context: context,
                                        payment:
                                            widget.payment,
                                        shop:
                                            returnShopProvider()
                                                .userShop()!,
                                        printType:
                                            returnShopProvider()
                                                .userShop()!
                                                .printType!,
                                      );
                                    } else {
                                      await generateAndPreviewPdfRollPurchasePayment(
                                        purchase:
                                            newPurchase,
                                        printerType:
                                            returnShopProvider()
                                                .userShop()!
                                                .printType ??
                                            1,
                                        context: context,
                                        payment:
                                            widget.payment,

                                        shop:
                                            returnShopProvider()
                                                .userShop()!,
                                      );
                                    }
                                    setState(() {
                                      isPrinting = false;
                                    });
                                  },
                                );
                              },
                            );
                          },
                          title: 'Print',
                          isLoading: isPrinting,
                        ),
                      ),
                      PurchasePaymentButtonWidget(
                        action: () {
                          SalesAuthAction().downloadReceiptAction(
                            context: context,
                            action: () async {
                              // var safeContext = context;

                              showDialog(
                                context: context,
                                builder: (confirmDialog) {
                                  return ConfirmationAlert(
                                    theme: theme,
                                    message:
                                        'You are about to download This purchase. Are you sure you want to Proceed?',
                                    title:
                                        'Download Purchase',
                                    action: () async {
                                      setState(() {
                                        isDownloading =
                                            true;
                                      });
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      var newPurchase =
                                          returnPurchaseProvider()
                                              .purchases
                                              .firstWhere(
                                                (purch) =>
                                                    purch
                                                        .uuid ==
                                                    widget
                                                        .payment
                                                        .purchaseId,
                                              )
                                              .copyWith();
                                      if (kIsWeb) {
                                        downloadPdfWebPurchasePayment(
                                          purchase:
                                              newPurchase,
                                          filename:
                                              'Stockall_Purchase_Payment_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                          context: context,
                                          payment:
                                              widget
                                                  .payment,
                                        );
                                      }
                                      if (!kIsWeb) {
                                        await generateAndPreviewPdfPurchasePayment(
                                          purchase:
                                              newPurchase,
                                          context: context,
                                          payment:
                                              widget
                                                  .payment,
                                        );
                                      }
                                      await Future.delayed(
                                        Duration(
                                          seconds: 1,
                                        ),
                                      );
                                      // if (context.mounted) {
                                      //   actionResultDialog(
                                      //     context: context,
                                      //     message:
                                      //         'Purchase Downloaded',
                                      //     isSuccess: true,
                                      //   );
                                      // }
                                      setState(() {
                                        isDownloading =
                                            false;
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                        title: 'Download',
                        isLoading: isDownloading,
                      ),
                      PurchasePaymentButtonWidget(
                        action: () {
                          showDialog(
                            context: context,
                            builder: (confirmContext) {
                              return ConfirmationAlert(
                                theme: theme,
                                message:
                                    'You are about to delete this payment. Are you sure you want to proceed?',
                                title: 'Delete Payment',
                                action: () async {
                                  Navigator.of(
                                    confirmContext,
                                  ).pop();
                                  setState(() {
                                    isDeleteLoading = true;
                                  });
                                  var newPurchase =
                                      returnPurchaseProvider()
                                          .purchases
                                          .firstWhere(
                                            (purch) =>
                                                purch
                                                    .uuid ==
                                                widget
                                                    .payment
                                                    .purchaseId,
                                          )
                                          .copyWith();

                                  newPurchase
                                      .purchasePayments
                                      .remove(
                                        widget.payment,
                                      );
                                  newPurchase.updatedAt =
                                      DateTime.now();
                                  var res =
                                      await returnPurchaseProvider()
                                          .updatePurchase(
                                            newPurchase,
                                          );
                                  if (res == null) {
                                    setState(() {
                                      isDeleteLoading =
                                          false;
                                    });
                                    showDialog(
                                      context: context,
                                      builder: (
                                        errorContext,
                                      ) {
                                        return InfoAlert(
                                          theme: theme,
                                          message:
                                              'An Error Occoured while deleting this payment. Please try again.',
                                          title:
                                              'An Error Occoured',
                                        );
                                      },
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                        title: 'Delete',
                        color: Colors.red,
                        isLoading: isDeleteLoading,
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PurchasePaymentButtonWidget extends StatelessWidget {
  const PurchasePaymentButtonWidget({
    super.key,
    required this.action,
    required this.title,
    required this.isLoading,
    this.color,
  });

  final Function()? action;
  final String title;
  final Color? color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 3.0,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: action,
          child: Padding(
            padding: EdgeInsetsGeometry.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            child: Center(
              child: Builder(
                builder: (context) {
                  if (isLoading) {
                    return SizedBox(
                      height: 17,
                      width: 17,
                      child: CircularProgressIndicator(
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                        strokeWidth: 2.5,
                      ),
                    );
                  } else {
                    return Text(
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color:
                            color ??
                            theme
                                .lightModeColor
                                .secColor100,
                      ),
                      title,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ActionButtonSmall extends StatelessWidget {
  final Function()? action;
  final Color? textColor;
  final String text;
  final bool? isLoading;
  const ActionButtonSmall({
    super.key,
    this.textColor,
    required this.action,
    required this.text,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(3),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 5,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: textColor ?? Colors.grey.shade200,
            ),
          ),
          child: Builder(
            builder: (context) {
              if (isLoading != null && isLoading == true) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      color:
                          theme.lightModeColor.secColor200,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              } else {
                return Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  text,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
