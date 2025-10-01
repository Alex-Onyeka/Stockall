import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/barcode_scanner.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
import 'package:stockall/components/text_fields/main_dropdown.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/auth_service.dart';

class AddProductDesktop extends StatefulWidget {
  final TempProductClass? product;
  final TextEditingController costController;
  final TextEditingController sellingController;
  final TextEditingController nameController;
  final TextEditingController lowQttyController;
  final TextEditingController quantityController;
  final TextEditingController discountController;

  const AddProductDesktop({
    super.key,
    required this.costController,
    required this.sellingController,
    required this.nameController,
    required this.lowQttyController,
    required this.quantityController,
    required this.discountController,
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
  bool isExp = false;

  String? barcode;
  //
  //
  //
  //

  bool isOpenUnit = false;
  bool isSizedTypeOpen = false;

  TextEditingController expiryDateC =
      TextEditingController();

  TextEditingController barcodeController =
      TextEditingController();
  //
  //
  //
  bool isOpen = false;

  bool setDate = false;

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
    } else if (widget.discountController.text.isNotEmpty &&
        returnData(context, listen: false).endDate ==
            null) {
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
      final safeContext = context; // screen-level context

      showDialog(
        context: safeContext,
        builder: (context) {
          return ConfirmationAlert(
            theme: returnTheme(safeContext),
            message:
                'You are about to add a new item to your stock, are you sure you want to proceed?',
            title: 'Are you sure?',
            action: () async {
              if (safeContext.mounted) {
                Navigator.of(
                  safeContext,
                ).pop(); // close dialog
              }

              setState(() {
                isLoading = true;
              });

              final dataProvider = returnData(
                safeContext,
                listen: false,
              );
              final shopId =
                  returnShopProvider(
                    context,
                    listen: false,
                  ).userShop!.shopId;

              await dataProvider.createProduct(
                TempProductClass(
                  isManaged:
                      widget.quantityController.text.isEmpty
                          ? false
                          : dataProvider.isManaged,
                  name: widget.nameController.text.trim(),
                  unit:
                      dataProvider.selectedUnit ?? 'Others',
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
                  startDate:
                      widget.discountController.text.isEmpty
                          ? null
                          : (dataProvider.startDate ??
                              DateTime.now()),
                  endDate: dataProvider.endDate,
                  expiryDate: dataProvider.expiryDate,
                  category: dataProvider.selectedCategory,
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
            final provider = returnData(
              context,
              listen: false,
            );
            final shopProvider = returnShopProvider(
              context,
              listen: false,
            );

            if (safeContext.mounted) {
              Navigator.of(safeContext).pop();
            }

            setState(() {
              isLoading = true;
            });

            await provider.updateProduct(
              context: context,
              product: TempProductClass(
                setCustomPrice: provider.setCustomPrice,
                isManaged:
                    widget.quantityController.text.isEmpty
                        ? false
                        : provider.isManaged,
                uuid: widget.product?.uuid,
                name: widget.nameController.text,
                unit: provider.selectedUnit!,
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
                category: provider.selectedCategory,
                createdAt: widget.product!.createdAt,
                discount: double.tryParse(
                  widget.discountController.text.replaceAll(
                    ',',
                    '',
                  ),
                ),
                endDate: provider.endDate,
                expiryDate: provider.expiryDate,
                lowQtty:
                    widget.lowQttyController.text.isEmpty
                        ? 10
                        : double.tryParse(
                          widget.lowQttyController.text
                              .replaceAll(',', ''),
                        ),
                sizeType: provider.selectedSize,
                startDate: provider.startDate,
                // uuid: widget.product?.uuid,
              ),
            );
            await provider.getProducts(
              shopProvider.userShop!.shopId!,
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

  //
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((context) {
      clearFields();
    });

    setShop();
  }

  Future<void> clearFields() async {
    await Future.delayed(Duration(microseconds: 500), () {
      if (context.mounted) {
        returnData(context, listen: false).clearFields();
      }
    });
    if (widget.product != null && context.mounted) {
      barcode = widget.product!.barcode;
      // barcodeController.text =
      //     widget.product!.barcode == null
      //         ? ''
      //         : widget.product!.barcode!;
      barCodeSet =
          widget.product!.barcode != null ? true : false;

      widget.nameController.text = widget.product!.name;
      widget.lowQttyController.text =
          widget.product!.lowQtty!.toString();
      widget.costController.text =
          widget.product!.costPrice.toString().split(
            '.',
          )[0];
      widget.sellingController.text =
          widget.product!.sellingPrice != null
              ? widget.product!.sellingPrice
                  .toString()
                  .split('.')[0]
              : '';
      widget.quantityController.text =
          widget.product!.quantity == null
              ? ''
              : widget.product!.quantity.toString();

      widget.discountController.text =
          widget.product!.discount != null
              ? widget.product!.discount.toString()
              : '';
      returnData(
            context,
            listen: false,
          ).isProductRefundable =
          widget.product!.isRefundable;
      returnData(context, listen: false).isManaged =
          widget.product!.isManaged;
      returnData(context, listen: false).setCustomPrice =
          widget.product!.setCustomPrice;
      // returnData(context, listen: false).selectedUnit =
      //     widget.product!.unit;
      returnData(
        context,
        listen: false,
      ).selectUnit(widget.product!.unit);
      // returnData(context, listen: false).selectedSize =
      //     widget.product!.sizeType ?? '';
      widget.product!.sizeType != null
          ? returnData(
            context,
            listen: false,
          ).selectSize(widget.product!.sizeType!)
          : null;
      widget.product!.category != null
          ? returnData(
            context,
            listen: false,
          ).selectCategory(widget.product!.category!)
          : null;
      returnData(context, listen: false).setBothDates(
        start: widget.product!.startDate,
        end: widget.product!.endDate,
        expDate: widget.product!.expiryDate,
      );
      setState(() {
        costDiscount =
            widget.product!.discount != null &&
                    widget.product!.sellingPrice != null
                ? widget.product!.sellingPrice! *
                    (widget.product!.discount! / 100)
                : 0;
        sellingDiscount =
            widget.product!.discount != null &&
                    widget.product!.sellingPrice != null
                ? widget.product!.sellingPrice! -
                    (widget.product!.sellingPrice! *
                        (widget.product!.discount! / 100))
                : 0;
        selling =
            double.tryParse(
              widget.sellingController.text.replaceAll(
                ',',
                '',
              ),
            ) ??
            0;
      });
    }
  }

  TempShopClass? userShop;
  void setShop() async {
    var shop = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!);

    setState(() {
      userShop = shop;
    });
  }

  double cost = 0;
  double selling = 0;
  double discount = 0;

  double costDiscount = 0;

  double sellingDiscount = 0;

  void checkDiscount() {
    final discountedPrice = selling * (discount / 100);
    final discountedSellingPrice =
        selling - (selling * (discount / 100));
    setState(() {
      costDiscount = discountedPrice;
      sellingDiscount = discountedSellingPrice;
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
    return Scaffold(
      body: Stack(
        children: [
          DesktopCenterContainer(
            width: 650,
            mainWidget: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 10,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
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
                                    theme: theme,
                                    hint: 'Enter Item Name',
                                    lines: 1,
                                    title: 'Item Name',
                                    controller:
                                        widget
                                            .nameController,
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        child: MoneyTextfield(
                                          onChanged: (
                                            value,
                                          ) {
                                            if (value
                                                .isEmpty) {
                                              cost = 0;
                                            } else {
                                              setState(() {
                                                cost = double.parse(
                                                  widget
                                                      .costController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                );
                                              });
                                            }
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
                                          onChanged: (
                                            value,
                                          ) {
                                            if (value
                                                .isEmpty) {
                                              selling = 0;
                                            } else {
                                              setState(() {
                                                selling = double.parse(
                                                  widget
                                                      .sellingController
                                                      .text
                                                      .replaceAll(
                                                        ',',
                                                        '',
                                                      ),
                                                );
                                              });
                                            }
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
                                  SizedBox(height: 10),
                                  EditCartTextField(
                                    theme: theme,
                                    hint: 'Enter Quantity',
                                    title:
                                        'Quantity (Optional)',
                                    controller:
                                        widget
                                            .quantityController,
                                  ),
                                  SizedBox(height: 20),
                                  InkWell(
                                    onTap: () {
                                      returnData(
                                        context,
                                        listen: false,
                                      ).toggleIsManaged();
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
                                                    'This controls wether Item quantity is automatically deducted after sales, and notifications are sent when item quantity is low or out of stock.',
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
                                                context,
                                              ).isManaged,
                                          onChanged: (
                                            value,
                                          ) {
                                            returnData(
                                              context,
                                              listen: false,
                                            ).toggleIsManaged();
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
                                      returnData(
                                        context,
                                        listen: false,
                                      ).toggleSetCustomPrice();
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
                                                context,
                                              ).setCustomPrice,
                                          onChanged: (
                                            value,
                                          ) {
                                            returnData(
                                              context,
                                              listen: false,
                                            ).toggleSetCustomPrice();
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
                                  Divider(),
                                  SizedBox(height: 15),
                                  Visibility(
                                    visible: expand,
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            Visibility(
                                              visible:
                                                  kIsWeb ||
                                                  platforms(
                                                        context,
                                                      ) ==
                                                      TargetPlatform
                                                          .android ||
                                                  platforms(
                                                        context,
                                                      ) ==
                                                      TargetPlatform
                                                          .iOS,
                                              child: BarcodeScanner(
                                                valueSet:
                                                    barCodeSet,
                                                onTap: () async {
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
                                                      TargetPlatform
                                                          .windows ||
                                                  platforms(
                                                        context,
                                                      ) ==
                                                      TargetPlatform
                                                          .linux ||
                                                  platforms(
                                                        context,
                                                      ) ==
                                                      TargetPlatform
                                                          .macOS,
                                              child: Column(
                                                spacing: 5,
                                                children: [
                                                  Text(
                                                    style:
                                                        theme.mobileTexts.b3.textStyleBold,
                                                    'Item Barcode (Optional)',
                                                  ),
                                                  TextFormField(
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
                                                      print(
                                                        barcode,
                                                      );
                                                      print(
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
                                        SizedBox(
                                          height: 10,
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              isExp = true;
                                              setDate =
                                                  true;
                                            });
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
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  vertical:
                                                      0,
                                                  horizontal:
                                                      5,
                                                ),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color:
                                                        returnData(
                                                                  context,
                                                                ).expiryDate !=
                                                                null
                                                            ? theme.lightModeColor.prColor300
                                                            : Colors.grey,
                                                    width:
                                                        returnData(
                                                                  context,
                                                                ).expiryDate !=
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
                                                                returnData(
                                                                          context,
                                                                        ).expiryDate !=
                                                                        null
                                                                    ? theme.mobileTexts.b2.fontSize
                                                                    : theme.mobileTexts.b2.fontSize,
                                                            fontWeight:
                                                                returnData(
                                                                          context,
                                                                        ).expiryDate !=
                                                                        null
                                                                    ? FontWeight.bold
                                                                    : null,
                                                            color:
                                                                returnData(
                                                                          context,
                                                                        ).expiryDate !=
                                                                        null
                                                                    ? null
                                                                    : Colors.grey.shade500,
                                                          ),
                                                          returnData(
                                                                    context,
                                                                  ).expiryDate ==
                                                                  null
                                                              ? 'Set Expiry Date'
                                                              : formatDateWithDay(
                                                                returnData(
                                                                      context,
                                                                    ).expiryDate ??
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
                                                          returnData(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).clearExpDate();
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
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MainDropdown(
                                          valueSet:
                                              returnData(
                                                context,
                                              ).unitValueSet,
                                          onTap: () {
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
                                          isOpen:
                                              isOpenUnit,
                                          title:
                                              'Item Unit (Optional)',
                                          hint:
                                              returnData(
                                                context,
                                              ).selectedUnit ??
                                              'Select Item Unit',
                                          theme: theme,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        MainDropdown(
                                          valueSet:
                                              returnData(
                                                context,
                                              ).sizeValueSet,
                                          onTap: () {
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
                                          isOpen:
                                              isSizedTypeOpen,
                                          title:
                                              'Size Type (Optional)',
                                          hint:
                                              returnData(
                                                context,
                                              ).selectedSize ??
                                              'Select Item Size Type',
                                          theme: theme,
                                        ),

                                        SizedBox(
                                          height: 10,
                                        ),
                                        MainDropdown(
                                          valueSet:
                                              returnData(
                                                context,
                                              ).catValueSet,
                                          onTap: () {
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
                                          isOpen: isOpen,
                                          title:
                                              'Category (Optional)',
                                          hint:
                                              returnData(
                                                context,
                                              ).selectedCategory ??
                                              'Select Item Category',
                                          theme: theme,
                                        ),
                                        SizedBox(
                                          height: 10,
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
                  Visibility(
                    visible: setDate,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          setDate = false;
                        });
                      },
                      child: Container(
                        color: const Color.fromARGB(
                          100,
                          0,
                          0,
                          0,
                        ),
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height,
                        width:
                            MediaQuery.of(
                              context,
                            ).size.width,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(
                                      context,
                                    ).size.height *
                                    0.02,
                              ),
                              Center(
                                child: Container(
                                  padding:
                                      EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 10,
                                      ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            const Color.fromARGB(
                                              30,
                                              0,
                                              0,
                                              0,
                                            ),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  height: 480,
                                  width:
                                      (MediaQuery.of(
                                            context,
                                          ).size.width /
                                          10) *
                                      9.2,
                                  child: CalendarWidget(
                                    isMain: false,
                                    onDaySelected: (
                                      selectedDay,
                                      focusedDay,
                                    ) {
                                      if (isExp) {
                                        returnData(
                                          context,
                                          listen: false,
                                        ).setExpDate(
                                          selectedDay,
                                        );
                                        returnData(
                                                  context,
                                                  listen:
                                                      false,
                                                ).expiryDate !=
                                                null
                                            ? expiryDateC
                                                .text = formatDateWithDay(
                                              returnData(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).expiryDate ??
                                                  DateTime.now(),
                                            )
                                            : '';
                                      } else {
                                        returnData(
                                          context,
                                          listen: false,
                                        ).setDate(
                                          selectedDay,
                                        );
                                      }
                                      setState(() {
                                        setDate = false;
                                      });
                                    },
                                    actionWeek: (
                                      startOfWeek,
                                      endOfWeek,
                                    ) {
                                      returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).setReceiptWeek(
                                        startOfWeek,
                                        endOfWeek,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(
                                      top: 15,
                                      left: 30,
                                      right: 30,
                                    ),
                                child:
                                    MainButtonTransparent(
                                      constraints:
                                          BoxConstraints(),
                                      themeProvider: theme,
                                      action: () {
                                        setState(() {
                                          setDate = false;
                                        });
                                      },
                                      text: 'Cancel',
                                    ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(
                                      context,
                                    ).size.height *
                                    0.4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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
