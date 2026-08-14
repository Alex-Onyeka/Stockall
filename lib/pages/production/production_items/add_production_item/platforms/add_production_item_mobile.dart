import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class AddProductionItemMobile extends StatefulWidget {
  final ProductionItem? productionItem;
  final TextEditingController costController;
  final TextEditingController nameController;
  final TextEditingController qttyPerGroupController;
  const AddProductionItemMobile({
    super.key,
    required this.costController,
    required this.nameController,
    required this.qttyPerGroupController,
    this.productionItem,
  });

  @override
  State<AddProductionItemMobile> createState() =>
      _AddProductionItemMobileState();
}

class _AddProductionItemMobileState
    extends State<AddProductionItemMobile> {
  bool isLoading = false;
  bool showSuccess = false;
  bool expand = false;
  //
  //
  //
  //

  bool isOpenUnit = false;
  bool isOpenGroupUnit = false;
  bool isSizedTypeOpen = false;

  TextEditingController expiryDateC =
      TextEditingController();
  //
  //
  //
  bool isOpen = false;

  void checkFields() async {
    if (widget.nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Item Name Must be set before item can be created',
            title: 'Empty Input',
          );
        },
      );
    } else {
      final safeContext = context;
      var samePro = returnProductionItemsProvider()
          .productionItemList()
          .where(
            (pr) =>
                pr.name.toLowerCase() ==
                widget.nameController.text.toLowerCase(),
          );
      showDialog(
        context: safeContext,
        builder: (confirmDialog) {
          return ConfirmationAlert(
            theme: returnTheme(safeContext),
            message:
                samePro.isNotEmpty
                    ? 'Item with the name  ${widget.nameController.text.toUpperCase()}  already Exists in your Inventory. Are you sure you want to proceed to create a duplicate Item?'
                    : 'You are about to add a new item to your stock, are you sure you want to proceed?',
            title:
                samePro.isNotEmpty
                    ? 'Item Already Exists'
                    : 'Are you sure?',
            action: () async {
              Navigator.of(confirmDialog).pop();

              setState(() {
                isLoading = true;
              });

              final productionItemProvider =
                  returnProductionItemsProvider();
              final dataProvider = returnData();

              ProductionItemHistory productionItemHistory =
                  ProductionItemHistory(
                    shopId: shopId(),
                    title: 'Item Created',
                    quantityChange: 0,
                    newValue: '0',
                    desc: 'Production Item Created Now',
                    isIncreased: true,
                    oldValue: '0',
                  );

              await productionItemProvider
                  .createProductionItem(
                    productionItemHistory:
                        productionItemHistory,
                    productionItem: ProductionItem(
                      useGroupUnit:
                          dataProvider.useGroupUnit,
                      categories:
                          dataProvider.selectedCategories
                              .toList(),
                      isManaged: dataProvider.isManaged,
                      name:
                          widget.nameController.text.trim(),
                      unit:
                          dataProvider.selectedUnit ??
                          'Unit(s)',
                      groupUnit:
                          dataProvider.selectedGroupUnit ??
                          'Group(s)',
                      qttyPerGroup:
                          widget
                                  .qttyPerGroupController
                                  .text
                                  .isNotEmpty
                              ? double.parse(
                                widget
                                    .qttyPerGroupController
                                    .text
                                    .replaceAll(',', ''),
                              )
                              : null,
                      sizeType: dataProvider.selectedSize,
                      costPrice:
                          widget
                                  .costController
                                  .text
                                  .isNotEmpty
                              ? double.parse(
                                widget.costController.text
                                    .replaceAll(',', ''),
                              )
                              : 0,
                      shopId: userShop!.shopId!,
                      quantity: 0,
                      expiryDate: dataProvider.expiryDate,
                      // categoryUuid:
                      //     dataProvider
                      //         .selectedCategory
                      //         ?.uuid,
                      uuid: createdProductionItemUuid,
                      departmentName:
                          dataProvider.departmentUuid !=
                                  null
                              ? returnDepartmentProvider()
                                  .departments
                                  .firstWhere(
                                    (dept) =>
                                        dept.uuid ==
                                        dataProvider
                                            .departmentUuid,
                                  )
                                  .name
                              : null,
                      departmentUuid:
                          dataProvider.departmentUuid,
                    ),
                  );

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              // Clear data before popping
              if (safeContext.mounted) {
                dataProvider.clearFields();
              }

              Future.delayed(Duration(seconds: 2), () {
                // Pop current screen
                if (safeContext.mounted) {
                  Navigator.of(
                    safeContext,
                  ).pop(); // pop current page
                }
              });
            },
          );
        },
      );
    }
  }

  void updateProductionItem() {
    final safeContext = context;
    showDialog(
      context: safeContext,
      builder: (confirmDialog) {
        var theme = returnTheme(context);
        return ConfirmationAlert(
          theme: theme,
          message:
              'Are you sure you want to proceed with update?',
          title: 'Proceed?',
          action: () async {
            final provider =
                returnProductionItemsProvider();
            final dataProvider = returnData();
            Navigator.of(confirmDialog).pop();

            setState(() {
              isLoading = true;
            });

            var res = await provider.updateProductionItem(
              productionItemHistory: null,
              includeQuantity: false,
              isIncrement: null,
              isQuantityUpdate: false,
              quantityChange: null,
              productionItem: ProductionItem(
                useGroupUnit: dataProvider.useGroupUnit,
                categories:
                    dataProvider.selectedCategories
                        .toList(),
                departmentName:
                    dataProvider.departmentUuid != null
                        ? returnDepartmentProvider()
                            .departments
                            .firstWhere(
                              (dept) =>
                                  dept.uuid ==
                                  dataProvider
                                      .departmentUuid,
                            )
                            .name
                        : null,
                departmentUuid: dataProvider.departmentUuid,
                isManaged: dataProvider.isManaged,
                uuid: widget.productionItem?.uuid,
                name: widget.nameController.text,
                unit: dataProvider.selectedUnit!,
                groupUnit: dataProvider.selectedGroupUnit,
                qttyPerGroup:
                    widget
                            .qttyPerGroupController
                            .text
                            .isNotEmpty
                        ? double.parse(
                          widget.qttyPerGroupController.text
                              .replaceAll(',', ''),
                        )
                        : null,
                costPrice:
                    widget.costController.text.isNotEmpty
                        ? double.parse(
                          widget.costController.text
                              .replaceAll(',', ''),
                        )
                        : 0,
                quantity: widget.productionItem?.quantity,

                shopId: userShop!.shopId!,
                // categoryUuid:
                //     dataProvider.selectedCategory?.uuid,
                createdAt: widget.productionItem!.createdAt,
                expiryDate: dataProvider.expiryDate,
                sizeType: dataProvider.selectedSize,
              ),
              oldProductionItem: widget.productionItem!,
            );
            if (res == null) {
              setState(() {
                isLoading = false;
              });
            } else {
              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              if (safeContext.mounted) {
                dataProvider.clearFields();
              }

              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }
            }
          },
        );
      },
    );
  }

  String? createdProductionItemUuid;

  //
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((context) {
      clearFields();
    });
    if (widget.productionItem == null) {
      setState(() {
        createdProductionItemUuid = uuidGen();
      });
    }
    setShop();
  }

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      if (context.mounted) {
        returnData().clearFields(setIsManaged: false);
      }
      var res = ItemsAuthAction()
          .allowStockallToManageItemAction(
            context: context,
          );
      if (res) {
        returnData().toggleIsManagedTemp(true);
      } else {
        returnData().toggleIsManagedTemp(false);
      }
    });
    if (widget.productionItem != null && context.mounted) {
      returnData().departmentUuid =
          widget.productionItem?.departmentUuid;
      returnData().expiryDate =
          widget.productionItem?.expiryDate;
      widget.nameController.text =
          widget.productionItem!.name;
      widget.costController.text =
          widget.productionItem!.costPrice.toString();

      returnData().isManaged =
          widget.productionItem!.isManaged;
      returnData().useGroupUnit =
          widget.productionItem!.useGroupUnit ?? false;
      returnData().selectUnit(widget.productionItem!.unit);
      returnData().selectGroupUnit(
        unit: widget.productionItem!.groupUnit,
      );
      widget.qttyPerGroupController.text =
          widget.productionItem!.qttyPerGroup != null
              ? widget.productionItem!.qttyPerGroup!
                  .toString()
              : '';
      widget.productionItem!.sizeType != null
          ? returnData().selectSize(
            widget.productionItem!.sizeType!,
          )
          : null;
      returnData().initCategories(
        categories: widget.productionItem?.categories ?? [],
      );
    }
  }

  TempShopClass? userShop;
  void setShop() async {
    await returnShopProvider().getUserShops();

    setState(() {
      userShop = returnShopProvider().userShop();
    });
  }

  @override
  void dispose() {
    super.dispose();
    expiryDateC.dispose();
  }

  //
  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.productionItem != null
                      ? 'Edit Item'
                      : 'New Item',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  widget.productionItem != null
                      ? 'Edit productionItem details'
                      : 'Add a new productionItem to your store.',
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                          ),
                          child: Column(
                            children: [
                              GeneralTextField(
                                theme: theme,
                                hint: 'Enter Item Name',
                                lines: 1,
                                title: 'Item Name',
                                controller:
                                    widget.nameController,
                              ),

                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .manageCostPrice,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: MoneyTextfield(
                                            theme: theme,
                                            hint:
                                                'Enter Real Cost',
                                            title:
                                                'Cost - Price (Optional)',
                                            controller:
                                                widget
                                                    .costController,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Column(
                                children: [
                                  SizedBox(height: 20),
                                  InkWell(
                                    mouseCursor:
                                        SystemMouseCursors
                                            .click,
                                    onTap: () {
                                      returnData()
                                          .toggleIsManaged(
                                            context:
                                                context,
                                          );
                                      FocusManager
                                          .instance
                                          .primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b1
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                'Allow Stockall to Manage Item Quantity?',
                                              ),
                                              Column(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          10,
                                                    ),
                                                    'This controls whether Item quantity is automatically deducted after sales, and notifications are sent when productionItem quantity is low or out of stock.',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Checkbox(
                                          activeColor:
                                              theme
                                                  .lightModeColor
                                                  .secColor100,
                                          value:
                                              returnData(
                                                context:
                                                    context,
                                              ).isManaged,
                                          onChanged: (
                                            value,
                                          ) {
                                            returnData()
                                                .toggleIsManaged(
                                                  context:
                                                      context,
                                                );
                                            FocusManager
                                                .instance
                                                .primaryFocus
                                                ?.unfocus();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              // SizedBox(height: 5),
                              InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setState(() {
                                    expand = !expand;
                                  });
                                },
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 5,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                        ),
                                        expand
                                            ? 'Hide Details'
                                            : 'More Details',
                                      ),
                                      InkWell(
                                        mouseCursor:
                                            SystemMouseCursors
                                                .click,
                                        onTap: () {
                                          setState(() {
                                            expand =
                                                !expand;
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                left: 35.0,
                                                top: 5,
                                                bottom: 5,
                                              ),
                                          child: Row(
                                            children: [
                                              Text(
                                                expand
                                                    ? 'Colapse'
                                                    : 'Expand',
                                              ),
                                              Icon(
                                                expand
                                                    ? Icons
                                                        .keyboard_arrow_up_outlined
                                                    : Icons
                                                        .keyboard_arrow_down,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // SizedBox(height: 5),
                              Divider(),
                              SizedBox(height: 15),
                              Visibility(
                                visible: expand,
                                child: Column(
                                  children: [
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Visibility(
                                          visible:
                                              returnShopProvider()
                                                      .userShop()
                                                      ?.manageDepartments ==
                                                  true &&
                                              authorization(
                                                authorized:
                                                    Authorizations()
                                                        .viewAllDepartments,
                                              ),
                                          child: InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              GeneralSettingsAuthAction().manageDeparmtmentsAction(
                                                context:
                                                    context,
                                                action: () {
                                                  String?
                                                  selectedDept;
                                                  setState(() {
                                                    selectedDept =
                                                        returnData().departmentUuid;
                                                  });
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      firstContext,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder: (
                                                          secondContext,
                                                          setState,
                                                        ) {
                                                          return DialogTemplate(
                                                            theme:
                                                                theme,
                                                            message:
                                                                'Select Department for this Staff',
                                                            title:
                                                                'Select Department(s)',
                                                            action: () {
                                                              returnData().setDepartment(
                                                                selectedDept,
                                                              );
                                                              Navigator.of(
                                                                context,
                                                              ).pop();
                                                            },
                                                            widget: SizedBox(
                                                              height:
                                                                  screenHeight(
                                                                    context,
                                                                  ) -
                                                                  300,
                                                              child: SingleChildScrollView(
                                                                child: Padding(
                                                                  padding: const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        20.0,
                                                                    vertical:
                                                                        15,
                                                                  ),
                                                                  child: Column(
                                                                    spacing:
                                                                        5,
                                                                    children:
                                                                        returnDepartmentProvider().departments
                                                                            .map(
                                                                              (
                                                                                dept,
                                                                              ) => Material(
                                                                                color:
                                                                                    Colors.transparent,
                                                                                child: InkWell(
                                                                                  mouseCursor:
                                                                                      SystemMouseCursors.click,
                                                                                  onTap: () {
                                                                                    setState(
                                                                                      () {
                                                                                        if (selectedDept ==
                                                                                            dept.uuid) {
                                                                                          selectedDept =
                                                                                              null;
                                                                                        } else {
                                                                                          selectedDept =
                                                                                              dept.uuid;
                                                                                        }
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(
                                                                                      vertical:
                                                                                          9.0,
                                                                                      horizontal:
                                                                                          12,
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
                                                                                          dept.name,
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
                                                                                                  selectedDept ==
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
                                            },
                                            child: Column(
                                              mainAxisSize:
                                                  MainAxisSize
                                                      .min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                              spacing: 5,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          theme.mobileTexts.b3.textStyleBold,
                                                      'Set Department',
                                                    ),
                                                  ],
                                                ),
                                                SubWrapper(
                                                  isVisible:
                                                      !GeneralSettingsAuthAction().manageDeparmtmentsAction(
                                                        context:
                                                            context,
                                                      ),
                                                  mainWidget: Container(
                                                    padding: EdgeInsets.symmetric(
                                                      vertical:
                                                          0,
                                                      horizontal:
                                                          5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color:
                                                            returnData().departmentUuid !=
                                                                    null
                                                                ? theme.lightModeColor.prColor300
                                                                : Colors.grey,
                                                        width:
                                                            returnData().departmentUuid !=
                                                                    null
                                                                ? 1.3
                                                                : 1,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            5,
                                                          ),
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  10,
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    returnData().departmentUuid !=
                                                                            null
                                                                        ? theme.mobileTexts.b2.fontSize
                                                                        : theme.mobileTexts.b2.fontSize,
                                                                fontWeight:
                                                                    returnData().departmentUuid !=
                                                                            null
                                                                        ? FontWeight.bold
                                                                        : null,
                                                                color:
                                                                    returnData().departmentUuid !=
                                                                            null
                                                                        ? null
                                                                        : Colors.grey.shade500,
                                                              ),
                                                              returnData().departmentUuid ==
                                                                      null
                                                                  ? 'Select Department'
                                                                  : returnDepartmentProvider().departments
                                                                      .firstWhere(
                                                                        (
                                                                          dept,
                                                                        ) =>
                                                                            dept.uuid ==
                                                                            returnData().departmentUuid,
                                                                      )
                                                                      .name,
                                                            ),
                                                          ],
                                                        ),
                                                        Ink(
                                                          child: InkWell(
                                                            mouseCursor:
                                                                SystemMouseCursors.click,
                                                            borderRadius: BorderRadius.circular(
                                                              20,
                                                            ),
                                                            onTap: () {
                                                              returnData().clearDepartment();
                                                            },
                                                            child: Container(
                                                              padding: EdgeInsets.all(
                                                                7,
                                                              ),
                                                              decoration: BoxDecoration(
                                                                shape:
                                                                    BoxShape.circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.clear,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          mouseCursor:
                                              SystemMouseCursors
                                                  .click,
                                          onTap: () {
                                            ItemsAuthAction().setExpiryDateAction(
                                              context:
                                                  context,
                                              action: () {
                                                myDatePickerAction(
                                                  theme,
                                                  context,
                                                ).then((
                                                  value,
                                                ) {
                                                  value !=
                                                          null
                                                      ? returnData().setExpDate(
                                                        value,
                                                      )
                                                      : {};
                                                });
                                              },
                                            );
                                          },
                                          child: Column(
                                            mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                            spacing: 5,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    textAlign:
                                                        TextAlign.start,
                                                    style:
                                                        theme.mobileTexts.b3.textStyleBold,
                                                    'Expiry Date (Optional)',
                                                  ),
                                                ],
                                              ),
                                              SubWrapper(
                                                isVisible:
                                                    !ItemsAuthAction().setExpiryDateAction(
                                                      context:
                                                          context,
                                                    ),
                                                mainWidget: Container(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        0,
                                                    horizontal:
                                                        5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color:
                                                          returnData().expiryDate !=
                                                                  null
                                                              ? theme.lightModeColor.prColor300
                                                              : Colors.grey,
                                                      width:
                                                          returnData().expiryDate !=
                                                                  null
                                                              ? 1.3
                                                              : 1,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          5,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width:
                                                                10,
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  returnData().expiryDate !=
                                                                          null
                                                                      ? theme.mobileTexts.b2.fontSize
                                                                      : theme.mobileTexts.b2.fontSize,
                                                              fontWeight:
                                                                  returnData().expiryDate !=
                                                                          null
                                                                      ? FontWeight.bold
                                                                      : null,
                                                              color:
                                                                  returnData().expiryDate !=
                                                                          null
                                                                      ? null
                                                                      : Colors.grey.shade500,
                                                            ),
                                                            returnData().expiryDate ==
                                                                    null
                                                                ? 'Set Expiry Date'
                                                                : formatDateWithDay(
                                                                  returnData().expiryDate ??
                                                                      DateTime.now(),
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      Ink(
                                                        child: InkWell(
                                                          mouseCursor:
                                                              SystemMouseCursors.click,
                                                          borderRadius: BorderRadius.circular(
                                                            20,
                                                          ),
                                                          onTap: () {
                                                            returnData().clearExpDate();
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets.all(
                                                              7,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                            ),
                                                            child: Icon(
                                                              Icons.clear,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Visibility(
                                      visible:
                                          returnShopProvider()
                                              .userShop()
                                              ?.manageInventoryStorage !=
                                          true,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            mouseCursor:
                                                SystemMouseCursors
                                                    .click,
                                            onTap: () {
                                              returnData()
                                                  .toggleUseGroupUnit();
                                              FocusManager
                                                  .instance
                                                  .primaryFocus
                                                  ?.unfocus();
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b1.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        'Use Group Unit?',
                                                      ),
                                                      Column(
                                                        spacing:
                                                            5,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  10,
                                                            ),
                                                            'This Controls if you want to also manage the group unit of this item  (E.g: Single Unit: Bottle, Group Unit: Crate.)',
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Checkbox(
                                                  activeColor:
                                                      theme
                                                          .lightModeColor
                                                          .secColor100,
                                                  value:
                                                      returnData(
                                                        context:
                                                            context,
                                                      ).useGroupUnit,
                                                  onChanged: (
                                                    value,
                                                  ) {
                                                    returnData()
                                                        .toggleUseGroupUnit();
                                                    FocusManager
                                                        .instance
                                                        .primaryFocus
                                                        ?.unfocus();
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SubWrapper(
                                            isVisible:
                                                !ItemsAuthAction()
                                                    .applyVariationsAction(
                                                      context:
                                                          context,
                                                    ),
                                            mainWidget: MainDropdown(
                                              valueSet:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).unitValueSet,
                                              onTap: () {
                                                ItemsAuthAction().applyVariationsAction(
                                                  context:
                                                      context,
                                                  action: () {
                                                    unitsBottomSheet(
                                                      context,
                                                      () {
                                                        setState(() {
                                                          isOpenUnit =
                                                              !isOpenUnit;
                                                        });
                                                      },
                                                    );
                                                    setState(() {
                                                      isOpenUnit =
                                                          !isOpenUnit;
                                                    });
                                                  },
                                                );
                                              },
                                              isOpen:
                                                  isOpenUnit,
                                              title:
                                                  'Item Unit (Optional)',
                                              hint:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).selectedUnit ??
                                                  'Select Item Unit',
                                              theme: theme,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                            visible:
                                                returnData(
                                                  context:
                                                      context,
                                                ).useGroupUnit ==
                                                true,
                                            child: SubWrapper(
                                              isVisible:
                                                  !ItemsAuthAction().useGroupUnitAction(
                                                    context:
                                                        context,
                                                  ),
                                              mainWidget: MainDropdown(
                                                valueSet:
                                                    returnData(
                                                      context:
                                                          context,
                                                    ).groupUnitValueSet,
                                                onTap: () {
                                                  ItemsAuthAction().useGroupUnitAction(
                                                    context:
                                                        context,
                                                    action: () {
                                                      groupUnitsBottomSheet(
                                                        context,
                                                        () {
                                                          setState(
                                                            () {
                                                              isOpenGroupUnit =
                                                                  !isOpenGroupUnit;
                                                            },
                                                          );
                                                        },
                                                      );
                                                      setState(() {
                                                        isOpenGroupUnit =
                                                            !isOpenGroupUnit;
                                                      });
                                                    },
                                                  );
                                                },
                                                isOpen:
                                                    isOpenGroupUnit,
                                                title:
                                                    'Item Group Unit (Optional)',
                                                hint:
                                                    returnData(
                                                      context:
                                                          context,
                                                    ).selectedGroupUnit ??
                                                    'Select Item Group Unit',
                                                theme:
                                                    theme,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                            visible:
                                                returnData(
                                                  context:
                                                      context,
                                                ).useGroupUnit ==
                                                true,
                                            child: Column(
                                              children: [
                                                EditCartTextField(
                                                  theme:
                                                      theme,
                                                  hint:
                                                      'Enter Item Quantity in Group',
                                                  title:
                                                      'Quantity in Group (Optional)',
                                                  controller:
                                                      widget
                                                          .qttyPerGroupController,
                                                ),
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
                                        SubWrapper(
                                          isVisible:
                                              !ItemsAuthAction()
                                                  .applyVariationsAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: MainDropdown(
                                            valueSet:
                                                returnData(
                                                  context:
                                                      context,
                                                ).sizeValueSet,
                                            onTap: () {
                                              ItemsAuthAction().applyVariationsAction(
                                                context:
                                                    context,
                                                action: () {
                                                  sizeTypeBottomSheet(
                                                    context,
                                                    () {
                                                      setState(() {
                                                        isSizedTypeOpen =
                                                            !isSizedTypeOpen;
                                                      });
                                                    },
                                                  );
                                                  setState(() {
                                                    isSizedTypeOpen =
                                                        !isSizedTypeOpen;
                                                  });
                                                },
                                              );
                                            },
                                            isOpen:
                                                isSizedTypeOpen,
                                            title:
                                                'Size Type (Optional)',
                                            hint:
                                                returnData(
                                                  context:
                                                      context,
                                                ).selectedSize ??
                                                'Select Item Size Type',
                                            theme: theme,
                                          ),
                                        ),

                                        SizedBox(
                                          height: 10,
                                        ),
                                        SubWrapper(
                                          isVisible:
                                              !ItemsAuthAction()
                                                  .applyVariationsAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: MainDropdown(
                                            valueSet:
                                                returnData(
                                                  context:
                                                      context,
                                                ).catValueSet,
                                            onTap: () {
                                              ItemsAuthAction().applyVariationsAction(
                                                context:
                                                    context,
                                                action: () {
                                                  categoriesBottomSheet(
                                                    context,
                                                    () {
                                                      setState(() {
                                                        isOpen =
                                                            false;
                                                      });
                                                    },
                                                  );
                                                  setState(() {
                                                    isOpen =
                                                        !isOpen;
                                                  });
                                                },
                                              );
                                            },
                                            isOpen: isOpen,
                                            title:
                                                'Categories (Optional)',
                                            hint:
                                                returnData(
                                                      context:
                                                          context,
                                                    ).selectedCategories.isNotEmpty
                                                    ? "(${returnData(context: context).selectedCategories.length}) Categories Selected"
                                                    : 'Select Item Categories',
                                            theme: theme,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
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
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 30.0,
                        top: 20,
                        left: 30,
                        right: 30,
                      ),
                      child: MainButtonP(
                        themeProvider: theme,
                        action: () {
                          widget.productionItem != null
                              ? updateProductionItem()
                              : checkFields();
                        },
                        text:
                            widget.productionItem != null
                                ? 'Update Item'
                                : 'Create Item',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Visibility(
          visible: isLoading,
          child: returnCompProvider(
            context,
            listen: false,
          ).showLoader(
            message:
                widget.productionItem != null
                    ? 'Updating Item'
                    : 'Creating Item',
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.productionItem != null
                ? 'Item Updated Successfully'
                : 'Item Created Successfully',
          ),
        ),
      ],
    );
  }
}
