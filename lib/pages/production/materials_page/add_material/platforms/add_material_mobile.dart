import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
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

class AddMaterialMobile extends StatefulWidget {
  final MaterialClass? material;
  final TextEditingController costController;
  final TextEditingController nameController;
  final TextEditingController lowQttyController;
  final TextEditingController qttyPerGroupController;
  const AddMaterialMobile({
    super.key,
    required this.costController,
    required this.nameController,
    required this.lowQttyController,
    required this.qttyPerGroupController,
    this.material,
  });

  @override
  State<AddMaterialMobile> createState() =>
      _AddMaterialMobileState();
}

class _AddMaterialMobileState
    extends State<AddMaterialMobile> {
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
                'Material Name Must be set before item can be created',
            title: 'Empty Input',
          );
        },
      );
    } else {
      final safeContext = context;
      var samePro = returnMaterialsProvider()
          .materialList()
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
                    ? 'Material with the name  ${widget.nameController.text.toUpperCase()}  already Exists in your Inventory. Are you sure you want to proceed to create a duplicate Material?'
                    : 'You are about to add a new item to your stock, are you sure you want to proceed?',
            title:
                samePro.isNotEmpty
                    ? 'Material Already Exists'
                    : 'Are you sure?',
            action: () async {
              Navigator.of(confirmDialog).pop();

              setState(() {
                isLoading = true;
              });

              final materialProvider =
                  returnMaterialsProvider();
              final dataProvider = returnData();

              MaterialsItemHistory materialsItemHistory =
                  MaterialsItemHistory(
                    shopId: shopId(),
                    title: 'Item Created',
                    quantityChange: 0,
                    newValue: '0',
                    desc: 'Item Created Now',
                    isIncreased: true,
                    oldValue: '0',
                  );

              await materialProvider.createMaterial(
                materialsItemHistoy: materialsItemHistory,
                material: MaterialClass(
                  useGroupUnit: dataProvider.useGroupUnit,
                  categories:
                      dataProvider.selectedCategories,
                  isManaged: dataProvider.isManaged,
                  name: widget.nameController.text.trim(),
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
                      widget.costController.text.isNotEmpty
                          ? double.parse(
                            widget.costController.text
                                .replaceAll(',', ''),
                          )
                          : 0,
                  shopId: userShop!.shopId!,
                  quantity: 0,
                  lowQtty:
                      widget.lowQttyController.text.isEmpty
                          ? 10
                          : double.tryParse(
                            widget.lowQttyController.text
                                .replaceAll(',', ''),
                          ),
                  expiryDate: dataProvider.expiryDate,
                  // categoryUuid:
                  //     dataProvider.selectedCategory?.uuid,
                  uuid: createdMaterialUuid,
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

  void updateMaterial() {
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
            final provider = returnMaterialsProvider();
            final dataProvider = returnData();
            Navigator.of(confirmDialog).pop();

            setState(() {
              isLoading = true;
            });

            var res = await provider.updateMaterial(
              materialsItemHistory: null,
              includeQuantity: false,
              isIncrement: null,
              isQuantityUpdate: false,
              quantityChange: null,
              material: MaterialClass(
                useGroupUnit: dataProvider.useGroupUnit,
                categories: dataProvider.selectedCategories,
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
                uuid: widget.material?.uuid,
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
                quantity: widget.material?.quantity,

                shopId: userShop!.shopId!,
                // categoryUuid:
                //     dataProvider.selectedCategory?.uuid,
                createdAt: widget.material!.createdAt,
                expiryDate: dataProvider.expiryDate,
                lowQtty:
                    widget.lowQttyController.text.isEmpty
                        ? 10
                        : double.tryParse(
                          widget.lowQttyController.text
                              .replaceAll(',', ''),
                        ),
                sizeType: dataProvider.selectedSize,
              ),
              oldMaterial: widget.material!,
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

  String? createdMaterialUuid;

  //
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((context) {
      clearFields();
    });
    if (widget.material == null) {
      setState(() {
        createdMaterialUuid = uuidGen();
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
    if (widget.material != null && context.mounted) {
      returnData().departmentUuid =
          widget.material?.departmentUuid;
      returnData().expiryDate = widget.material?.expiryDate;
      widget.nameController.text = widget.material!.name;
      widget.lowQttyController.text = widget
          .material!
          .lowQtty!
          .toStringAsFixed(0);
      widget.costController.text =
          widget.material!.costPrice.toString();

      returnData().isManaged = widget.material!.isManaged;
      returnData().useGroupUnit =
          widget.material!.useGroupUnit ?? false;
      returnData().selectUnit(widget.material!.unit);
      returnData().selectGroupUnit(
        unit: widget.material!.groupUnit,
      );
      widget.qttyPerGroupController.text =
          widget.material!.qttyPerGroup != null
              ? widget.material!.qttyPerGroup!.toString()
              : '';
      widget.material!.sizeType != null
          ? returnData().selectSize(
            widget.material!.sizeType!,
          )
          : null;
      returnData().initCategories(
        categories: widget.material?.categories ?? [],
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
                  widget.material != null
                      ? 'Edit Material'
                      : 'New Material',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  widget.material != null
                      ? 'Edit material details'
                      : 'Add a new material to your store.',
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
                                hint: 'Enter Material Name',
                                lines: 1,
                                title: 'Material Name',
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
                                                'Allow Stockall to Manage Material Quantity?',
                                              ),
                                              Column(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          10,
                                                    ),
                                                    'This controls whether Material quantity is automatically deducted after sales, and notifications are sent when material quantity is low or out of stock.',
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
                                        EditCartTextField(
                                          theme: theme,
                                          hint:
                                              'Enter Limit',
                                          title:
                                              'Low Quantity Limit',
                                          controller:
                                              widget
                                                  .lowQttyController,
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
                                          child: SizedBox(
                                            height: 10,
                                          ),
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
                                                  'Material Unit (Optional)',
                                              hint:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).selectedUnit ??
                                                  'Select Material Unit',
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
                                                    'Material Group Unit (Optional)',
                                                hint:
                                                    returnData(
                                                      context:
                                                          context,
                                                    ).selectedGroupUnit ??
                                                    'Select Material Group Unit',
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
                                                      'Enter Material Quantity in Group',
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
                                                'Select Material Size Type',
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
                          widget.material != null
                              ? updateMaterial()
                              : checkFields();
                        },
                        text:
                            widget.material != null
                                ? 'Update Material'
                                : 'Create Material',
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
                widget.material != null
                    ? 'Updating Material'
                    : 'Creating Material',
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(
            context,
            listen: false,
          ).showSuccess(
            widget.material != null
                ? 'Material Updated Successfully'
                : 'Material Created Successfully',
          ),
        ),
      ],
    );
  }
}
