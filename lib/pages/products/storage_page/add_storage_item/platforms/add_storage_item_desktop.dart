import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';

class AddStorageItemDesktop extends StatefulWidget {
  final TempStorageProducts? storageProduct;
  final TextEditingController nameController;
  final TextEditingController qttyPerGroupController;
  final TextEditingController costPriceController;
  final TextEditingController sellingPriceController;

  const AddStorageItemDesktop({
    super.key,
    required this.nameController,
    required this.qttyPerGroupController,
    required this.costPriceController,
    required this.sellingPriceController,
    this.storageProduct,
  });

  @override
  State<AddStorageItemDesktop> createState() =>
      _AddStorageItemDesktopState();
}

class _AddStorageItemDesktopState
    extends State<AddStorageItemDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  bool isOpenUnit = false;
  bool isOpenGroupUnit = false;
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
      var samePro = returnStorageProductProvider()
          .storageProductListMain
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

              final dataProvider =
                  returnStorageProductProvider();
              var product = TempStorageProducts(
                shopId: shopId(),
                name: widget.nameController.text.trim(),
                createdAt: DateTime.now(),
                groupUnit: returnData().selectedGroupUnit,
                qttyPerGroup: double.tryParse(
                  widget.qttyPerGroupController.text
                      .replaceAll(',', ''),
                ),
                quantity: null,
                unit: returnData().selectedUnit,
                updatedAt: DateTime.now(),
                uuid: uuidGen(),
                costPrice: double.tryParse(
                  widget.costPriceController.text
                      .replaceAll(',', ''),
                ),
                sellingPrice: double.tryParse(
                  widget.sellingPriceController.text
                      .replaceAll(',', ''),
                ),
              );

              await dataProvider.createStorageProduct(
                product: product,
              );

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              // Clear data before popping
              if (safeContext.mounted) {
                returnData().clearFields();
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

  void updateStorageProduct() {
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
      showDialog(
        context: safeContext,
        builder: (context) {
          var theme = returnTheme(context);
          return ConfirmationAlert(
            theme: theme,
            message:
                'Are you sure you want to proceed with update?',
            title: 'Proceed?',
            action: () async {
              final provider =
                  returnStorageProductProvider();
              final dataProvider = returnData();
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }

              setState(() {
                isLoading = true;
              });
              var res = await provider.updateProduct(
                product: TempStorageProducts(
                  createdAt:
                      widget.storageProduct?.createdAt,
                  updatedAt: DateTime.now(),
                  uuid: widget.storageProduct?.uuid,
                  name: widget.nameController.text.trim(),
                  unit: dataProvider.selectedUnit!,
                  groupUnit: dataProvider.selectedGroupUnit,
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
                  quantity: widget.storageProduct?.quantity,
                  costPrice:
                      widget
                              .costPriceController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.costPriceController.text
                                .replaceAll(',', ''),
                          )
                          : null,
                  sellingPrice:
                      widget
                              .sellingPriceController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget
                                .sellingPriceController
                                .text
                                .replaceAll(',', ''),
                          )
                          : null,
                  shopId: userShop!.shopId!,
                ),
                // oldProduct: widget.product!,
              );

              if (res == 0) {
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
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearFields();
    });
    setShop();
  }

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      if (context.mounted) {
        returnData().clearFields(setIsManaged: false);
      }
    });
    if (widget.storageProduct != null) {
      widget.nameController.text =
          widget.storageProduct?.name ?? '';
      returnData().selectUnit(
        widget.storageProduct!.unit ?? 'Others',
      );
      returnData().selectGroupUnit(
        unit: widget.storageProduct!.groupUnit,
      );
      widget.qttyPerGroupController.text =
          widget.storageProduct!.qttyPerGroup != null
              ? widget.storageProduct!.qttyPerGroup!
                  .toString()
              : '';
      widget.costPriceController.text =
          widget.storageProduct!.costPrice == null
              ? ''
              : widget.storageProduct!.costPrice.toString();

      widget.sellingPriceController.text =
          widget.storageProduct!.sellingPrice == null
              ? ''
              : widget.storageProduct!.sellingPrice
                  .toString();
    }
  }

  bool isGroup = false;

  TempShopClass? userShop;
  void setShop() async {
    await returnShopProvider().getUserShops();
    setState(() {
      userShop = returnShopProvider().userShop();
    });
  }

  //
  //
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          DesktopCenterContainer(
            width: 650,
            mainWidget: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      widget.storageProduct != null
                          ? 'Edit Item'
                          : 'New Item',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      widget.storageProduct != null
                          ? 'Edit item details'
                          : 'Add a new item to your store.',
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
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
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
                                        widget
                                            .nameController,
                                  ),
                                  SizedBox(height: 5),
                                  MoneyTextfield(
                                    theme: theme,
                                    hint:
                                        'Enter Cost Price',
                                    title:
                                        'Cost Price (Optional)',
                                    controller:
                                        widget
                                            .costPriceController,
                                  ),
                                  SizedBox(height: 5),
                                  MoneyTextfield(
                                    theme: theme,
                                    hint:
                                        'Enter Selling Price',
                                    title:
                                        'Selling Price (Optional)',
                                    controller:
                                        widget
                                            .sellingPriceController,
                                  ),
                                  SizedBox(height: 15),
                                  Column(
                                    children: [
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: SubWrapper(
                                                  isVisible:
                                                      !ItemsAuthAction().applyVariationsAction(
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
                                                              setState(
                                                                () {
                                                                  isOpenUnit =
                                                                      !isOpenUnit;
                                                                },
                                                              );
                                                            },
                                                          );
                                                          setState(
                                                            () {
                                                              isOpenUnit =
                                                                  !isOpenUnit;
                                                            },
                                                          );
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
                                                    theme:
                                                        theme,
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    returnShopProvider(
                                                      context:
                                                          context,
                                                    ).userShop()?.useGroupUnit ==
                                                    true,
                                                child:
                                                    SizedBox(
                                                      width:
                                                          10,
                                                    ),
                                              ),
                                              Visibility(
                                                visible:
                                                    returnShopProvider(
                                                      context:
                                                          context,
                                                    ).userShop()?.useGroupUnit ==
                                                    true,
                                                child: Expanded(
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
                                                            setState(
                                                              () {
                                                                isOpenGroupUnit =
                                                                    !isOpenGroupUnit;
                                                              },
                                                            );
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
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Visibility(
                                            visible:
                                                returnShopProvider(
                                                  context:
                                                      context,
                                                ).userShop()?.useGroupUnit ==
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
                                      SizedBox(height: 10),
                                    ],
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
                              if (widget.storageProduct !=
                                  null) {
                                updateStorageProduct();
                              } else {
                                checkFields();
                              }
                            },
                            text:
                                widget.storageProduct !=
                                        null
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
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(
              message:
                  widget.storageProduct != null
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
              widget.storageProduct != null
                  ? 'Item Updated Successfully'
                  : 'Item Created Successfully',
            ),
          ),
        ],
      ),
    );
  }
}
