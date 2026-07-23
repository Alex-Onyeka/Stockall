import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/waybill_print_and_download.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/waybills/create_waybill/create_waybill.dart';
import 'package:stockall/pages/waybills/waybill_list/waybill_list.dart';

class WaybillPageDesktop extends StatefulWidget {
  final String waybillUuid;
  const WaybillPageDesktop({
    super.key,
    required this.waybillUuid,
  });

  @override
  State<WaybillPageDesktop> createState() =>
      _WaybillPageDesktopState();
}

class _WaybillPageDesktopState
    extends State<WaybillPageDesktop> {
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
    // List<WaybillItems> waybillItems =
    //     waybill == null ? [] : waybill.items;

    var custs =
        returnCustomers(context).customers
            .where(
              (cust) => cust.uuid == waybill?.customerId,
            )
            .toList();
    TempCustomersClass? customer =
        custs.isNotEmpty ? custs.first : null;
    return Builder(
      builder: (context) {
        if (waybill == null) {
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
                                'Waybill',
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
                                'Customer Name',
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
                                'Waybill',
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
                                customer?.name ??
                                    'Customer Name',
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
                              await returnWaybillProvider()
                                  .loadWaybills(shopId());
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
                                        'You are about to Print This Waybill Receipt. Are you sure you want to Proceed?',
                                    title:
                                        'Print Waybill Receipt',
                                    action: () async {
                                      setState(() {
                                        isPrintLoading =
                                            true;
                                      });
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      if (kIsWeb) {
                                        downloadPdfWebRollWaybill(
                                          waybill: waybill,
                                          filename:
                                              'Stockall_Waybill_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                          context: context,
                                          shop:
                                              returnShopProvider()
                                                  .userShop()!,
                                          printType:
                                              returnShopProvider()
                                                  .userShop()!
                                                  .printType!,
                                        );
                                      } else {
                                        await generateAndPreviewPdfRollWaybill(
                                          waybill: waybill,
                                          printerType:
                                              returnShopProvider()
                                                  .userShop()!
                                                  .printType ??
                                              1,
                                          context: context,

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
                                            downloadPdfWebWaybill(
                                              waybill:
                                                  waybill,
                                              filename:
                                                  'Stockall_Waybill_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                              context:
                                                  context,
                                            );
                                          }
                                          if (!kIsWeb) {
                                            await generateAndPreviewPdfWaybill(
                                              waybill:
                                                  waybill,
                                              context:
                                                  context,
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
                                        'You are about to edit this waybill. Are you sure you want to proceed?',
                                    title: 'Edit Invoice',
                                    action: () {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return CreateWaybill(
                                              waybill:
                                                  waybill,
                                            );
                                          },
                                        ),
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
                                  return ConfirmationAlert(
                                    theme: theme,
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
                                      var res =
                                          await returnWaybillProvider()
                                              .deleteWaybill(
                                                waybill,
                                                updateInventory,
                                                true,
                                              );
                                      if (res == 1) {
                                        await returnWaybillProvider()
                                            .loadWaybills(
                                              shopId(),
                                            );
                                      }
                                      await actionResultDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
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
                                          context.mounted) {
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
                                          waybill.items
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
                                                //         amount: returnWaybillProvider(
                                                //           context:
                                                //               context,
                                                //         ).getTotalWaybillPayments(
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
                                                //         amount: returnWaybillProvider(
                                                //           context:
                                                //               context,
                                                //         ).getWaybillPaymentBalance(
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
                                                      returnWaybillProvider(
                                                                context:
                                                                    context,
                                                              ).getWaybillStatus(waybill) ==
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
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  color:
                                                      returnWaybillProvider(
                                                                context:
                                                                    context,
                                                              ).getWaybillStatus(waybill) ==
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
                                                  customer?.name ??
                                                      'Customer Name',
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
                                                  customer?.phone ??
                                                      'Customer Phone',
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible:
                                                  customer?.email !=
                                                      null &&
                                                  customer!
                                                      .email
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
                                                    customer?.email ??
                                                        'Customer Email',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  customer?.address !=
                                                      null &&
                                                  customer
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
                                                      customer?.address !=
                                                                  null &&
                                                              customer?.address?.isNotEmpty ==
                                                                  true
                                                          ? "${customer?.address} | ${customer?.city ?? "City"} | ${customer?.state ?? "State"} | ${customer?.country ?? 'Country'}"
                                                          : 'Customer Address',
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
                                  // Row(
                                  //   mainAxisAlignment:
                                  //       MainAxisAlignment
                                  //           .spaceBetween,
                                  //   spacing: 4,
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
                                  //       'Make Payment',
                                  //     ),
                                  //     Row(
                                  //       spacing: 5,
                                  //       children: [
                                  //         InkWell( mouseCursor: SystemMouseCursors.click,
                                  //           onTap: () {
                                  //             selectPayment(
                                  //               value: 1,
                                  //               waybill:
                                  //                   waybill,
                                  //             );
                                  //           },
                                  //           child: Padding(
                                  //             padding:
                                  //                 const EdgeInsets.all(
                                  //                   4,
                                  //                 ),
                                  //             child: Row(
                                  //               spacing: 4,
                                  //               children: [
                                  //                 Text(
                                  //                   style: TextStyle(
                                  //                     fontSize:
                                  //                         theme.mobileTexts.b4.fontSize,
                                  //                     fontWeight:
                                  //                         paymentSelected ==
                                  //                                 1
                                  //                             ? FontWeight.bold
                                  //                             : null,
                                  //                   ),
                                  //                   'Part',
                                  //                 ),
                                  //                 Container(
                                  //                   padding:
                                  //                       EdgeInsets.all(
                                  //                         1.5,
                                  //                       ),
                                  //                   decoration: BoxDecoration(
                                  //                     shape:
                                  //                         BoxShape.circle,
                                  //                     border: Border.all(
                                  //                       color:
                                  //                           Colors.grey.shade400,
                                  //                     ),
                                  //                   ),
                                  //                   child: Container(
                                  //                     padding:
                                  //                         EdgeInsets.all(
                                  //                           3,
                                  //                         ),
                                  //                     decoration: BoxDecoration(
                                  //                       shape:
                                  //                           BoxShape.circle,
                                  //                       color:
                                  //                           paymentSelected ==
                                  //                                   1
                                  //                               ? theme.lightModeColor.prColor250
                                  //                               : null,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //         InkWell( mouseCursor: SystemMouseCursors.click,
                                  //           onTap: () {
                                  //             selectPayment(
                                  //               value: 2,
                                  //               waybill:
                                  //                   waybill,
                                  //             );
                                  //           },
                                  //           child: Padding(
                                  //             padding:
                                  //                 const EdgeInsets.all(
                                  //                   4,
                                  //                 ),
                                  //             child: Row(
                                  //               spacing: 4,
                                  //               children: [
                                  //                 Text(
                                  //                   style: TextStyle(
                                  //                     fontSize:
                                  //                         theme.mobileTexts.b4.fontSize,
                                  //                     fontWeight:
                                  //                         paymentSelected ==
                                  //                                 2
                                  //                             ? FontWeight.bold
                                  //                             : null,
                                  //                   ),
                                  //                   'Full',
                                  //                 ),
                                  //                 Container(
                                  //                   padding:
                                  //                       EdgeInsets.all(
                                  //                         1.5,
                                  //                       ),
                                  //                   decoration: BoxDecoration(
                                  //                     shape:
                                  //                         BoxShape.circle,
                                  //                     border: Border.all(
                                  //                       color:
                                  //                           Colors.grey.shade400,
                                  //                     ),
                                  //                   ),
                                  //                   child: Container(
                                  //                     padding:
                                  //                         EdgeInsets.all(
                                  //                           3,
                                  //                         ),
                                  //                     decoration: BoxDecoration(
                                  //                       shape:
                                  //                           BoxShape.circle,
                                  //                       color:
                                  //                           paymentSelected ==
                                  //                                   2
                                  //                               ? theme.lightModeColor.prColor250
                                  //                               : null,
                                  //                     ),
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ],
                                  // ),
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
                                  //                 returnWaybillProvider()
                                  //                     .getWaybillPaymentBalance(
                                  //                       waybill,
                                  //                     )) {
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
                                  //                 returnWaybillProvider()
                                  //                     .getWaybillPaymentBalance(
                                  //                       waybill,
                                  //                     )) {
                                  //               paymentController
                                  //                   .text = returnWaybillProvider()
                                  //                   .getWaybillPaymentBalance(
                                  //                     waybill,
                                  //                   )
                                  //                   .toStringAsFixed(
                                  //                     0,
                                  //                   );
                                  //               setState(() {
                                  //                 paymentSelected =
                                  //                     2;
                                  //               });
                                  //             }
                                  //           },
                                  //           showTitle:
                                  //               false,
                                  //           title: 'Amount',
                                  //           hint:
                                  //               'Enter Amount',
                                  //           controller:
                                  //               paymentController,
                                  //           theme: theme,
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
                                  //               theme
                                  //                   .lightModeColor
                                  //                   .prGradient,
                                  //         ),
                                  //         child: InkWell( mouseCursor: SystemMouseCursors.click,
                                  //           onTap: () {
                                  //             if (paymentController
                                  //                     .text
                                  //                     .isNotEmpty &&
                                  //                 paymentController
                                  //                         .text !=
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
                                  //                       setState(() {
                                  //                         isLoading =
                                  //                             true;
                                  //                       });
                                  //                       var tempWaybill =
                                  //                           waybill.copyWith();
                                  //                       tempWaybill.items.add(
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
                                  //               paymentNode
                                  //                   .requestFocus();
                                  //             }
                                  //           },
                                  //           child: Container(
                                  //             padding:
                                  //                 EdgeInsets.symmetric(
                                  //                   vertical:
                                  //                       7.5,
                                  //                   horizontal:
                                  //                       25,
                                  //                 ),
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
                                  // Divider(
                                  //   color:
                                  //       Colors
                                  //           .grey
                                  //           .shade200,
                                  //   height: 10,
                                  // ),
                                  // SizedBox(height: 5),
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
                                  //       'Item Records',
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
                                  //         horizontal: 10,
                                  //         vertical: 10,
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
                                  //     builder: (context) {
                                  //       if (waybill
                                  //           .items
                                  //           .isEmpty) {
                                  //         return SizedBox(
                                  //           height: 100,
                                  //           child: Center(
                                  //             child: Column(
                                  //               spacing: 5,
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment
                                  //                       .center,
                                  //               children: [
                                  //                 Container(
                                  //                   padding:
                                  //                       EdgeInsets.all(
                                  //                         15,
                                  //                       ),
                                  //                   decoration: BoxDecoration(
                                  //                     shape:
                                  //                         BoxShape.circle,
                                  //                     color:
                                  //                         Colors.grey.shade100,
                                  //                   ),
                                  //                   child: Icon(
                                  //                     Icons
                                  //                         .clear,
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
                                  //         spacing: 8,
                                  //         children:
                                  //             waybill
                                  //                 .items
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
