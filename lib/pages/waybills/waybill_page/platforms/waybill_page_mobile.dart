import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/classes/temp_waybills/waybill_items.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/waybills/waybill_list/waybill_list.dart';

class WaybillPageMobile extends StatefulWidget {
  final String waybillUuid;
  const WaybillPageMobile({
    super.key,
    required this.waybillUuid,
  });

  @override
  State<WaybillPageMobile> createState() =>
      _WaybillPageMobileState();
}

class _WaybillPageMobileState
    extends State<WaybillPageMobile> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var waybills =
        returnWaybillProvider(context: context).waybills
            .where(
              (waybill) =>
                  waybill.uuid == widget.waybillUuid,
            )
            .toList();

    TempWayBills? waybill =
        waybills.isNotEmpty ? waybills.first : null;
    List<WaybillItems> waybillItems =
        waybill == null ? [] : waybill.items;

    var customers =
        returnCustomers(context).customers
            .where(
              (cust) => cust.uuid == waybill?.customerId,
            )
            .toList();
    TempCustomersClass? customer =
        customers.isNotEmpty ? customers.first : null;
    return Builder(
      builder: (context) {
        if (waybill == null) {
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
                                  'Waybill',
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
                                  'Waybill',
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
                                    // showDialog(
                                    //   context: context,
                                    //   builder: (
                                    //     confirmDialog,
                                    //   ) {
                                    //     return ConfirmationAlert(
                                    //       theme: theme,
                                    //       message:
                                    //           'You are about to edit this waybill. Are you sure you want to proceed?',
                                    //       title:
                                    //           'Edit Invoice',
                                    //       action: () {
                                    //         Navigator.of(
                                    //           confirmDialog,
                                    //         ).pop();
                                    //         returnWaybillActionProvider()
                                    //             .editWaybill(
                                    //               waybill:
                                    //                   waybill,
                                    //               context:
                                    //                   context,
                                    //             );
                                    //       },
                                    //     );
                                    //   },
                                    // );
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
                                //               'You are about to Print This Waybill Receipt. Are you sure you want to Proceed?',
                                //           title:
                                //               'Print Waybill Receipt',
                                //           action: () async {
                                //             setState(() {
                                //               isPrintLoading =
                                //                   true;
                                //             });
                                //             Navigator.of(
                                //               confirmDialog,
                                //             ).pop();
                                //             if (kIsWeb) {
                                //               downloadPdfWebRollWaybill(
                                //                 waybill:
                                //                     waybill,
                                //                 filename:
                                //                     'Stockall_Waybill_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                //                 context:
                                //                     context,
                                //                 records:
                                //                     waybillItems,
                                //                 shop:
                                //                     returnShopProvider()
                                //                         .userShop()!,
                                //                 printType:
                                //                     returnShopProvider()
                                //                         .userShop()!
                                //                         .printType!,
                                //               );
                                //             } else {
                                //               await generateAndPreviewPdfRollWaybill(
                                //                 waybill:
                                //                     waybill,
                                //                 printerType:
                                //                     returnShopProvider()
                                //                         .userShop()!
                                //                         .printType ??
                                //                     1,
                                //                 context:
                                //                     context,
                                //                 records:
                                //                     waybillItems,

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
                                                  'You are about to download This waybill. Are you sure you want to Proceed?',
                                              title:
                                                  'Download Waybill',
                                              action: () async {
                                                setState(() {
                                                  isDownloadLoading =
                                                      true;
                                                });
                                                Navigator.of(
                                                  confirmDialog,
                                                ).pop();
                                                if (kIsWeb) {
                                                  // downloadPdfWebWaybill(
                                                  //   waybill:
                                                  //       waybill,
                                                  //   filename:
                                                  //       'Stockall_Waybill_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                                  //   context:
                                                  //       context,
                                                  //   records:
                                                  //       waybillItems,
                                                  // );
                                                }
                                                if (!kIsWeb) {
                                                  // await generateAndPreviewPdfWaybill(
                                                  //   waybill:
                                                  //       waybill,
                                                  //   context:
                                                  //       context,
                                                  //   records:
                                                  //       waybillItems,
                                                  // );
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
                                                        'Invoice Downloaded',
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
                                                    'You are about to delete this Waybill Receipt, are you sure you want to proceed?',
                                                title:
                                                    'Delete Waybill Receipt?',
                                                action: () async {
                                                  Navigator.of(
                                                    confirmDialog,
                                                  ).pop();
                                                  setState(() {
                                                    isDeleteLoading =
                                                        true;
                                                  });
                                                  var res = await returnWaybillProvider().deleteWaybill(
                                                    waybill,
                                                    updateInventory,
                                                    true,
                                                  );
                                                  if (res ==
                                                      1) {
                                                    await returnWaybillProvider().loadWaybills(
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
                                                            return WaybillList();
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
                                                      waybill.staffName ??
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
                                                            "${formatDateTime(waybill.createdAt!)}  |  ${formatTime(waybill.createdAt!)}",
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
                                                waybillItems
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
                                                                    record.itemName,
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
                                                                          record.amount,
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
                                                            waybill.totalAmount ??
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
                                                        amount: returnWaybillProvider().getTotalMainRevenueWaybill(
                                                          waybill,
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
                                                                amount: returnWaybillProvider().getTotalMainRevenueWaybill(
                                                                  waybill,
                                                                ),
                                                                context:
                                                                    context,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        // Row(
                                                        //   children: [
                                                        //     SizedBox(
                                                        //       width:
                                                        //           50,
                                                        //       child: Text(
                                                        //         style: TextStyle(
                                                        //           fontSize:
                                                        //               theme.mobileTexts.b4.fontSize,
                                                        //           fontWeight:
                                                        //               FontWeight.normal,
                                                        //           // color:
                                                        //           //     Colors
                                                        //           //         .green,
                                                        //         ),
                                                        //         'Paid:',
                                                        //       ),
                                                        //     ),
                                                        //     Text(
                                                        //       style: TextStyle(
                                                        //         fontSize:
                                                        //             theme.mobileTexts.b4.fontSize,
                                                        //         fontWeight:
                                                        //             FontWeight.bold,
                                                        //         // color:
                                                        //         //     Colors
                                                        //         //         .green,
                                                        //       ),
                                                        //       formatMoneyMid(
                                                        //         amount: returnWaybillProvider().getTotalWaybillPayments(
                                                        //           waybill,
                                                        //         ),
                                                        //         context:
                                                        //             context,
                                                        //       ),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                        // Row(
                                                        //   children: [
                                                        //     SizedBox(
                                                        //       width:
                                                        //           50,
                                                        //       child: Text(
                                                        //         style: TextStyle(
                                                        //           fontSize:
                                                        //               theme.mobileTexts.b4.fontSize,
                                                        //           fontWeight:
                                                        //               FontWeight.normal,
                                                        //           // color:
                                                        //           //     Colors
                                                        //           //         .green,
                                                        //         ),
                                                        //         'Balance:',
                                                        //       ),
                                                        //     ),
                                                        //     Text(
                                                        //       style: TextStyle(
                                                        //         fontSize:
                                                        //             theme.mobileTexts.b4.fontSize,
                                                        //         fontWeight:
                                                        //             FontWeight.bold,
                                                        //         // color:
                                                        //         //     Colors
                                                        //         //         .green,
                                                        //       ),
                                                        //       formatMoneyMid(
                                                        //         amount: returnWaybillProvider().getWaybillPaymentBalance(
                                                        //           waybill,
                                                        //         ),
                                                        //         context:
                                                        //             context,
                                                        //       ),
                                                        //     ),
                                                        //   ],
                                                        // ),
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
                                                              returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      0
                                                                  ? Colors.grey
                                                                  : returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      1
                                                                  ? const Color.fromARGB(
                                                                    255,
                                                                    255,
                                                                    223,
                                                                    126,
                                                                  )
                                                                  : returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      2
                                                                  ? Colors.blue
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
                                                              returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      0
                                                                  ? Colors.grey
                                                                  : returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      1
                                                                  ? const Color.fromARGB(
                                                                    255,
                                                                    245,
                                                                    185,
                                                                    6,
                                                                  )
                                                                  : returnWaybillProvider(
                                                                        context:
                                                                            context,
                                                                      ).getWaybillStatus(
                                                                        waybill,
                                                                      ) ==
                                                                      2
                                                                  ? Colors.blue
                                                                  : Colors.green,
                                                        ),
                                                        returnWaybillProvider(
                                                          context:
                                                              context,
                                                        ).getWaybillText(
                                                          waybill,
                                                        ),
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
                                                              null &&
                                                          customer!.email.isNotEmpty,
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
                                                    Visibility(
                                                      visible:
                                                          customer?.address !=
                                                              null &&
                                                          customer?.address?.isNotEmpty ==
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
                                                              customer?.address !=
                                                                          null &&
                                                                      customer?.address?.isNotEmpty ==
                                                                          true
                                                                  ? "${customer?.address} | ${customer?.city ?? "City"} | ${customer?.state ?? "State"} | ${customer?.country ?? 'Country'}"
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
                                                'Update Status',
                                              ),
                                              // Row(
                                              //   spacing: 5,
                                              //   children: [
                                              //     InkWell(
                                              //       onTap: () {
                                              //         selectPayment(
                                              //           value:
                                              //               1,
                                              //           waybill:
                                              //               waybill,
                                              //         );
                                              //       },
                                              //       child: Padding(
                                              //         padding:
                                              //             const EdgeInsets.all(
                                              //               4,
                                              //             ),
                                              //         child: Row(
                                              //           spacing:
                                              //               4,
                                              //           children: [
                                              //             Text(
                                              //               style: TextStyle(
                                              //                 fontSize:
                                              //                     theme.mobileTexts.b4.fontSize,
                                              //                 fontWeight:
                                              //                     paymentSelected ==
                                              //                             1
                                              //                         ? FontWeight.bold
                                              //                         : null,
                                              //               ),
                                              //               'Part',
                                              //             ),
                                              //             Container(
                                              //               padding: EdgeInsets.all(
                                              //                 1.5,
                                              //               ),
                                              //               decoration: BoxDecoration(
                                              //                 shape:
                                              //                     BoxShape.circle,
                                              //                 border: Border.all(
                                              //                   color:
                                              //                       Colors.grey.shade400,
                                              //                 ),
                                              //               ),
                                              //               child: Container(
                                              //                 padding: EdgeInsets.all(
                                              //                   3,
                                              //                 ),
                                              //                 decoration: BoxDecoration(
                                              //                   shape:
                                              //                       BoxShape.circle,
                                              //                   color:
                                              //                       paymentSelected ==
                                              //                               1
                                              //                           ? theme.lightModeColor.prColor250
                                              //                           : null,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //     InkWell(
                                              //       onTap: () {
                                              //         selectPayment(
                                              //           value:
                                              //               2,
                                              //           waybill:
                                              //               waybill,
                                              //         );
                                              //       },
                                              //       child: Padding(
                                              //         padding:
                                              //             const EdgeInsets.all(
                                              //               4,
                                              //             ),
                                              //         child: Row(
                                              //           spacing:
                                              //               4,
                                              //           children: [
                                              //             Text(
                                              //               style: TextStyle(
                                              //                 fontSize:
                                              //                     theme.mobileTexts.b4.fontSize,
                                              //                 fontWeight:
                                              //                     paymentSelected ==
                                              //                             2
                                              //                         ? FontWeight.bold
                                              //                         : null,
                                              //               ),
                                              //               'Full',
                                              //             ),
                                              //             Container(
                                              //               padding: EdgeInsets.all(
                                              //                 1.5,
                                              //               ),
                                              //               decoration: BoxDecoration(
                                              //                 shape:
                                              //                     BoxShape.circle,
                                              //                 border: Border.all(
                                              //                   color:
                                              //                       Colors.grey.shade400,
                                              //                 ),
                                              //               ),
                                              //               child: Container(
                                              //                 padding: EdgeInsets.all(
                                              //                   3,
                                              //                 ),
                                              //                 decoration: BoxDecoration(
                                              //                   shape:
                                              //                       BoxShape.circle,
                                              //                   color:
                                              //                       paymentSelected ==
                                              //                               2
                                              //                           ? theme.lightModeColor.prColor250
                                              //                           : null,
                                              //                 ),
                                              //               ),
                                              //             ),
                                              //           ],
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ],
                                              // ),
                                            ],
                                          ),
                                          // Padding(
                                          //   padding:
                                          //       const EdgeInsets.only(
                                          //         top: 10.0,
                                          //       ),
                                          //   child: Row(
                                          //     mainAxisAlignment:
                                          //         MainAxisAlignment
                                          //             .center,
                                          //     spacing: 5,
                                          //     children: [
                                          //       Expanded(
                                          //         child: MoneyTextfield(
                                          //           onChanged: (
                                          //             value,
                                          //           ) {
                                          //             if ((double.tryParse(
                                          //                       value.replaceAll(
                                          //                         ',',
                                          //                         '',
                                          //                       ),
                                          //                     ) ??
                                          //                     0) <
                                          //                 returnWaybillProvider().getWaybillPaymentBalance(
                                          //                   waybill,
                                          //                 )) {
                                          //               setState(() {
                                          //                 paymentSelected =
                                          //                     1;
                                          //               });
                                          //             }
                                          //             if ((double.tryParse(
                                          //                       value.replaceAll(
                                          //                         ',',
                                          //                         '',
                                          //                       ),
                                          //                     ) ??
                                          //                     0) >=
                                          //                 returnWaybillProvider().getWaybillPaymentBalance(
                                          //                   waybill,
                                          //                 )) {
                                          //               paymentController.text = returnWaybillProvider()
                                          //                   .getWaybillPaymentBalance(
                                          //                     waybill,
                                          //                   )
                                          //                   .toStringAsFixed(0);
                                          //               setState(() {
                                          //                 paymentSelected =
                                          //                     2;
                                          //               });
                                          //             }
                                          //           },
                                          //           showTitle:
                                          //               false,
                                          //           title:
                                          //               'Amount',
                                          //           hint:
                                          //               'Enter Amount',
                                          //           controller:
                                          //               paymentController,
                                          //           theme:
                                          //               theme,
                                          //           focusNode:
                                          //               paymentNode,
                                          //         ),
                                          //       ),
                                          //       Ink(
                                          //         decoration: BoxDecoration(
                                          //           borderRadius:
                                          //               BorderRadius.circular(
                                          //                 2,
                                          //               ),

                                          //           gradient:
                                          //               theme.lightModeColor.prGradient,
                                          //         ),
                                          //         child: InkWell(
                                          //           onTap: () {
                                          //             if (paymentController.text.isNotEmpty &&
                                          //                 paymentController.text !=
                                          //                     '0' &&
                                          //                 !isLoading) {
                                          //               showDialog(
                                          //                 context:
                                          //                     context,
                                          //                 builder: (
                                          //                   confirmDialog,
                                          //                 ) {
                                          //                   return ConfirmationAlert(
                                          //                     theme:
                                          //                         theme,
                                          //                     message:
                                          //                         'You are about to pay for an waybill. Are you sure you want to proceed?',
                                          //                     title:
                                          //                         'Make Payment',
                                          //                     action: () async {
                                          //                       Navigator.of(
                                          //                         confirmDialog,
                                          //                       ).pop();
                                          //                       setState(
                                          //                         () {
                                          //                           isLoading =
                                          //                               true;
                                          //                         },
                                          //                       );
                                          //                       var tempWaybill =
                                          //                           waybill.copyWith();
                                          //                       tempWaybill.waybillPayments.add(
                                          //                         WaybillPayments(
                                          //                           uuid:
                                          //                               uuidGen(),
                                          //                           waybillId:
                                          //                               waybill.uuid!,
                                          //                           createdAt:
                                          //                               DateTime.now(),
                                          //                           amount:
                                          //                               double.tryParse(
                                          //                                 paymentController.text.replaceAll(
                                          //                                   ',',
                                          //                                   '',
                                          //                                 ),
                                          //                               ) ??
                                          //                               0,
                                          //                           userId:
                                          //                               currentUser().userId!,
                                          //                           staffName:
                                          //                               currentUser().name,
                                          //                           paymentMethod:
                                          //                               'Cash',
                                          //                         ),
                                          //                       );

                                          //                       var res = await returnWaybillProvider().updateWaybill(
                                          //                         tempWaybill,
                                          //                       );

                                          //                       if (res ==
                                          //                           null) {
                                          //                         setState(
                                          //                           () {
                                          //                             isLoading =
                                          //                                 false;
                                          //                           },
                                          //                         );
                                          //                         showDialog(
                                          //                           // ignore: use_build_context_synchronously
                                          //                           context:
                                          //                               context,
                                          //                           builder: (
                                          //                             popDialog,
                                          //                           ) {
                                          //                             return InfoAlert(
                                          //                               theme:
                                          //                                   theme,
                                          //                               message:
                                          //                                   'An Error Occoured while making this payment. Please try again.',
                                          //                               title:
                                          //                                   'An Error Occoured',
                                          //                             );
                                          //                           },
                                          //                         );
                                          //                       } else {
                                          //                         setState(
                                          //                           () {
                                          //                             isLoading =
                                          //                                 false;
                                          //                           },
                                          //                         );
                                          //                         actionResultDialog(
                                          //                           // ignore: use_build_context_synchronously
                                          //                           context:
                                          //                               context,
                                          //                           isSuccess:
                                          //                               true,
                                          //                           message:
                                          //                               'Payment Successful',
                                          //                         );
                                          //                         if (context.mounted) {
                                          //                           paymentController.clear();
                                          //                         }
                                          //                         setState(
                                          //                           () {
                                          //                             paymentSelected =
                                          //                                 1;
                                          //                           },
                                          //                         );
                                          //                       }
                                          //                     },
                                          //                   );
                                          //                 },
                                          //               );
                                          //             } else {
                                          //               paymentNode.requestFocus();
                                          //             }
                                          //           },
                                          //           child: Container(
                                          //             padding: EdgeInsets.symmetric(
                                          //               vertical:
                                          //                   7.5,
                                          //               horizontal:
                                          //                   25,
                                          //             ),
                                          //             child: Builder(
                                          //               builder: (
                                          //                 context,
                                          //               ) {
                                          //                 if (!isLoading) {
                                          //                   return Text(
                                          //                     style: TextStyle(
                                          //                       fontSize:
                                          //                           theme.mobileTexts.b3.fontSize,
                                          //                       color:
                                          //                           Colors.white,
                                          //                     ),
                                          //                     'Pay',
                                          //                   );
                                          //                 } else {
                                          //                   return SizedBox(
                                          //                     height:
                                          //                         15,
                                          //                     width:
                                          //                         15,
                                          //                     child: CircularProgressIndicator(
                                          //                       color:
                                          //                           Colors.white,
                                          //                       strokeWidth:
                                          //                           2,
                                          //                     ),
                                          //                   );
                                          //                 }
                                          //               },
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          // SizedBox(
                                          //   height: 5,
                                          // ),
                                          // Divider(
                                          //   color:
                                          //       Colors
                                          //           .grey
                                          //           .shade200,
                                          //   height: 10,
                                          // ),
                                          // SizedBox(
                                          //   height: 5,
                                          // ),
                                          // Row(
                                          //   children: [
                                          //     Text(
                                          //       style: TextStyle(
                                          //         fontSize:
                                          //             theme
                                          //                 .mobileTexts
                                          //                 .b3
                                          //                 .fontSize,
                                          //         fontWeight:
                                          //             FontWeight
                                          //                 .bold,
                                          //       ),
                                          //       'Payment Records',
                                          //     ),
                                          //   ],
                                          // ),
                                          // Divider(
                                          //   color:
                                          //       Colors
                                          //           .grey
                                          //           .shade200,
                                          //   height: 10,
                                          // ),
                                          // Container(
                                          //   padding:
                                          //       EdgeInsets.symmetric(
                                          //         horizontal:
                                          //             10,
                                          //         vertical:
                                          //             10,
                                          //       ),
                                          //   decoration: BoxDecoration(
                                          //     borderRadius:
                                          //         BorderRadius.circular(
                                          //           5,
                                          //         ),
                                          //     border: Border.all(
                                          //       color:
                                          //           Colors
                                          //               .grey
                                          //               .shade200,
                                          //     ),
                                          //   ),
                                          //   child: Builder(
                                          //     builder: (
                                          //       context,
                                          //     ) {
                                          //       if (waybill
                                          //           .waybillPayments
                                          //           .isEmpty) {
                                          //         return SizedBox(
                                          //           height:
                                          //               100,
                                          //           child: Center(
                                          //             child: Column(
                                          //               spacing:
                                          //                   5,
                                          //               mainAxisAlignment:
                                          //                   MainAxisAlignment.center,
                                          //               children: [
                                          //                 Container(
                                          //                   padding: EdgeInsets.all(
                                          //                     15,
                                          //                   ),
                                          //                   decoration: BoxDecoration(
                                          //                     shape:
                                          //                         BoxShape.circle,
                                          //                     color:
                                          //                         Colors.grey.shade100,
                                          //                   ),
                                          //                   child: Icon(
                                          //                     Icons.clear,
                                          //                     color:
                                          //                         Colors.grey,
                                          //                   ),
                                          //                 ),
                                          //                 Text(
                                          //                   style: TextStyle(
                                          //                     fontSize:
                                          //                         10,
                                          //                     fontWeight:
                                          //                         FontWeight.bold,
                                          //                     color:
                                          //                         Colors.grey.shade600,
                                          //                   ),
                                          //                   'No Records Found',
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //           ),
                                          //         );
                                          //       }
                                          //       return Column(
                                          //         spacing:
                                          //             4,
                                          //         children:
                                          //             waybill
                                          //                 .waybillPayments
                                          //                 .reversed
                                          //                 .map(
                                          //                   (
                                          //                     payment,
                                          //                   ) => WaybillPaymentWidget(
                                          //                     payment:
                                          //                         payment,
                                          //                   ),
                                          //                 )
                                          //                 .toList(),
                                          //       );
                                          //     },
                                          //   ),
                                          // ),
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
