import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/add_material/add_material.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/transfer_materials_quantity.dart';
import 'package:stockall/pages/production/materials_page/materials_details/platforms/components/update_material_quantity.dart';
import 'package:stockall/pages/production/materials_page/materials_item_history_page/materials_item_history_page.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class MaterialsDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String materialUuid;
  const MaterialsDetailsMobile({
    super.key,
    required this.theme,
    required this.materialUuid,
  });

  @override
  State<MaterialsDetailsMobile> createState() =>
      _MaterialsDetailsMobileState();
}

class _MaterialsDetailsMobileState
    extends State<MaterialsDetailsMobile> {
  late Future<MaterialClass> materialFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;
  TextEditingController costController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController qttyPerUnitController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    quantityController.dispose();
    qttyPerUnitController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final shopI = returnShopProvider().userShop()!.shopId!;
    List<MaterialClass>? materialList =
        returnMaterialsProvider().materialListMain
            .where(
              (material) =>
                  material.uuid == widget.materialUuid,
            )
            .toList();
    if (materialList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading...'),
      );
    } else {
      MaterialClass material = materialList.first;
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
              widget: Visibility(
                visible: !isStoreKeeper(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 15.0,
                  ),
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return MaterialsItemHistoryPage(
                              materialsItemUuid:
                                  widget.materialUuid,
                              fromMaterialsItemDetails:
                                  true,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        right: 15,
                        left: 15,
                        top: 5,
                        bottom: 5,
                      ),
                      decoration: BoxDecoration(),
                      child: Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'History',
                          ),
                          Icon(
                            size: 15,
                            Icons.receipt_long_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
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
                                material.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor200,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Date Created: ${formatDateTime(material.createdAt ?? DateTime.now())}',
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  Visibility(
                                    visible: authorization(
                                      authorized:
                                          Authorizations()
                                              .manageCostPrice,
                                    ),
                                    child: Expanded(
                                      child: TabContainerMobile(
                                        isMoney: true,
                                        text: 'Cost Price',
                                        price:
                                            material
                                                .costPrice,
                                        theme: widget.theme,
                                        backGround:
                                            const Color.fromARGB(
                                              11,
                                              15,
                                              4,
                                              114,
                                            ),
                                        border:
                                            const Color.fromARGB(
                                              32,
                                              45,
                                              3,
                                              255,
                                            ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .updateMaterials,
                                ),
                                child: SizedBox(height: 10),
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .updateMaterials,
                                ),
                                child: EditButton(
                                  theme: widget.theme,
                                  action: () {
                                    updatePriceAction(
                                      material: material,
                                    );
                                  },
                                  text: 'Edit Price',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        // spacing: 15,
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Expanded(
                                            child: TabContainerMobile(
                                              isMoney:
                                                  false,
                                              text:
                                                  material.unit !=
                                                          'Others'
                                                      ? ' Qtty Of ${material.unit}'
                                                      : 'Unit Qtty',
                                              price:
                                                  material
                                                      .quantity ??
                                                  0,
                                              theme:
                                                  widget
                                                      .theme,
                                              backGround:
                                                  material.isManaged
                                                      ? (material.quantity ??
                                                                  0) >
                                                              (material.lowQtty ??
                                                                  10)
                                                          ? const Color.fromARGB(
                                                            18,
                                                            2,
                                                            163,
                                                            31,
                                                          )
                                                          : const Color.fromARGB(
                                                            15,
                                                            207,
                                                            6,
                                                            29,
                                                          )
                                                      : const Color.fromARGB(
                                                        48,
                                                        158,
                                                        158,
                                                        158,
                                                      ),
                                              border:
                                                  material.isManaged
                                                      ? (material.quantity ??
                                                                  0) >
                                                              (material.lowQtty ??
                                                                  10)
                                                          ? const Color.fromARGB(
                                                            63,
                                                            2,
                                                            163,
                                                            31,
                                                          )
                                                          : const Color.fromARGB(
                                                            57,
                                                            176,
                                                            4,
                                                            30,
                                                          )
                                                      : const Color.fromARGB(
                                                        45,
                                                        158,
                                                        158,
                                                        158,
                                                      ),
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                shop(
                                                  context,
                                                )?.useGroupUnit ==
                                                true,
                                            child: SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                shop(
                                                  context,
                                                )?.useGroupUnit ==
                                                true,
                                            child: Expanded(
                                              child: TabContainerMobile(
                                                isMoney:
                                                    false,
                                                text:
                                                    material.groupUnit !=
                                                                null &&
                                                            material.groupUnit !=
                                                                'Others'
                                                        ? ' Qtty Of ${material.groupUnit}'
                                                        : 'Group Qtty',
                                                price: returnMaterialsProvider(
                                                  context:
                                                      context,
                                                ).returnGroupQuantityValue(
                                                  material,
                                                ),
                                                theme:
                                                    widget
                                                        .theme,
                                                backGround:
                                                    material.isManaged
                                                        ? (material.quantity ??
                                                                    0) >
                                                                (material.lowQtty ??
                                                                    10)
                                                            ? const Color.fromARGB(
                                                              18,
                                                              2,
                                                              163,
                                                              31,
                                                            )
                                                            : const Color.fromARGB(
                                                              15,
                                                              207,
                                                              6,
                                                              29,
                                                            )
                                                        : const Color.fromARGB(
                                                          48,
                                                          158,
                                                          158,
                                                          158,
                                                        ),
                                                border:
                                                    material.isManaged
                                                        ? (material.quantity ??
                                                                    0) >
                                                                (material.lowQtty ??
                                                                    10)
                                                            ? const Color.fromARGB(
                                                              63,
                                                              2,
                                                              163,
                                                              31,
                                                            )
                                                            : const Color.fromARGB(
                                                              57,
                                                              176,
                                                              4,
                                                              30,
                                                            )
                                                        : const Color.fromARGB(
                                                          45,
                                                          158,
                                                          158,
                                                          158,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateMaterials,
                                            ) &&
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateItemQuantity,
                                            ),
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateMaterials,
                                            ) &&
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateItemQuantity,
                                            ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: EditButton(
                                                theme:
                                                    widget
                                                        .theme,
                                                action: () {
                                                  updateMaterialQuantity(
                                                    context,
                                                    material,
                                                  );
                                                },
                                                text:
                                                    'Edit Unit Qtty',
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
                          SizedBox(height: 20),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
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
                                ),
                                'Other Details',
                              ),
                            ],
                          ),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
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
                                        'Manage this Item?',
                                      ),
                                      InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap: () {
                                          ItemsAuthAction().allowStockallToManageItemAction(
                                            context:
                                                context,
                                            action: () {
                                              if (authorization(
                                                authorized:
                                                    Authorizations()
                                                        .updateMaterials,
                                              )) {
                                                var materialsProvider =
                                                    returnMaterialsProvider();
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    confirmDialog,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          widget.theme,
                                                      message:
                                                          material.isManaged
                                                              ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                                                              : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                                                      title:
                                                          'Proceed with Action?',
                                                      action: () async {
                                                        Navigator.of(
                                                          confirmDialog,
                                                        ).pop();
                                                        setState(() {
                                                          isLoading =
                                                              true;
                                                        });
                                                        await materialsProvider.updateMaterial(
                                                          materialsItemHistory:
                                                              null,
                                                          includeQuantity:
                                                              false,
                                                          isIncrement:
                                                              null,
                                                          isQuantityUpdate:
                                                              false,
                                                          quantityChange:
                                                              null,
                                                          material: MaterialClass(
                                                            categories:
                                                                material.categories,
                                                            departmentName:
                                                                material.departmentName,
                                                            departmentUuid:
                                                                material.departmentUuid,
                                                            groupUnit:
                                                                material.groupUnit,
                                                            qttyPerGroup:
                                                                material.qttyPerGroup,
                                                            updatedAt:
                                                                DateTime.now(),
                                                            isManaged:
                                                                material.isManaged
                                                                    ? false
                                                                    : true,
                                                            name:
                                                                material.name,
                                                            unit:
                                                                material.unit,
                                                            costPrice:
                                                                material.costPrice,
                                                            quantity:
                                                                !material.isManaged &&
                                                                        material.quantity ==
                                                                            null
                                                                    ? 0
                                                                    : material.quantity,
                                                            shopId:
                                                                material.shopId,
                                                            barcode:
                                                                material.barcode,
                                                            // categoryUuid:
                                                            //     material.categoryUuid,
                                                            createdAt:
                                                                material.createdAt,
                                                            expiryDate:
                                                                material.expiryDate,
                                                            lowQtty:
                                                                material.lowQtty,
                                                            sizeType:
                                                                material.sizeType,
                                                            uuid:
                                                                material.uuid,
                                                          ),
                                                          oldMaterial:
                                                              material,
                                                        );
                                                        setState(() {
                                                          isLoading =
                                                              false;
                                                        });
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          );
                                        },
                                        child: SubWrapper(
                                          isVisible:
                                              !ItemsAuthAction()
                                                  .allowStockallToManageItemAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: Container(
                                            width: 50,
                                            padding:
                                                EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      5,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    20,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    material.isManaged
                                                        ? widget.theme.lightModeColor.prColor250
                                                        : Colors.grey,
                                              ),
                                              color:
                                                  material.isManaged
                                                      ? widget
                                                          .theme
                                                          .lightModeColor
                                                          .prColor250
                                                      : Colors
                                                          .grey
                                                          .shade200,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  material.isManaged
                                                      ? MainAxisAlignment
                                                          .end
                                                      : MainAxisAlignment
                                                          .start,
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    color:
                                                        material.isManaged
                                                            ? Colors.white
                                                            : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      material.expiryDate !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        material.expiryDate !=
                                                null
                                            ? getDayDifference(
                                                      material.expiryDate ??
                                                          DateTime.now(),
                                                    ) >=
                                                    1
                                                ? formatDateTime(
                                                  material.expiryDate ??
                                                      DateTime.now(),
                                                )
                                                : 'Item Expired'
                                            : 'Not Set',
                                    text: 'Expiry Date',
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      returnShopProvider()
                                          .userShop()
                                          ?.useGroupUnit ==
                                      true,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        material.qttyPerGroup !=
                                                null
                                            ? formatLargeNumberDouble(
                                              (material
                                                      .qttyPerGroup ??
                                                  0),
                                            )
                                            : 'Not Set',
                                    text: 'Qtty Per Group',
                                  ),
                                ),

                                // BottomInfoSection(
                                //   theme: widget.theme,
                                //   mainText:
                                //       material.barcode ??
                                //       'Not Set',
                                //   text: 'Barcode',
                                //   onClick: () {
                                //     if (authorization(
                                //       authorized:
                                //           Authorizations()
                                //               .updateMaterials,
                                //     )) {
                                //       // ItemsAuthAction().generateBarcodeAction(
                                //       //   context: context,
                                //       //   action: () {
                                //       //     returnMaterialsProvider()
                                //       //         .addToBarcodeGenerationList(
                                //       //           MaterialBarcode(
                                //       //             material:
                                //       //                 material,
                                //       //             number: 1,
                                //       //           ),
                                //       //         );
                                //       //     showDialog(
                                //       //       context:
                                //       //           context,
                                //       //       builder: (
                                //       //         firstContext,
                                //       //       ) {
                                //       //         return ConfirmationAlert(
                                //       //           theme:
                                //       //               widget
                                //       //                   .theme,
                                //       //           message:
                                //       //               'You are about to regenrate and print the barcode of this item, are you sure you want to proceed?',
                                //       //           actionButtonText:
                                //       //               'Generate',
                                //       //           title:
                                //       //               'Regenerate and Print Barcode?',
                                //       //           action: () async {
                                //       //             Navigator.of(
                                //       //               firstContext,
                                //       //             ).pop();
                                //       //             setState(() {
                                //       //               isLoading =
                                //       //                   true;
                                //       //             });
                                //       //             generateBarcodeAndPrint(
                                //       //               context,
                                //       //               returnMaterialsProvider()
                                //       //                   .barcodeGenerationList,
                                //       //               false,
                                //       //             ).then((
                                //       //               _,
                                //       //             ) {
                                //       //               returnMaterialsProvider()
                                //       //                   .clearBarcodeGenerationList();
                                //       //               setState(() {
                                //       //                 isLoading =
                                //       //                     false;
                                //       //               });
                                //       //             });

                                //       //             await mainLocalLog(
                                //       //               'Generate Clicked',
                                //       //             );
                                //       //           },
                                //       //         );
                                //       //       },
                                //       //     );
                                //       //   },
                                //       // );
                                //     }
                                //   },
                                //   setBarcodeAction:
                                //       material.barcode ==
                                //               null
                                //           ? () {
                                //             if (authorization(
                                //               authorized:
                                //                   Authorizations()
                                //                       .updateMaterials,
                                //             )) {
                                //               // ItemsAuthAction().generateBarcodeAction(
                                //               //   context:
                                //               //       context,
                                //               //   action: () {
                                //               //     returnMaterialsProvider().addToBarcodeGenerationList(
                                //               //       MaterialBarcode(
                                //               //         material:
                                //               //             material,
                                //               //         number:
                                //               //             1,
                                //               //       ),
                                //               //     );
                                //               //     generateBarcodeAndPrint(
                                //               //       context,
                                //               //       returnMaterialsProvider()
                                //               //           .barcodeGenerationList,
                                //               //       false,
                                //               //     );
                                //               //   },
                                //               // );
                                //             }
                                //           }
                                //           : null,
                                //   actionText:
                                //       material.barcode ==
                                //               null
                                //           ? 'Create Barcode'
                                //           : null,
                                // ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      '${material.unit.substring(0, 1).toUpperCase()}${material.unit.substring(1)}',
                                  text: 'Unit',
                                ),
                                Visibility(
                                  visible:
                                      material.sizeType !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        material.sizeType ??
                                        'Not Set',
                                    text: 'Size Type',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      "(${material.categories?.length ?? 0}) Category(s)",
                                  text: 'Categories',
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      (material.lowQtty ??
                                              10)
                                          .toString(),
                                  text:
                                      'Low Quantity Limit',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 5,
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .transferMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Transfer',
                            action: () {
                              transferMaterialsQuantity(
                                context,
                                material,
                              );
                            },
                            theme: returnTheme(context),
                            icon: Icons.rotate_left_rounded,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .deleteMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Delete',
                            action: () {
                              final safeContext = context;
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  var provider =
                                      returnMaterialsProvider();
                                  return ConfirmationAlert(
                                    theme: returnTheme(
                                      context,
                                    ),
                                    message:
                                        'Are you sure you want to proceed with action?',
                                    title: 'Are you sure?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();

                                      setState(() {
                                        isLoading = true;
                                      });
                                      MaterialsItemHistory
                                      materialsItemHistory = MaterialsItemHistory(
                                        shopId: shopId(),
                                        title:
                                            'Item Deleted',
                                        quantityChange: 0,
                                        newValue:
                                            (material.quantity ??
                                                    0)
                                                .toString(),
                                        desc:
                                            'Materials Item Deleted Now',
                                        isIncreased: false,
                                        oldValue:
                                            (material.quantity ??
                                                    0)
                                                .toString(),
                                      );
                                      await provider
                                          .deleteMaterialMain(
                                            materialsItemHistory:
                                                materialsItemHistory,
                                            material:
                                                material,
                                          );
                                      setState(() {
                                        isLoading = false;
                                        showSuccess = true;
                                      });
                                      Future.delayed(
                                        Duration(
                                          seconds: 1,
                                        ),
                                        () {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            theme: returnTheme(context),
                            icon:
                                Icons
                                    .delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .updateMaterials,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Edit',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddMaterial(
                                      material: material,
                                    );
                                  },
                                ),
                              ).then((context) {
                                setState(() {});
                              });
                            },
                            theme: returnTheme(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Updating'),
          ),
        ],
      );
    }
  }

  void updatePriceAction({
    required MaterialClass material,
  }) {
    setState(() {
      costController.text = material.costPrice.toString();
    });
    bool isEditPriceLoading = false;
    showGeneralDialog(
      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return StatefulBuilder(
          builder:
              (context, setState) => Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap:
                      () =>
                          FocusManager.instance.primaryFocus
                              ?.unfocus(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30.0,
                        top: 40,
                        right: 30,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: IconButton(
                                  mouseCursor:
                                      SystemMouseCursors
                                          .click,
                                  onPressed: () {},
                                  icon: Icon(Icons.clear),
                                ),
                              ),
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
                                'Edit Prices',
                              ),
                              Builder(
                                builder: (context) {
                                  if (isEditPriceLoading ==
                                      true) {
                                    return SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        color:
                                            widget
                                                .theme
                                                .lightModeColor
                                                .secColor200,
                                      ),
                                    );
                                  } else {
                                    return IconButton(
                                      mouseCursor:
                                          SystemMouseCursors
                                              .click,
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                      icon: Icon(
                                        Icons.clear,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            children: [
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .manageCostPrice,
                                ),
                                child: MoneyTextfield(
                                  title: 'Cost Price',
                                  hint: 'Enter Cost Price',
                                  controller:
                                      costController,
                                  theme: widget.theme,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          MainButtonP(
                            themeProvider: widget.theme,
                            action: () {
                              final safeContext = context;
                              if (isEditPriceLoading ==
                                  false) {
                                showDialog(
                                  context: safeContext,
                                  builder: (confirmDialog) {
                                    return ConfirmationAlert(
                                      theme: widget.theme,
                                      message:
                                          'Are you sure you want to proceed?',
                                      title: 'Proceed?',
                                      action: () async {
                                        final materialsProvider =
                                            returnMaterialsProvider();
                                        Navigator.of(
                                          confirmDialog,
                                        ).pop();

                                        setState(() {
                                          isEditPriceLoading =
                                              true;
                                        });
                                        await materialsProvider.updateMaterial(
                                          materialsItemHistory:
                                              null,
                                          includeQuantity:
                                              false,
                                          isIncrement: null,
                                          isQuantityUpdate:
                                              false,
                                          quantityChange:
                                              null,
                                          material: MaterialClass(
                                            categories:
                                                material
                                                    .categories,
                                            departmentName:
                                                material
                                                    .departmentName,
                                            departmentUuid:
                                                material
                                                    .departmentUuid,
                                            groupUnit:
                                                material
                                                    .groupUnit,
                                            qttyPerGroup:
                                                material
                                                    .qttyPerGroup,
                                            updatedAt:
                                                DateTime.now(),
                                            isManaged:
                                                material
                                                    .isManaged,
                                            uuid:
                                                material
                                                    .uuid,
                                            name:
                                                material
                                                    .name,
                                            unit:
                                                material
                                                    .unit,
                                            costPrice:
                                                double.tryParse(
                                                  costController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                ) ??
                                                0,
                                            quantity:
                                                material
                                                    .quantity,
                                            shopId:
                                                material
                                                    .shopId,
                                            barcode:
                                                material
                                                    .barcode,
                                            // categoryUuid:
                                            //     material
                                            //         .categoryUuid,
                                            createdAt:
                                                material
                                                    .createdAt,
                                            expiryDate:
                                                material
                                                    .expiryDate,
                                            lowQtty:
                                                material
                                                    .lowQtty,
                                            sizeType:
                                                material
                                                    .sizeType,
                                          ),
                                          oldMaterial:
                                              material,
                                        );
                                        if (safeContext
                                            .mounted) {
                                          Navigator.of(
                                            safeContext,
                                          ).pop();
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                );
                              }
                            },
                            text: 'Update Price',
                          ),
                          SizedBox(height: 15),
                          Material(
                            color: Colors.transparent,
                            child: EditButton(
                              text: 'Cancel',
                              action: () {
                                Navigator.of(context).pop();
                              },
                              theme: widget.theme,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }
}

class EditButton extends StatelessWidget {
  final String text;
  final Function() action;
  final ThemeProvider theme;
  final IconData? icon;
  final Color? color;

  const EditButton({
    super.key,
    required this.text,
    required this.action,
    required this.theme,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),

          child: Center(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: theme.lightModeColor.prColor300,
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  text,
                ),
                Icon(
                  size: 18,
                  color:
                      color ??
                      theme.lightModeColor.prColor300,
                  icon ?? Icons.edit_note_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabContainerMobile extends StatelessWidget {
  const TabContainerMobile({
    super.key,
    required this.theme,
    required this.backGround,
    required this.border,
    required this.price,
    required this.text,
    required this.isMoney,
    this.isDiscount,
  });
  final Color backGround;
  final Color border;
  final double price;
  final ThemeProvider theme;
  final String text;
  final bool isMoney;
  final bool? isDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backGround,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                text,
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                '${isMoney ? currencySymbol(context: context) : ''}${isMoney
                    ? formatLargeNumberDouble(price)
                    : authorization(authorized: Authorizations().viewItemQuantity)
                    ? formatLargeNumberDouble(price)
                    : 'Restricted'}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
