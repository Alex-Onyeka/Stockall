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
import 'package:stockall/constants/purchase_print_and_download.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/purchases/purchase_page/platforms/purchase_page_desktop.dart';

class PurchasePageMobile extends StatefulWidget {
  final String purchaseUuid;
  const PurchasePageMobile({
    super.key,
    required this.purchaseUuid,
  });

  @override
  State<PurchasePageMobile> createState() =>
      _PurchasePageMobileState();
}

class _PurchasePageMobileState
    extends State<PurchasePageMobile> {
  FocusNode paymentNode = FocusNode();
  final paymentController = TextEditingController();

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
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
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
                                  'Purchase',
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
                                  'Supplier Name',
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
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
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
                                  'Purchase',
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
                                  supplier?.name ??
                                      'Supplier Name',
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
                                  enabled: true,
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
                                              'You are about to edit this purchase. Are you sure you want to proceed?',
                                          title:
                                              'Edit Purchase',
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
                                // PopupMenuItem(
                                //   enabled: !kIsWeb,
                                //   height: 35,
                                //   onTap: () {
                                //     showDialog(
                                //       context: context,
                                //       builder: (
                                //         confirmDialog,
                                //       ) {
                                //         return ConfirmationAlert(
                                //           theme: theme,
                                //           message:
                                //               'You are about to Print This Purchase Receipt. Are you sure you want to Proceed?',
                                //           title:
                                //               'Print Purchase Receipt',
                                //           action: () async {
                                //             setState(() {
                                //               isPrintLoading =
                                //                   true;
                                //             });
                                //             Navigator.of(
                                //               confirmDialog,
                                //             ).pop();
                                //             if (kIsWeb) {
                                //               downloadPdfWebRollPurchase(
                                //                 purchase:
                                //                     purchase,
                                //                 filename:
                                //                     'Stockall_Purchase_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                //                 context:
                                //                     context,
                                //                 records:
                                //                     saleRecords,
                                //                 shop:
                                //                     returnShopProvider()
                                //                         .userShop()!,
                                //                 printType:
                                //                     returnShopProvider()
                                //                         .userShop()!
                                //                         .printType!,
                                //               );
                                //             } else {
                                //               await generateAndPreviewPdfRollPurchase(
                                //                 purchase:
                                //                     purchase,
                                //                 printerType:
                                //                     returnShopProvider()
                                //                         .userShop()!
                                //                         .printType ??
                                //                     1,
                                //                 context:
                                //                     context,
                                //                 records:
                                //                     saleRecords,

                                //                 shop:
                                //                     returnShopProvider()
                                //                         .userShop()!,
                                //               );
                                //             }
                                //             setState(() {
                                //               isPrintLoading =
                                //                   false;
                                //             });
                                //           },
                                //         );
                                //       },
                                //     );
                                //   },
                                //   child: Text(
                                //     style: TextStyle(
                                //       fontSize:
                                //           theme
                                //               .mobileTexts
                                //               .b3
                                //               .fontSize,
                                //       fontWeight:
                                //           FontWeight.bold,
                                //     ),
                                //     'Print',
                                //   ),
                                // ),
                                PopupMenuItem(
                                  height: 35,
                                  onTap: () {
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
                                                    seconds:
                                                        1,
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
                                        bool
                                        updateInventory =
                                            false;
                                        return StatefulBuilder(
                                          builder:
                                              (
                                                newContext,
                                                setStatee,
                                              ) => DialogTemplate(
                                                theme:
                                                    theme,
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
                                                  var res = await returnPurchaseProvider().deletePurchase(
                                                    purchase,
                                                    updateInventory,
                                                    true,
                                                  );
                                                  if (res ==
                                                      1) {
                                                    await returnPurchaseProvider().loadPurchases(
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
                                                  if (res ==
                                                          1 &&
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
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal:
                                                        20.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
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
                                                          setStatee(
                                                            () {
                                                              updateInventory =
                                                                  !updateInventory;
                                                            },
                                                          );
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
                                                      'Staff:',
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.normal,
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
                                                                amount: returnPurchaseProvider().getTotalPurchasePayments(
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
                                                                amount: returnPurchaseProvider().getPurchasePaymentBalance(
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
                                                              theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                          supplier?.name ??
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
                                                          supplier?.phone ??
                                                              'Phone Number',
                                                        ),
                                                      ],
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          supplier?.email !=
                                                              null &&
                                                          supplier!.email!.isNotEmpty,
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
                                                            supplier?.email ??
                                                                'Email',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible:
                                                          supplier?.address !=
                                                              null &&
                                                          supplier?.address?.isNotEmpty ==
                                                              true,
                                                      child: Row(
                                                        spacing:
                                                            10,
                                                        children: [
                                                          Icon(
                                                            size:
                                                                16,
                                                            color:
                                                                Colors.grey,
                                                            Icons.pin_drop_outlined,
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
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
                                                    onTap: () {
                                                      selectPayment(
                                                        value:
                                                            1,
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
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
                                                    onTap: () {
                                                      selectPayment(
                                                        value:
                                                            2,
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
                                                              0) <
                                                          returnPurchaseProvider().getPurchasePaymentBalance(
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
                                                          returnPurchaseProvider().getPurchasePaymentBalance(
                                                            purchase,
                                                          )) {
                                                        paymentController.text = returnPurchaseProvider()
                                                            .getPurchasePaymentBalance(
                                                              purchase,
                                                            )
                                                            .toStringAsFixed(0);
                                                        setState(() {
                                                          paymentSelected =
                                                              2;
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
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
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
                                                                  'You are about to pay for an purchase. Are you sure you want to proceed?',
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
                                          SizedBox(
                                            height: 5,
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
                                          Container(
                                            padding:
                                                EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      10,
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
                                              builder: (
                                                context,
                                              ) {
                                                if (purchase
                                                    .purchasePayments
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
                                                  spacing:
                                                      4,
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
