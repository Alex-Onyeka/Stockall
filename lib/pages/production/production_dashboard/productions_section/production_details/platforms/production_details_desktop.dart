import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/components/materials_usage_tile.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';

class ProductionDetailsDesktop extends StatefulWidget {
  final String productionRecordUuid;
  const ProductionDetailsDesktop({
    super.key,
    required this.productionRecordUuid,
  });

  @override
  State<ProductionDetailsDesktop> createState() =>
      _ProductionDetailsDesktopState();
}

class _ProductionDetailsDesktopState
    extends State<ProductionDetailsDesktop> {
  // final paymentController = TextEditingController();

  // FocusNode paymentNode = FocusNode();

  // int paymentSelected = 1;

  // void selectPayment({
  //   required int value,
  //   required ProductionRecord productionRecord,
  // }) {
  //   setState(() {
  //     paymentSelected = value;
  //     if (value == 2) {
  //       paymentController.text =
  //           returnProductionRecordsProvider()
  //               .getProductionPaymentBalance(
  //                 productionRecord,
  //               )
  //               .toString();
  //     } else {
  //       paymentController.clear();
  //       paymentNode.requestFocus();
  //     }
  //   });
  // }

  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<ProductionRecordMaterials> materials =
        returnProductionRecordsProvider(
          context: context,
        ).returnAllProductionRecordMaterials(
          productionRecords: null,
          recordUuids: [widget.productionRecordUuid],
        );
    var purchs =
        returnProductionRecordsProvider(context: context)
            .productionRecords
            .where(
              (productionRecord) =>
                  productionRecord.uuid ==
                  widget.productionRecordUuid,
            )
            .toList();

    ProductionRecord? productionRecord =
        purchs.isNotEmpty ? purchs.first : null;
    return Builder(
      builder: (context) {
        if (productionRecord == null) {
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
                                'Production',
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
                                'Produced Item Name',
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

                          // ActionButtonSmall(
                          //   action: () {},
                          //   text: 'Print',
                          // ),
                          // ActionButtonSmall(
                          //   action: () {},
                          //   text: 'Dowmload',
                          // ),
                          ActionButtonSmall(
                            action: () {},
                            text: 'Edit',
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
                                'Production',
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
                                productionRecord.itemName ??
                                    'Produced Item Name',
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          ActionButtonSmall(
                            isLoading: isLoading,
                            action: () async {
                              await returnProductionRecordsProvider()
                                  .getProductionRecords(
                                    shopId(),
                                  );
                              setState(() {});
                            },
                            text: 'Refresh',
                          ),
                          // ActionButtonSmall(
                          //   isLoading: isPrintLoading,
                          //   action: () {
                          //     // showDialog(
                          //     //   context: context,
                          //     //   builder: (confirmDialog) {
                          //     //     return ConfirmationAlert(
                          //     //       theme: theme,
                          //     //       message:
                          //     //           'You are about to Print This Production Receipt. Are you sure you want to Proceed?',
                          //     //       title:
                          //     //           'Print Production Receipt',
                          //     //       action: () async {
                          //     //         setState(() {
                          //     //           isPrintLoading =
                          //     //               true;
                          //     //         });
                          //     //         Navigator.of(
                          //     //           confirmDialog,
                          //     //         ).pop();
                          //     //         if (kIsWeb) {
                          //     //           downloadPdfWebRollProduction(
                          //     //             productionRecord:
                          //     //                 productionRecord,
                          //     //             filename:
                          //     //                 'Stockall_Production_${DateTime.now().millisecondsSinceEpoch}.pdf',
                          //     //             context: context,
                          //     //             records:
                          //     //                 materials,
                          //     //             shop:
                          //     //                 returnShopProvider()
                          //     //                     .userShop()!,
                          //     //             printType:
                          //     //                 returnShopProvider()
                          //     //                     .userShop()!
                          //     //                     .printType!,
                          //     //           );
                          //     //         } else {
                          //     //           await generateAndPreviewPdfRollProduction(
                          //     //             productionRecord:
                          //     //                 productionRecord,
                          //     //             printerType:
                          //     //                 returnShopProvider()
                          //     //                     .userShop()!
                          //     //                     .printType ??
                          //     //                 1,
                          //     //             context: context,
                          //     //             records:
                          //     //                 materials,

                          //     //             shop:
                          //     //                 returnShopProvider()
                          //     //                     .userShop()!,
                          //     //           );
                          //     //         }
                          //     //         setState(() {
                          //     //           isPrintLoading =
                          //     //               false;
                          //     //         });
                          //     //       },
                          //     //     );
                          //     //   },
                          //     // );
                          //   },
                          //   text: 'Print',
                          // ),
                          // ActionButtonSmall(
                          //   isLoading: isDownloadLoading,
                          //   action: () {
                          //     SalesAuthAction().downloadReceiptAction(
                          //       context: context,
                          //       action: () async {
                          //         // var safeContext = context;

                          //         // showDialog(
                          //         //   context: context,
                          //         //   builder: (
                          //         //     confirmDialog,
                          //         //   ) {
                          //         //     return ConfirmationAlert(
                          //         //       theme: theme,
                          //         //       message:
                          //         //           'You are about to download This productionRecord. Are you sure you want to Proceed?',
                          //         //       title:
                          //         //           'Download Production',
                          //         //       action: () async {
                          //         //         setState(() {
                          //         //           isDownloadLoading =
                          //         //               true;
                          //         //         });
                          //         //         Navigator.of(
                          //         //           confirmDialog,
                          //         //         ).pop();
                          //         //         if (kIsWeb) {
                          //         //           downloadPdfWebProduction(
                          //         //             productionRecord:
                          //         //                 productionRecord,
                          //         //             filename:
                          //         //                 'Stockall_Production_${DateTime.now().millisecondsSinceEpoch}.pdf',
                          //         //             context:
                          //         //                 context,
                          //         //             records:
                          //         //                 materials,
                          //         //           );
                          //         //         }
                          //         //         if (!kIsWeb) {
                          //         //           await generateAndPreviewPdfProduction(
                          //         //             productionRecord:
                          //         //                 productionRecord,
                          //         //             context:
                          //         //                 context,
                          //         //             records:
                          //         //                 materials,
                          //         //           );
                          //         //         }
                          //         //         await Future.delayed(
                          //         //           Duration(
                          //         //             seconds: 1,
                          //         //           ),
                          //         //         );
                          //         //         if (context
                          //         //             .mounted) {
                          //         //           actionResultDialog(
                          //         //             context:
                          //         //                 context,
                          //         //             message:
                          //         //                 'Production Downloaded',
                          //         //             isSuccess:
                          //         //                 true,
                          //         //           );
                          //         //         }
                          //         //         setState(() {
                          //         //           isDownloadLoading =
                          //         //               false;
                          //         //         });
                          //         //       },
                          //         //     );
                          //         //   },
                          //         // );
                          //       },
                          //     );
                          //   },
                          //   text: 'Download',
                          // ),
                          ActionButtonSmall(
                            action: () {
                              // showDialog(
                              //   context: context,
                              //   builder: (confirmDialog) {
                              //     return ConfirmationAlert(
                              //       theme: theme,
                              //       message:
                              //           'You are about to edit this productionRecord. Are you sure you want to proceed?',
                              //       title:
                              //           'Edit Production',
                              //       action: () {
                              //         Navigator.of(
                              //           confirmDialog,
                              //         ).pop();
                              //         returnProductionActionProvider()
                              //             .editProduction(
                              //               productionRecord:
                              //                   productionRecord,
                              //               context:
                              //                   context,
                              //             );
                              //       },
                              //     );
                              //   },
                              // );
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
                                              'You are about to delete this Production Receipt, are you sure you want to proceed?',
                                          title:
                                              'Delete Production Receipt?',
                                          action: () async {
                                            Navigator.of(
                                              confirmDialog,
                                            ).pop();
                                            setState(() {
                                              isDeleteLoading =
                                                  true;
                                            });
                                            var res = await returnProductionRecordsProvider()
                                                .deleteProductionRecords(
                                                  productionRecord,
                                                  updateInventory,
                                                  true,
                                                );
                                            if (res == 1) {
                                              await returnProductionRecordsProvider()
                                                  .getProductionRecords(
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
                                                      return ProductionRecordsList();
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
                                                  'Update Item Quantity?',
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
                                                productionRecord
                                                        .staffName ??
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
                                                      "${formatDateTime(productionRecord.createdAt ?? DateTime.now())}  |  ${formatTime(productionRecord.createdAt ?? DateTime.now())}",
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
                                            'Item',
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
                                            'Quantity',
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            top: 15.0,
                                          ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
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
                                              productionRecord
                                                      .itemName ??
                                                  'Item Name',
                                            ),
                                          ),
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
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  '[ ${formatLargeNumberDouble(productionRecord.quantity ?? 0)} ]',
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                                                            theme.mobileTexts.b3.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      'Total Cost:',
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
                                                        amount: returnProductionRecordsProvider().getTotalCostForProduction(
                                                          productionRecords: [
                                                            productionRecord,
                                                          ],
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
                                      spacing: 5,
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Visibility(
                                          visible:
                                              productionRecord
                                                  .departmentId !=
                                              null,
                                          child: Row(
                                            spacing: 5,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .normal,
                                                ),
                                                'Department:',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                productionRecord
                                                        .departmentName ??
                                                    'Not Set',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              'Unit:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              productionRecord
                                                      .unit ??
                                                  'Unit Not Set',
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              'Materials Qtty:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              formatLargeNumberDouble(
                                                materials
                                                    .length,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              'Comment:',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                // color:
                                                //     Colors
                                                //         .green,
                                              ),
                                              productionRecord
                                                      .comment ??
                                                  'Not Set',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),

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
                                        'Materials Used',
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
                                        if (materials
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
                                              materials
                                                  .map(
                                                    (
                                                      productionMaterial,
                                                    ) => ProductionMaterialWidget(
                                                      productionMaterial:
                                                          productionMaterial,
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

class ProductionMaterialWidget extends StatefulWidget {
  const ProductionMaterialWidget({
    super.key,
    required this.productionMaterial,
  });

  final ProductionRecordMaterials productionMaterial;

  @override
  State<ProductionMaterialWidget> createState() =>
      _ProductionMaterialWidgetState();
}

class _ProductionMaterialWidgetState
    extends State<ProductionMaterialWidget> {
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
                        widget
                            .productionMaterial
                            .materialName,
                      ),
                    ],
                  ),
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  formatLargeNumberDouble(
                    widget.productionMaterial.quantity,
                  ),
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
                              formatMoneyBig(
                                amount:
                                    widget
                                        .productionMaterial
                                        .getTotalCost(),
                                context: context,
                              ),
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
                          widget
                                  .productionMaterial
                                  .createdAt ??
                              DateTime.now(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Divider(thickness: 0.5),
                  SizedBox(height: 3),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    // spacing: 5,
                    children: [
                      ProductionPaymentButtonWidget(
                        action: () {
                          showDialog(
                            context: context,
                            builder: (firstContext) {
                              return DialogTemplate(
                                theme: theme,
                                message:
                                    'View Item History Details',
                                title: 'Usage Details',
                                action: () {},
                                showBottomActionButtons:
                                    false,
                                widget: SizedBox(
                                  height:
                                      screenHeight(
                                        context,
                                      ) -
                                      200,
                                  child: MaterialUsageDetailsWidget(
                                    productionRecordMaterials:
                                        widget
                                            .productionMaterial,
                                    fromDetails: true,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        title: 'View  More',
                        isLoading: isPrinting,
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

class ProductionPaymentButtonWidget
    extends StatelessWidget {
  const ProductionPaymentButtonWidget({
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
