import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';

Future<Object?> transferProductionItemQuantity(
  BuildContext context,
  ProductionItem productionItem,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return TransferProductionItemQuantityWidget(
        productionItem: productionItem,
      );
    },
  );
}

class TransferProductionItemQuantityWidget
    extends StatefulWidget {
  final ProductionItem productionItem;
  const TransferProductionItemQuantityWidget({
    super.key,
    required this.productionItem,
  });

  @override
  State<TransferProductionItemQuantityWidget>
  createState() =>
      _TransferProductionItemQuantityWidgetState();
}

class _TransferProductionItemQuantityWidgetState
    extends State<TransferProductionItemQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  String? unitUuid;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap:
              () =>
                  FocusManager.instance.primaryFocus
                      ?.unfocus(),
          child: Container(
            decoration: BoxDecoration(color: Colors.white),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                top: 40,
                right: 20,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(30),
                    margin: EdgeInsets.only(bottom: 100),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        15,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(
                            39,
                            4,
                            1,
                            41,
                          ),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    width: 500,
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
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Transfer ${widget.productionItem.getProductUnit(unitUuid: unitUuid).name} Quantity',
                            ),
                            Builder(
                              builder: (context) {
                                if (isEditQuantityLoading ==
                                    true) {
                                  return SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                      strokeWidth: 3,
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
                                      size: 20,
                                      Icons.clear,
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Column(
                          spacing: 20,
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              widget
                                          .productionItem
                                          .quantity ==
                                      null
                                  ? 'Quantity Not Set'
                                  : 'Current Quantity in ${widget.productionItem.getProductUnit(unitUuid: unitUuid).name}: ${formatLargeNumberDouble(widget.productionItem.getProductUnit(unitUuid: unitUuid).getQuantityEquivDivided(index: 2, context: context))}',
                            ),
                            EditCartTextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    quantityController
                                        .text = '0';
                                  });
                                } else {
                                  var eValue = double.parse(
                                    quantityController.text,
                                  );
                                  if (widget.productionItem
                                          .getProductUnit(
                                            unitUuid:
                                                unitUuid,
                                          )
                                          .getQuantityEquivMultiplied(
                                            index: 2,
                                            newQuantity:
                                                eValue,
                                          ) >
                                      (widget
                                              .productionItem
                                              .quantity ??
                                          0)) {
                                    setState(() {
                                      quantityController
                                          .text = '0';
                                    });
                                  }
                                }
                              },
                              title:
                                  '${widget.productionItem.getProductUnit(unitUuid: unitUuid).name} Quantity',
                              hint: 'Enter Quantity Amount',
                              controller:
                                  quantityController,
                              theme: theme,
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        UnitSelectionWidget(
                          storageProduct: null,
                          material: null,
                          productionItem:
                              widget.productionItem,
                          product: null,
                          setUnitUuid: (uuid) {
                            setState(() {
                              unitUuid = uuid;
                            });
                            if (widget.productionItem
                                    .getProductUnit(
                                      unitUuid: unitUuid,
                                    )
                                    .getQuantityEquivMultiplied(
                                      index: 2,
                                      newQuantity:
                                          double.tryParse(
                                            quantityController
                                                .text
                                                .replaceAll(
                                                  ',',
                                                  '',
                                                ),
                                          ) ??
                                          0,
                                    ) >
                                (widget
                                        .productionItem
                                        .quantity ??
                                    0)) {
                              quantityController.text = '0';
                            }
                          },
                          theme: theme,
                          unitUuid: unitUuid,
                        ),

                        SizedBox(height: 15),
                        MainButtonP(
                          themeProvider: theme,
                          action: () {
                            var firstContext = context;
                            if (widget.productionItem
                                        .getProductUnit(
                                          unitUuid:
                                              unitUuid,
                                        )
                                        .getQuantityEquivMultiplied(
                                          index: 2,
                                          newQuantity:
                                              double.tryParse(
                                                quantityController
                                                    .text
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0,
                                        ) <=
                                    (widget
                                            .productionItem
                                            .quantity ??
                                        0) &&
                                quantityController
                                    .text
                                    .isNotEmpty &&
                                quantityController.text !=
                                    '0') {
                              if (returnShopProvider()
                                          .userShop()
                                          ?.manageDepartments ==
                                      false &&
                                  returnShopProvider()
                                          .userShops
                                          .length ==
                                      1) {
                                selectItemInADepartmentsProduction(
                                  unitUuid: unitUuid,
                                  thirdContext: null,
                                  secondContext: null,
                                  firstContext:
                                      firstContext,
                                  mainProductionItem:
                                      widget.productionItem,
                                  enteredValue:
                                      (double.tryParse(
                                            quantityController
                                                .text,
                                          ) ??
                                          0),
                                  loadingAction: (value) {
                                    setState(() {
                                      isEditQuantityLoading =
                                          value;
                                    });
                                  },
                                );
                              } else {
                                transferProductionItemAction(
                                  unitUuid: unitUuid,
                                  mainProductionItem:
                                      widget.productionItem,
                                  enteredValue:
                                      (double.tryParse(
                                            quantityController
                                                .text,
                                          ) ??
                                          0),
                                  firstContext:
                                      firstContext,
                                  loadingAction: (value) {
                                    setState(() {
                                      isEditQuantityLoading =
                                          value;
                                    });
                                  },
                                );
                              }
                            }
                          },
                          text: 'Proceed',
                        ),
                        SizedBox(height: 15),
                        Material(
                          color: Colors.transparent,
                          child: EditButton(
                            text: 'Cancel',
                            action: () {
                              Navigator.of(context).pop();
                            },
                            theme: theme,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void transferProductionItemAction({
  required BuildContext firstContext,
  required String? unitUuid,
  required ProductionItem mainProductionItem,
  required Function(bool value) loadingAction,
  required double enteredValue,
}) {
  var theme = returnTheme(firstContext, listen: false);
  showDialog(
    context: firstContext,
    builder: (secondContext) {
      return DialogTemplate(
        theme: theme,
        message: 'Select the action you want to Perform',
        title: 'Select Action',
        action: () {},
        showBottomActionButtons: false,
        widget: Column(
          spacing: 5,
          children: [
            MainButtonTransparent(
              themeProvider: theme,
              constraints: BoxConstraints(),
              text: 'Transfer To General Sales',
              action: () {
                selectItemInADepartmentsProduction(
                  unitUuid: unitUuid,
                  mainProductionItem: mainProductionItem,
                  firstContext: firstContext,
                  secondContext: secondContext,
                  thirdContext: null,
                  enteredValue: enteredValue,
                  loadingAction: (value) {
                    loadingAction(value);
                  },
                );
              },
            ),

            Visibility(
              visible:
                  returnShopProvider()
                      .userShop()
                      ?.manageDepartments ==
                  true,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Transfer To Department (Sales)',
                action: () {
                  selectDepartmentProductionItems(
                    unitUuid: unitUuid,
                    mainProductionItem: mainProductionItem,
                    firstContext: firstContext,
                    secondContext: secondContext,
                    enteredValue: enteredValue,
                    loadingAction: (value) {
                      loadingAction(value);
                    },
                  );
                },
              ),
            ),
            Visibility(
              visible:
                  returnShopProvider().userShops.length > 1,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Transfer To Branch (Sales)',
                action: () {
                  bool isOnline =
                      returnConnectivityProvider()
                          .isConnected;
                  if (!isOnline) {
                    showDialog(
                      context: firstContext,
                      builder: (errorContext) {
                        return InfoAlert(
                          theme: theme,
                          message:
                              'You Can Only Transfer Production Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                          title: 'No Internet Connection',
                        );
                      },
                    );
                  } else {
                    selectShopsProductionItems(
                      unitUuid: unitUuid,
                      secondContext: secondContext,
                      firstContext: firstContext,
                      enteredValue: enteredValue,
                      mainProductionItem:
                          mainProductionItem,
                      loadingAction: (value) {
                        loadingAction(value);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void selectDepartmentProductionItems({
  required BuildContext? secondContext,
  required String? unitUuid,
  required BuildContext firstContext,
  required ProductionItem mainProductionItem,
  required Function(bool value) loadingAction,
  required double enteredValue,
}) {
  var theme = returnTheme(
    secondContext ?? firstContext,
    listen: false,
  );
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: secondContext ?? firstContext,
    action: () {
      DepartmentClass? selectedDept;
      showDialog(
        context: secondContext ?? firstContext,
        builder: (thirdContext) {
          return StatefulBuilder(
            builder: (statefulContext, setState) {
              return DialogTemplate(
                theme: theme,
                message:
                    'Select a Department From the List Below',
                title: 'Select Department',
                action: () {
                  if (selectedDept != null) {
                    selectItemInADepartmentsProduction(
                      secondContext: secondContext,
                      unitUuid: unitUuid,
                      firstContext: firstContext,
                      mainProductionItem:
                          mainProductionItem,
                      thirdContext: thirdContext,
                      loadingAction: loadingAction,
                      department: selectedDept,
                      enteredValue: enteredValue,
                    );
                  }
                },
                widget: SizedBox(
                  height:
                      screenHeight(statefulContext) - 270,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 10,
                      ),
                      child: Builder(
                        builder: (context) {
                          List<DepartmentClass>
                          departments =
                              returnDepartmentProvider()
                                  .departments
                                  .where(
                                    (dept) =>
                                        dept.uuid !=
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.uuid,
                                  )
                                  .toList();
                          if (departments.isEmpty) {
                            return SizedBox(
                              height: 400,
                              child: EmptyWidgetDisplayOnly(
                                title:
                                    'No Department Found',
                                subText:
                                    'You have not been added to any departments.',
                                theme: theme,
                                height: 30,
                                altAction: () async {
                                  await returnDepartmentProvider()
                                      .getDepartments();
                                  setState(() {});
                                },
                                altActionText: 'Refresh',
                                icon: Icons.clear,
                              ),
                            );
                          } else {
                            return Column(
                              spacing: 5,
                              children:
                                  departments
                                      .map(
                                        (dept) => Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              setState(() {
                                                if (selectedDept
                                                        ?.uuid ==
                                                    dept.uuid) {
                                                  selectedDept =
                                                      null;
                                                } else {
                                                  selectedDept =
                                                      dept;
                                                }
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical:
                                                        9.0,
                                                    horizontal:
                                                        12,
                                                  ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          theme.mobileTexts.b3.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    dept.name,
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.all(
                                                          2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      shape:
                                                          BoxShape.circle,
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(
                                                            5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.circle,
                                                        color:
                                                            selectedDept?.uuid ==
                                                                    dept.uuid
                                                                ? theme.lightModeColor.prColor250
                                                                : Colors.transparent,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}

void selectItemInADepartmentsProduction({
  required BuildContext? thirdContext,
  required String? unitUuid,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required ProductionItem mainProductionItem,
  required Function(bool value) loadingAction,
  DepartmentClass? department,
  required double enteredValue,
}) {
  var theme = returnTheme(
    thirdContext ?? secondContext ?? firstContext,
    listen: false,
  );
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: thirdContext ?? secondContext ?? firstContext,
    action: () {
      final searchController = TextEditingController();
      TempProductClass? selectedItem;
      showDialog(
        context:
            thirdContext ?? secondContext ?? firstContext,
        builder: (fourthContext) {
          return StatefulBuilder(
            builder: (statefulContext, setState) {
              return DialogTemplate(
                theme: theme,
                message:
                    'Select an Item From the List Below',
                title: 'Select Item',
                action: () {
                  if (selectedItem != null) {
                    showDialog(
                      context: fourthContext,
                      builder: (fifthContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to perform an Production Item quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                          title: 'Transfer Item Quantity',
                          action: () async {
                            loadingAction(true);
                            TempProductClass oldProduct =
                                selectedItem!;
                            TempProductClass newProduct =
                                oldProduct.copyWith();
                            newProduct.quantity =
                                (newProduct.quantity ?? 0) +
                                mainProductionItem
                                    .getProductUnit(
                                      unitUuid: unitUuid,
                                    )
                                    .getQuantityEquivMultiplied(
                                      index: 2,
                                      newQuantity:
                                          enteredValue,
                                    );
                            ItemHistory
                            itemHistory = ItemHistory(
                              event:
                                  ItemHistoryEventClass
                                      .transferedIn,
                              source:
                                  ItemHistoryEventClass
                                      .productionSource,
                              isManaged:
                                  newProduct.isManaged,
                              shopId: shopId(),
                              isIncreased: true,
                              departmentName:
                                  newProduct.departmentName,
                              departmentUuid:
                                  newProduct.departmentUuid,
                              desc:
                                  'Item Quantity Received From Transfer - From Production Item Name: ${mainProductionItem.name}. Department Name: ${returnDepartmentProvider().currentDepartment()?.name ?? 'Department Not Set'}.',
                              title: 'Transfered In',
                              createdAt: DateTime.now(),
                              itemUuid: newProduct.uuid,
                              itemName: newProduct.name,
                              newValue: formatLargeNumberDouble(
                                newProduct
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 1,
                                      newQuantity:
                                          (newProduct
                                                  .quantity ??
                                              0),
                                    ),
                              ),
                              oldValue: formatLargeNumberDouble(
                                oldProduct
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 1,
                                      newQuantity:
                                          (oldProduct
                                                  .quantity ??
                                              0),
                                    ),
                              ),
                              quantityChange: enteredValue,
                              staffId: currentUser().userId,
                              staffName: currentUser().name,
                              unit:
                                  mainProductionItem
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .name,
                              primaryUnit:
                                  newProduct
                                      .getProductUnit()
                                      .name,
                            );
                            var res = await returnData()
                                .updateProduct(
                                  product: newProduct,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange:
                                      mainProductionItem
                                          .getProductUnit(
                                            unitUuid:
                                                unitUuid,
                                          )
                                          .getQuantityEquivMultiplied(
                                            index: 2,
                                            newQuantity:
                                                enteredValue,
                                          ),
                                  isIncrement: true,
                                  itemHistory: itemHistory,
                                );

                            ProductionItem newProduct2 =
                                mainProductionItem
                                    .copyWith();
                            newProduct2.quantity =
                                ((newProduct2.quantity ??
                                        0) -
                                    newProduct2
                                        .getProductUnit(
                                          unitUuid:
                                              unitUuid,
                                        )
                                        .getQuantityEquivMultiplied(
                                          index: 2,
                                          newQuantity:
                                              enteredValue,
                                        ));
                            ProductionItemHistory
                            productionItemHistory2 = ProductionItemHistory(
                              event:
                                  ProductionItemHistoryEventClass
                                      .transferedOut,
                              source:
                                  ProductionItemHistoryEventClass
                                      .departmentSource,
                              isManaged:
                                  mainProductionItem
                                      .isManaged,
                              shopId: shopId(),
                              isIncreased: false,
                              desc:
                                  'Production Item Quantity Transfered To - Item Name: ${oldProduct.name}, Department Name: ${department?.name ?? 'Department Not Set'}.',
                              title: 'Transfered Out',
                              createdAt: DateTime.now(),
                              itemUuid: newProduct2.uuid,
                              itemName: newProduct2.name,
                              newValue: formatLargeNumberDouble(
                                mainProductionItem
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 2,
                                      newQuantity:
                                          (newProduct2
                                                  .quantity ??
                                              0),
                                    ),
                              ),
                              oldValue: formatLargeNumberDouble(
                                mainProductionItem
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 2,
                                      newQuantity:
                                          (mainProductionItem
                                                  .quantity ??
                                              0),
                                    ),
                              ),
                              quantityChange: -enteredValue,
                              staffId: currentUser().userId,
                              staffName: currentUser().name,
                              unit:
                                  newProduct2
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .name,
                              primaryUnit:
                                  newProduct2
                                      .getProductUnit()
                                      .name,
                            );
                            var res2 = await returnProductionItemsProvider()
                                .updateProductionItem(
                                  productionItem:
                                      newProduct2,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange: newProduct2
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .getQuantityEquivMultiplied(
                                        index: 2,
                                        newQuantity:
                                            enteredValue,
                                      ),
                                  isIncrement: false,
                                  productionItemHistory:
                                      productionItemHistory2,
                                );
                            if (res == null ||
                                res2 == null) {
                              loadingAction(false);
                              showDialog(
                                // ignore: use_build_context_synchronously
                                context: fifthContext,
                                builder: (errorContext) {
                                  return InfoAlert(
                                    theme: theme,
                                    message:
                                        'An error occoured while Transferring ProductionItem Quantity. Please try again.',
                                    title:
                                        'An Error Occured',
                                  );
                                },
                              );
                            } else {
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                fifthContext,
                              ).pop();
                              // ignore: use_build_context_synchronously
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                fourthContext,
                              ).pop();
                              if (thirdContext != null) {
                                Navigator.of(
                                  // ignore: use_build_context_synchronously
                                  thirdContext,
                                ).pop();
                              }
                              if (secondContext != null) {
                                Navigator.of(
                                  // ignore: use_build_context_synchronously
                                  secondContext,
                                ).pop();
                              }
                              Navigator.of(
                                // ignore: use_build_context_synchronously
                                firstContext,
                              ).pop();
                              loadingAction(false);
                            }
                          },
                        );
                      },
                    );
                  }
                },
                widget: SizedBox(
                  height:
                      screenHeight(statefulContext) - 270,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 400,
                                maxHeight: 40,
                              ),
                              child: GeneralTextfieldOnly(
                                onChanged: (p0) {
                                  setState(() {});
                                },
                                hint: 'Search Name',
                                controller:
                                    searchController,
                                lines: 1,
                                theme: theme,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 10,
                                ),
                            child: Builder(
                              builder: (context) {
                                if (returnData()
                                    .productListMain
                                    .where(
                                      (item) =>
                                          (department !=
                                                  null
                                              ? item.departmentUuid ==
                                                  department
                                                      .uuid
                                              : true) &&
                                          item.name
                                              .toLowerCase()
                                              .contains(
                                                searchController
                                                    .text
                                                    .toLowerCase(),
                                              ) &&
                                          item.uuid !=
                                              mainProductionItem
                                                  .uuid,
                                    )
                                    .isEmpty) {
                                  return SizedBox(
                                    height: 400,
                                    child: EmptyWidgetDisplayOnly(
                                      title:
                                          'No Production Item Found',
                                      subText:
                                          'You have not added to any item under this department.',
                                      theme: theme,
                                      height: 30,
                                      altAction: () async {
                                        await returnData()
                                            .getProducts(
                                              shopId(),
                                            );
                                        setState(() {});
                                      },
                                      altActionText:
                                          'Refresh',
                                      icon: Icons.clear,
                                    ),
                                  );
                                } else {
                                  return Column(
                                    spacing: 5,
                                    children:
                                        returnData()
                                            .productListMain
                                            .where(
                                              (item) =>
                                                  (department !=
                                                          null
                                                      ? item.departmentUuid ==
                                                          department.uuid
                                                      : true) &&
                                                  item.name.toLowerCase().contains(
                                                    searchController
                                                        .text
                                                        .toLowerCase(),
                                                  ) &&
                                                  item.uuid !=
                                                      mainProductionItem
                                                          .uuid,
                                            )
                                            .map(
                                              (
                                                item,
                                              ) => Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: InkWell(
                                                  mouseCursor:
                                                      SystemMouseCursors
                                                          .click,
                                                  onTap: () {
                                                    setState(() {
                                                      if (selectedItem?.uuid ==
                                                          item.uuid) {
                                                        selectedItem =
                                                            null;
                                                      } else {
                                                        selectedItem =
                                                            item;
                                                      }
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical:
                                                          9.0,
                                                      horizontal:
                                                          10,
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b3.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          item.name,
                                                        ),
                                                        Row(
                                                          spacing:
                                                              15,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    theme.mobileTexts.b3.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                              '${item.getProductUnit().getQuantityEquivDivided(index: 1)} ${item.getProductUnit().name}',
                                                            ),
                                                            Container(
                                                              padding: EdgeInsets.all(
                                                                2,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                                border: Border.all(
                                                                  color:
                                                                      Colors.grey,
                                                                ),
                                                              ),
                                                              child: Container(
                                                                padding: EdgeInsets.all(
                                                                  5,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape.circle,
                                                                  color:
                                                                      selectedItem?.uuid ==
                                                                              item.uuid
                                                                          ? theme.lightModeColor.prColor250
                                                                          : Colors.transparent,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
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
              );
            },
          );
        },
      );
    },
  );
}

void selectShopsProductionItems({
  required BuildContext? secondContext,
  required String? unitUuid,
  required BuildContext firstContext,
  required ProductionItem mainProductionItem,
  required Function(bool value) loadingAction,
  required double enteredValue,
}) {
  var theme = returnTheme(
    secondContext ?? firstContext,
    listen: false,
  );
  TempShopClass? selectedShop;
  showDialog(
    context: secondContext ?? firstContext,
    builder: (thirdContext) {
      return StatefulBuilder(
        builder: (statefulContext, setState) {
          return DialogTemplate(
            theme: theme,
            message:
                'Select a Shop Branch From the List Below',
            title: 'Select Shop Branch',
            cancelAction: () {
              Navigator.of(
                secondContext ?? firstContext,
              ).pop();
            },
            action: () {
              if (selectedShop != null) {
                selectItemInAShopProduction(
                  unitUuid: unitUuid,
                  firstContext: firstContext,
                  secondContext: secondContext,
                  thirdContext: thirdContext,
                  mainProductionItem: mainProductionItem,
                  loadingAction: loadingAction,
                  enteredValue: enteredValue,
                  shop: selectedShop!,
                );
              }
            },
            widget: SizedBox(
              height: screenHeight(statefulContext) - 270,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5.0,
                    vertical: 10,
                  ),
                  child: Builder(
                    builder: (context) {
                      if (returnShopProvider().userShops
                          .where(
                            (shop) =>
                                shop.shopId !=
                                returnShopProvider()
                                    .userShop()
                                    ?.shopId,
                          )
                          .isEmpty) {
                        return SizedBox(
                          height: 400,
                          child: EmptyWidgetDisplayOnly(
                            title: 'No Shop Found',
                            subText:
                                'No Shop Branches Was Found.',
                            theme: theme,
                            height: 30,
                            altAction: () async {
                              await returnShopProvider()
                                  .getUserShops();
                              setState(() {});
                            },
                            altActionText: 'Refresh',
                            icon: Icons.clear,
                          ),
                        );
                      } else {
                        return Column(
                          spacing: 5,
                          children:
                              returnShopProvider(
                                    context: context,
                                  ).userShops
                                  .where(
                                    (shop) =>
                                        shop.shopId !=
                                        returnShopProvider()
                                            .userShop()
                                            ?.shopId,
                                  )
                                  .map(
                                    (shop) => Material(
                                      color:
                                          Colors
                                              .transparent,
                                      child: InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap: () {
                                          setState(() {
                                            if (selectedShop
                                                    ?.shopId ==
                                                shop.shopId) {
                                              selectedShop =
                                                  null;
                                            } else {
                                              selectedShop =
                                                  shop;
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    9.0,
                                                horizontal:
                                                    12,
                                              ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
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
                                                shop.name,
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.all(
                                                      2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  shape:
                                                      BoxShape
                                                          .circle,
                                                  border: Border.all(
                                                    color:
                                                        Colors.grey,
                                                  ),
                                                ),
                                                child: Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    color:
                                                        selectedShop?.shopId ==
                                                                shop.shopId
                                                            ? theme.lightModeColor.prColor250
                                                            : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

void selectItemInAShopProduction({
  required BuildContext thirdContext,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required ProductionItem mainProductionItem,
  required String? unitUuid,
  required Function(bool value) loadingAction,
  required TempShopClass shop,
  required double enteredValue,
}) {
  var theme = returnTheme(thirdContext, listen: false);
  final searchController = TextEditingController();
  TempProductClass? selectedItem;
  late Future<List<TempProductClass>> productFuture;
  showDialog(
    context: thirdContext,
    builder: (fourthContext) {
      productFuture = returnData().getProductsForOtherShops(
        shop.shopId!,
      );
      return StatefulBuilder(
        builder: (statefulContext, setState) {
          return DialogTemplate(
            theme: theme,
            message: 'Select an Item From the List Below',
            title: 'Select Item',
            action: () {
              if (selectedItem != null) {
                showDialog(
                  context: fourthContext,
                  builder: (fifthContext) {
                    return ConfirmationAlert(
                      theme: theme,
                      message:
                          'You are about to perform an productionItem quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                      title:
                          'Transfer productionItem Quantity',
                      action: () async {
                        loadingAction(true);
                        TempProductClass oldProduct =
                            selectedItem!;
                        TempProductClass newProduct =
                            oldProduct.copyWith();
                        newProduct.quantity =
                            (newProduct.quantity ?? 0) +
                            mainProductionItem
                                .getProductUnit(
                                  unitUuid: unitUuid,
                                )
                                .getQuantityEquivMultiplied(
                                  index: 2,
                                  newQuantity: enteredValue,
                                );
                        ItemHistory
                        productionItemHistory = ItemHistory(
                          event:
                              ItemHistoryEventClass
                                  .transferedIn,
                          source:
                              ItemHistoryEventClass
                                  .branchStoreSource,
                          isManaged: newProduct.isManaged,
                          desc:
                              'Item Quantity Received From Transfer - From Production Item Name: ${mainProductionItem.name}. Shop Name: ${returnShopProvider().userShop()?.name}.',
                          shopId: shop.shopId!,
                          title: 'Transfered In',
                          isIncreased: true,
                          departmentName:
                              newProduct.departmentName,
                          departmentUuid:
                              newProduct.departmentUuid,
                          createdAt: DateTime.now(),
                          itemUuid: newProduct.uuid,
                          itemName: newProduct.name,
                          newValue: formatLargeNumberDouble(
                            newProduct
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  product: newProduct,
                                  newQuantity:
                                      (newProduct
                                              .quantity ??
                                          0),
                                ),
                          ),
                          oldValue: formatLargeNumberDouble(
                            oldProduct
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  product: oldProduct,
                                  newQuantity:
                                      (oldProduct
                                              .quantity ??
                                          0),
                                ),
                          ),
                          quantityChange: enteredValue,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          unit:
                              mainProductionItem
                                  .getProductUnit(
                                    unitUuid: unitUuid,
                                  )
                                  .name,
                          primaryUnit:
                              newProduct
                                  .getProductUnit()
                                  .name,
                        );
                        var res = await returnData()
                            .updateProductForOtherShops(
                              product: newProduct,
                              itemHistory:
                                  productionItemHistory,
                            );

                        ProductionItem newProduct2 =
                            mainProductionItem.copyWith();
                        newProduct2.quantity =
                            ((newProduct2.quantity ?? 0) -
                                newProduct2
                                    .getProductUnit(
                                      unitUuid: unitUuid,
                                    )
                                    .getQuantityEquivMultiplied(
                                      index: 2,
                                      newQuantity:
                                          enteredValue,
                                    ));
                        ProductionItemHistory
                        productionItemHistory2 = ProductionItemHistory(
                          event:
                              ProductionItemHistoryEventClass
                                  .transferedOut,
                          source:
                              ProductionItemHistoryEventClass
                                  .branchStoreSource,
                          isManaged:
                              mainProductionItem.isManaged,
                          shopId: shopId(),
                          isIncreased: false,
                          desc:
                              'Production Item Quantity Transfered To - Item Name: ${oldProduct.name}, Shop Name: ${shop.name}.',
                          title: 'Transfered Out',
                          createdAt: DateTime.now(),
                          itemUuid: newProduct2.uuid,
                          itemName: newProduct2.name,
                          newValue: formatLargeNumberDouble(
                            newProduct2
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 2,
                                  newQuantity:
                                      (newProduct2
                                              .quantity ??
                                          0),
                                ),
                          ),
                          oldValue: formatLargeNumberDouble(
                            mainProductionItem
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 2,
                                  newQuantity:
                                      (mainProductionItem
                                              .quantity ??
                                          0),
                                ),
                          ),
                          quantityChange: -enteredValue,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          unit:
                              newProduct2
                                  .getProductUnit(
                                    unitUuid: unitUuid,
                                  )
                                  .name,
                          primaryUnit:
                              mainProductionItem
                                  .getProductUnit()
                                  .name,
                        );
                        var res2 =
                            await returnProductionItemsProvider()
                                .updateProductionItem(
                                  productionItem:
                                      newProduct2,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange: newProduct2
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .getQuantityEquivMultiplied(
                                        index: 2,
                                        newQuantity:
                                            enteredValue,
                                      ),
                                  isIncrement: false,
                                  productionItemHistory:
                                      productionItemHistory2,
                                );
                        if (res == null || res2 == null) {
                          loadingAction(false);
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: fifthContext,
                            builder: (errorContext) {
                              return InfoAlert(
                                theme: theme,
                                message:
                                    'An error occoured while Transferring Item Quantity. Please try again.',
                                title: 'An Error Occured',
                              );
                            },
                          );
                        } else {
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            fifthContext,
                          ).pop();
                          // ignore: use_build_context_synchronously
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            fourthContext,
                          ).pop();
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            thirdContext,
                          ).pop();
                          if (secondContext != null) {
                            Navigator.of(
                              // ignore: use_build_context_synchronously
                              secondContext,
                            ).pop();
                          }
                          Navigator.of(
                            // ignore: use_build_context_synchronously
                            firstContext,
                          ).pop();
                          loadingAction(false);
                        }
                      },
                    );
                  },
                );
              }
            },
            widget: SizedBox(
              height: screenHeight(statefulContext) - 270,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 400,
                            maxHeight: 40,
                          ),
                          child: GeneralTextfieldOnly(
                            onChanged: (p0) {
                              setState(() {});
                            },
                            hint: 'Search Name',
                            controller: searchController,
                            lines: 1,
                            theme: theme,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: FutureBuilder(
                      future: productFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: returnCompProvider(
                              context,
                            ).showLoader(
                              message: 'Loading',
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: SizedBox(
                              height: 400,
                              child: EmptyWidgetDisplayOnly(
                                title: 'An Error Occoured',
                                subText:
                                    'An Error Occoured while trying to get items',
                                theme: theme,
                                height: 30,
                                icon: Icons.clear,
                              ),
                            ),
                          );
                        } else {
                          List<TempProductClass> products =
                              (snapshot.data ?? [])
                                  .where(
                                    (item) =>
                                        item.name
                                            .toLowerCase()
                                            .contains(
                                              searchController
                                                  .text
                                                  .toLowerCase(),
                                            ) &&
                                        item.uuid !=
                                            mainProductionItem
                                                .uuid,
                                  )
                                  .toList();
                          return SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                    vertical: 10,
                                  ),
                              child: Builder(
                                builder: (context) {
                                  if (products.isEmpty) {
                                    return SizedBox(
                                      height: 400,
                                      child: EmptyWidgetDisplayOnly(
                                        title:
                                            'No Item Found',
                                        subText:
                                            'You have not added to any Item under this Shop.',
                                        theme: theme,
                                        height: 30,
                                        icon: Icons.clear,
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      spacing: 5,
                                      children:
                                          products
                                              .map(
                                                (
                                                  item,
                                                ) => Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  child: InkWell(
                                                    mouseCursor:
                                                        SystemMouseCursors.click,
                                                    onTap: () {
                                                      setState(() {
                                                        if (selectedItem?.uuid ==
                                                            item.uuid) {
                                                          selectedItem =
                                                              null;
                                                        } else {
                                                          selectedItem =
                                                              item;
                                                        }
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                        vertical:
                                                            9.0,
                                                        horizontal:
                                                            10,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            item.name,
                                                          ),
                                                          Row(
                                                            spacing:
                                                                15,
                                                            children: [
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      theme.mobileTexts.b3.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                '${item.quantity ?? 0}',
                                                              ),
                                                              Container(
                                                                padding: EdgeInsets.all(
                                                                  2,
                                                                ),
                                                                decoration: BoxDecoration(
                                                                  shape:
                                                                      BoxShape.circle,
                                                                  border: Border.all(
                                                                    color:
                                                                        Colors.grey,
                                                                  ),
                                                                ),
                                                                child: Container(
                                                                  padding: EdgeInsets.all(
                                                                    5,
                                                                  ),
                                                                  decoration: BoxDecoration(
                                                                    shape:
                                                                        BoxShape.circle,
                                                                    color:
                                                                        selectedItem?.uuid ==
                                                                                item.uuid
                                                                            ? theme.lightModeColor.prColor250
                                                                            : Colors.transparent,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
