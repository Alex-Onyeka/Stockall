import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
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
import 'package:stockall/pages/products/add_product_one/platforms/components/select_product_quantity_type_section.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/use_multiple_toggle_add_item_page.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/product_prices_page.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/product_units_page.dart';
import 'package:stockall/providers/data_provider.dart';

class AddProductMobile extends StatefulWidget {
  final TempProductClass? product;
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController nameController;
  final TextEditingController lowQttyController;
  // final TextEditingController quantityController;
  final TextEditingController discountController;
  // final TextEditingController storageQuantityController;
  final TextEditingController qttyPerGroupController;
  final TextEditingController wholeSaleController;
  final TextEditingController heightController;
  final TextEditingController widthController;

  const AddProductMobile({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.nameController,
    required this.lowQttyController,
    // required this.quantityController,
    required this.discountController,
    // required this.storageQuantityController,
    required this.qttyPerGroupController,
    required this.wholeSaleController,
    required this.heightController,
    required this.widthController,
    this.product,
  });

  @override
  State<AddProductMobile> createState() =>
      _AddProductMobileState();
}

class _AddProductMobileState
    extends State<AddProductMobile> {
  bool barCodeSet = false;
  bool isLoading = false;
  bool showSuccess = false;
  bool expand = false;
  String? barcode;
  //
  //
  //
  //

  bool isSizedTypeOpen = false;

  TextEditingController expiryDateC =
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
    } else if (quantityType == 2 &&
        (widget.heightController.text.isEmpty ||
            widget.widthController.text.isEmpty)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Max-Width and Max-Height Cannot be Empty For 2 Dimensional Items.',
            title: 'Max-Width and Max-Height Not Set',
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
                source: 'Not Set',
                event: ItemHistoryEventClass.itemCreated,
                isManaged: true,
                unit: 'Not Set',
                shopId: shopId(),
                title: 'Item Created',
                quantityChange: 0,
                newValue: '0',
                desc: 'Item Created Now',
                isIncreased: true,
                oldValue: '0',
              );

              await dataProvider.createProduct(
                isMultiple: false,
                itemHistory: itemHistory,
                product: TempProductClass(
                  manageSalesWastage:
                      dataProvider.manageWastage,
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
                  unitsList: dataProvider.getFinalUnitList(),
                  pricesList: dataProvider.getFinalPriceList(
                    productUuid: createdProductUuid ?? '',
                    sellingText: widget.sellingController.text,
                  ),
                  useGroupUnit: dataProvider.useGroupUnit,
                  categories:
                      dataProvider.selectedCategories
                          .toList(),
                  storageUuid: null,
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
                  isManaged: dataProvider.isManaged,
                  name: widget.nameController.text.trim(),
                  unit:
                      (dataProvider.useMultipleUnits
                          ? dataProvider.selectedUnit
                          : dataProvider.singleUnitName()) ??
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
                ),
              );

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
    if (quantityType == 2 &&
        (widget.heightController.text.isEmpty ||
            widget.widthController.text.isEmpty)) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'Max-Width and Max-Height Cannot be Empty For 2 Dimensional Items.',
            title: 'Max-Width and Max-Height Not Set',
          );
        },
      );
    } else {
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
              final provider = returnData();
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }

              setState(() {
                isLoading = true;
              });

              var res = await provider.updateProduct(
                itemHistory: null,
                includeQuantity: false,
                isIncrement: null,
                isQuantityUpdate: false,
                quantityChange: null,
                product: TempProductClass(
                  manageSalesWastage:
                      provider.manageWastage,
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
                  unitsList: provider.getFinalUnitList(),
                  pricesList: provider.getFinalPriceList(
                    productUuid: createdProductUuid ?? '',
                    sellingText: widget.sellingController.text,
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
                  // id: widget.product!.id,
                  totalQttyInStorageDouble: null,
                  uuid: widget.product!.uuid,
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
                  quantity: widget.product?.quantity,
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
                  lowQtty:
                      widget.lowQttyController.text.isEmpty
                          ? 10
                          : double.tryParse(
                            widget.lowQttyController.text
                                .replaceAll(',', ''),
                          ),
                  sizeType: provider.selectedSize,
                  // startDate: provider.startDate,
                ),
                oldProduct: widget.product!,
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

    WidgetsBinding.instance.addPostFrameCallback((context) {
      clearFields();
    });
    if (widget.product == null) {
      setState(() {
        createdProductUuid = uuidGen();
      });
    } else {
      createdProductUuid = widget.product?.uuid;
    }
    // setShop();
  }

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      returnData().clearFields(setIsManaged: false);
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
    if (widget.product != null && context.mounted) {
      returnData().manageWastage =
          widget.product?.manageSalesWastage ?? false;
      barcode = widget.product!.barcode;
      barCodeSet =
          widget.product!.barcode != null ? true : false;

      widget.nameController.text = widget.product!.name;
      widget.lowQttyController.text =
          widget.product!.lowQtty!.toString();
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
      returnData().departmentUuid =
          widget.product?.departmentUuid;
      returnData().expiryDate = widget.product?.expiryDate;
      returnData().isProductRefundable =
          widget.product!.isRefundable;
      returnData().isManaged = widget.product!.isManaged;
      returnData().useGroupUnit =
          widget.product!.useGroupUnit ?? false;
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
            primaryValue != 0 ? primaryValue.toString() : '';
      }
      returnData().setCustomPrice =
          widget.product!.setCustomPrice;
      returnData().selectUnit(widget.product!.unit);
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
                  widget.product != null
                      ? 'Edit Item'
                      : 'New Item',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
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
                              SizedBox(height: 10),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .manageCostPrice,
                                ),
                                child: MoneyTextfield(
                                  theme: theme,
                                  hint: 'Enter Real Cost',
                                  title:
                                      'Cost - Price (Optional)',
                                  controller:
                                      widget.costController,
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                      top: 15.0,
                                    ),
                                child: UseMultipleToggleAddItemPage(
                                  theme: theme,
                                  title:
                                      'Manage Multiple Prices',
                                  description:
                                      'Turn on to set more than one selling price for this item.',
                                  value:
                                      returnData(
                                        context: context,
                                      ).useMultiplePrices,
                                  onTap: () {
                                    toggleMultiplePricesAction(
                                      context: context,
                                      sellingController:
                                          widget
                                              .sellingController,
                                      productUuid:
                                          createdProductUuid ??
                                          '',
                                    );
                                  },
                                ),
                              ),
                              Visibility(
                                visible:
                                    !returnData(
                                      context: context,
                                    ).useMultiplePrices,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                        bottom: 10.0,
                                        top: 10,
                                      ),
                                  child: MoneyTextfield(
                                    theme: theme,
                                    hint: 'Enter Selling Price',
                                    title: 'Selling Price',
                                    controller:
                                        widget.sellingController,
                                  ),
                                ),
                              ),
                              Visibility(
                                visible:
                                    returnData(
                                      context: context,
                                    ).useMultiplePrices,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                        bottom: 10.0,
                                        top: 10,
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
                                          builder: (context) {
                                            return ProductPricesPage(
                                              productUuid:
                                                  createdProductUuid ??
                                                  '',
                                            );
                                          },
                                        ),
                                      );
                                    },
                                    isOpen:
                                        returnData()
                                            .tempPricesList
                                            .isNotEmpty,
                                    title: 'Selling Price(s)',
                                    hint:
                                        returnData(
                                                  context:
                                                      context,
                                                )
                                                .tempPricesList
                                                .isEmpty
                                            ? 'Price Not Set'
                                            : "${returnData(context: context).tempPricesList.firstWhere((item) => item.isPrimary).priceValue} and (${returnData(context: context).tempPricesList.length - 1}) More",
                                    theme: theme,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  SizedBox(height: 20),
                                  AllowToManageItemQuantityAddItemPage(
                                    theme: theme,
                                  ),
                                  SizedBox(height: 20),
                                  AllowToSetCustomPriceAddItemPage(
                                    theme: theme,
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
                                        BarcodeScanner(
                                          valueSet:
                                              barCodeSet,
                                          onTap: () async {
                                            ItemsAuthAction().useOfBArcodeAction(
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
                                          theme: theme,
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
                                                      if (widget
                                                          .sellingController
                                                          .text
                                                          .isEmpty) {
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
                                                      if (widget
                                                          .wholeSaleController
                                                          .text
                                                          .isEmpty) {
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
                                                      unitsList:
                                                          widget.product?.unitsList ??
                                                          [],
                                                      pricesList:
                                                          widget.product?.pricesList ??
                                                          [],
                                                      categories:
                                                          widget.product?.categories ??
                                                          [],
                                                      storageUuid:
                                                          widget.product?.storageUuid,
                                                      departmentName:
                                                          returnDepartmentProvider().currentDepartment()?.name,
                                                      departmentUuid:
                                                          returnDepartmentProvider().currentDepartment()?.name,
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
                                                        // barcodeController.text =
                                                        //     barcode ??
                                                        //     '';
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
                                                      Icons
                                                          .qr_code_rounded,
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
                                    Column(
                                      children: [
                                        SizedBox(
                                          height: 10,
                                        ),
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
                                      visible: canSeeItemUnit(),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(
                                              top: 10.0,
                                            ),
                                        child: Column(
                                          children: [
                                            UseMultipleToggleAddItemPage(
                                              theme: theme,
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
                                              height: 10,
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
                                                            returnData()
                                                                .tempUnitsList
                                                                .isNotEmpty,
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
                                                        isOpen: false,
                                                        title:
                                                            'Item Unit (Optional)',
                                                        hint:
                                                            returnData(
                                                                  context:
                                                                      context,
                                                                ).tempUnitsList.isEmpty
                                                                ? 'Unit Not Set'
                                                                : "${returnData(context: context).tempUnitsList.firstWhere((item) => item.isPrimary).name} and (${returnData(context: context).tempUnitsList.length - 1}) More",
                                                        theme: theme,
                                                      )
                                                      : MainDropdown(
                                                        valueSet:
                                                            returnData()
                                                                .tempUnitsList
                                                                .isNotEmpty,
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
                                                        isOpen: false,
                                                        title:
                                                            'Item Unit (Optional)',
                                                        hint:
                                                            returnData(
                                                              context:
                                                                  context,
                                                            ).singleUnitName() ??
                                                            'Unit Not Set',
                                                        theme: theme,
                                                      ),
                                            ),
                                          ],
                                        ),
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
    );
  }
}
