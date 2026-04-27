import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  const ProductDetailsMobile({
    super.key,
    required this.theme,
    required this.productUuid,
  });

  @override
  State<ProductDetailsMobile> createState() =>
      _ProductDetailsMobileState();
}

class _ProductDetailsMobileState
    extends State<ProductDetailsMobile> {
  late Future<TempProductClass> productFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;
  bool isAddToQuantity = true;

  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController wholeSaleController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController discountController =
      TextEditingController();
  TextEditingController qttyPerUnitController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    sellingController.dispose();
    quantityController.dispose();
    discountController.dispose();
    qttyPerUnitController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final shopI = returnShopProvider().userShop()!.shopId!;
    List<TempProductClass>? productList =
        returnData().productListMain
            .where(
              (product) =>
                  product.uuid! == widget.productUuid,
            )
            .toList();
    if (productList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader(message: 'Loading...'),
      );
    } else {
      TempProductClass product = productList.first;
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
              widget: Visibility(
                visible: !isStoreKeeper(),
                child: InkWell(
                  onTap: () {
                    var safeContext = context;
                    showDialog(
                      context: safeContext,
                      builder: (context) {
                        return ConfirmationAlert(
                          theme: widget.theme,
                          message:
                              'This item is going to be added to your cart. Are you sure you want to proceed with this action?',
                          title: 'Add Item to Cart',
                          action: () {
                            Navigator.of(safeContext).pop();
                            var res = returnSalesProvider()
                                .addItemToCart(
                                  context: context,
                                  newItem: TempCartItem(
                                    useWholeSalePrice:
                                        false,
                                    setCustomPrice: false,
                                    item: product,
                                    quantity: 1,
                                    discount: null,
                                    addToStock: false,
                                    setTotalPrice: false,
                                  ),
                                  isCustomEdit: false,
                                );
                            if (res ==
                                "Quantity Limit Exceeded") {
                              return;
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return MakeSalesPage(
                                    isMain: true,
                                    // product: product,
                                  );
                                },
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 5),
                    padding: EdgeInsets.only(
                      right: 15,
                      left: 15,
                      top: 5,
                      bottom: 5,
                    ),
                    decoration: BoxDecoration(),
                    child: Row(
                      spacing: 3,
                      children: [
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                          ),
                          'Sell Item',
                        ),
                        Icon(
                          size: 16,
                          Icons.shopping_cart_outlined,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            children: [
                              Text(
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .h4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                product.name,
                              ),
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  color:
                                      widget
                                          .theme
                                          .lightModeColor
                                          .secColor200,
                                  fontWeight:
                                      FontWeight.normal,
                                ),
                                'Date Created: ${formatDateTime(product.createdAt!)}',
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Column(
                            children: [
                              Row(
                                spacing: 10,
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  Expanded(
                                    child: TabContainerMobile(
                                      isMoney: true,
                                      text: 'Cost Price',
                                      price:
                                          product.costPrice,
                                      theme: widget.theme,
                                      backGround:
                                          const Color.fromARGB(
                                            11,
                                            15,
                                            4,
                                            114,
                                          ),
                                      border:
                                          const Color.fromARGB(
                                            32,
                                            45,
                                            3,
                                            255,
                                          ),
                                    ),
                                  ),
                                  Expanded(
                                    child: TabContainerMobile(
                                      isMoney: true,
                                      text: 'Selling Price',
                                      price:
                                          product
                                              .sellingPrice ??
                                          0,
                                      theme: widget.theme,
                                      backGround:
                                          const Color.fromARGB(
                                            25,
                                            235,
                                            150,
                                            3,
                                          ),
                                      border:
                                          const Color.fromARGB(
                                            74,
                                            232,
                                            148,
                                            3,
                                          ),
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
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TabContainerMobile(
                                            isMoney: true,
                                            text:
                                                'Whole Sale Price',
                                            price:
                                                product
                                                    .wholeSalePrice ??
                                                0,
                                            theme:
                                                widget
                                                    .theme,
                                            backGround:
                                                const Color.fromARGB(
                                                  24,
                                                  135,
                                                  235,
                                                  3,
                                                ),
                                            border:
                                                const Color.fromARGB(
                                                  73,
                                                  106,
                                                  232,
                                                  3,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .updateProduct,
                                ),
                                child: SizedBox(height: 10),
                              ),
                              Visibility(
                                visible: authorization(
                                  authorized:
                                      Authorizations()
                                          .updateProduct,
                                ),
                                child: EditButton(
                                  theme: widget.theme,
                                  action: () {
                                    setState(() {
                                      sellingController
                                              .text =
                                          product.sellingPrice !=
                                                  null
                                              ? product
                                                  .sellingPrice
                                                  .toString()
                                              : '';
                                      wholeSaleController
                                              .text =
                                          product.wholeSalePrice !=
                                                  null
                                              ? product
                                                  .wholeSalePrice
                                                  .toString()
                                              : '';

                                      costController.text =
                                          product.costPrice
                                              .toString();
                                    });
                                    bool
                                    isEditPriceLoading =
                                        false;
                                    showGeneralDialog(
                                      context: context,
                                      pageBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) {
                                        return StatefulBuilder(
                                          builder:
                                              (
                                                context,
                                                setState,
                                              ) => Material(
                                                color:
                                                    Colors
                                                        .transparent,
                                                child: GestureDetector(
                                                  onTap:
                                                      () =>
                                                          FocusManager.instance.primaryFocus?.unfocus(),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.white,
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                        left:
                                                            30.0,
                                                        top:
                                                            40,
                                                        right:
                                                            30,
                                                      ),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Opacity(
                                                                opacity:
                                                                    0,
                                                                child: IconButton(
                                                                  onPressed:
                                                                      () {},
                                                                  icon: Icon(
                                                                    Icons.clear,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      widget.theme.mobileTexts.b1.fontSize,
                                                                  fontWeight:
                                                                      FontWeight.bold,
                                                                ),
                                                                'Edit Prices',
                                                              ),
                                                              Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  if (isEditPriceLoading ==
                                                                      true) {
                                                                    return SizedBox(
                                                                      height:
                                                                          20,
                                                                      width:
                                                                          20,
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            1.5,
                                                                        color:
                                                                            widget.theme.lightModeColor.secColor200,
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    return IconButton(
                                                                      onPressed: () {
                                                                        Navigator.of(
                                                                          context,
                                                                        ).pop();
                                                                      },
                                                                      icon: Icon(
                                                                        Icons.clear,
                                                                      ),
                                                                    );
                                                                  }
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                15,
                                                          ),
                                                          Column(
                                                            spacing:
                                                                20,
                                                            children: [
                                                              MoneyTextfield(
                                                                title:
                                                                    'Cost Price',
                                                                hint:
                                                                    'Enter Cost Price',
                                                                controller:
                                                                    costController,
                                                                theme:
                                                                    widget.theme,
                                                              ),
                                                              MoneyTextfield(
                                                                title:
                                                                    'Selling Price',
                                                                hint:
                                                                    'Enter Selling Price',
                                                                controller:
                                                                    sellingController,
                                                                theme:
                                                                    widget.theme,
                                                              ),
                                                              Visibility(
                                                                visible:
                                                                    returnShopProvider().userShop()?.wholeSale ==
                                                                    true,
                                                                child: MoneyTextfield(
                                                                  title:
                                                                      'Whole Sale Price',
                                                                  hint:
                                                                      'Enter Whole Sale Price',
                                                                  controller:
                                                                      wholeSaleController,
                                                                  theme:
                                                                      widget.theme,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                20,
                                                          ),
                                                          MainButtonP(
                                                            themeProvider:
                                                                widget.theme,
                                                            action: () {
                                                              final safeContext =
                                                                  context;
                                                              if (isEditPriceLoading ==
                                                                  false) {
                                                                showDialog(
                                                                  context:
                                                                      safeContext,
                                                                  builder: (
                                                                    confirmDialog,
                                                                  ) {
                                                                    return ConfirmationAlert(
                                                                      theme:
                                                                          widget.theme,
                                                                      message:
                                                                          'Are you sure you want to proceed?',
                                                                      title:
                                                                          'Proceed?',
                                                                      action: () async {
                                                                        final dataProvider =
                                                                            returnData();
                                                                        Navigator.of(
                                                                          confirmDialog,
                                                                        ).pop();

                                                                        setState(
                                                                          () {
                                                                            isEditPriceLoading =
                                                                                true;
                                                                          },
                                                                        );
                                                                        await dataProvider.updateProduct(
                                                                          product: TempProductClass(
                                                                            storageUuid:
                                                                                product.storageUuid,
                                                                            departmentName:
                                                                                product.departmentName,
                                                                            departmentUuid:
                                                                                product.departmentUuid,
                                                                            groupUnit:
                                                                                product.groupUnit,
                                                                            qttyPerGroup:
                                                                                product.qttyPerGroup,
                                                                            updatedAt:
                                                                                DateTime.now(),
                                                                            setCustomPrice:
                                                                                product.setCustomPrice,
                                                                            isManaged:
                                                                                product.isManaged,
                                                                            totalQttyInStorageDouble:
                                                                                product.totalQttyInStorageDouble,
                                                                            uuid:
                                                                                product.uuid,
                                                                            name:
                                                                                product.name,
                                                                            unit:
                                                                                product.unit,
                                                                            isRefundable:
                                                                                product.isRefundable,
                                                                            costPrice:
                                                                                double.tryParse(
                                                                                  costController.text.replaceAll(
                                                                                    ',',
                                                                                    '',
                                                                                  ),
                                                                                ) ??
                                                                                0,
                                                                            sellingPrice:
                                                                                sellingController.text.isNotEmpty
                                                                                    ? double.tryParse(
                                                                                      sellingController.text.replaceAll(
                                                                                        ',',
                                                                                        '',
                                                                                      ),
                                                                                    )
                                                                                    : null,
                                                                            wholeSalePrice:
                                                                                wholeSaleController.text.isNotEmpty
                                                                                    ? double.tryParse(
                                                                                      wholeSaleController.text.replaceAll(
                                                                                        ',',
                                                                                        '',
                                                                                      ),
                                                                                    )
                                                                                    : null,
                                                                            quantity:
                                                                                product.quantity,
                                                                            shopId:
                                                                                product.shopId,
                                                                            barcode:
                                                                                product.barcode,
                                                                            categoryUuid:
                                                                                product.categoryUuid,
                                                                            createdAt:
                                                                                product.createdAt,
                                                                            discount:
                                                                                product.discount,
                                                                            endDate:
                                                                                product.endDate,
                                                                            expiryDate:
                                                                                product.expiryDate,
                                                                            lowQtty:
                                                                                product.lowQtty,
                                                                            sizeType:
                                                                                product.sizeType,
                                                                            startDate:
                                                                                product.startDate,
                                                                            // uuid:
                                                                            //     product.uuid,
                                                                          ),
                                                                          oldProduct:
                                                                              product,
                                                                        );
                                                                        // if (safeContext.mounted) {
                                                                        //   await dataProvider.getProducts(
                                                                        //     shopI,
                                                                        //   );
                                                                        // }

                                                                        // setState(
                                                                        //   () {
                                                                        //     isLoading =
                                                                        //         false;
                                                                        //     showSuccess =
                                                                        //         true;
                                                                        //   },
                                                                        // );

                                                                        if (safeContext.mounted) {
                                                                          Navigator.of(
                                                                            safeContext,
                                                                          ).pop();
                                                                          setState(
                                                                            () {
                                                                              // productFuture =
                                                                              //     getProduct();
                                                                            },
                                                                          );
                                                                        }

                                                                        // setState(
                                                                        //   () {
                                                                        //     showSuccess =
                                                                        //         false;
                                                                        //   },
                                                                        // );
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                            },
                                                            text:
                                                                'Update Prices',
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                15,
                                                          ),
                                                          Material(
                                                            color:
                                                                Colors.transparent,
                                                            child: EditButton(
                                                              text:
                                                                  'Cancel',
                                                              action: () {
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              theme:
                                                                  widget.theme,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        );
                                      },
                                    );
                                  },
                                  text: 'Edit Prices',
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              spacing: 10,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Row(
                                        // spacing: 15,
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Expanded(
                                            child: TabContainerMobile(
                                              isMoney:
                                                  false,
                                              text:
                                                  product.storageUuid !=
                                                              null &&
                                                          returnStorageProductProvider().storageProductListMain
                                                              .where(
                                                                (
                                                                  storage,
                                                                ) =>
                                                                    storage.uuid ==
                                                                    product.storageUuid,
                                                              )
                                                              .isNotEmpty
                                                      ? ' Quantity Of ${returnStorageProductProvider().storageProductListMain.where((storage) => storage.uuid == product.storageUuid).first.unit ?? 'Others'}'
                                                      : product.unit !=
                                                          'Others'
                                                      ? ' Qtty Of ${product.unit}'
                                                      : 'Unit Qtty',
                                              price:
                                                  product
                                                      .quantity ??
                                                  0,
                                              theme:
                                                  widget
                                                      .theme,
                                              backGround:
                                                  product.isManaged
                                                      ? (product.quantity ??
                                                                  0) >
                                                              product.lowQtty!
                                                          ? const Color.fromARGB(
                                                            18,
                                                            2,
                                                            163,
                                                            31,
                                                          )
                                                          : const Color.fromARGB(
                                                            15,
                                                            207,
                                                            6,
                                                            29,
                                                          )
                                                      : const Color.fromARGB(
                                                        48,
                                                        158,
                                                        158,
                                                        158,
                                                      ),
                                              border:
                                                  product.isManaged
                                                      ? (product.quantity ??
                                                                  0) >
                                                              product.lowQtty!
                                                          ? const Color.fromARGB(
                                                            63,
                                                            2,
                                                            163,
                                                            31,
                                                          )
                                                          : const Color.fromARGB(
                                                            57,
                                                            176,
                                                            4,
                                                            30,
                                                          )
                                                      : const Color.fromARGB(
                                                        45,
                                                        158,
                                                        158,
                                                        158,
                                                      ),
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                shop(
                                                      context,
                                                    )?.manageInventoryStorage !=
                                                    true &&
                                                shop(
                                                      context,
                                                    )?.useGroupUnit ==
                                                    true,
                                            child: SizedBox(
                                              width: 10,
                                            ),
                                          ),
                                          Visibility(
                                            visible:
                                                shop(
                                                      context,
                                                    )?.manageInventoryStorage !=
                                                    true &&
                                                shop(
                                                      context,
                                                    )?.useGroupUnit ==
                                                    true,
                                            child: Expanded(
                                              child: TabContainerMobile(
                                                isMoney:
                                                    false,
                                                text:
                                                    product.storageUuid !=
                                                                null &&
                                                            returnStorageProductProvider().storageProductListMain
                                                                .where(
                                                                  (
                                                                    storage,
                                                                  ) =>
                                                                      storage.uuid ==
                                                                      product.storageUuid,
                                                                )
                                                                .isNotEmpty
                                                        ? ' Quantity Of ${returnStorageProductProvider().storageProductListMain.where((storage) => storage.uuid == product.storageUuid).first.groupUnit ?? 'Others'}'
                                                        : product.groupUnit !=
                                                                null &&
                                                            product.groupUnit !=
                                                                'Others'
                                                        ? ' Qtty Of ${product.groupUnit}'
                                                        : 'Group Qtty',
                                                price: returnData(
                                                  context:
                                                      context,
                                                ).returnGroupQuantityValue(
                                                  product,
                                                ),
                                                theme:
                                                    widget
                                                        .theme,
                                                backGround:
                                                    product.isManaged
                                                        ? (product.quantity ??
                                                                    0) >
                                                                product.lowQtty!
                                                            ? const Color.fromARGB(
                                                              18,
                                                              2,
                                                              163,
                                                              31,
                                                            )
                                                            : const Color.fromARGB(
                                                              15,
                                                              207,
                                                              6,
                                                              29,
                                                            )
                                                        : const Color.fromARGB(
                                                          48,
                                                          158,
                                                          158,
                                                          158,
                                                        ),
                                                border:
                                                    product.isManaged
                                                        ? (product.quantity ??
                                                                    0) >
                                                                product.lowQtty!
                                                            ? const Color.fromARGB(
                                                              63,
                                                              2,
                                                              163,
                                                              31,
                                                            )
                                                            : const Color.fromARGB(
                                                              57,
                                                              176,
                                                              4,
                                                              30,
                                                            )
                                                        : const Color.fromARGB(
                                                          45,
                                                          158,
                                                          158,
                                                          158,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateProduct,
                                            ) &&
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateItemQuantity,
                                            ),
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateProduct,
                                            ) &&
                                            authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateItemQuantity,
                                            ) &&
                                            returnShopProvider()
                                                    .userShop()
                                                    ?.manageInventoryStorage !=
                                                true,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: EditButton(
                                                theme:
                                                    widget
                                                        .theme,
                                                action: () {
                                                  bool
                                                  isEditQuantityLoading =
                                                      false;
                                                  showGeneralDialog(
                                                    context:
                                                        context,
                                                    pageBuilder: (
                                                      context,
                                                      animation,
                                                      secondaryAnimation,
                                                    ) {
                                                      return StatefulBuilder(
                                                        builder:
                                                            (
                                                              context,
                                                              setState,
                                                            ) => Material(
                                                              color:
                                                                  Colors.transparent,
                                                              child: GestureDetector(
                                                                onTap:
                                                                    () =>
                                                                        FocusManager.instance.primaryFocus?.unfocus(),
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color:
                                                                        Colors.white,
                                                                  ),
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(
                                                                      left:
                                                                          30.0,
                                                                      top:
                                                                          40,
                                                                      right:
                                                                          30,
                                                                    ),
                                                                    child: Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Opacity(
                                                                              opacity:
                                                                                  0,
                                                                              child: IconButton(
                                                                                onPressed:
                                                                                    () {},
                                                                                icon: Icon(
                                                                                  Icons.clear,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    widget.theme.mobileTexts.b1.fontSize,
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                              'Edit Quantity',
                                                                            ),
                                                                            Builder(
                                                                              builder: (
                                                                                context,
                                                                              ) {
                                                                                if (isEditQuantityLoading ==
                                                                                    true) {
                                                                                  return SizedBox(
                                                                                    height:
                                                                                        20,
                                                                                    width:
                                                                                        20,
                                                                                    child: CircularProgressIndicator(
                                                                                      strokeWidth:
                                                                                          1.5,
                                                                                      color:
                                                                                          widget.theme.lightModeColor.secColor200,
                                                                                    ),
                                                                                  );
                                                                                } else {
                                                                                  return IconButton(
                                                                                    onPressed: () {
                                                                                      Navigator.of(
                                                                                        context,
                                                                                      ).pop();
                                                                                    },
                                                                                    icon: Icon(
                                                                                      Icons.clear,
                                                                                    ),
                                                                                  );
                                                                                }
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        Column(
                                                                          spacing:
                                                                              20,
                                                                          children: [
                                                                            Text(
                                                                              style: TextStyle(
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                                fontSize:
                                                                                    widget.theme.mobileTexts.b1.fontSize,
                                                                              ),
                                                                              product.quantity ==
                                                                                      null
                                                                                  ? 'Quantity Not Set'
                                                                                  : 'Current Quantity Amount : ${product.quantity!.toString()}',
                                                                            ),
                                                                            EditCartTextField(
                                                                              onChanged: (
                                                                                value,
                                                                              ) {
                                                                                if (value.isEmpty) {
                                                                                  setState(
                                                                                    () {
                                                                                      quantityController.text = '0';
                                                                                    },
                                                                                  );
                                                                                } else if (value.toString()[0] ==
                                                                                    '0') {
                                                                                  setState(
                                                                                    () {
                                                                                      quantityController.text = value.substring(
                                                                                        1,
                                                                                      );
                                                                                    },
                                                                                  );
                                                                                } else if (isAddToQuantity) {
                                                                                  if (product.isManaged &&
                                                                                      returnShopProvider().userShop()?.manageInventoryStorage ==
                                                                                          true) {
                                                                                    if (((double.tryParse(
                                                                                                  value.replaceAll(
                                                                                                    ',',
                                                                                                    '',
                                                                                                  ),
                                                                                                ) ??
                                                                                                0) +
                                                                                            (double.tryParse(
                                                                                                  product.quantity?.toString() ??
                                                                                                      '0',
                                                                                                ) ??
                                                                                                0)) >
                                                                                        ((product.totalQttyInStorageDouble ??
                                                                                                0) +
                                                                                            (double.tryParse(
                                                                                                  product.quantity?.toString() ??
                                                                                                      '0',
                                                                                                ) ??
                                                                                                0))) {
                                                                                      quantityController.text = '0';
                                                                                    }
                                                                                  }
                                                                                } else if (!isAddToQuantity) {
                                                                                  if (product.isManaged &&
                                                                                      returnShopProvider().userShop()?.manageInventoryStorage ==
                                                                                          true) {
                                                                                    if (((double.tryParse(
                                                                                              value.replaceAll(
                                                                                                ',',
                                                                                                '',
                                                                                              ),
                                                                                            ) ??
                                                                                            0)) >
                                                                                        ((product.totalQttyInStorageDouble ??
                                                                                                0) +
                                                                                            (double.tryParse(
                                                                                                  product.quantity?.toString() ??
                                                                                                      '0',
                                                                                                ) ??
                                                                                                0))) {
                                                                                      quantityController.text = '0';
                                                                                    }
                                                                                  }
                                                                                }
                                                                              },
                                                                              title:
                                                                                  'Quantity',
                                                                              hint:
                                                                                  'Enter Quantity Amount',
                                                                              controller:
                                                                                  quantityController,
                                                                              theme:
                                                                                  widget.theme,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              20,
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          spacing:
                                                                              5,
                                                                          children: [
                                                                            Material(
                                                                              color:
                                                                                  Colors.transparent,
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  setState(
                                                                                    () {
                                                                                      isAddToQuantity =
                                                                                          true;
                                                                                    },
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(
                                                                                    horizontal:
                                                                                        8,
                                                                                    vertical:
                                                                                        8,
                                                                                  ),
                                                                                  child: Row(
                                                                                    spacing:
                                                                                        5,
                                                                                    children: [
                                                                                      Container(
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(
                                                                                            color:
                                                                                                !isAddToQuantity
                                                                                                    ? Colors.grey
                                                                                                    : Colors.transparent,
                                                                                          ),
                                                                                          color:
                                                                                              isAddToQuantity
                                                                                                  ? widget.theme.lightModeColor.prColor250
                                                                                                  : Colors.transparent,
                                                                                          shape:
                                                                                              BoxShape.circle,
                                                                                        ),
                                                                                        child: Icon(
                                                                                          size:
                                                                                              14,
                                                                                          color:
                                                                                              Colors.white,
                                                                                          Icons.check,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        style: TextStyle(
                                                                                          fontSize:
                                                                                              widget.theme.mobileTexts.b4.fontSize,
                                                                                          fontWeight:
                                                                                              FontWeight.bold,
                                                                                        ),
                                                                                        'Add to Quantity',
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            Material(
                                                                              color:
                                                                                  Colors.transparent,
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  setState(
                                                                                    () {
                                                                                      isAddToQuantity =
                                                                                          false;
                                                                                    },
                                                                                  );
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.symmetric(
                                                                                    vertical:
                                                                                        8,
                                                                                    horizontal:
                                                                                        8,
                                                                                  ),
                                                                                  child: Row(
                                                                                    spacing:
                                                                                        5,
                                                                                    children: [
                                                                                      Container(
                                                                                        decoration: BoxDecoration(
                                                                                          border: Border.all(
                                                                                            color:
                                                                                                isAddToQuantity
                                                                                                    ? Colors.grey
                                                                                                    : Colors.transparent,
                                                                                          ),
                                                                                          color:
                                                                                              !isAddToQuantity
                                                                                                  ? widget.theme.lightModeColor.prColor250
                                                                                                  : Colors.transparent,
                                                                                          shape:
                                                                                              BoxShape.circle,
                                                                                        ),
                                                                                        child: Icon(
                                                                                          size:
                                                                                              14,
                                                                                          color:
                                                                                              Colors.white,
                                                                                          Icons.check,
                                                                                        ),
                                                                                      ),
                                                                                      Text(
                                                                                        style: TextStyle(
                                                                                          fontSize:
                                                                                              widget.theme.mobileTexts.b4.fontSize,
                                                                                          fontWeight:
                                                                                              FontWeight.bold,
                                                                                        ),
                                                                                        'Replace Quantity',
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        MainButtonP(
                                                                          themeProvider:
                                                                              widget.theme,
                                                                          action: () {
                                                                            final safeContext =
                                                                                context;

                                                                            final dataProvider =
                                                                                returnData();

                                                                            if (isEditQuantityLoading ==
                                                                                false) {
                                                                              showDialog(
                                                                                context:
                                                                                    safeContext,
                                                                                builder: (
                                                                                  confirmDialog,
                                                                                ) {
                                                                                  return ConfirmationAlert(
                                                                                    theme:
                                                                                        widget.theme,
                                                                                    message:
                                                                                        quantityController.text.isEmpty &&
                                                                                                !isAddToQuantity
                                                                                            ? 'You are about to empty your entire product stock, are you sure?'
                                                                                            : 'Are you sure you want to proceed?',
                                                                                    title:
                                                                                        quantityController.text.isEmpty &&
                                                                                                !isAddToQuantity
                                                                                            ? "Empty Stock?"
                                                                                            : 'Proceed?',
                                                                                    action: () async {
                                                                                      if (safeContext.mounted) {
                                                                                        Navigator.of(
                                                                                          confirmDialog,
                                                                                        ).pop();
                                                                                      }
                                                                                      setState(
                                                                                        () {
                                                                                          isEditQuantityLoading =
                                                                                              true;
                                                                                        },
                                                                                      );
                                                                                      double totalQttyInStorageCalc() {
                                                                                        final total =
                                                                                            product.totalQttyInStorageDouble ??
                                                                                            0;
                                                                                        final qty =
                                                                                            double.tryParse(
                                                                                              quantityController.text.replaceAll(
                                                                                                ',',
                                                                                                '',
                                                                                              ),
                                                                                            ) ??
                                                                                            0;
                                                                                        final currentQty =
                                                                                            product.quantity ??
                                                                                            0;

                                                                                        double result;
                                                                                        if (isAddToQuantity) {
                                                                                          result =
                                                                                              total -
                                                                                              qty;
                                                                                        } else {
                                                                                          result =
                                                                                              (total -
                                                                                                      (qty -
                                                                                                          currentQty))
                                                                                                  .toDouble();
                                                                                        }

                                                                                        return result <
                                                                                                0
                                                                                            ? 0
                                                                                            : result;
                                                                                      }

                                                                                      await dataProvider.updateProduct(
                                                                                        product: TempProductClass(
                                                                                          storageUuid:
                                                                                              product.storageUuid,
                                                                                          departmentName:
                                                                                              product.departmentName,
                                                                                          departmentUuid:
                                                                                              product.departmentUuid,
                                                                                          groupUnit:
                                                                                              product.groupUnit,
                                                                                          qttyPerGroup:
                                                                                              product.qttyPerGroup,
                                                                                          updatedAt:
                                                                                              DateTime.now(),
                                                                                          setCustomPrice:
                                                                                              product.setCustomPrice,
                                                                                          totalQttyInStorageDouble:
                                                                                              totalQttyInStorageCalc(),
                                                                                          isManaged:
                                                                                              product.isManaged,
                                                                                          // id:
                                                                                          //     product.id,
                                                                                          name:
                                                                                              product.name,
                                                                                          unit:
                                                                                              product.unit,
                                                                                          isRefundable:
                                                                                              product.isRefundable,
                                                                                          costPrice:
                                                                                              product.costPrice,
                                                                                          sellingPrice:
                                                                                              product.sellingPrice,
                                                                                          wholeSalePrice:
                                                                                              product.wholeSalePrice,
                                                                                          quantity:
                                                                                              quantityController.text.isEmpty &&
                                                                                                      !isAddToQuantity &&
                                                                                                      product.isManaged
                                                                                                  ? 0
                                                                                                  : quantityController.text.isEmpty &&
                                                                                                      !isAddToQuantity &&
                                                                                                      !product.isManaged
                                                                                                  ? null
                                                                                                  : quantityController.text.isNotEmpty &&
                                                                                                      !isAddToQuantity
                                                                                                  ? double.parse(
                                                                                                    quantityController.text.replaceAll(
                                                                                                      ',',
                                                                                                      '',
                                                                                                    ),
                                                                                                  )
                                                                                                  : quantityController.text.isNotEmpty &&
                                                                                                      isAddToQuantity
                                                                                                  ? double.parse(
                                                                                                        quantityController.text.replaceAll(
                                                                                                          ',',
                                                                                                          '',
                                                                                                        ),
                                                                                                      ) +
                                                                                                      (product.quantity ??
                                                                                                          0)
                                                                                                  : product.quantity,
                                                                                          shopId:
                                                                                              product.shopId,
                                                                                          barcode:
                                                                                              product.barcode,
                                                                                          categoryUuid:
                                                                                              product.categoryUuid,
                                                                                          createdAt:
                                                                                              product.createdAt,
                                                                                          discount:
                                                                                              product.discount,
                                                                                          endDate:
                                                                                              product.endDate,
                                                                                          expiryDate:
                                                                                              product.expiryDate,
                                                                                          lowQtty:
                                                                                              product.lowQtty,
                                                                                          sizeType:
                                                                                              product.sizeType,
                                                                                          startDate:
                                                                                              product.startDate,
                                                                                          uuid:
                                                                                              product.uuid,
                                                                                        ),
                                                                                        oldProduct:
                                                                                            product,
                                                                                      );

                                                                                      // setState(
                                                                                      //   () {
                                                                                      //     isEditQuantityLoading =
                                                                                      //         false;
                                                                                      //     showSuccess =
                                                                                      //         true;
                                                                                      //   },
                                                                                      // );
                                                                                      // if (safeContext.mounted) {
                                                                                      //   await dataProvider.getProducts(
                                                                                      //     shopI,
                                                                                      //   );
                                                                                      // }
                                                                                      // if (safeContext.mounted) {
                                                                                      //   await dataProvider.getProducts(
                                                                                      //     shopI,
                                                                                      //   );
                                                                                      // }

                                                                                      if (safeContext.mounted) {
                                                                                        Navigator.of(
                                                                                          safeContext,
                                                                                        ).pop();
                                                                                        setState(
                                                                                          () {
                                                                                            // productFuture =
                                                                                            //     getProduct();
                                                                                          },
                                                                                        );
                                                                                      }

                                                                                      // setState(
                                                                                      //   () {
                                                                                      //     showSuccess =
                                                                                      //         false;
                                                                                      //   },
                                                                                      // );
                                                                                    },
                                                                                  );
                                                                                },
                                                                              );
                                                                            }
                                                                          },
                                                                          text:
                                                                              'Update Quantity',
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              15,
                                                                        ),
                                                                        Material(
                                                                          color:
                                                                              Colors.transparent,
                                                                          child: EditButton(
                                                                            text:
                                                                                'Cancel',
                                                                            action: () {
                                                                              Navigator.of(
                                                                                context,
                                                                              ).pop();
                                                                            },
                                                                            theme:
                                                                                widget.theme,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                      );
                                                    },
                                                  ).then((
                                                    context,
                                                  ) {
                                                    setState(() {
                                                      quantityController
                                                          .clear();
                                                      isAddToQuantity =
                                                          true;
                                                    });
                                                  });
                                                },
                                                text:
                                                    'Edit Unit Qtty',
                                              ),
                                            ),
                                            // Visibility(
                                            //   visible:
                                            //       shop(
                                            //             context,
                                            //           )?.manageInventoryStorage !=
                                            //           true &&
                                            //       shop(
                                            //             context,
                                            //           )?.useGroupUnit ==
                                            //           true &&
                                            //       authorization(
                                            //         authorized:
                                            //             Authorizations().updateItemQuantity,
                                            //       ),
                                            //   child:
                                            //       SizedBox(
                                            //         width:
                                            //             10,
                                            //       ),
                                            // ),
                                            // Visibility(
                                            //   visible:
                                            //       shop(
                                            //             context,
                                            //           )?.manageInventoryStorage !=
                                            //           true &&
                                            //       shop(
                                            //             context,
                                            //           )?.useGroupUnit ==
                                            //           true &&
                                            //       authorization(
                                            //         authorized:
                                            //             Authorizations().updateItemQuantity,
                                            //       ),
                                            //   child: Expanded(
                                            //     child: EditButton(
                                            //       theme:
                                            //           widget
                                            //               .theme,
                                            //       action: () {
                                            //         bool
                                            //         isEditQuantityLoading =
                                            //             false;
                                            //         showGeneralDialog(
                                            //           context:
                                            //               context,
                                            //           pageBuilder: (
                                            //             context,
                                            //             animation,
                                            //             secondaryAnimation,
                                            //           ) {
                                            //             return StatefulBuilder(
                                            //               builder:
                                            //                   (
                                            //                     context,
                                            //                     setState,
                                            //                   ) => Material(
                                            //                     color:
                                            //                         Colors.transparent,
                                            //                     child: GestureDetector(
                                            //                       onTap:
                                            //                           () =>
                                            //                               FocusManager.instance.primaryFocus?.unfocus(),
                                            //                       child: Container(
                                            //                         decoration: BoxDecoration(
                                            //                           color:
                                            //                               Colors.white,
                                            //                         ),
                                            //                         child: Padding(
                                            //                           padding: const EdgeInsets.only(
                                            //                             left:
                                            //                                 30.0,
                                            //                             top:
                                            //                                 40,
                                            //                             right:
                                            //                                 30,
                                            //                           ),
                                            //                           child: Column(
                                            //                             mainAxisAlignment:
                                            //                                 MainAxisAlignment.center,
                                            //                             children: [
                                            //                               Container(
                                            //                                 padding: EdgeInsets.all(
                                            //                                   40,
                                            //                                 ),
                                            //                                 margin: EdgeInsets.only(
                                            //                                   bottom:
                                            //                                       100,
                                            //                                 ),
                                            //                                 decoration: BoxDecoration(
                                            //                                   color:
                                            //                                       Colors.white,
                                            //                                   borderRadius: BorderRadius.circular(
                                            //                                     15,
                                            //                                   ),
                                            //                                   boxShadow: [
                                            //                                     BoxShadow(
                                            //                                       color: const Color.fromARGB(
                                            //                                         39,
                                            //                                         4,
                                            //                                         1,
                                            //                                         41,
                                            //                                       ),
                                            //                                       blurRadius:
                                            //                                           10,
                                            //                                     ),
                                            //                                   ],
                                            //                                 ),
                                            //                                 width:
                                            //                                     500,
                                            //                                 child: Column(
                                            //                                   children: [
                                            //                                     Row(
                                            //                                       mainAxisAlignment:
                                            //                                           MainAxisAlignment.spaceBetween,
                                            //                                       children: [
                                            //                                         Opacity(
                                            //                                           opacity:
                                            //                                               0,
                                            //                                           child: IconButton(
                                            //                                             onPressed:
                                            //                                                 () {},
                                            //                                             icon: Icon(
                                            //                                               Icons.clear,
                                            //                                             ),
                                            //                                           ),
                                            //                                         ),
                                            //                                         Text(
                                            //                                           style: TextStyle(
                                            //                                             fontSize:
                                            //                                                 widget.theme.mobileTexts.b1.fontSize,
                                            //                                             fontWeight:
                                            //                                                 FontWeight.bold,
                                            //                                           ),
                                            //                                           'Edit ${product.groupUnit != null && product.groupUnit != 'Others' ? '${product.groupUnit}' : 'Group'} Quantity',
                                            //                                         ),
                                            //                                         Builder(
                                            //                                           builder: (
                                            //                                             context,
                                            //                                           ) {
                                            //                                             if (isEditQuantityLoading ==
                                            //                                                 true) {
                                            //                                               return SizedBox(
                                            //                                                 height:
                                            //                                                     20,
                                            //                                                 width:
                                            //                                                     20,
                                            //                                                 child: CircularProgressIndicator(
                                            //                                                   strokeWidth:
                                            //                                                       1.5,
                                            //                                                   color:
                                            //                                                       widget.theme.lightModeColor.secColor200,
                                            //                                                 ),
                                            //                                               );
                                            //                                             } else {
                                            //                                               return IconButton(
                                            //                                                 onPressed: () {
                                            //                                                   Navigator.of(
                                            //                                                     context,
                                            //                                                   ).pop();
                                            //                                                 },
                                            //                                                 icon: Icon(
                                            //                                                   Icons.clear,
                                            //                                                 ),
                                            //                                               );
                                            //                                             }
                                            //                                           },
                                            //                                         ),
                                            //                                       ],
                                            //                                     ),
                                            //                                     SizedBox(
                                            //                                       height:
                                            //                                           15,
                                            //                                     ),
                                            //                                     Column(
                                            //                                       spacing:
                                            //                                           20,
                                            //                                       children: [
                                            //                                         Text(
                                            //                                           style: TextStyle(
                                            //                                             fontWeight:
                                            //                                                 FontWeight.bold,
                                            //                                             fontSize:
                                            //                                                 widget.theme.mobileTexts.b1.fontSize,
                                            //                                           ),
                                            //                                           product.quantity ==
                                            //                                                   null
                                            //                                               ? 'Quantity Not Set'
                                            //                                               : 'Current Quantity Amount : ${formatLargeNumberDouble(returnData().returnGroupQuantityValue(product))}',
                                            //                                         ),
                                            //                                         EditCartTextField(
                                            //                                           onChanged: (
                                            //                                             value,
                                            //                                           ) {
                                            //                                             if (value.isEmpty) {
                                            //                                               setState(
                                            //                                                 () {
                                            //                                                   qttyPerUnitController.text = '0';
                                            //                                                 },
                                            //                                               );
                                            //                                             } else if (value.toString()[0] ==
                                            //                                                 '0') {
                                            //                                               setState(
                                            //                                                 () {
                                            //                                                   qttyPerUnitController.text = value.substring(
                                            //                                                     1,
                                            //                                                   );
                                            //                                                 },
                                            //                                               );
                                            //                                             }
                                            //                                           },
                                            //                                           title:
                                            //                                               'Quantity',
                                            //                                           hint:
                                            //                                               'Enter Quantity Amount',
                                            //                                           controller:
                                            //                                               qttyPerUnitController,
                                            //                                           theme:
                                            //                                               widget.theme,
                                            //                                         ),
                                            //                                       ],
                                            //                                     ),
                                            //                                     SizedBox(
                                            //                                       height:
                                            //                                           20,
                                            //                                     ),
                                            //                                     Row(
                                            //                                       mainAxisAlignment:
                                            //                                           MainAxisAlignment.center,
                                            //                                       spacing:
                                            //                                           10,
                                            //                                       children: [
                                            //                                         Material(
                                            //                                           color:
                                            //                                               Colors.transparent,
                                            //                                           child: InkWell(
                                            //                                             onTap: () {
                                            //                                               setState(
                                            //                                                 () {
                                            //                                                   isAddToQuantity =
                                            //                                                       true;
                                            //                                                 },
                                            //                                               );
                                            //                                             },
                                            //                                             child: Container(
                                            //                                               padding: EdgeInsets.symmetric(
                                            //                                                 horizontal:
                                            //                                                     10,
                                            //                                                 vertical:
                                            //                                                     10,
                                            //                                               ),
                                            //                                               child: Row(
                                            //                                                 spacing:
                                            //                                                     10,
                                            //                                                 children: [
                                            //                                                   Container(
                                            //                                                     decoration: BoxDecoration(
                                            //                                                       border: Border.all(
                                            //                                                         color:
                                            //                                                             !isAddToQuantity
                                            //                                                                 ? Colors.grey
                                            //                                                                 : Colors.transparent,
                                            //                                                       ),
                                            //                                                       color:
                                            //                                                           isAddToQuantity
                                            //                                                               ? widget.theme.lightModeColor.prColor250
                                            //                                                               : Colors.transparent,
                                            //                                                       shape:
                                            //                                                           BoxShape.circle,
                                            //                                                     ),
                                            //                                                     child: Icon(
                                            //                                                       size:
                                            //                                                           16,
                                            //                                                       color:
                                            //                                                           Colors.white,
                                            //                                                       Icons.check,
                                            //                                                     ),
                                            //                                                   ),
                                            //                                                   Text(
                                            //                                                     style: TextStyle(
                                            //                                                       fontSize:
                                            //                                                           widget.theme.mobileTexts.b3.fontSize,
                                            //                                                       fontWeight:
                                            //                                                           FontWeight.bold,
                                            //                                                     ),
                                            //                                                     'Add to Quantity',
                                            //                                                   ),
                                            //                                                 ],
                                            //                                               ),
                                            //                                             ),
                                            //                                           ),
                                            //                                         ),
                                            //                                         Material(
                                            //                                           color:
                                            //                                               Colors.transparent,
                                            //                                           child: InkWell(
                                            //                                             onTap: () {
                                            //                                               setState(
                                            //                                                 () {
                                            //                                                   isAddToQuantity =
                                            //                                                       false;
                                            //                                                 },
                                            //                                               );
                                            //                                             },
                                            //                                             child: Container(
                                            //                                               padding: EdgeInsets.symmetric(
                                            //                                                 vertical:
                                            //                                                     10,
                                            //                                                 horizontal:
                                            //                                                     10,
                                            //                                               ),
                                            //                                               child: Row(
                                            //                                                 spacing:
                                            //                                                     5,
                                            //                                                 children: [
                                            //                                                   Container(
                                            //                                                     decoration: BoxDecoration(
                                            //                                                       border: Border.all(
                                            //                                                         color:
                                            //                                                             isAddToQuantity
                                            //                                                                 ? Colors.grey
                                            //                                                                 : Colors.transparent,
                                            //                                                       ),
                                            //                                                       color:
                                            //                                                           !isAddToQuantity
                                            //                                                               ? widget.theme.lightModeColor.prColor250
                                            //                                                               : Colors.transparent,
                                            //                                                       shape:
                                            //                                                           BoxShape.circle,
                                            //                                                     ),
                                            //                                                     child: Icon(
                                            //                                                       size:
                                            //                                                           16,
                                            //                                                       color:
                                            //                                                           Colors.white,
                                            //                                                       Icons.check,
                                            //                                                     ),
                                            //                                                   ),
                                            //                                                   Text(
                                            //                                                     style: TextStyle(
                                            //                                                       fontSize:
                                            //                                                           widget.theme.mobileTexts.b3.fontSize,
                                            //                                                       fontWeight:
                                            //                                                           FontWeight.bold,
                                            //                                                     ),
                                            //                                                     'Replace Quantity',
                                            //                                                   ),
                                            //                                                 ],
                                            //                                               ),
                                            //                                             ),
                                            //                                           ),
                                            //                                         ),
                                            //                                       ],
                                            //                                     ),
                                            //                                     SizedBox(
                                            //                                       height:
                                            //                                           15,
                                            //                                     ),
                                            //                                     MainButtonP(
                                            //                                       themeProvider:
                                            //                                           widget.theme,
                                            //                                       action: () {
                                            //                                         final safeContext =
                                            //                                             context;

                                            //                                         final dataProvider =
                                            //                                             returnData();

                                            //                                         if (isEditQuantityLoading ==
                                            //                                             false) {
                                            //                                           showDialog(
                                            //                                             context:
                                            //                                                 safeContext,
                                            //                                             builder: (
                                            //                                               confirmDialog,
                                            //                                             ) {
                                            //                                               return ConfirmationAlert(
                                            //                                                 theme:
                                            //                                                     widget.theme,
                                            //                                                 message:
                                            //                                                     qttyPerUnitController.text.isEmpty &&
                                            //                                                             !isAddToQuantity
                                            //                                                         ? 'You are about to empty your entire product stock, are you sure?'
                                            //                                                         : 'Are you sure you want to proceed?',
                                            //                                                 title:
                                            //                                                     qttyPerUnitController.text.isEmpty &&
                                            //                                                             !isAddToQuantity
                                            //                                                         ? "Empty Stock?"
                                            //                                                         : 'Proceed?',
                                            //                                                 action: () async {
                                            //                                                   Navigator.of(
                                            //                                                     confirmDialog,
                                            //                                                   ).pop();
                                            //                                                   setState(
                                            //                                                     () {
                                            //                                                       isEditQuantityLoading =
                                            //                                                           true;
                                            //                                                     },
                                            //                                                   );

                                            //                                                   await dataProvider.updateProduct(
                                            //                                                     product: TempProductClass(
                                            //                                                       storageUuid:
                                            //                                                           product.storageUuid,
                                            //                                                       departmentName:
                                            //                                                           product.departmentName,
                                            //                                                       departmentUuid:
                                            //                                                           product.departmentUuid,
                                            //                                                       groupUnit:
                                            //                                                           product.groupUnit,
                                            //                                                       qttyPerGroup:
                                            //                                                           product.qttyPerGroup,
                                            //                                                       updatedAt:
                                            //                                                           DateTime.now(),
                                            //                                                       setCustomPrice:
                                            //                                                           product.setCustomPrice,
                                            //                                                       totalQttyInStorageDouble:
                                            //                                                           product.totalQttyInStorageDouble,
                                            //                                                       isManaged:
                                            //                                                           product.isManaged,
                                            //                                                       // id:
                                            //                                                       //     product.id,
                                            //                                                       name:
                                            //                                                           product.name,
                                            //                                                       unit:
                                            //                                                           product.unit,
                                            //                                                       isRefundable:
                                            //                                                           product.isRefundable,
                                            //                                                       costPrice:
                                            //                                                           product.costPrice,
                                            //                                                       sellingPrice:
                                            //                                                           product.sellingPrice,
                                            //                                                       wholeSalePrice:
                                            //                                                           product.wholeSalePrice,
                                            //                                                       quantity:
                                            //                                                           qttyPerUnitController.text.isEmpty &&
                                            //                                                                   !isAddToQuantity &&
                                            //                                                                   product.isManaged
                                            //                                                               ? 0
                                            //                                                               : qttyPerUnitController.text.isEmpty &&
                                            //                                                                   !isAddToQuantity &&
                                            //                                                                   !product.isManaged
                                            //                                                               ? null
                                            //                                                               : qttyPerUnitController.text.isNotEmpty &&
                                            //                                                                   !isAddToQuantity
                                            //                                                               ? (double.parse(
                                            //                                                                     qttyPerUnitController.text.replaceAll(
                                            //                                                                       ',',
                                            //                                                                       '',
                                            //                                                                     ),
                                            //                                                                   ) *
                                            //                                                                   (product.qttyPerGroup ??
                                            //                                                                       0))
                                            //                                                               : qttyPerUnitController.text.isNotEmpty &&
                                            //                                                                   isAddToQuantity
                                            //                                                               ? (double.parse(
                                            //                                                                         qttyPerUnitController.text.replaceAll(
                                            //                                                                           ',',
                                            //                                                                           '',
                                            //                                                                         ),
                                            //                                                                       ) *
                                            //                                                                       (product.qttyPerGroup ??
                                            //                                                                           0)) +
                                            //                                                                   (product.quantity ??
                                            //                                                                       0)
                                            //                                                               : product.quantity,
                                            //                                                       shopId:
                                            //                                                           product.shopId,
                                            //                                                       barcode:
                                            //                                                           product.barcode,
                                            //                                                       categoryUuid:
                                            //                                                           product.categoryUuid,
                                            //                                                       createdAt:
                                            //                                                           product.createdAt,
                                            //                                                       discount:
                                            //                                                           product.discount,
                                            //                                                       endDate:
                                            //                                                           product.endDate,
                                            //                                                       expiryDate:
                                            //                                                           product.expiryDate,
                                            //                                                       lowQtty:
                                            //                                                           product.lowQtty,
                                            //                                                       sizeType:
                                            //                                                           product.sizeType,
                                            //                                                       startDate:
                                            //                                                           product.startDate,
                                            //                                                       uuid:
                                            //                                                           product.uuid,
                                            //                                                     ),
                                            //                                                     oldProduct:
                                            //                                                         product,
                                            //                                                   );

                                            //                                                   // setState(
                                            //                                                   //   () {
                                            //                                                   //     isLoading =
                                            //                                                   //         false;
                                            //                                                   //     showSuccess =
                                            //                                                   //         true;
                                            //                                                   //   },
                                            //                                                   // );
                                            //                                                   // if (safeContext.mounted) {
                                            //                                                   //   await dataProvider.getProducts(
                                            //                                                   //     shopI,
                                            //                                                   //   );
                                            //                                                   // }
                                            //                                                   // if (safeContext.mounted) {
                                            //                                                   //   await dataProvider.getProducts(
                                            //                                                   //     shopI,
                                            //                                                   //   );
                                            //                                                   // }

                                            //                                                   if (safeContext.mounted) {
                                            //                                                     Navigator.of(
                                            //                                                       safeContext,
                                            //                                                     ).pop();
                                            //                                                     setState(
                                            //                                                       () {},
                                            //                                                     );
                                            //                                                   }

                                            //                                                   // setState(
                                            //                                                   //   () {
                                            //                                                   //     showSuccess =
                                            //                                                   //         false;
                                            //                                                   //   },
                                            //                                                   // );
                                            //                                                 },
                                            //                                               );
                                            //                                             },
                                            //                                           );
                                            //                                         }
                                            //                                       },
                                            //                                       text:
                                            //                                           'Update Quantity',
                                            //                                     ),
                                            //                                     SizedBox(
                                            //                                       height:
                                            //                                           15,
                                            //                                     ),
                                            //                                     Material(
                                            //                                       color:
                                            //                                           Colors.transparent,
                                            //                                       child: EditButton(
                                            //                                         text:
                                            //                                             'Cancel',
                                            //                                         action: () {
                                            //                                           Navigator.of(
                                            //                                             context,
                                            //                                           ).pop();
                                            //                                         },
                                            //                                         theme:
                                            //                                             widget.theme,
                                            //                                       ),
                                            //                                     ),
                                            //                                   ],
                                            //                                 ),
                                            //                               ),
                                            //                             ],
                                            //                           ),
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //             );
                                            //           },
                                            //         ).then((
                                            //           context,
                                            //         ) {
                                            //           setState(() {
                                            //             qttyPerUnitController.clear();
                                            //             isAddToQuantity =
                                            //                 true;
                                            //           });
                                            //         });
                                            //       },
                                            //       text:
                                            //           'Edit ${product.groupUnit != null && product.groupUnit != 'Others' ? '${product.groupUnit}' : 'Group'} Qtty',
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Other Details',
                              ),
                            ],
                          ),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 5.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b2
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                        ),
                                        'Manage this Item?',
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ItemsAuthAction().allowStockallToManageItemAction(
                                            context:
                                                context,
                                            action: () {
                                              if (authorization(
                                                authorized:
                                                    Authorizations()
                                                        .updateProduct,
                                              )) {
                                                var dataProvider =
                                                    returnData();
                                                showDialog(
                                                  context:
                                                      context,
                                                  builder: (
                                                    confirmDialog,
                                                  ) {
                                                    return ConfirmationAlert(
                                                      theme:
                                                          widget.theme,
                                                      message:
                                                          product.isManaged
                                                              ? 'This item quantity will no longer be automatically managed by Stockall, are you sure you want to proceed?'
                                                              : 'This item quantity will now be automatically managed by Stockall, are you sure you want to proceed?',
                                                      title:
                                                          'Proceed with Action?',
                                                      action: () async {
                                                        Navigator.of(
                                                          confirmDialog,
                                                        ).pop();
                                                        setState(() {
                                                          isLoading =
                                                              true;
                                                        });
                                                        await dataProvider.updateProduct(
                                                          product: TempProductClass(
                                                            storageUuid:
                                                                product.storageUuid,
                                                            departmentName:
                                                                product.departmentName,
                                                            departmentUuid:
                                                                product.departmentUuid,
                                                            groupUnit:
                                                                product.groupUnit,
                                                            qttyPerGroup:
                                                                product.qttyPerGroup,
                                                            updatedAt:
                                                                DateTime.now(),
                                                            totalQttyInStorageDouble:
                                                                product.totalQttyInStorageDouble,
                                                            setCustomPrice:
                                                                product.setCustomPrice,
                                                            isManaged:
                                                                product.isManaged
                                                                    ? false
                                                                    : true,
                                                            // id:
                                                            //     product.id,
                                                            name:
                                                                product.name,
                                                            unit:
                                                                product.unit,
                                                            isRefundable:
                                                                product.isRefundable,
                                                            costPrice:
                                                                product.costPrice,
                                                            sellingPrice:
                                                                product.sellingPrice,
                                                            wholeSalePrice:
                                                                product.wholeSalePrice,
                                                            quantity:
                                                                !product.isManaged &&
                                                                        product.quantity ==
                                                                            null
                                                                    ? 0
                                                                    : product.quantity,
                                                            shopId:
                                                                product.shopId,
                                                            barcode:
                                                                product.barcode,
                                                            categoryUuid:
                                                                product.categoryUuid,
                                                            createdAt:
                                                                product.createdAt,
                                                            discount:
                                                                product.discount,
                                                            endDate:
                                                                product.endDate,
                                                            expiryDate:
                                                                product.expiryDate,
                                                            lowQtty:
                                                                product.lowQtty,
                                                            sizeType:
                                                                product.sizeType,
                                                            startDate:
                                                                product.startDate,
                                                            uuid:
                                                                product.uuid,
                                                          ),
                                                          oldProduct:
                                                              product,
                                                        );
                                                        setState(() {
                                                          isLoading =
                                                              false;
                                                        });
                                                      },
                                                    );
                                                  },
                                                );
                                              }
                                            },
                                          );
                                        },
                                        child: SubWrapper(
                                          isVisible:
                                              !ItemsAuthAction()
                                                  .allowStockallToManageItemAction(
                                                    context:
                                                        context,
                                                  ),
                                          mainWidget: Container(
                                            width: 50,
                                            padding:
                                                EdgeInsets.symmetric(
                                                  horizontal:
                                                      10,
                                                  vertical:
                                                      5,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    20,
                                                  ),
                                              border: Border.all(
                                                color:
                                                    product.isManaged
                                                        ? widget.theme.lightModeColor.prColor250
                                                        : Colors.grey,
                                              ),
                                              color:
                                                  product.isManaged
                                                      ? widget
                                                          .theme
                                                          .lightModeColor
                                                          .prColor250
                                                      : Colors
                                                          .grey
                                                          .shade200,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  product.isManaged
                                                      ? MainAxisAlignment
                                                          .end
                                                      : MainAxisAlignment
                                                          .start,
                                              children: [
                                                Container(
                                                  padding:
                                                      EdgeInsets.all(
                                                        5,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    shape:
                                                        BoxShape.circle,
                                                    color:
                                                        product.isManaged
                                                            ? Colors.white
                                                            : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      product.expiryDate !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        product.expiryDate !=
                                                null
                                            ? getDayDifference(
                                                      product.expiryDate ??
                                                          DateTime.now(),
                                                    ) >=
                                                    1
                                                ? formatDateTime(
                                                  product.expiryDate ??
                                                      DateTime.now(),
                                                )
                                                : 'Item Expired'
                                            : 'Not Set',
                                    text: 'Expiry Date',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.barcode ??
                                      'Not Set',
                                  text: 'Barcode',
                                  onClick: () {
                                    if (authorization(
                                      authorized:
                                          Authorizations()
                                              .updateProduct,
                                    )) {
                                      ItemsAuthAction().generateBarcodeAction(
                                        context: context,
                                        action: () {
                                          returnData()
                                              .addToBarcodeGenerationList(
                                                ProductBarcode(
                                                  product:
                                                      product,
                                                  number: 1,
                                                ),
                                              );
                                          showDialog(
                                            context:
                                                context,
                                            builder: (
                                              firstContext,
                                            ) {
                                              return ConfirmationAlert(
                                                theme:
                                                    widget
                                                        .theme,
                                                message:
                                                    'You are about to regenrate and print the barcode of this item, are you sure you want to proceed?',
                                                actionButtonText:
                                                    'Generate',
                                                title:
                                                    'Regenerate and Print Barcode?',
                                                action: () async {
                                                  Navigator.of(
                                                    firstContext,
                                                  ).pop();
                                                  setState(() {
                                                    isLoading =
                                                        true;
                                                  });
                                                  generateBarcodeAndPrint(
                                                    context,
                                                    returnData()
                                                        .barcodeGenerationList,
                                                    false,
                                                  ).then((
                                                    _,
                                                  ) {
                                                    returnData()
                                                        .clearBarcodeGenerationList();
                                                    setState(() {
                                                      isLoading =
                                                          false;
                                                    });
                                                  });

                                                  print(
                                                    'Generate Clicked',
                                                  );
                                                },
                                              );
                                            },
                                          );
                                        },
                                      );
                                    }
                                  },
                                  setBarcodeAction:
                                      product.barcode ==
                                              null
                                          ? () {
                                            if (authorization(
                                              authorized:
                                                  Authorizations()
                                                      .updateProduct,
                                            )) {
                                              ItemsAuthAction().generateBarcodeAction(
                                                context:
                                                    context,
                                                action: () {
                                                  returnData().addToBarcodeGenerationList(
                                                    ProductBarcode(
                                                      product:
                                                          product,
                                                      number:
                                                          1,
                                                    ),
                                                  );
                                                  generateBarcodeAndPrint(
                                                    context,
                                                    returnData()
                                                        .barcodeGenerationList,
                                                    false,
                                                  );
                                                },
                                              );
                                            }
                                          }
                                          : null,
                                  actionText:
                                      product.barcode ==
                                              null
                                          ? 'Create Barcode'
                                          : null,
                                ),

                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.discount !=
                                              null
                                          ? "${product.discount}%"
                                          : 'Not Set',
                                  text: 'Discount',
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.storageUuid !=
                                                  null &&
                                              returnStorageProductProvider()
                                                  .storageProductListMain
                                                  .where(
                                                    (
                                                      storage,
                                                    ) =>
                                                        storage.uuid ==
                                                        product.storageUuid,
                                                  )
                                                  .isNotEmpty
                                          ? returnStorageProductProvider()
                                                  .storageProductListMain
                                                  .where(
                                                    (
                                                      storage,
                                                    ) =>
                                                        storage.uuid ==
                                                        product.storageUuid,
                                                  )
                                                  .first
                                                  .unit ??
                                              'Others'
                                          : '${product.unit.substring(0, 1).toUpperCase()}${product.unit.substring(1)}',
                                  text: 'Unit',
                                ),
                                Visibility(
                                  visible:
                                      product.sizeType !=
                                      null,
                                  child: BottomInfoSection(
                                    theme: widget.theme,
                                    mainText:
                                        product.sizeType ??
                                        'Not Set',
                                    text: 'Size Type',
                                  ),
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      returnCategoriesProvider(
                                                context:
                                                    context,
                                              )
                                              .categories()
                                              .where(
                                                (cat) =>
                                                    cat.uuid ==
                                                    product
                                                        .categoryUuid,
                                              )
                                              .isNotEmpty
                                          ? returnCategoriesProvider(
                                                context:
                                                    context,
                                              )
                                              .categories()
                                              .where(
                                                (cat) =>
                                                    cat.uuid ==
                                                    product
                                                        .categoryUuid,
                                              )
                                              .first
                                              .name
                                          : 'Not Set',
                                  text: 'CategoryUuid',
                                ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.lowQtty!
                                          .toString(),
                                  text:
                                      'Low Quantity Limit',
                                ),
                                // BottomInfoSection(
                                //   theme: widget.theme,
                                //   mainText:
                                //       product.isRefundable
                                //           ? 'True'
                                //           : 'False',
                                //   text: 'Is Refundable?',
                                // ),
                                BottomInfoSection(
                                  theme: widget.theme,
                                  mainText:
                                      product.setCustomPrice
                                          ? 'True'
                                          : 'False',
                                  text:
                                      'Can Set Custom Price?',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    spacing: 15,
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .deleteProduct,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Delete Item',
                            action: () {
                              final safeContext = context;
                              showDialog(
                                context: safeContext,
                                builder: (confirmDialog) {
                                  var provider =
                                      returnData();
                                  var shopId =
                                      returnShopProvider()
                                          .userShop()!
                                          .shopId!;
                                  return ConfirmationAlert(
                                    theme: returnTheme(
                                      context,
                                    ),
                                    message:
                                        'Are you sure you want to proceed with action?',
                                    title: 'Are you sure?',
                                    action: () async {
                                      Navigator.of(
                                        confirmDialog,
                                      ).pop();

                                      setState(() {
                                        isLoading = true;
                                      });
                                      await provider
                                          .deleteProductMain(
                                            product,
                                          );
                                      await provider
                                          .getProducts(
                                            shopId,
                                          );
                                      setState(() {
                                        isLoading = false;
                                        showSuccess = true;
                                      });
                                      Future.delayed(
                                        Duration(
                                          seconds: 2,
                                        ),
                                        () {
                                          if (safeContext
                                              .mounted) {
                                            Navigator.of(
                                              safeContext,
                                            ).pop();
                                          }
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            theme: returnTheme(context),
                            icon:
                                Icons
                                    .delete_forever_outlined,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations()
                                  .updateProduct,
                        ),
                        child: Expanded(
                          child: EditButton(
                            text: 'Edit Item',
                            action: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddProduct(
                                      product: product,
                                      isStorage: false,
                                    );
                                  },
                                ),
                              ).then((context) {
                                setState(() {});
                              });
                            },
                            theme: returnTheme(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Updating'),
          ),
        ],
      );
    }
  }
}

class EditButton extends StatelessWidget {
  final String text;
  final Function() action;
  final ThemeProvider theme;
  final IconData? icon;
  final Color? color;

  const EditButton({
    super.key,
    required this.text,
    required this.action,
    required this.theme,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.transparent,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 7),

          child: Center(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: theme.lightModeColor.prColor300,
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  text,
                ),
                Icon(
                  size: 18,
                  color:
                      color ??
                      theme.lightModeColor.prColor300,
                  icon ?? Icons.edit_note_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabContainerMobile extends StatelessWidget {
  const TabContainerMobile({
    super.key,
    required this.theme,
    required this.backGround,
    required this.border,
    required this.price,
    required this.text,
    required this.isMoney,
    this.isDiscount,
  });
  final Color backGround;
  final Color border;
  final double price;
  final ThemeProvider theme;
  final String text;
  final bool isMoney;
  final bool? isDiscount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backGround,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                text,
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                '${isMoney ? currencySymbol(context: context) : ''}${isMoney
                    ? formatLargeNumberDouble(price)
                    : authorization(authorized: Authorizations().viewItemQuantity)
                    ? formatLargeNumberDouble(price)
                    : 'Restricted'}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
