import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
// import 'package:path/path.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
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
import 'package:stockall/constants/generate_barcode.dart';
// import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/data_provider.dart';

class AddProductMobile extends StatefulWidget {
  final TempProductClass? product;
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController nameController;
  final TextEditingController lowQttyController;
  final TextEditingController quantityController;
  final TextEditingController discountController;
  final TextEditingController storageQuantityController;
  final TextEditingController qttyPerGroupController;
  final TextEditingController wholeSaleController;

  const AddProductMobile({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.nameController,
    required this.lowQttyController,
    required this.quantityController,
    required this.discountController,
    required this.storageQuantityController,
    required this.qttyPerGroupController,
    required this.wholeSaleController,
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
    } else if (widget.discountController.text.isNotEmpty
    // &&
    //     returnData().endDate == null
    ) {
      showDialog(
        context: context,
        builder: (context) {
          var theme = returnTheme(context);
          return InfoAlert(
            theme: theme,
            message:
                'If you want to set a discount for this item, you must set end date for that discount.',
            title: 'Set End Date for Discount',
          );
        },
      );
    } else {
      final safeContext = context;
      var samePro = returnData().productList.where(
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
              final shopId =
                  returnShopProvider().userShop()!.shopId;

              await dataProvider.createProduct(
                TempProductClass(
                  totalQttyInStorageDouble:
                      widget
                              .storageQuantityController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget
                                .storageQuantityController
                                .text
                                .replaceAll(',', ''),
                          )
                          : null,
                  isManaged:
                      widget.quantityController.text.isEmpty
                          ? false
                          : dataProvider.isManaged,
                  name: widget.nameController.text.trim(),
                  unit:
                      dataProvider.selectedUnit ?? 'Others',
                  groupUnit:
                      dataProvider.selectedGroupUnit ??
                      'Others',
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
                  shopId: userShop!.shopId!,
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
                      widget
                              .quantityController
                              .text
                              .isNotEmpty
                          ? double.parse(
                            widget.quantityController.text
                                .replaceAll(',', ''),
                          )
                          : null,
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
                  categoryUuid:
                      dataProvider.selectedCategory?.uuid,
                  uuid: createdProductUuid,
                ),
                context,
              );

              await dataProvider.getProducts(shopId!);

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

  void updateProduct() {
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
            final provider = returnData();
            final shopProvider = returnShopProvider();

            if (safeContext.mounted) {
              Navigator.of(safeContext).pop();
            }

            setState(() {
              isLoading = true;
            });
            double totalQttyInStorageCalc() {
              final total =
                  widget
                      .product
                      ?.totalQttyInStorageDouble ??
                  0;
              final qty =
                  double.tryParse(
                    widget.quantityController.text
                        .replaceAll(',', ''),
                  ) ??
                  0;
              final currentQty =
                  widget.product?.quantity ?? 0;

              double result =
                  (total - (qty - currentQty)).toDouble();

              return result < 0 ? 0 : result;
            }

            await provider.updateProduct(
              product: TempProductClass(
                setCustomPrice: provider.setCustomPrice,
                isManaged:
                    widget.quantityController.text.isEmpty
                        ? false
                        : provider.isManaged,
                // id: widget.product!.id,
                totalQttyInStorageDouble:
                    totalQttyInStorageCalc(),
                uuid: widget.product!.uuid,
                name: widget.nameController.text,
                unit: provider.selectedUnit!,
                groupUnit: provider.selectedGroupUnit,
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
                isRefundable: provider.isProductRefundable,
                costPrice:
                    widget.costController.text.isNotEmpty
                        ? double.parse(
                          widget.costController.text
                              .replaceAll(',', ''),
                        )
                        : 0,
                sellingPrice:
                    widget.sellingController.text.isNotEmpty
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
                    widget
                            .quantityController
                            .text
                            .isNotEmpty
                        ? double.parse(
                          widget.quantityController.text
                              .replaceAll(',', ''),
                        )
                        : null,
                shopId: userShop!.shopId!,
                barcode: barcode,
                categoryUuid:
                    provider.selectedCategory?.uuid,
                createdAt: widget.product!.createdAt,
                discount: double.tryParse(
                  widget.discountController.text.replaceAll(
                    ',',
                    '',
                  ),
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
            await provider.getProducts(
              shopProvider.userShop()!.shopId!,
            );

            setState(() {
              isLoading = false;
              showSuccess = true;
            });

            if (safeContext.mounted) {
              provider.clearFields();
            }

            Future.delayed(Duration(seconds: 2), () {
              if (safeContext.mounted) {
                Navigator.of(safeContext).pop();
              }
            });
          },
        );
      },
    );
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
    if (widget.product != null && context.mounted) {
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
      widget.quantityController.text =
          widget.product!.quantity == null
              ? ''
              : widget.product!.quantity.toString();

      widget.discountController.text =
          widget.product!.discount != null
              ? widget.product!.discount!.toString()
              : '';
      returnData().isProductRefundable =
          widget.product!.isRefundable;
      returnData().isManaged = widget.product!.isManaged;
      returnData().setCustomPrice =
          widget.product!.setCustomPrice;
      // returnData().selectedUnit =
      //     widget.product!.unit;
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
      widget.product!.categoryUuid != null
          ? returnData().selectCategory(
            returnCategoriesProvider().categories
                    .where(
                      (cat) =>
                          cat.uuid ==
                          widget.product?.categoryUuid,
                    )
                    .isNotEmpty
                ? returnCategoriesProvider().categories
                    .where(
                      (cat) =>
                          cat.uuid ==
                          widget.product?.categoryUuid,
                    )
                    .first
                : CategoryClass(
                  name: 'Not Set',
                  shopId: shopId(),
                  uuid: 'uuid',
                ),
          )
          : null;
      // setState(() {
      //   costDiscount =
      //       widget.product!.discount != null &&
      //               widget.product!.sellingPrice != null
      //           ? widget.product!.sellingPrice! *
      //               (widget.product!.discount! / 100)
      //           : 0;
      //   sellingDiscount =
      //       widget.product!.discount != null &&
      //               widget.product!.sellingPrice != null
      //           ? widget.product!.sellingPrice! -
      //               (widget.product!.sellingPrice! *
      //                   (widget.product!.discount! / 100))
      //           : 0;
      //   selling =
      //       double.tryParse(
      //         widget.sellingController.text.replaceAll(
      //           ',',
      //           '',
      //         ),
      //       ) ??
      //       0;
      // });
    }
  }

  TempShopClass? userShop;
  void setShop() async {
    await returnShopProvider().getUserShops();

    setState(() {
      userShop = returnShopProvider().userShop();
    });
  }

  // double cost = 0;
  // double selling = 0;
  // double discount = 0;

  // double costDiscount = 0;

  // double sellingDiscount = 0;

  // void checkDiscount() {
  //   final discountedPrice = selling * (discount / 100);
  //   final discountedSellingPrice =
  //       selling - (selling * (discount / 100));
  //   setState(() {
  //     costDiscount = discountedPrice;
  //     sellingDiscount = discountedSellingPrice;
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
                              Row(
                                spacing: 10,
                                children: [
                                  Expanded(
                                    child: MoneyTextfield(
                                      onChanged: (value) {
                                        // if (value.isEmpty) {
                                        //   cost = 0;
                                        // } else {
                                        //   setState(() {
                                        //     cost = double.parse(
                                        //       widget
                                        //           .costController
                                        //           .text
                                        //           .replaceAll(
                                        //             ',',
                                        //             '',
                                        //           ),
                                        //     );
                                        //   });
                                        // }
                                      },
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
                                  Expanded(
                                    child: MoneyTextfield(
                                      onChanged: (value) {
                                        // if (value.isEmpty) {
                                        //   selling = 0;
                                        // } else {
                                        //   setState(() {
                                        //     selling = double.parse(
                                        //       widget
                                        //           .sellingController
                                        //           .text
                                        //           .replaceAll(
                                        //             ',',
                                        //             '',
                                        //           ),
                                        //     );
                                        //   });
                                        // }
                                      },
                                      theme: theme,
                                      hint:
                                          'Enter Sale Price',
                                      title:
                                          'Selling-Price (Optional)',
                                      controller:
                                          widget
                                              .sellingController,
                                    ),
                                  ),
                                ],
                              ),
                              Visibility(
                                visible:
                                    shop(
                                      context,
                                    )?.wholeSale ==
                                    true,
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    MoneyTextfield(
                                      theme: theme,
                                      hint:
                                          'Enter Whole Sale Price',
                                      title:
                                          'Whole-Sale-Price (Optional)',
                                      controller:
                                          widget
                                              .wholeSaleController,
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible:
                                    returnShopProvider()
                                            .userShop()
                                            ?.manageInventoryStorage ==
                                        true &&
                                    widget.product ==
                                        null &&
                                    ItemsAuthAction()
                                        .manageInventoryStorageAction(
                                          context: context,
                                        ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    EditCartTextField(
                                      theme: theme,
                                      hint:
                                          'Enter Quantity In Storage',
                                      title:
                                          'Storage Quantity (Optional)',
                                      controller:
                                          widget
                                              .storageQuantityController,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              EditCartTextField(
                                theme: theme,
                                hint: 'Enter Quantity',
                                title:
                                    'Quantity (Optional)',
                                controller:
                                    widget
                                        .quantityController,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    if (widget.product !=
                                            null &&
                                        widget
                                                .product
                                                ?.isManaged ==
                                            true &&
                                        returnShopProvider()
                                                .userShop()
                                                ?.manageInventoryStorage ==
                                            true) {
                                      if (((double.tryParse(
                                                value
                                                    .replaceAll(
                                                      ',',
                                                      '',
                                                    ),
                                              ) ??
                                              0)) >
                                          ((widget
                                                      .product
                                                      ?.totalQttyInStorageDouble ??
                                                  0) +
                                              (double.tryParse(
                                                    widget.product?.quantity?.toString() ??
                                                        '0',
                                                  ) ??
                                                  0))) {
                                        widget
                                            .quantityController
                                            .text = (widget
                                                        .product
                                                        ?.quantity ??
                                                    0)
                                                .toString();
                                      }
                                    }
                                  }
                                },
                              ),
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  returnData()
                                      .toggleIsManaged(
                                        context: context,
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
                                                'This controls whether Item quantity is automatically deducted after sales, and notifications are sent when item quantity is low or out of stock.',
                                              ),
                                              // Text(
                                              //   'NOTE: if "YES", then cashier can set a custom price during sale, instead of the selling price.',
                                              // ),
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
                                      onChanged: (value) {
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
                              SizedBox(height: 20),
                              InkWell(
                                onTap: () {
                                  returnData()
                                      .toggleSetCustomPrice();
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
                                            'Allow To Set Custom Price?',
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            spacing: 5,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      10,
                                                ),
                                                'Allow Cashier to Set custom price during sale? ',
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      10,
                                                ),
                                                'NOTE: if "YES", then cashier can set a custom price during sale, instead of the selling price.',
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
                                          ).setCustomPrice,
                                      onChanged: (value) {
                                        returnData()
                                            .toggleSetCustomPrice();
                                        FocusManager
                                            .instance
                                            .primaryFocus
                                            ?.unfocus();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 15),
                              Divider(),
                              // SizedBox(height: 5),
                              InkWell(
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
                                                          'Others',
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
                                    SizedBox(height: 10),
                                    EditCartTextField(
                                      theme: theme,
                                      hint:
                                          'Enter Discount (%)',
                                      title:
                                          'Discount Percent (%)',
                                      controller:
                                          widget
                                              .discountController,
                                      onChanged: (value) {
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
                                    SizedBox(height: 10),
                                    EditCartTextField(
                                      theme: theme,
                                      hint: 'Enter Limit',
                                      title:
                                          'Low Quantity Limit',
                                      controller:
                                          widget
                                              .lowQttyController,
                                    ),
                                    SizedBox(height: 10),
                                    InkWell(
                                      onTap: () {
                                        ItemsAuthAction().setExpiryDateAction(
                                          context: context,
                                          action: () {
                                            myDatePickerAction(
                                              theme,
                                              context,
                                            ).then((value) {
                                              value != null
                                                  ? returnData()
                                                      .setExpDate(
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
                                                    TextAlign
                                                        .start,
                                                style:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .textStyleBold,
                                                'Expiry Date (Optional)',
                                              ),
                                            ],
                                          ),
                                          SubWrapper(
                                            isVisible:
                                                !ItemsAuthAction()
                                                    .setExpiryDateAction(
                                                      context:
                                                          context,
                                                    ),
                                            mainWidget: Container(
                                              padding:
                                                  EdgeInsets.symmetric(
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
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
                                    SizedBox(height: 10),
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
                                        isOpen: isOpenUnit,
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
                                    SizedBox(height: 10),
                                    Visibility(
                                      visible:
                                          returnShopProvider(
                                                context:
                                                    context,
                                              )
                                              .userShop()
                                              ?.useGroupUnit ==
                                          true,
                                      child: SubWrapper(
                                        isVisible:
                                            !ItemsAuthAction()
                                                .useGroupUnitAction(
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
                                                    setState(() {
                                                      isOpenGroupUnit =
                                                          !isOpenGroupUnit;
                                                    });
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
                                          theme: theme,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Visibility(
                                      visible:
                                          returnShopProvider(
                                                context:
                                                    context,
                                              )
                                              .userShop()
                                              ?.useGroupUnit ==
                                          true,
                                      child: Column(
                                        children: [
                                          EditCartTextField(
                                            theme: theme,
                                            hint:
                                                'Enter Item Quantity in Group',
                                            title:
                                                'Quantity in Group (Optional)',
                                            controller:
                                                widget
                                                    .qttyPerGroupController,
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
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

                                    SizedBox(height: 10),
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
                                            'Category (Optional)',
                                        hint:
                                            returnData(
                                                  context:
                                                      context,
                                                )
                                                .selectedCategory
                                                ?.name ??
                                            'Select Item Category',
                                        theme: theme,
                                      ),
                                    ),
                                    SizedBox(height: 10),
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
