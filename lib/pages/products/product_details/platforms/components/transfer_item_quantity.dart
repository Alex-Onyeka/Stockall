import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
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
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/components/edit_button.dart';
import 'package:stockall/pages/products/product_details/platforms/components/unit_selection_widget.dart';
import 'package:stockall/services/product_linking_helper.dart';

Future<Object?> transferItemQuantity(
  BuildContext context,
  TempProductClass item,
) {
  return showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return TransferItemQuantityWidget(item: item);
    },
  );
}

class TransferItemQuantityWidget extends StatefulWidget {
  final TempProductClass item;
  const TransferItemQuantityWidget({
    super.key,
    required this.item,
  });

  @override
  State<TransferItemQuantityWidget> createState() =>
      _TransferItemQuantityWidgetState();
}

class _TransferItemQuantityWidgetState
    extends State<TransferItemQuantityWidget> {
  bool isEditQuantityLoading = false;
  final quantityController = TextEditingController();
  String? unitUuid;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final isMobile = screenWidth(context) < mobileScreen;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: GestureDetector(
            onTap:
                () =>
                    FocusManager.instance.primaryFocus
                        ?.unfocus(),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20.0,
                    top: isMobile ? 10 : 40,
                    right: 20,
                    bottom: isMobile ? 20 : 0,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                          isMobile ? 20 : 30,
                        ),
                        margin: EdgeInsets.only(
                          bottom: isMobile ? 20 : 100,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(15),
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
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Transfer ${widget.item.getProductUnit(unitUuid: unitUuid).name} Quantity',
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
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  widget.item.getActualQuantity() ==
                                          null
                                      ? 'Quantity Not Set'
                                      : 'Current Quantity in ${widget.item.getProductUnit(unitUuid: unitUuid).name}: ${formatLargeNumberDouble(widget.item.getProductUnit(unitUuid: unitUuid).getQuantityEquivDivided(index: 1, context: context))}',
                                ),
                                EditCartTextField(
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        quantityController
                                            .text = '0';
                                      });
                                    } else {
                                      var eValue =
                                          double.parse(
                                            quantityController
                                                .text,
                                          );
                                      if (widget.item
                                              .getProductUnit(
                                                unitUuid:
                                                    unitUuid,
                                              )
                                              .getQuantityEquivMultiplied(
                                                index: 1,
                                                newQuantity:
                                                    eValue,
                                              ) >
                                          (widget.item
                                                  .getActualQuantity() ??
                                              0)) {
                                        setState(() {
                                          quantityController
                                              .text = '0';
                                        });
                                      }
                                    }
                                  },
                                  title:
                                      '${widget.item.getProductUnit(unitUuid: unitUuid).name} Quantity',
                                  hint:
                                      'Enter Quantity Amount',
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
                              productionItem: null,
                              product: widget.item,
                              setUnitUuid: (uuid) {
                                setState(() {
                                  unitUuid = uuid;
                                });
                                if (widget.item
                                        .getProductUnit(
                                          unitUuid:
                                              unitUuid,
                                        )
                                        .getQuantityEquivMultiplied(
                                          index: 1,
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
                                    (widget.item
                                            .getActualQuantity() ??
                                        0)) {
                                  quantityController.text =
                                      '0';
                                }
                              },
                              theme: theme,
                              unitUuid: unitUuid,
                            ),

                            // SizedBox(height: 15),
                            MainButtonP(
                              themeProvider: theme,
                              action: () {
                                var firstContext = context;
                                if (widget.item
                                            .getProductUnit(
                                              unitUuid:
                                                  unitUuid,
                                            )
                                            .getQuantityEquivMultiplied(
                                              index: 1,
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
                                        (widget.item
                                                .getActualQuantity() ??
                                            0) &&
                                    quantityController
                                        .text
                                        .isNotEmpty &&
                                    quantityController
                                            .text !=
                                        '0') {
                                  if (returnShopProvider()
                                          .userShop()
                                          ?.manageDepartments ==
                                      true) {
                                    if (returnShopProvider()
                                            .userShops
                                            .length >
                                        1) {
                                      transferItemAction(
                                        unitUuid: unitUuid,
                                        mainItem:
                                            widget.item,
                                        enteredValue:
                                            (double.tryParse(
                                                  quantityController
                                                      .text,
                                                ) ??
                                                0),
                                        firstContext:
                                            firstContext,
                                        loadingAction: (
                                          value,
                                        ) {
                                          setState(() {
                                            isEditQuantityLoading =
                                                value;
                                          });
                                        },
                                      );
                                    } else {
                                      selectDepartmentProducts(
                                        unitUuid: unitUuid,
                                        secondContext: null,
                                        firstContext:
                                            firstContext,
                                        enteredValue:
                                            (double.tryParse(
                                                  quantityController
                                                      .text,
                                                ) ??
                                                0),
                                        mainItem:
                                            widget.item,
                                        loadingAction: (
                                          value,
                                        ) {
                                          setState(() {
                                            isEditQuantityLoading =
                                                value;
                                          });
                                        },
                                      );
                                    }
                                  } else {
                                    bool isOnline =
                                        returnConnectivityProvider()
                                            .isConnected;
                                    if (!isOnline) {
                                      showDialog(
                                        context: context,
                                        builder: (
                                          errorContext,
                                        ) {
                                          return InfoAlert(
                                            theme: theme,
                                            message:
                                                'You Can Only Transfer Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                                            title:
                                                'No Internet Connection',
                                          );
                                        },
                                      );
                                    } else {
                                      selectShopsProducts(
                                        secondContext: null,
                                        unitUuid: unitUuid,
                                        firstContext:
                                            firstContext,
                                        enteredValue:
                                            (double.tryParse(
                                                  quantityController
                                                      .text,
                                                ) ??
                                                0),
                                        mainItem:
                                            widget.item,
                                        loadingAction: (
                                          value,
                                        ) {
                                          setState(() {
                                            isEditQuantityLoading =
                                                value;
                                          });
                                        },
                                      );
                                    }
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
                                  Navigator.of(
                                    context,
                                  ).pop();
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
        ),
      ),
    );
  }
}

void transferItemAction({
  required BuildContext firstContext,
  required TempProductClass mainItem,
  required String? unitUuid,
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
            Visibility(
              visible:
                  returnShopProvider()
                      .userShop()
                      ?.manageDepartments ==
                  true,
              child: MainButtonTransparent(
                themeProvider: theme,
                constraints: BoxConstraints(),
                text: 'Transfer To Department',
                action: () {
                  selectDepartmentProducts(
                    unitUuid: unitUuid,
                    mainItem: mainItem,
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
                text: 'Transfer To Branch',
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
                              'You Can Only Transfer Items Into Other Stores When you have Internet Connection. Please turn on your internet connection and try again.',
                          title: 'No Internet Connection',
                        );
                      },
                    );
                  } else {
                    selectShopsProducts(
                      unitUuid: unitUuid,
                      secondContext: secondContext,
                      firstContext: firstContext,
                      enteredValue: enteredValue,
                      mainItem: mainItem,
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

void selectDepartmentProducts({
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required TempProductClass mainItem,
  required String? unitUuid,
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
                    selectItemInADepartmentProducts(
                      secondContext: secondContext,
                      firstContext: firstContext,
                      mainItem: mainItem,
                      thirdContext: thirdContext,
                      loadingAction: loadingAction,
                      department: selectedDept,
                      enteredValue: enteredValue,
                      unitUuid: unitUuid,
                    );
                  }
                },
                widget: SizedBox(
                  height:
                      screenWidth(statefulContext) <
                              mobileScreen
                          ? (screenHeight(statefulContext) *
                                  0.45)
                              .clamp(180.0, 420.0)
                          : (screenHeight(statefulContext) -
                              270),
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

void selectItemInADepartmentProducts({
  required BuildContext thirdContext,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required String? unitUuid,
  required TempProductClass mainItem,
  required Function(bool value) loadingAction,
  DepartmentClass? department,
  required double enteredValue,
}) {
  var theme = returnTheme(thirdContext, listen: false);
  GeneralSettingsAuthAction().manageDeparmtmentsAction(
    context: thirdContext,
    action: () {
      final searchController = TextEditingController();
      final deptProducts = returnData()
          .productListMain
          .where((item) =>
              (department != null ? item.departmentUuid == department.uuid : true) &&
              item.uuid != mainItem.uuid)
          .toList();
      TempProductClass? selectedItem = ProductLinkingHelper.resolveLinkedProduct(
        sourceProduct: mainItem,
        destinationProducts: deptProducts,
      );
      showDialog(
        context: thirdContext,
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
                              'You are about to perform an item quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                          title: 'Transfer item Quantity',
                          action: () async {
                            loadingAction(true);
                            TempProductClass oldProduct =
                                selectedItem!;
                            TempProductClass newProduct =
                                oldProduct.copyWith();
                            newProduct.quantity =
                                ((newProduct
                                        .getActualQuantity() ??
                                    0) +
                                mainItem
                                    .getProductUnit(
                                      unitUuid: unitUuid,
                                    )
                                    .getQuantityEquivMultiplied(
                                      index: 1,
                                      newQuantity:
                                          enteredValue,
                                    )) /
                                newProduct.dimensionArea();
                            ItemHistory
                            itemHistory = ItemHistory(
                              event:
                                  ItemHistoryEventClass
                                      .transferedIn,
                              isManaged:
                                  newProduct.isManaged,
                              source:
                                  ItemHistoryEventClass
                                      .departmentSource,
                              destination:
                                  ItemHistoryEventClass
                                      .productDestination,
                              shopId: shopId(),
                              isIncreased: true,
                              departmentName:
                                  newProduct.departmentName,
                              departmentUuid:
                                  newProduct.departmentUuid,
                              desc:
                                  'Item Quantity Received From Transfer - From Item Name: ${mainItem.name}. Department Name: ${returnDepartmentProvider().currentDepartment()?.name ?? 'Department Not Set'}.',
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
                                                  .getActualQuantity() ??
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
                                                  .getActualQuantity() ??
                                              0),
                                    ),
                              ),
                              quantityChange: enteredValue,
                              staffId: currentUser().userId,
                              staffName: currentUser().name,
                              unit:
                                  mainItem
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
                                  quantityChange: newProduct
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .getQuantityEquivMultiplied(
                                        index: 1,
                                        newQuantity:
                                            enteredValue,
                                      ),
                                  isIncrement: true,
                                  itemHistory: itemHistory,
                                );

                            TempProductClass newProduct2 =
                                mainItem.copyWith();
                            newProduct2.quantity =
                                (((newProduct2
                                            .getActualQuantity() ??
                                        0) -
                                    newProduct2
                                        .getProductUnit(
                                          unitUuid:
                                              unitUuid,
                                        )
                                        .getQuantityEquivMultiplied(
                                          index: 1,
                                          newQuantity:
                                              enteredValue,
                                        ))) /
                                newProduct2.dimensionArea();
                            ItemHistory
                            itemHistory2 = ItemHistory(
                              event:
                                  ItemHistoryEventClass
                                      .transferedOut,
                              isManaged:
                                  oldProduct.isManaged,
                              source:
                                  ItemHistoryEventClass
                                      .productSource,
                              destination:
                                  ItemHistoryEventClass
                                      .departmentDestination,
                              shopId: shopId(),
                              isIncreased: false,
                              desc:
                                  'Item Quantity Transfered To - Item Name: ${oldProduct.name}, Department Name: ${department?.name ?? 'Department Not Set'}.',
                              title: 'Transfered Out',
                              createdAt: DateTime.now(),
                              itemUuid: newProduct2.uuid,
                              itemName: newProduct2.name,
                              newValue: formatLargeNumberDouble(
                                mainItem
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 1,
                                      newQuantity:
                                          (newProduct2
                                                  .getActualQuantity() ??
                                              0),
                                    ),
                              ),
                              oldValue: formatLargeNumberDouble(
                                mainItem
                                    .getProductUnit()
                                    .getQuantityEquivDivided(
                                      index: 1,
                                      newQuantity:
                                          (mainItem
                                                  .getActualQuantity() ??
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
                            var res2 = await returnData()
                                .updateProduct(
                                  product: newProduct2,
                                  isQuantityUpdate: true,
                                  includeQuantity: true,
                                  quantityChange: newProduct2
                                      .getProductUnit(
                                        unitUuid: unitUuid,
                                      )
                                      .getQuantityEquivMultiplied(
                                        index: 1,
                                        newQuantity:
                                            enteredValue,
                                      ),
                                  isIncrement: false,
                                  itemHistory: itemHistory2,
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
                                        'An error occoured while Transferring Item Quantity. Please try again.',
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
                  height:
                      screenWidth(statefulContext) <
                              mobileScreen
                          ? (screenHeight(statefulContext) *
                                  0.45)
                              .clamp(180.0, 420.0)
                          : (screenHeight(statefulContext) -
                              270),
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
                                              mainItem.uuid,
                                    )
                                    .isEmpty) {
                                  return SizedBox(
                                    height: 400,
                                    child: EmptyWidgetDisplayOnly(
                                      title:
                                          'No Item Found',
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
                                                      mainItem
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

void selectShopsProducts({
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required TempProductClass mainItem,
  required String? unitUuid,
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
                selectItemInAShop(
                  unitUuid: unitUuid,
                  firstContext: firstContext,
                  secondContext: secondContext,
                  thirdContext: thirdContext,
                  mainItem: mainItem,
                  loadingAction: loadingAction,
                  enteredValue: enteredValue,
                  shop: selectedShop!,
                );
              }
            },
            widget: SizedBox(
              height:
                  screenWidth(statefulContext) <
                          mobileScreen
                      ? (screenHeight(statefulContext) *
                              0.45)
                          .clamp(180.0, 420.0)
                      : (screenHeight(statefulContext) -
                          270),
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

void selectItemInAShop({
  required BuildContext thirdContext,
  required BuildContext? secondContext,
  required BuildContext firstContext,
  required TempProductClass mainItem,
  required Function(bool value) loadingAction,
  required TempShopClass shop,
  required double enteredValue,
  required String? unitUuid,
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
                          'You are about to perform an item quantity Transfer. Please note that this action can not be reversed. Are you sure you want to proceed?',
                      title: 'Transfer item Quantity',
                      action: () async {
                        loadingAction(true);
                        TempProductClass oldProduct =
                            selectedItem!;
                        TempProductClass newProduct =
                            oldProduct.copyWith();
                        newProduct.quantity =
                            ((newProduct
                                    .getActualQuantity() ??
                                0) +
                            mainItem
                                .getProductUnit(
                                  unitUuid: unitUuid,
                                )
                                .getQuantityEquivMultiplied(
                                  index: 1,
                                  newQuantity: enteredValue,
                                )) /
                            newProduct.dimensionArea();
                        ItemHistory
                        itemHistory = ItemHistory(
                          event:
                              ItemHistoryEventClass
                                  .transferedIn,
                          isManaged: oldProduct.isManaged,
                          source:
                              ItemHistoryEventClass
                                  .branchStoreSource,
                          destination:
                              ItemHistoryEventClass
                                  .productDestination,
                          desc:
                              'Item Quantity Received From Transfer - From Item Name: ${mainItem.name}. Shop Name: ${returnShopProvider().userShop()?.name}.',
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
                                              .getActualQuantity() ??
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
                                              .getActualQuantity() ??
                                          0),
                                ),
                          ),
                          quantityChange: enteredValue,
                          staffId: currentUser().userId,
                          staffName: currentUser().name,
                          unit:
                              mainItem
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
                              itemHistory: itemHistory,
                            );

                        TempProductClass newProduct2 =
                            mainItem.copyWith();
                        newProduct2.quantity =
                            (((newProduct2
                                        .getActualQuantity() ??
                                    0) -
                                newProduct2
                                    .getProductUnit(
                                      unitUuid: unitUuid,
                                    )
                                    .getQuantityEquivMultiplied(
                                      index: 1,
                                      newQuantity:
                                          enteredValue,
                                    ))) /
                            newProduct2.dimensionArea();
                        ItemHistory
                        itemHistory2 = ItemHistory(
                          event:
                              ItemHistoryEventClass
                                  .transferedOut,
                          isManaged: oldProduct.isManaged,
                          source:
                              ItemHistoryEventClass
                                  .productSource,
                          destination:
                              ItemHistoryEventClass
                                  .branchStoreDestination,
                          shopId: shopId(),
                          isIncreased: false,
                          desc:
                              'Item Quantity Transfered To - Item Name: ${oldProduct.name}, Shop Name: ${shop.name}.',
                          title: 'Transfered Out',
                          createdAt: DateTime.now(),
                          itemUuid: newProduct2.uuid,
                          itemName: newProduct2.name,
                          newValue: formatLargeNumberDouble(
                            newProduct2
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  newQuantity:
                                      (newProduct2
                                              .getActualQuantity() ??
                                          0),
                                ),
                          ),
                          oldValue: formatLargeNumberDouble(
                            mainItem
                                .getProductUnit()
                                .getQuantityEquivDivided(
                                  index: 1,
                                  newQuantity:
                                      (mainItem
                                              .getActualQuantity() ??
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
                              mainItem
                                  .getProductUnit()
                                  .name,
                        );
                        var res2 = await returnData()
                            .updateProduct(
                              product: newProduct2,
                              isQuantityUpdate: true,
                              includeQuantity: true,
                              quantityChange: newProduct2
                                  .getProductUnit(
                                    unitUuid: unitUuid,
                                  )
                                  .getQuantityEquivDivided(
                                    index: 1,
                                    newQuantity:
                                        enteredValue,
                                  ),
                              isIncrement: false,
                              itemHistory: itemHistory2,
                            );
                        if (res == null || res2 == null) {
                          if (mainItem.transferedProductId == null ||
                              mainItem.transferedProductId!.isEmpty) {
                            await ProductLinkingHelper.linkProducts(
                              sourceProduct: mainItem,
                              targetProduct: oldProduct,
                            );
                          }
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
                          if (mainItem.transferedProductId == null ||
                              mainItem.transferedProductId!.isEmpty) {
                            await ProductLinkingHelper.linkProducts(
                              sourceProduct: mainItem,
                              targetProduct: oldProduct,
                            );
                          }
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
                  screenWidth(statefulContext) <
                          mobileScreen
                      ? (screenHeight(statefulContext) *
                              0.45)
                          .clamp(180.0, 420.0)
                      : (screenHeight(statefulContext) -
                          270),
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
                          final allShopProducts = snapshot.data ?? [];
                          final autoLinked = ProductLinkingHelper.resolveLinkedProduct(
                            sourceProduct: mainItem,
                            destinationProducts: allShopProducts,
                          );
                          if (selectedItem == null && autoLinked != null) {
                            selectedItem = autoLinked;
                          }
                          List<TempProductClass> products =
                              allShopProducts
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
                                            mainItem.uuid,
                                  )
                                  .toList();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (autoLinked != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.link_rounded,
                                          color: Colors.green.shade700,
                                          size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Auto-Selected Linked Destination',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade900,
                                              ),
                                            ),
                                            Text(
                                              '${autoLinked.name} (${shop.name})',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                  if (products.isEmpty) {
                                    return SizedBox(
                                      height: 400,
                                      child: EmptyWidgetDisplayOnly(
                                        title:
                                            'No Item Found',
                                        subText:
                                            'You have not added any item under this Shop.',
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
                                                                '${item.getProductUnit().getQuantityEquivDivided(index: 1, product: item)} ${item.getProductUnit().name}',
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
