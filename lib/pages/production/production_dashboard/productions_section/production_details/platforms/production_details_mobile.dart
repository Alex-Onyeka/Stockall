import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_details/platforms/production_details_desktop.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';

class ProductionDetailsMobile extends StatefulWidget {
  final String productionRecordUuid;
  const ProductionDetailsMobile({
    super.key,
    required this.productionRecordUuid,
  });

  @override
  State<ProductionDetailsMobile> createState() =>
      _ProductionDetailsMobileState();
}

class _ProductionDetailsMobileState
    extends State<ProductionDetailsMobile> {
  bool isLoading = false;
  bool isDeleteLoading = false;
  bool isPrintLoading = false;
  bool isDownloadLoading = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<ProductionRecordMaterials> materials =
        returnProductionRecordsProvider(context: context)
            .returnAllProductionRecordMaterials(
              productionRecords: null,
              recordUuids: [widget.productionRecordUuid],
            )
            .toList();
    var productions =
        returnProductionRecordsProvider(context: context)
            .productionRecords
            .where(
              (productionRecord) =>
                  productionRecord.uuid ==
                  widget.productionRecordUuid,
            )
            .toList();

    ProductionRecord? productionRecord =
        productions.isNotEmpty ? productions.first : null;
    return Builder(
      builder: (context) {
        if (productionRecord == null) {
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
                                  'Production Record',
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
                                  'Production Item Name',
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
                                // PopupMenuItem(
                                //   height: 35,
                                //   onTap: () {},
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
                                // PopupMenuItem(
                                //   height: 35,
                                //   onTap: () {},
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
                                //     'Download',
                                //   ),
                                // ),
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
                                  'Production Record',
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
                                  productionRecord
                                          .itemName ??
                                      'Production Item Name',
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
                                // PopupMenuItem(
                                //   height: 35,
                                //   onTap: () {},
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
                                //     kIsWeb
                                //         ? 'Download'
                                //         : 'Share',
                                //   ),
                                // ),
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
                                                    'You are about to delete this Production Record, are you sure you want to proceed?',
                                                title:
                                                    'Delete Production Record?',
                                                action: () async {
                                                  Navigator.of(
                                                    confirmDialog,
                                                  ).pop();
                                                  setState(() {
                                                    isDeleteLoading =
                                                        true;
                                                  });
                                                  var res = await returnProductionRecordsProvider().deleteProductionRecords(
                                                    productionRecord,
                                                    updateInventory,
                                                    true,
                                                  );
                                                  if (res ==
                                                      1) {
                                                    await returnProductionRecordsProvider().getProductionRecords(
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
                                                            return ProductionRecordsList();
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
                                                      productionRecord.staffName ??
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
                                                        theme.mobileTexts.b3.fontSize,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  'Item',
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
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    productionRecord.itemName ??
                                                        'Item Name',
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 5,
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
                                                        '[ ${formatLargeNumberDouble(productionRecord.quantity ?? 0)} ]',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
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
                                                      spacing:
                                                          5,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                      children: [
                                                        Visibility(
                                                          visible:
                                                              productionRecord.departmentId !=
                                                              null,
                                                          child: Row(
                                                            spacing:
                                                                5,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.normal,
                                                                ),
                                                                'Department:',
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b4.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                productionRecord.departmentName ??
                                                                    'Not Set',
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Row(
                                                          spacing:
                                                              5,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.normal,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              'Unit:',
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
                                                              productionRecord.unit ??
                                                                  'Unit Not Set',
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          spacing:
                                                              5,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.normal,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              'Materials Qtty:',
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
                                                              formatLargeNumberDouble(
                                                                materials.length,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          spacing:
                                                              5,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b4.fontSize,
                                                                fontWeight:
                                                                    FontWeight.normal,
                                                                // color:
                                                                //     Colors
                                                                //         .green,
                                                              ),
                                                              'Comment:',
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
                                                              productionRecord.comment ??
                                                                  'Not Set',
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
                                                'Material Usage Records',
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
                                                if (materials
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
