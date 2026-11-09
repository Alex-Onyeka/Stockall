import 'package:stockall/pages/products/add_product_one/platforms/components/product_linking_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/barcode_scanner.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/allow_to_manage_item_quantity_add_item_page.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/allow_to_set_custom_price_add_item_page.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/markup_margin_fields.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/select_product_quantity_type_section.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/use_multiple_toggle_add_item_page.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/product_prices_page.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/product_units_page.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/components/storage_dimension_rules.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:stockall/providers/data_provider.dart';

class AddProductDesktop extends StatefulWidget {
  final TempProductClass? product;
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController wholeSaleController;
  final TextEditingController nameController;
  final TextEditingController lowQttyController;
  final TextEditingController discountController;
  final TextEditingController qttyPerGroupController;
  final TextEditingController heightController;
  final TextEditingController widthController;

  const AddProductDesktop({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.nameController,
    required this.lowQttyController,
    required this.discountController,
    required this.qttyPerGroupController,
    required this.wholeSaleController,
    required this.heightController,
    required this.widthController,
    this.product,
  });

  @override
  State<AddProductDesktop> createState() =>
      _AddProductDesktopState();
}

class _AddProductDesktopState
    extends State<AddProductDesktop> {
  bool barCodeSet = false;
  bool isLoading = false;
  bool showSuccess = false;
  bool expand = false;

  String? barcode;
  //
  //
  //
  //

  bool isOpenUnit = false;
  bool isOpenGroupUnit = false;
  bool isSizedTypeOpen = false;

  TextEditingController expiryDateC =
      TextEditingController();

  TextEditingController barcodeController =
      TextEditingController();

  int quantityType = 1;

  void switchQuantityType(int index) {
    setState(() {
      quantityType = index;
    });
    widget.widthController.clear();
    widget.heightController.clear();
  }

  //
  //
  //
  bool isOpen = false;
  List<LinkedProductInfo> stagedBranchLinks = [];
  List<LinkedProductInfo> removedBranchLinks = [];
  bool isBranchUnlinked = false;
  List<LinkedDepartmentProductInfo> stagedDeptLinks = [];
  List<LinkedDepartmentProductInfo> removedDeptLinks = [];
  bool isDeptUnlinked = false;

  void checkFields() async {
    final hasWidth =
        widget.widthController.text.trim().isNotEmpty;
    final hasHeight =
        widget.heightController.text.trim().isNotEmpty;
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
    } else if (quantityType == 2 &&
        (hasWidth != hasHeight)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Both Width and Height must be provided if setting dimensions, or both left empty.',
            title: 'Incomplete Dimensions',
          );
        },
      );
    } else if (quantityType == 2 &&
        hasWidth &&
        hasHeight &&
        ((double.tryParse(
                      widget.widthController.text
                          .replaceAll(',', '')
                          .trim(),
                    ) ??
                    0) <=
                0 ||
            (double.tryParse(
                      widget.heightController.text
                          .replaceAll(',', '')
                          .trim(),
                    ) ??
                    0) <=
                0)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Width and Height must be numbers greater than 0.',
            title: 'Invalid Dimensions',
          );
        },
      );
    } else {
      final safeContext = context;
      var samePro = returnData().productList().where(
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

              final dataProvider = returnData();
              ItemHistory itemHistory = ItemHistory(
                event: ItemHistoryEventClass.itemCreated,
                source: ItemHistoryEventClass.manualSource,
                destination:
                    ItemHistoryEventClass
                        .productDestination,
                unit: 'Not Set',
                shopId: shopId(),
                title: 'Item Created',
                quantityChange: 0,
                newValue: '0',
                desc: 'Item Created Now',
                isIncreased: true,
                oldValue: '0',
                isManaged: true,
              );

              await dataProvider.createProduct(
                isMultiple: false,
                itemHistory: itemHistory,
                product: TempProductClass(
                  manageSalesWastage:
                      dataProvider.manageWastage,
                  deriveQuantityFromPrice:
                      dataProvider.deriveQuantityFromPrice,
                  quantityType: quantityType,
                  heightDimension: double.tryParse(
                    widget.heightController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ),
                  widthDimension: double.tryParse(
                    widget.widthController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ),
                  dimensionUnit:
                      dataProvider.selectedDimensionUnit,
                  dimensionUnitConversion:
                      dataProvider
                          .selectedDimensionConversion,
                  unitsList:
                      dataProvider.getFinalUnitList(),
                  pricesList: dataProvider
                      .getFinalPriceList(
                        productUuid:
                            createdProductUuid ?? '',
                        sellingText:
                            widget.sellingController.text,
                      ),
                  useGroupUnit: dataProvider.useGroupUnit,
                  categories:
                      dataProvider.selectedCategories
                          .toList(),
                  storageUuid: null,
                  isManaged: dataProvider.isManaged,
                  name: widget.nameController.text.trim(),
                  unit:
                      (dataProvider.useMultipleUnits
                          ? dataProvider.selectedUnit
                          : dataProvider
                              .singleUnitName()) ??
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
                  isRefundable:
                      dataProvider.isProductRefundable,
                  setCustomPrice:
                      dataProvider.setCustomPrice,
                  costPrice:
                      widget.costController.text.isNotEmpty
                          ? double.parse(
                            widget.costController.text
                                .replaceAll(',', ''),
                          )
                          : 0,
                  shopId: shopId(),
                  sellingPrice:
                      widget
                              .sellingController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.sellingController.text
                                .replaceAll(',', ''),
                          )
                          : null,
                  wholeSalePrice:
                      widget
                              .wholeSaleController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.wholeSaleController.text
                                .replaceAll(',', ''),
                          )
                          : null,
                  quantity: 0,
                  barcode: barcode,
                  globalProductId:
                      stagedBranchLinks.isNotEmpty
                          ? (() {
                            for (final link
                                in stagedBranchLinks) {
                              if (link
                                          .product
                                          .globalProductId !=
                                      null &&
                                  link
                                      .product
                                      .globalProductId!
                                      .trim()
                                      .isNotEmpty) {
                                return link
                                    .product
                                    .globalProductId;
                              }
                            }
                            return createdProductUuid;
                          })()
                          : uuidGen(),
                  globalDepartmentProductId:
                      stagedDeptLinks.isNotEmpty
                          ? (() {
                            for (final link
                                in stagedDeptLinks) {
                              if (link
                                          .product
                                          .globalDepartmentProductId !=
                                      null &&
                                  link
                                      .product
                                      .globalDepartmentProductId!
                                      .trim()
                                      .isNotEmpty) {
                                return link
                                    .product
                                    .globalDepartmentProductId;
                              }
                            }
                            return createdProductUuid;
                          })()
                          : uuidGen(),
                  lowQtty:
                      widget.lowQttyController.text.isEmpty
                          ? 10
                          : double.tryParse(
                            widget.lowQttyController.text
                                .replaceAll(',', ''),
                          ),
                  discount: double.tryParse(
                    widget.discountController.text
                        .replaceAll(',', ''),
                  ),
                  expiryDate: dataProvider.expiryDate,
                  // categoryUuid:
                  //     dataProvider.selectedCategory?.uuid,
                  uuid: createdProductUuid,
                  departmentName:
                      returnData().departmentUuid != null
                          ? returnDepartmentProvider()
                              .departments
                              .firstWhere(
                                (dept) =>
                                    dept.uuid ==
                                    returnData()
                                        .departmentUuid,
                              )
                              .name
                          : null,
                  departmentUuid:
                      returnData().departmentUuid,
                ),
              );

              // 1. Sync staged branch products
              if (stagedBranchLinks.isNotEmpty) {
                String? savedBranchClusterId;
                for (final link in stagedBranchLinks) {
                  if (link.product.globalProductId !=
                          null &&
                      link.product.globalProductId!
                          .trim()
                          .isNotEmpty) {
                    savedBranchClusterId =
                        link.product.globalProductId;
                    break;
                  }
                }
                savedBranchClusterId ??= createdProductUuid;

                for (final link in stagedBranchLinks) {
                  await returnData()
                      .updateProductForOtherShops(
                        product: link.product.copyWith(
                          globalProductId:
                              savedBranchClusterId,
                        ),
                        itemHistory: null,
                      );
                }
              }

              // 2. Sync staged department products
              if (stagedDeptLinks.isNotEmpty) {
                String? savedDeptClusterId;
                for (final link in stagedDeptLinks) {
                  if (link
                              .product
                              .globalDepartmentProductId !=
                          null &&
                      link
                          .product
                          .globalDepartmentProductId!
                          .trim()
                          .isNotEmpty) {
                    savedDeptClusterId =
                        link
                            .product
                            .globalDepartmentProductId;
                    break;
                  }
                }
                savedDeptClusterId ??= createdProductUuid;

                for (final link in stagedDeptLinks) {
                  await returnData().updateProduct(
                    product: link.product.copyWith(
                      globalDepartmentProductId:
                          savedDeptClusterId,
                    ),
                    isQuantityUpdate: false,
                    includeQuantity: false,
                    quantityChange: null,
                    isIncrement: null,
                    itemHistory: null,
                  );
                }
              }

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

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

  void updateProduct() {
    final safeContext = context;
    if (!salesTypeChangeAllowed(
      context: context,
      product: widget.product!,
      quantityType: quantityType,
    )) {
      return;
    }
    final hasWidth =
        widget.widthController.text.trim().isNotEmpty;
    final hasHeight =
        widget.heightController.text.trim().isNotEmpty;
    if (quantityType == 2 && (hasWidth != hasHeight)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Both Width and Height must be provided if setting dimensions, or both left empty.',
            title: 'Incomplete Dimensions',
          );
        },
      );
    } else if (quantityType == 2 &&
        hasWidth &&
        hasHeight &&
        ((double.tryParse(
                      widget.widthController.text
                          .replaceAll(',', '')
                          .trim(),
                    ) ??
                    0) <=
                0 ||
            (double.tryParse(
                      widget.heightController.text
                          .replaceAll(',', '')
                          .trim(),
                    ) ??
                    0) <=
                0)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Width and Height must be numbers greater than 0.',
            title: 'Invalid Dimensions',
          );
        },
      );
    } else {
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
              final provider = returnData();
              Navigator.of(confirmDialog).pop();

              setState(() {
                isLoading = true;
              });

              String? updatedBranchClusterId =
                  widget.product?.globalProductId;
              if (isBranchUnlinked) {
                updatedBranchClusterId = uuidGen();
              } else if (stagedBranchLinks.isNotEmpty) {
                for (final link in stagedBranchLinks) {
                  if (link.product.globalProductId !=
                          null &&
                      link.product.globalProductId!
                          .trim()
                          .isNotEmpty) {
                    updatedBranchClusterId =
                        link.product.globalProductId;
                    break;
                  }
                }
                updatedBranchClusterId ??=
                    widget.product?.globalProductId ??
                    uuidGen();
              } else {
                updatedBranchClusterId ??= uuidGen();
              }

              String? updatedDeptClusterId =
                  widget.product?.globalDepartmentProductId;
              if (isDeptUnlinked) {
                updatedDeptClusterId = uuidGen();
              } else if (stagedDeptLinks.isNotEmpty) {
                for (final link in stagedDeptLinks) {
                  if (link
                              .product
                              .globalDepartmentProductId !=
                          null &&
                      link
                          .product
                          .globalDepartmentProductId!
                          .trim()
                          .isNotEmpty) {
                    updatedDeptClusterId =
                        link
                            .product
                            .globalDepartmentProductId;
                    break;
                  }
                }
                updatedDeptClusterId ??=
                    widget
                        .product
                        ?.globalDepartmentProductId ??
                    uuidGen();
              } else {
                updatedDeptClusterId ??= uuidGen();
              }

              var res = await provider.updateProduct(
                itemHistory: null,
                includeQuantity: false,
                isIncrement: null,
                isQuantityUpdate: false,
                quantityChange: null,
                product: TempProductClass(
                  manageSalesWastage:
                      provider.manageWastage,
                  deriveQuantityFromPrice:
                      provider.deriveQuantityFromPrice,
                  quantityType: quantityType,
                  heightDimension: double.tryParse(
                    widget.heightController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ),
                  widthDimension: double.tryParse(
                    widget.widthController.text.replaceAll(
                      ',',
                      '',
                    ),
                  ),
                  dimensionUnit:
                      provider.selectedDimensionUnit,
                  dimensionUnitConversion:
                      provider.selectedDimensionConversion,
                  unitsList: provider.getFinalUnitList(),
                  pricesList: provider.getFinalPriceList(
                    productUuid: createdProductUuid ?? '',
                    sellingText:
                        widget.sellingController.text,
                  ),
                  useGroupUnit: provider.useGroupUnit,
                  categories:
                      provider.selectedCategories.toList(),
                  storageUuid: widget.product?.storageUuid,
                  departmentName:
                      returnData().departmentUuid != null
                          ? returnDepartmentProvider()
                              .departments
                              .firstWhere(
                                (dept) =>
                                    dept.uuid ==
                                    returnData()
                                        .departmentUuid,
                              )
                              .name
                          : null,
                  departmentUuid:
                      returnData().departmentUuid,
                  setCustomPrice: provider.setCustomPrice,
                  isManaged:
                      // widget.quantityController.text.isEmpty
                      //     ? false
                      //     :
                      provider.isManaged,
                  totalQttyInStorageDouble: null,
                  uuid: widget.product?.uuid,
                  name: widget.nameController.text,
                  unit:
                      (provider.useMultipleUnits
                          ? provider.selectedUnit
                          : provider.singleUnitName()) ??
                      'Unit(s)',
                  groupUnit: provider.selectedGroupUnit,
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
                  isRefundable:
                      provider.isProductRefundable,
                  costPrice:
                      widget.costController.text.isNotEmpty
                          ? double.parse(
                            widget.costController.text
                                .replaceAll(',', ''),
                          )
                          : 0,
                  sellingPrice:
                      widget
                              .sellingController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.sellingController.text
                                .replaceAll(',', ''),
                          )
                          : null,
                  wholeSalePrice:
                      widget
                              .wholeSaleController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.wholeSaleController.text
                                .replaceAll(',', ''),
                          )
                          : null,
                  quantity:
                      ProductsFunc()
                          .getSingleProduct(
                            uuid:
                                widget.product?.uuid ?? '',
                          )
                          ?.quantity ??
                      widget.product?.quantity,
                  shopId: shopId(),
                  barcode: barcode,
                  // categoryUuid:
                  //     provider.selectedCategory?.uuid,
                  createdAt: widget.product!.createdAt,
                  discount: double.tryParse(
                    widget.discountController.text
                        .replaceAll(',', ''),
                  ),
                  // endDate: provider.endDate,
                  expiryDate: provider.expiryDate,
                  globalProductId: updatedBranchClusterId,
                  globalDepartmentProductId:
                      updatedDeptClusterId,
                  lowQtty:
                      widget.lowQttyController.text.isEmpty
                          ? 10
                          : double.tryParse(
                            widget.lowQttyController.text
                                .replaceAll(',', ''),
                          ),
                  sizeType: provider.selectedSize,
                ),
                oldProduct: widget.product!,
              );
              if (res == null) {
                setState(() {
                  isLoading = false;
                });
              } else {
                if (!isBranchUnlinked) {
                  for (final link in stagedBranchLinks) {
                    if (link.product.globalProductId !=
                        updatedBranchClusterId) {
                      await returnData()
                          .updateProductForOtherShops(
                            product: link.product.copyWith(
                              globalProductId:
                                  updatedBranchClusterId,
                            ),
                            itemHistory: null,
                          );
                    }
                  }
                }
                for (final link in removedBranchLinks) {
                  await returnData()
                      .updateProductForOtherShops(
                        product: link.product.copyWith(
                          globalProductId: uuidGen(),
                        ),
                        itemHistory: null,
                      );
                }

                if (!isDeptUnlinked) {
                  for (final link in stagedDeptLinks) {
                    if (link
                            .product
                            .globalDepartmentProductId !=
                        updatedDeptClusterId) {
                      await returnData().updateProduct(
                        product: link.product.copyWith(
                          globalDepartmentProductId:
                              updatedDeptClusterId,
                        ),
                        isQuantityUpdate: false,
                        includeQuantity: false,
                        quantityChange: null,
                        isIncrement: null,
                        itemHistory: null,
                      );
                    }
                  }
                }
                for (final link in removedDeptLinks) {
                  await returnData().updateProduct(
                    product: link.product.copyWith(
                      globalDepartmentProductId: uuidGen(),
                    ),
                    isQuantityUpdate: false,
                    includeQuantity: false,
                    quantityChange: null,
                    isIncrement: null,
                    itemHistory: null,
                  );
                }

                setState(() {
                  isLoading = false;
                  showSuccess = true;
                });

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

  String? createdProductUuid;

  //
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearFields();
      FocusScope.of(context).requestFocus(nameFieldNode);
    });
    if (widget.product == null) {
      setState(() {
        createdProductUuid = uuidGen();
      });
      final currentDept =
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid;
      if (currentDept != null) {
        returnData().departmentUuid = currentDept;
      }
    } else {
      createdProductUuid = widget.product?.uuid;
    }
    // setShop();
  }

  final FocusNode nameFieldNode = FocusNode();
  final FocusNode costFieldNode = FocusNode();
  final FocusNode sellingFieldNode = FocusNode();
  final FocusNode wholeSaleFieldNode = FocusNode();
  // final FocusNode quantityFieldNode = FocusNode();
  final FocusNode barcodeFieldNode = FocusNode();
  // final FocusNode storageQuantityFieldNode = FocusNode();

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      returnData().clearFields(setIsManaged: false);
      var res = ItemsAuthAction()
          .allowStockallToManageItemAction(
            // ignore: use_build_context_synchronously
            context: context,
          );
      if (res) {
        returnData().toggleIsManagedTemp(true);
      } else {
        returnData().toggleIsManagedTemp(false);
      }
    });
    if (widget.product != null && context.mounted) {
      returnData().departmentUuid =
          widget.product?.departmentUuid;
      returnData().manageWastage =
          widget.product?.manageSalesWastage ?? false;
      returnData().selectedDimensionUnit =
          widget.product?.dimensionUnit;
      returnData().selectedDimensionConversion =
          widget.product?.dimensionUnitConversion;
      returnData().deriveQuantityFromPrice =
          widget.product?.deriveQuantityFromPrice ?? false;
      returnData().expiryDate = widget.product?.expiryDate;
      barcode = widget.product!.barcode;
      barCodeSet =
          widget.product!.barcode != null ? true : false;
      widget.nameController.text = widget.product!.name;
      widget.lowQttyController.text = widget
          .product!
          .lowQtty!
          .toStringAsFixed(0);
      widget.costController.text =
          widget.product!.costPrice.toString();
      widget.sellingController.text =
          widget.product!.sellingPrice != null
              ? widget.product!.sellingPrice.toString()
              : '';
      widget.wholeSaleController.text =
          widget.product!.wholeSalePrice != null
              ? widget.product!.wholeSalePrice.toString()
              : '';
      widget.discountController.text =
          widget.product!.discount != null
              ? widget.product!.discount!.toString()
              : '';
      returnData().isProductRefundable =
          widget.product!.isRefundable;
      returnData().isManaged = widget.product!.isManaged;
      returnData().useGroupUnit =
          widget.product!.useGroupUnit ?? false;
      returnData().setCustomPrice =
          widget.product!.setCustomPrice;
      returnData().selectUnit(widget.product!.unit);
      returnData().initUnitsList(
        productUuid: createdProductUuid,
        unitsListNew: widget.product?.getUnitsList() ?? [],
      );
      returnData().initPricesList(
        productUuid: createdProductUuid,
        pricesListNew:
            widget.product?.getPricesList() ?? [],
      );
      returnData().initPriceUnitModes();
      if (!returnData().useMultiplePrices) {
        final primaryValue =
            widget.product!.getPrimaryPrice().priceValue;
        widget.sellingController.text =
            primaryValue != 0
                ? primaryValue.toString()
                : '';
      }
      returnData().selectGroupUnit(
        unit: widget.product!.groupUnit,
      );
      widget.qttyPerGroupController.text =
          widget.product!.qttyPerGroup != null
              ? widget.product!.qttyPerGroup!.toString()
              : '';
      widget.product!.sizeType != null
          ? returnData().selectSize(
            widget.product!.sizeType!,
          )
          : null;
      returnData().initCategories(
        categories: widget.product?.categories ?? [],
      );
      quantityType = widget.product?.quantityType ?? 1;
      widget.heightController.text =
          widget.product?.heightDimension?.toString() ?? '';
      widget.widthController.text =
          widget.product?.widthDimension?.toString() ?? '';
    } else if (context.mounted) {
      final currentDept =
          returnDepartmentProvider(
            context: context,
          ).currentDepartment()?.uuid;
      if (currentDept != null) {
        returnData(context: context).departmentUuid =
            currentDept;
      }
    }
  }

  // TempShopClass? userShop;
  // void setShop() async {
  //   await returnShopProvider().getUserShops();

  //   setState(() {
  //     userShop = returnShopProvider().userShop();
  //   });
  // }

  @override
  void dispose() {
    super.dispose();
    expiryDateC.dispose();
    // quantityFieldNode.dispose();
    sellingFieldNode.dispose();
    wholeSaleFieldNode.dispose();
    costFieldNode.dispose();
    nameFieldNode.dispose();
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
                      widget.product != null
                          ? 'Edit Item'
                          : 'New Item',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      widget.product != null
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
                                    focusNode:
                                        nameFieldNode,
                                    onSubmitted: (value) {
                                      FocusScope.of(
                                        context,
                                      ).requestFocus(
                                        costFieldNode,
                                      );
                                    },
                                    theme: theme,
                                    hint: 'Enter Item Name',
                                    lines: 1,
                                    title: 'Item Name',
                                    controller:
                                        widget
                                            .nameController,
                                  ),
                                  SizedBox(height: 10),
                                  Column(
                                    children: [
                                      Row(
                                        children: [
                                          Visibility(
                                            visible: authorization(
                                              authorized:
                                                  Authorizations()
                                                      .manageCostPrice,
                                            ),
                                            child: Expanded(
                                              child: MoneyTextfield(
                                                focusNode:
                                                    costFieldNode,
                                                onSubmitted: (
                                                  value,
                                                ) {
                                                  FocusScope.of(
                                                    context,
                                                  ).requestFocus(
                                                    sellingFieldNode,
                                                  );
                                                },
                                                onChanged:
                                                    (
                                                      value,
                                                    ) {},
                                                theme:
                                                    theme,
                                                hint:
                                                    'Enter Real Cost',
                                                title:
                                                    'Cost - Price (Optional)',
                                                controller:
                                                    widget
                                                        .costController,
                                              ),
                                            ),
                                          ),
                                          // Visibility(
                                          //   visible: authorization(
                                          //     authorized:
                                          //         Authorizations()
                                          //             .manageCostPrice,
                                          //   ),
                                          //   child: SizedBox(
                                          //     width: 10,
                                          //   ),
                                          // ),
                                          // Expanded(
                                          //   child: MoneyTextfield(
                                          //     focusNode:
                                          //         sellingFieldNode,
                                          //     onSubmitted: (
                                          //       value,
                                          //     ) {
                                          //       returnShopProvider().userShop()?.wholeSale ==
                                          //               true
                                          //           ? FocusScope.of(
                                          //             context,
                                          //           ).requestFocus(
                                          //             wholeSaleFieldNode,
                                          //           )
                                          //           : {};
                                          //       // : FocusScope.of(
                                          //       //   context,
                                          //       // ).requestFocus(
                                          //       //   quantityFieldNode,
                                          //       // );
                                          //     },
                                          //     onChanged:
                                          //         (
                                          //           value,
                                          //         ) {},
                                          //     theme: theme,
                                          //     hint:
                                          //         'Enter Sale Price',
                                          //     title:
                                          //         'Selling-Price (Optional)',
                                          //     controller:
                                          //         widget
                                          //             .sellingController,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      // SizedBox(height: 10),
                                      // Visibility(
                                      //   visible:
                                      //       shop(
                                      //         context,
                                      //       )?.wholeSale ==
                                      //       true,
                                      //   child: Column(
                                      //     children: [
                                      //       MoneyTextfield(
                                      //         focusNode:
                                      //             wholeSaleFieldNode,
                                      //         onSubmitted: (
                                      //           value,
                                      //         ) {
                                      //           // FocusScope.of(
                                      //           //   context,
                                      //           // ).requestFocus(
                                      //           //   quantityFieldNode,
                                      //           // );
                                      //         },
                                      //         onChanged:
                                      //             (
                                      //               value,
                                      //             ) {},
                                      //         theme: theme,
                                      //         hint:
                                      //             'Enter Whole Sale Price',
                                      //         title:
                                      //             'Whole-Sale-Price (Optional)',
                                      //         controller:
                                      //             widget
                                      //                 .wholeSaleController,
                                      //       ),
                                      //       SizedBox(
                                      //         height: 10,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ),
                                      SizedBox(height: 15),

                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .editSellingPrice,
                                        ),
                                        child: Column(
                                          children: [
                                            UseMultipleToggleAddItemPage(
                                              theme: theme,
                                              title:
                                                  'Manage Multiple Prices',
                                              description:
                                                  'Turn on to set more than one selling price for this item.',
                                              value:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).useMultiplePrices,
                                              onTap: () {
                                                toggleMultiplePricesAction(
                                                  context:
                                                      context,
                                                  sellingController:
                                                      widget
                                                          .sellingController,
                                                  productUuid:
                                                      createdProductUuid ??
                                                      '',
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Visibility(
                                              visible:
                                                  !returnData(
                                                    context:
                                                        context,
                                                  ).useMultiplePrices,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                mainAxisSize:
                                                    MainAxisSize
                                                        .min,
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      bottom:
                                                          10.0,
                                                    ),
                                                    child: MoneyTextfield(
                                                      focusNode:
                                                          sellingFieldNode,
                                                      theme:
                                                          theme,
                                                      hint:
                                                          'Enter Selling Price',
                                                      title:
                                                          'Selling Price',
                                                      controller:
                                                          widget.sellingController,
                                                    ),
                                                  ),
                                                  MarkupMarginFields(
                                                    sellingPriceController:
                                                        widget.sellingController,
                                                    costPriceController:
                                                        widget.costController,
                                                    theme:
                                                        theme,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).useMultiplePrices,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                      bottom:
                                                          10.0,
                                                    ),
                                                child: MainDropdown(
                                                  valueSet:
                                                      returnData()
                                                          .tempPricesList
                                                          .isNotEmpty,
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return ProductPricesPage(
                                                            productUuid:
                                                                createdProductUuid ??
                                                                '',
                                                            costPrice: double.tryParse(
                                                              widget.costController.text
                                                                  .replaceAll(
                                                                    ',',
                                                                    '',
                                                                  )
                                                                  .trim(),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  isOpen:
                                                      returnData()
                                                          .tempPricesList
                                                          .isNotEmpty,
                                                  title:
                                                      'Selling Price(s)',
                                                  hint:
                                                      returnData(
                                                            context:
                                                                context,
                                                          ).tempPricesList.isEmpty
                                                          ? 'Price Not Set'
                                                          : "${returnData(context: context).tempPricesList.firstWhere((item) => item.isPrimary).priceValue} and (${returnData(context: context).tempPricesList.length - 1}) More",
                                                  theme:
                                                      theme,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      SizedBox(height: 10),
                                      Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Visibility(
                                                visible:
                                                    kIsWeb ||
                                                    platforms(
                                                          context,
                                                        ) ==
                                                        TargetPlatform.android ||
                                                    platforms(
                                                          context,
                                                        ) ==
                                                        TargetPlatform.iOS,
                                                child: BarcodeScanner(
                                                  focusNode:
                                                      barcodeFieldNode,
                                                  controller:
                                                      barcodeController,
                                                  valueSet:
                                                      barCodeSet,
                                                  onTap: () async {
                                                    ItemsAuthAction().generateBarcodeAction(
                                                      context:
                                                          context,
                                                      action: () async {
                                                        String?
                                                        info = await scanCode(
                                                          context,
                                                          'Not Saved',
                                                        );

                                                        setState(() {
                                                          barcode =
                                                              info;
                                                          barCodeSet =
                                                              true;
                                                        });
                                                      },
                                                    );
                                                  },
                                                  title:
                                                      'Item Barcode (Optional)',
                                                  hint:
                                                      barcode ??
                                                      'Click to Scan Item Barcode',
                                                  theme:
                                                      theme,
                                                ),
                                              ),
                                              Visibility(
                                                visible:
                                                    platforms(
                                                          context,
                                                        ) ==
                                                        TargetPlatform.windows ||
                                                    platforms(
                                                          context,
                                                        ) ==
                                                        TargetPlatform.linux ||
                                                    platforms(
                                                          context,
                                                        ) ==
                                                        TargetPlatform.macOS,
                                                child: Column(
                                                  spacing:
                                                      5,
                                                  children: [
                                                    Text(
                                                      style:
                                                          theme.mobileTexts.b3.textStyleBold,
                                                      'Item Barcode (Optional)',
                                                    ),
                                                    TextFormField(
                                                      focusNode:
                                                          barcodeFieldNode,
                                                      controller:
                                                          barcodeController,
                                                      onChanged: (
                                                        value,
                                                      ) {
                                                        setState(() {
                                                          barcode =
                                                              value;
                                                          if (value.isEmpty) {
                                                            barCodeSet =
                                                                false;
                                                          } else {
                                                            barCodeSet =
                                                                true;
                                                          }
                                                        });
                                                        mainLocalLog(
                                                          barcode,
                                                        );
                                                        mainLocalLog(
                                                          barCodeSet.toString(),
                                                        );
                                                      },
                                                      enabled:
                                                          true,
                                                      decoration: InputDecoration(
                                                        isCollapsed:
                                                            true,
                                                        suffixIcon: Padding(
                                                          padding: const EdgeInsets.only(
                                                            right:
                                                                50.0,
                                                          ),
                                                          child: Icon(
                                                            size:
                                                                20,
                                                            color:
                                                                Colors.grey,
                                                            Icons.qr_code_scanner_sharp,
                                                          ),
                                                        ),
                                                        suffixIconConstraints: BoxConstraints(
                                                          maxHeight:
                                                              20,
                                                          maxWidth:
                                                              35,
                                                        ),
                                                        contentPadding: EdgeInsets.symmetric(
                                                          horizontal:
                                                              20,
                                                          vertical:
                                                              8,
                                                        ),
                                                        hintText:
                                                            barcode ??
                                                            'Click to Scan Item Barcode',
                                                        hintStyle: TextStyle(
                                                          color:
                                                              barCodeSet
                                                                  ? Colors.grey.shade700
                                                                  : Colors.grey.shade500,
                                                          fontSize:
                                                              theme.mobileTexts.b2.fontSize,
                                                          fontWeight:
                                                              barCodeSet
                                                                  ? FontWeight.bold
                                                                  : FontWeight.normal,
                                                        ),
                                                        border: OutlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                Colors.grey,
                                                            width:
                                                                1,
                                                          ),
                                                          borderRadius: BorderRadius.circular(
                                                            5,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .end,
                                            children: [
                                              InkWell(
                                                mouseCursor:
                                                    SystemMouseCursors
                                                        .click,
                                                onTap: () async {
                                                  ItemsAuthAction().generateBarcodeAction(
                                                    context:
                                                        context,
                                                    action: () async {
                                                      String
                                                      sellingPrice() {
                                                        if (widget.sellingController.text.isEmpty) {
                                                          return '';
                                                        } else {
                                                          if (widget.sellingController.text
                                                                  .split(
                                                                    ',',
                                                                  )
                                                                  .length >
                                                              1) {
                                                            return widget.sellingController.text
                                                                    .split(
                                                                      ',',
                                                                    )
                                                                    .first +
                                                                widget.sellingController.text
                                                                    .split(
                                                                      ',',
                                                                    )
                                                                    .last;
                                                          } else {
                                                            return widget.sellingController.text;
                                                          }
                                                        }
                                                      }

                                                      wholeSalePrice() {
                                                        if (widget.wholeSaleController.text.isEmpty) {
                                                          return '';
                                                        } else {
                                                          if (widget.wholeSaleController.text
                                                                  .split(
                                                                    ',',
                                                                  )
                                                                  .length >
                                                              1) {
                                                            return widget.wholeSaleController.text
                                                                    .split(
                                                                      ',',
                                                                    )
                                                                    .first +
                                                                widget.wholeSaleController.text
                                                                    .split(
                                                                      ',',
                                                                    )
                                                                    .last;
                                                          } else {
                                                            return widget.wholeSaleController.text;
                                                          }
                                                        }
                                                      }

                                                      var tempProduct = TempProductClass(
                                                        manageSalesWastage:
                                                            null,
                                                        heightDimension:
                                                            null,
                                                        quantityType:
                                                            1,
                                                        widthDimension:
                                                            null,
                                                        pricesList:
                                                            widget.product?.pricesList ??
                                                            [],
                                                        unitsList:
                                                            widget.product?.unitsList ??
                                                            [],
                                                        categories:
                                                            widget.product?.categories ??
                                                            [],
                                                        storageUuid:
                                                            widget.product?.storageUuid,
                                                        departmentName:
                                                            returnData().departmentUuid !=
                                                                    null
                                                                ? returnDepartmentProvider().departments
                                                                    .where(
                                                                      (
                                                                        d,
                                                                      ) =>
                                                                          d.uuid ==
                                                                          returnData().departmentUuid,
                                                                    )
                                                                    .firstOrNull
                                                                    ?.name
                                                                : returnDepartmentProvider().currentDepartment()?.name,
                                                        departmentUuid:
                                                            returnData().departmentUuid ??
                                                            returnDepartmentProvider().currentDepartment()?.uuid,
                                                        groupUnit:
                                                            widget.product?.groupUnit,
                                                        qttyPerGroup:
                                                            widget.product?.qttyPerGroup,
                                                        name:
                                                            widget.product ==
                                                                    null
                                                                ? widget.nameController.text
                                                                : widget.product?.name ??
                                                                    'Product Name',
                                                        unit:
                                                            'Unit(s)',
                                                        isRefundable:
                                                            false,
                                                        costPrice:
                                                            0,
                                                        shopId:
                                                            1,
                                                        setCustomPrice:
                                                            false,
                                                        isManaged:
                                                            false,
                                                        useGroupUnit:
                                                            false,
                                                        uuid:
                                                            widget.product ==
                                                                    null
                                                                ? createdProductUuid
                                                                : widget.product?.uuid,
                                                        sellingPrice:
                                                            widget.product ==
                                                                    null
                                                                ? double.tryParse(
                                                                  sellingPrice(),
                                                                )
                                                                : widget.product?.sellingPrice,
                                                        wholeSalePrice:
                                                            widget.product ==
                                                                    null
                                                                ? double.tryParse(
                                                                  wholeSalePrice(),
                                                                )
                                                                : widget.product?.wholeSalePrice,
                                                      );

                                                      if (widget
                                                          .nameController
                                                          .text
                                                          .isNotEmpty) {
                                                        returnData().addToBarcodeGenerationList(
                                                          ProductBarcode(
                                                            product:
                                                                tempProduct,
                                                            number:
                                                                1,
                                                          ),
                                                        );
                                                        await generateBarcodeAndPrint(
                                                          context,
                                                          returnData().barcodeGenerationList,
                                                          true,
                                                        );
                                                        // if (res) {
                                                        setState(() {
                                                          barcode = returnOnlyDigits(
                                                            widget.product ==
                                                                    null
                                                                ? createdProductUuid!
                                                                : widget.product!.uuid!,
                                                          );
                                                          barCodeSet =
                                                              true;
                                                        });
                                                        // }
                                                      } else {
                                                        showDialog(
                                                          context:
                                                              context,
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return InfoAlert(
                                                              theme:
                                                                  theme,
                                                              message:
                                                                  'Product Name must be set before barcode can be generated.',
                                                              title:
                                                                  'Product Name Not Set',
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                  );
                                                },
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(
                                                        5.0,
                                                      ),
                                                  child: Row(
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Icon(
                                                        size:
                                                            15,
                                                        color:
                                                            theme.lightModeColor.secColor200,
                                                        Icons.qr_code_rounded,
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              theme.mobileTexts.b3.fontSize,
                                                        ),
                                                        'Generate Barcode',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      AllowToManageItemQuantityAddItemPage(
                                        theme: theme,
                                      ),
                                      AllowToSetCustomPriceAddItemPage(
                                        theme: theme,
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15),
                                  Divider(height: 0),
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
                                                    left:
                                                        35.0,
                                                    top: 5,
                                                    bottom:
                                                        5,
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
                                                        ? Icons.keyboard_arrow_up_outlined
                                                        : Icons.keyboard_arrow_down,
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
                                  Divider(height: 0),
                                  SizedBox(height: 15),
                                  Visibility(
                                    visible: expand,
                                    child: Column(
                                      children: [
                                        Column(
                                          children: [
                                            EditCartTextField(
                                              theme: theme,
                                              hint:
                                                  'Enter Discount (%)',
                                              title:
                                                  'Discount Percent (%)',
                                              controller:
                                                  widget
                                                      .discountController,
                                              onChanged: (
                                                value,
                                              ) {
                                                if (value
                                                    .isNotEmpty) {
                                                  if (int.parse(
                                                        value,
                                                      ) >
                                                      100) {
                                                    widget
                                                        .discountController
                                                        .text = '100';
                                                  }
                                                }
                                              },
                                            ),
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
                                                        Authorizations().viewAllDepartments,
                                                  ),
                                              child:
                                                  SizedBox(
                                                    height:
                                                        10,
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
                                                        Authorizations().viewAllDepartments,
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
                                                  spacing:
                                                      5,
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
                                                          borderRadius: BorderRadius.circular(
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
                                                                              .where(
                                                                                (
                                                                                  dept,
                                                                                ) =>
                                                                                    dept.uuid ==
                                                                                    returnData().departmentUuid,
                                                                              )
                                                                              .firstOrNull
                                                                              ?.name ??
                                                                          'Select Department',
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
                                                        borderRadius: BorderRadius.circular(
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
                                            SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        ),
                                        SelectProductQuantityTypeSection(
                                          heightController:
                                              widget
                                                  .heightController,
                                          quantityType:
                                              quantityType,
                                          switchQuantityType: (
                                            index,
                                          ) {
                                            switchQuantityType(
                                              index,
                                            );
                                          },
                                          widthController:
                                              widget
                                                  .widthController,
                                        ),
                                        Visibility(
                                          visible:
                                              canSeeItemUnit(),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                  bottom:
                                                      10.0,
                                                ),
                                            child: Column(
                                              children: [
                                                UseMultipleToggleAddItemPage(
                                                  theme:
                                                      theme,
                                                  title:
                                                      'Use Multiple Units',
                                                  description:
                                                      'Turn on to sell or count this item in more than one unit (e.g. Bottle and Crate).',
                                                  value:
                                                      returnData(
                                                        context:
                                                            context,
                                                      ).useMultipleUnits,
                                                  onTap: () {
                                                    toggleMultipleUnitsAction(
                                                      context:
                                                          context,
                                                    );
                                                  },
                                                ),
                                                SizedBox(
                                                  height:
                                                      10,
                                                ),
                                                SubWrapper(
                                                  isVisible:
                                                      !itemUnitAuthAction(
                                                        context:
                                                            context,
                                                      ),
                                                  mainWidget:
                                                      returnData(
                                                            context:
                                                                context,
                                                          ).useMultipleUnits
                                                          ? MainDropdown(
                                                            valueSet:
                                                                returnData().tempUnitsList.isNotEmpty,
                                                            onTap: () {
                                                              itemUnitAuthAction(
                                                                context:
                                                                    context,
                                                                action: () {
                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      builder: (
                                                                        context,
                                                                      ) {
                                                                        return ProductUnitsPage(
                                                                          productUuid:
                                                                              createdProductUuid ??
                                                                              '',
                                                                          isDimensional:
                                                                              quantityType ==
                                                                              2,
                                                                        );
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            isOpen:
                                                                returnData().tempUnitsList.isNotEmpty,
                                                            title:
                                                                'Item Unit(s) (Optional)',
                                                            hint:
                                                                returnData(
                                                                      context:
                                                                          context,
                                                                    ).tempUnitsList.isEmpty
                                                                    ? 'Unit Not Set'
                                                                    : "${returnData(context: context).tempUnitsList.firstWhere((item) => item.isPrimary).name} and (${returnData(context: context).tempUnitsList.length - 1}) More",
                                                            theme:
                                                                theme,
                                                          )
                                                          : MainDropdown(
                                                            valueSet:
                                                                returnData().tempUnitsList.isNotEmpty,
                                                            onTap: () {
                                                              selectSingleUnitAction(
                                                                context:
                                                                    context,
                                                                productUuid:
                                                                    createdProductUuid ??
                                                                    '',
                                                                isDimensional:
                                                                    quantityType ==
                                                                    2,
                                                              );
                                                            },
                                                            isOpen:
                                                                false,
                                                            title:
                                                                'Item Unit (Optional)',
                                                            hint:
                                                                returnData(
                                                                  context:
                                                                      context,
                                                                ).singleUnitName() ??
                                                                'Unit Not Set',
                                                            theme:
                                                                theme,
                                                          ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Price entry only works out
                                        // quantity for 1D items.
                                        Visibility(
                                          visible:
                                              quantityType !=
                                              2,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(
                                                  top: 10.0,
                                                ),
                                            child: UseMultipleToggleAddItemPage(
                                              theme: theme,
                                              title:
                                                  'Derive Quantity From Price',
                                              description:
                                                  'Turn on to let sellers enter a price during sale; the app works out the quantity for that price.',
                                              value:
                                                  returnData(
                                                    context:
                                                        context,
                                                  ).deriveQuantityFromPrice,
                                              onTap: () {
                                                returnData()
                                                    .toggleDeriveQuantityFromPrice();
                                              },
                                            ),
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            SubWrapper(
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
                                                    ).sizeValueSet,
                                                onTap: () {
                                                  ItemsAuthAction().applyVariationsAction(
                                                    context:
                                                        context,
                                                    action: () {
                                                      sizeTypeBottomSheet(
                                                        context,
                                                        () {
                                                          setState(
                                                            () {
                                                              isSizedTypeOpen =
                                                                  !isSizedTypeOpen;
                                                            },
                                                          );
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
                                                    returnData()
                                                        .selectedSize ??
                                                    'Select Item Size Type',
                                                theme:
                                                    theme,
                                              ),
                                            ),

                                            SizedBox(
                                              height: 10,
                                            ),
                                            SubWrapper(
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
                                                    ).catValueSet,
                                                onTap: () {
                                                  ItemsAuthAction().applyVariationsAction(
                                                    context:
                                                        context,
                                                    action: () {
                                                      categoriesBottomSheet(
                                                        context,
                                                        () {
                                                          setState(
                                                            () {
                                                              isOpen =
                                                                  false;
                                                            },
                                                          );
                                                        },
                                                      );
                                                      setState(() {
                                                        isOpen =
                                                            !isOpen;
                                                      });
                                                    },
                                                  );
                                                },
                                                isOpen:
                                                    isOpen,
                                                title:
                                                    'Categories (Optional)',
                                                hint:
                                                    returnData(
                                                          context:
                                                              context,
                                                        ).selectedCategories.toList().isNotEmpty
                                                        ? "(${returnData(context: context).selectedCategories.toList().length}) Categories Selected"
                                                        : 'Select Item Categories',
                                                theme:
                                                    theme,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        if (widget.product !=
                                                null &&
                                            returnShopProvider()
                                                    .userShops
                                                    .length >
                                                1) ...[
                                          BranchProductLinkWidget(
                                            currentProduct:
                                                widget
                                                    .product,
                                            theme: theme,
                                            onBranchesChanged: (
                                              staged,
                                              removed,
                                              unlinked,
                                            ) {
                                              setState(() {
                                                stagedBranchLinks =
                                                    staged;
                                                removedBranchLinks =
                                                    removed;
                                                isBranchUnlinked =
                                                    unlinked;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                        if (widget.product !=
                                                null &&
                                            returnShopProvider()
                                                    .userShop()
                                                    ?.manageDepartments ==
                                                true) ...[
                                          DepartmentProductLinkWidget(
                                            currentProduct:
                                                widget
                                                    .product,
                                            theme: theme,
                                            onDepartmentsChanged: (
                                              staged,
                                              removed,
                                              unlinked,
                                            ) {
                                              setState(() {
                                                stagedDeptLinks =
                                                    staged;
                                                removedDeptLinks =
                                                    removed;
                                                isDeptUnlinked =
                                                    unlinked;
                                              });
                                            },
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                        ],
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
                              widget.product != null
                                  ? updateProduct()
                                  : checkFields();
                            },
                            text:
                                widget.product != null
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
                  widget.product != null
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
              widget.product != null
                  ? 'Item Updated Successfully'
                  : 'Item Created Successfully',
            ),
          ),
        ],
      ),
    );
  }
}
