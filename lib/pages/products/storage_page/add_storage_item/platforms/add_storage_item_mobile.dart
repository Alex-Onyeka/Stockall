import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/select_product_quantity_type_section.dart';
import 'package:stockall/pages/products/add_product_one/platforms/components/use_multiple_toggle_add_item_page.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/product_units_page.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/components/storage_dimension_rules.dart';

class AddStorageItemMobile extends StatefulWidget {
  final TempStorageProducts? storageProduct;
  final TextEditingController nameController;
  final TextEditingController qttyPerGroupController;
  final TextEditingController costPriceController;
  final TextEditingController sellingPriceController;
  final TextEditingController widthController;
  final TextEditingController heightController;

  const AddStorageItemMobile({
    super.key,
    required this.nameController,
    required this.qttyPerGroupController,
    required this.costPriceController,
    required this.sellingPriceController,
    required this.widthController,
    required this.heightController,
    this.storageProduct,
  });

  @override
  State<AddStorageItemMobile> createState() => AddStorageItemMobileState();
}

class AddStorageItemMobileState extends State<AddStorageItemMobile> {
  bool isLoading = false;
  bool showSuccess = false;
  int quantityType = 1;

  void switchQuantityType(int index) {
    setState(() {
      quantityType = index;
    });
    widget.widthController.clear();
    widget.heightController.clear();
  }

  void checkFields() async {
    if (!validStorageDimensions(
      context: context,
      quantityType: quantityType,
      widthController: widget.widthController,
      heightController: widget.heightController,
    )) {
      return;
    }
    if (widget.nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message: 'Item Name Must be set before item can be created',
            title: 'Empty Input',
          );
        },
      );
    } else {
      final safeContext = context;
      var samePro = returnStorageProductProvider().storageProductListMain.where(
        (pr) =>
            pr.name.toLowerCase() == widget.nameController.text.toLowerCase(),
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
            title: samePro.isNotEmpty ? 'Item Already Exists' : 'Are you sure?',
            action: () async {
              Navigator.of(confirmDialog).pop();

              setState(() {
                isLoading = true;
              });

              final dataProvider = returnStorageProductProvider();
              var product = TempStorageProducts(
                unitsList: returnData().getFinalUnitList(),
                useGroupUnit: returnData().useGroupUnit,
                shopId: shopId(),
                name: widget.nameController.text.trim(),
                createdAt: DateTime.now(),
                groupUnit: returnData().selectedGroupUnit,
                qttyPerGroup: double.tryParse(
                  widget.qttyPerGroupController.text.replaceAll(',', ''),
                ),
                quantity: null,
                unit:
                    (returnData().useMultipleUnits
                        ? returnData().selectedUnit
                        : returnData().singleUnitName()) ??
                    'Unit(s)',
                updatedAt: DateTime.now(),
                uuid: createdProductUuid,
                costPrice: double.tryParse(
                  widget.costPriceController.text.replaceAll(',', ''),
                ),
                sellingPrice: double.tryParse(
                  widget.sellingPriceController.text.replaceAll(',', ''),
                ),
                quantityType: quantityType,
                widthDimension: parseDimension(
                  widget.widthController,
                ),
                heightDimension: parseDimension(
                  widget.heightController,
                ),
                dimensionUnit: returnData().selectedDimensionUnit,
                dimensionUnitConversion:
                    returnData().selectedDimensionConversion,
              );

              StorageItemHistory itemHistory = StorageItemHistory(
                event: StorageItemHistoryEventClass.itemCreated,
                source: StorageItemHistoryEventClass.manualSource,
                destination: StorageItemHistoryEventClass.storageDestination,
                storageUnit: 'Not Set',
                shopId: shopId(),
                title: 'Item Created',
                quantityChange: 0,
                storageItemNewValue: '0',
                desc: 'Item Created Now',
                isIncreased: true,
                storageItemOldValue: '0',
              );

              await dataProvider.createStorageProduct(
                product: product,
                itemHistory: itemHistory,
              );

              setState(() {
                isLoading = false;
                showSuccess = true;
              });

              Future.delayed(Duration(seconds: 2), () {
                // Pop current screen
                if (safeContext.mounted) {
                  Navigator.of(safeContext).pop(); // pop current page
                }
              });
            },
          );
        },
      );
    }
  }

  void updateStorageProduct() {
    if (!validStorageDimensions(
          context: context,
          quantityType: quantityType,
          widthController: widget.widthController,
          heightController: widget.heightController,
        ) ||
        !storageTypeChangeAllowed(
          context: context,
          storageProduct: widget.storageProduct,
          quantityType: quantityType,
        )) {
      return;
    }
    if (widget.nameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message: 'Item Name Must be set before item can be created',
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
            message: 'Are you sure you want to proceed with update?',
            title: 'Proceed?',
            action: () async {
              final provider = returnStorageProductProvider();
              final dataProvider = returnData();
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }

              setState(() {
                isLoading = true;
              });
              var res = await provider.updateProduct(
                isIncrement: null,
                isQuantityUpdate: false,
                quantityChange: null,
                product: TempStorageProducts(
                  unitsList:
                      returnData().getFinalUnitList(),
                  useGroupUnit: returnData().useGroupUnit,
                  createdAt: widget.storageProduct?.createdAt,
                  updatedAt: DateTime.now(),
                  uuid: createdProductUuid,
                  name: widget.nameController.text.trim(),
                  unit:
                      (dataProvider.useMultipleUnits
                          ? dataProvider.selectedUnit
                          : dataProvider
                              .singleUnitName()) ??
                      'Unit(s)',
                  groupUnit: dataProvider.selectedGroupUnit,
                  qttyPerGroup:
                      widget.qttyPerGroupController.text.isNotEmpty
                          ? double.parse(
                            widget.qttyPerGroupController.text.replaceAll(
                              ',',
                              '',
                            ),
                          )
                          : null,
                  quantity: widget.storageProduct?.quantity,
                  costPrice:
                      widget.costPriceController.text.isNotEmpty
                          ? double.parse(
                            widget.costPriceController.text.replaceAll(',', ''),
                          )
                          : null,
                  sellingPrice:
                      widget.sellingPriceController.text.isNotEmpty
                          ? double.parse(
                            widget.sellingPriceController.text.replaceAll(
                              ',',
                              '',
                            ),
                          )
                          : null,
                  shopId: shopId(),
                  quantityType: quantityType,
                  widthDimension: parseDimension(
                    widget.widthController,
                  ),
                  heightDimension: parseDimension(
                    widget.heightController,
                  ),
                  dimensionUnit: dataProvider.selectedDimensionUnit,
                  dimensionUnitConversion:
                      dataProvider.selectedDimensionConversion,
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
    if (widget.storageProduct == null) {
      createdProductUuid = uuidGen();
    } else {
      createdProductUuid = widget.storageProduct?.uuid;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearFields();
    });
  }

  String? createdProductUuid;

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      if (context.mounted) {
        returnData().clearFields(setIsManaged: false);
      }
    });
    returnData().manageWastage = false;
    if (widget.storageProduct != null) {
      widget.nameController.text = widget.storageProduct?.name ?? '';
      returnData().useGroupUnit = widget.storageProduct?.useGroupUnit ?? false;
      returnData().selectUnit(widget.storageProduct!.unit ?? 'Others');
      returnData().selectGroupUnit(unit: widget.storageProduct!.groupUnit);
      returnData().initUnitsList(
        unitsListNew: widget.storageProduct?.getUnitsList() ?? [],
        productUuid: createdProductUuid,
      );
      returnData().initPriceUnitModes();
      returnData().selectedDimensionUnit =
          widget.storageProduct?.dimensionUnit;
      returnData().selectedDimensionConversion =
          widget.storageProduct?.dimensionUnitConversion;
      widget.qttyPerGroupController.text =
          widget.storageProduct!.qttyPerGroup != null
              ? widget.storageProduct!.qttyPerGroup!.toString()
              : '';
      widget.costPriceController.text =
          widget.storageProduct!.costPrice == null
              ? ''
              : widget.storageProduct!.costPrice.toString();
      widget.sellingPriceController.text =
          widget.storageProduct!.sellingPrice == null
              ? ''
              : widget.storageProduct!.sellingPrice.toString();
      setState(() {
        quantityType =
            widget.storageProduct?.quantityType ?? 1;
      });
      widget.widthController.text =
          widget.storageProduct?.widthDimension
              ?.toString() ??
          '';
      widget.heightController.text =
          widget.storageProduct?.heightDimension
              ?.toString() ??
          '';
    }
  }

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
                  widget.storageProduct != null ? 'Edit Item' : 'New Item',
                ),
                SizedBox(height: 5),
                Text(
                  style: TextStyle(fontSize: theme.mobileTexts.b2.fontSize),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Column(
                            children: [
                              GeneralTextField(
                                theme: theme,
                                hint: 'Enter Item Name',
                                lines: 1,
                                title: 'Item Name',
                                controller: widget.nameController,
                              ),
                              SizedBox(height: 5),
                              MoneyTextfield(
                                theme: theme,
                                hint: 'Enter Cost Price',
                                title: 'Cost Price',
                                controller: widget.costPriceController,
                              ),
                              SizedBox(height: 15),
                              SelectProductQuantityTypeSection(
                                heightController:
                                    widget.heightController,
                                quantityType: quantityType,
                                switchQuantityType: (
                                  index,
                                ) {
                                  switchQuantityType(index);
                                },
                                widthController:
                                    widget.widthController,
                                showManageSalesWastage:
                                    false,
                              ),
                              Visibility(
                                visible: canSeeItemUnit(),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(
                                        bottom: 10.0,
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
                                      const SizedBox(
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
                                                  isOpen:
                                                      false,
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
                          if (widget.storageProduct != null) {
                            updateStorageProduct();
                          } else {
                            checkFields();
                          }
                        },
                        text:
                            widget.storageProduct != null
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
          child: returnCompProvider(context, listen: false).showLoader(
            message:
                widget.storageProduct != null
                    ? 'Updating Item'
                    : 'Creating Item',
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: returnCompProvider(context, listen: false).showSuccess(
            widget.storageProduct != null
                ? 'Item Updated Successfully'
                : 'Item Created Successfully',
          ),
        ),
      ],
    );
  }
}
