import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
// import 'package:path/path.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/barcode_printing_page/barcode_printing_page.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/product_details/platforms/components/update_item_quantity.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductDetailsDesktop extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  final bool? comingFromInventoryUpdatesPage;
  const ProductDetailsDesktop({
    super.key,
    required this.theme,
    required this.productUuid,
    this.comingFromInventoryUpdatesPage,
  });

  @override
  State<ProductDetailsDesktop> createState() =>
      _ProductDetailsDesktopState();
}

class _ProductDetailsDesktopState
    extends State<ProductDetailsDesktop> {
  late Future<TempProductClass> productFuture;

  bool isLoading = false;
  bool showSuccess = false;
  bool setDate = false;

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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final shopI = returnShopProvider().userShop()!.shopId!;
    List<TempProductClass>? productList =
        returnData(context: context).productListMain
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
      return Scaffold(
        key: _scaffoldKey,
        body: Row(
          spacing: 15,
          children: [
            Container(
              width:
                  screenWidth(context) < tabletScreenSmall
                      ? 50
                      : (screenWidth(context) >
                              tabletScreenSmall &&
                          screenWidth(context) <
                              tabletScreen + 100)
                      ? 100
                      : 230,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
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
                child: Stack(
                  children: [
                    Scaffold(
                      appBar: appBar(
                        context: context,
                        title: 'Item Details',
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
                                    title:
                                        'Add Item to Cart',
                                    action: () async {
                                      Navigator.of(
                                        safeContext,
                                      ).pop();
                                      var res = await returnSalesProvider()
                                          .addItemToCart(
                                            context:
                                                context,
                                            newItem: TempCartItem(
                                              isVoid: false,
                                              qttyPerGroup:
                                                  null,
                                              useGroupQuantity:
                                                  false,
                                              useWholeSalePrice:
                                                  false,
                                              setCustomPrice:
                                                  false,
                                              item: product,
                                              quantity: 1,
                                              discount:
                                                  null,
                                              addToStock:
                                                  false,
                                              setTotalPrice:
                                                  false,
                                            ),
                                            isCustomEdit:
                                                false,
                                          );
                                      if (res ==
                                          "Quantity Limit Exceeded") {
                                        return;
                                      }
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
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
                              margin: EdgeInsets.only(
                                right: 5,
                              ),
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
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                    ),
                                    'Add to Cart',
                                  ),
                                  Icon(
                                    size: 17,
                                    Icons
                                        .shopping_cart_outlined,
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
                                      CrossAxisAlignment
                                          .center,
                                  children: [
                                    SizedBox(height: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                      children: [
                                        Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .h4
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
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
                                                FontWeight
                                                    .normal,
                                          ),
                                          'Date Created:  ${formatDateTime(product.createdAt!)}',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Column(
                                            spacing: 10,
                                            children: [
                                              Row(
                                                spacing: 10,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Expanded(
                                                    child: TabContainer(
                                                      isMoney:
                                                          true,
                                                      text:
                                                          'Cost Price',
                                                      price:
                                                          product.costPrice,
                                                      theme:
                                                          widget.theme,
                                                      backGround: const Color.fromARGB(
                                                        11,
                                                        15,
                                                        4,
                                                        114,
                                                      ),
                                                      border: const Color.fromARGB(
                                                        32,
                                                        45,
                                                        3,
                                                        255,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: TabContainer(
                                                      isMoney:
                                                          true,
                                                      text:
                                                          'Selling Price',
                                                      price:
                                                          product.sellingPrice ??
                                                          0,
                                                      theme:
                                                          widget.theme,
                                                      backGround: const Color.fromARGB(
                                                        25,
                                                        235,
                                                        150,
                                                        3,
                                                      ),
                                                      border: const Color.fromARGB(
                                                        74,
                                                        232,
                                                        148,
                                                        3,
                                                      ),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible:
                                                        shop(
                                                          context,
                                                        )?.wholeSale ==
                                                        true,
                                                    child: Expanded(
                                                      child: TabContainer(
                                                        isMoney:
                                                            true,
                                                        text:
                                                            'Whole Sale Price',
                                                        price:
                                                            product.wholeSalePrice ??
                                                            0,
                                                        theme:
                                                            widget.theme,
                                                        backGround: const Color.fromARGB(
                                                          24,
                                                          135,
                                                          235,
                                                          3,
                                                        ),
                                                        border: const Color.fromARGB(
                                                          73,
                                                          106,
                                                          232,
                                                          3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Visibility(
                                                visible: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .updateProduct,
                                                ),
                                                child: EditButton(
                                                  theme:
                                                      widget
                                                          .theme,
                                                  action: () {
                                                    setState(() {
                                                      sellingController.text =
                                                          product.sellingPrice !=
                                                                  null
                                                              ? product.sellingPrice.toString()
                                                              : '';

                                                      wholeSaleController.text =
                                                          product.wholeSalePrice !=
                                                                  null
                                                              ? product.wholeSalePrice.toString()
                                                              : '';

                                                      costController.text =
                                                          product.costPrice.toString().toString();
                                                    });
                                                    bool
                                                    isEditPriceLoading =
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
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            padding: EdgeInsets.all(
                                                                              40,
                                                                            ),
                                                                            margin: EdgeInsets.only(
                                                                              bottom:
                                                                                  100,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              color:
                                                                                  Colors.white,
                                                                              borderRadius: BorderRadius.circular(
                                                                                15,
                                                                              ),
                                                                              boxShadow: [
                                                                                BoxShadow(
                                                                                  color: const Color.fromARGB(
                                                                                    39,
                                                                                    4,
                                                                                    1,
                                                                                    41,
                                                                                  ),
                                                                                  blurRadius:
                                                                                      10,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            width:
                                                                                500,
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
                                                                                                  totalQttyInStorageDouble:
                                                                                                      product.totalQttyInStorageDouble,
                                                                                                  setCustomPrice:
                                                                                                      product.setCustomPrice,
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
                                                                                                  uuid:
                                                                                                      product.uuid,
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
                                                  text:
                                                      'Edit Prices',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              returnShopProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .userShop()
                                                  ?.useGroupUnit !=
                                              true,
                                          child: SizedBox(
                                            width: 10,
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              returnShopProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .userShop()
                                                  ?.useGroupUnit !=
                                              true,
                                          child:
                                              quantityInStockWidget(
                                                context,
                                                product,
                                                shopI,
                                              ),
                                        ),
                                      ],
                                    ),

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
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            spacing: 10,
                                            children: [
                                              quantityInStockWidget(
                                                context,
                                                product,
                                                shopI,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Divider(
                                      height: 15,
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment
                                              .center,
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
                                                    .bold,
                                          ),
                                          'Other Details',
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      height: 15,
                                      color:
                                          Colors
                                              .grey
                                              .shade200,
                                    ),
                                    SizedBox(height: 10),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0,
                                          ),
                                      child: Column(
                                        spacing: 0,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  vertical:
                                                      5.0,
                                                ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        widget.theme.mobileTexts.b1.fontSize,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                  'Manage this Item?',
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    ItemsAuthAction().allowStockallToManageItemAction(
                                                      context:
                                                          context,
                                                      action: () async {
                                                        if (authorization(
                                                          authorized:
                                                              Authorizations().updateProduct,
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
                                                                  setState(
                                                                    () {
                                                                      isLoading =
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
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          false;
                                                                    },
                                                                  );
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
                                                        !ItemsAuthAction().allowStockallToManageItemAction(
                                                          context:
                                                              context,
                                                        ),
                                                    mainWidget: Container(
                                                      width:
                                                          50,
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal:
                                                            10,
                                                        vertical:
                                                            5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
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
                                                                ? widget.theme.lightModeColor.prColor250
                                                                : Colors.grey.shade200,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            product.isManaged
                                                                ? MainAxisAlignment.end
                                                                : MainAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(
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
                                                product
                                                    .expiryDate !=
                                                null,
                                            child: BottomInfoSection(
                                              theme:
                                                  widget
                                                      .theme,
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
                                              text:
                                                  'Expiry Date',
                                            ),
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                product
                                                    .barcode ??
                                                'Not Set',
                                            text: 'Barcode',
                                            onClick: () {
                                              if (authorization(
                                                authorized:
                                                    Authorizations()
                                                        .updateProduct,
                                              )) {
                                                ItemsAuthAction().generateBarcodeAction(
                                                  context:
                                                      context,
                                                  action: () {
                                                    if (kIsWeb) {
                                                      showDialog(
                                                        context:
                                                            context,
                                                        builder: (
                                                          firstContext,
                                                        ) {
                                                          return ConfirmationAlert(
                                                            theme:
                                                                widget.theme,
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
                                                              setState(
                                                                () {
                                                                  isLoading =
                                                                      true;
                                                                },
                                                              );
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
                                                                returnData().barcodeGenerationList,
                                                                false,
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  returnData().clearBarcodeGenerationList();
                                                                  setState(
                                                                    () {
                                                                      isLoading =
                                                                          false;
                                                                    },
                                                                  );
                                                                },
                                                              );

                                                              print(
                                                                'Generate Clicked',
                                                              );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return BarcodePrintingPage(
                                                              product:
                                                                  product,
                                                            );
                                                          },
                                                        ),
                                                      );
                                                    }
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
                                                            Authorizations().updateProduct,
                                                      )) {
                                                        ItemsAuthAction().generateBarcodeAction(
                                                          context:
                                                              context,
                                                          action: () {
                                                            if (kIsWeb) {
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
                                                                returnData().barcodeGenerationList,
                                                                false,
                                                              );
                                                            } else {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return BarcodePrintingPage(
                                                                      product:
                                                                          product,
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            }
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
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                product.discount !=
                                                        null
                                                    ? "${product.discount}%"
                                                    : 'Not Set',
                                            text:
                                                'Discount',
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
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
                                                    ? returnStorageProductProvider().storageProductListMain
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
                                                product
                                                    .sizeType !=
                                                null,
                                            child: BottomInfoSection(
                                              theme:
                                                  widget
                                                      .theme,
                                              mainText:
                                                  product
                                                      .sizeType ??
                                                  'Not Set',
                                              text:
                                                  'Size Type',
                                            ),
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                returnCategoriesProvider(
                                                          context:
                                                              context,
                                                        )
                                                        .categories()
                                                        .where(
                                                          (
                                                            cat,
                                                          ) =>
                                                              cat.uuid ==
                                                              product.categoryUuid,
                                                        )
                                                        .isNotEmpty
                                                    ? returnCategoriesProvider(
                                                          context:
                                                              context,
                                                        )
                                                        .categories()
                                                        .where(
                                                          (
                                                            cat,
                                                          ) =>
                                                              cat.uuid ==
                                                              product.categoryUuid,
                                                        )
                                                        .first
                                                        .name
                                                    : 'Not Set',
                                            text:
                                                'Category',
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                product
                                                    .lowQtty!
                                                    .toString(),
                                            text:
                                                'Low Quantity Limit',
                                          ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
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
                                        final safeContext =
                                            context;
                                        showDialog(
                                          context:
                                              safeContext,
                                          builder: (
                                            confirmDialog,
                                          ) {
                                            var provider =
                                                returnData();
                                            return ConfirmationAlert(
                                              theme:
                                                  returnTheme(
                                                    context,
                                                  ),
                                              message:
                                                  'Are you sure you want to proceed with action?',
                                              title:
                                                  'Are you sure?',
                                              action: () async {
                                                Navigator.of(
                                                  confirmDialog,
                                                ).pop();
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                await provider
                                                    .deleteProductMain(
                                                      product,
                                                    );
                                                // await provider
                                                //     .getProducts(
                                                //       shopId,
                                                //     );
                                                setState(() {
                                                  isLoading =
                                                      false;
                                                  showSuccess =
                                                      true;
                                                });
                                                Future.delayed(
                                                  Duration(
                                                    seconds:
                                                        2,
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
                                      theme: returnTheme(
                                        context,
                                      ),
                                      icon:
                                          Icons
                                              .delete_forever_outlined,
                                      color:
                                          Colors.redAccent,
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
                                            builder: (
                                              context,
                                            ) {
                                              return AddProduct(
                                                product:
                                                    product,
                                              );
                                            },
                                          ),
                                        ).then((context) {
                                          setState(() {});
                                        });
                                      },
                                      theme: returnTheme(
                                        context,
                                      ),
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
                ),
              ),
            ),
            Container(
              width:
                  screenWidth(context) < tabletScreenSmall
                      ? 50
                      : (screenWidth(context) >
                              tabletScreenSmall &&
                          screenWidth(context) <
                              tabletScreen + 100)
                      ? 100
                      : 230,
            ),
            // Visibility(
            //   visible:
            //       widget.comingFromInventoryUpdatesPage ==
            //       null,
            //   child: RightSideBar(theme: widget.theme),
            // ),
          ],
        ),
      );
    }
  }

  Widget quantityInStockWidget(
    BuildContext context,
    TempProductClass product,
    int shopI,
  ) {
    return Expanded(
      flex: 1,
      child: Column(
        spacing: 10,
        children: [
          Row(
            children: [
              Visibility(
                visible:
                    shop(context)?.useGroupUnit == true,
                child: Expanded(
                  child: TabContainer(
                    isMoney: false,
                    text:
                        product.storageUuid != null &&
                                returnStorageProductProvider()
                                    .storageProductListMain
                                    .where(
                                      (storage) =>
                                          storage.uuid ==
                                          product
                                              .storageUuid,
                                    )
                                    .isNotEmpty
                            ? ' Quantity Of ${returnStorageProductProvider().storageProductListMain.where((storage) => storage.uuid == product.storageUuid).first.groupUnit ?? 'Others'}'
                            : product.groupUnit != null &&
                                product.groupUnit !=
                                    'Others'
                            ? ' Quantity Of ${product.groupUnit}'
                            : 'Group Quantity',
                    price: returnData(
                      context: context,
                    ).returnGroupQuantityValue(product),
                    theme: widget.theme,
                    backGround:
                        product.isManaged
                            ? (product.quantity ?? 0) >
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
                            ? (product.quantity ?? 0) >
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
              Visibility(
                visible:
                    shop(context)?.useGroupUnit == true,
                child: SizedBox(width: 10),
              ),
              Expanded(
                child: TabContainer(
                  isMoney: false,
                  text:
                      product.storageUuid != null &&
                              returnStorageProductProvider()
                                  .storageProductListMain
                                  .where(
                                    (storage) =>
                                        storage.uuid ==
                                        product.storageUuid,
                                  )
                                  .isNotEmpty
                          ? ' Quantity Of ${returnStorageProductProvider().storageProductListMain.where((storage) => storage.uuid == product.storageUuid).first.unit ?? 'Others'}'
                          : product.unit != 'Others'
                          ? ' Quantity Of ${product.unit}'
                          : 'Unit Quantity',
                  price: product.quantity ?? 0,
                  theme: widget.theme,
                  backGround:
                      product.isManaged
                          ? (product.quantity ?? 0) >
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
                          ? (product.quantity ?? 0) >
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
            ],
          ),
          Visibility(
            visible:
                authorization(
                  authorized:
                      Authorizations().updateProduct,
                ) &&
                authorization(
                  authorized:
                      Authorizations().updateItemQuantity,
                ) &&
                returnShopProvider()
                        .userShop()
                        ?.manageInventoryStorage !=
                    true,
            child: Row(
              children: [
                Expanded(
                  child: EditButton(
                    theme: widget.theme,
                    action: () {
                      updateItemQuantity(context, product);
                    },
                    text: 'Edit Unit Qtty',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomInfoSection extends StatefulWidget {
  const BottomInfoSection({
    super.key,
    required this.theme,
    required this.text,
    required this.mainText,
    this.setBarcodeAction,
    this.actionText,
    this.onClick,
  });

  final ThemeProvider theme;
  final String text;
  final String mainText;
  final Function()? setBarcodeAction;
  final String? actionText;
  final Function()? onClick;

  @override
  State<BottomInfoSection> createState() =>
      _BottomInfoSectionState();
}

class _BottomInfoSectionState
    extends State<BottomInfoSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            style: TextStyle(
              fontSize:
                  widget.theme.mobileTexts.b2.fontSize,
              fontWeight: FontWeight.normal,
            ),
            '${widget.text}:',
          ),
          Row(
            children: [
              Visibility(
                visible: widget.setBarcodeAction != null,
                child: Material(
                  color: Colors.transparent,
                  child: Ink(
                    decoration: BoxDecoration(
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .prColor300,
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(
                        3,
                      ),
                      onTap: widget.setBarcodeAction,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        child: Center(
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            widget.actionText ?? '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.setBarcodeAction == null,
                child: InkWell(
                  onTap: () {
                    widget.onClick != null
                        ? widget.onClick!()
                        : {};
                    print('Clicked');
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: widget.onClick != null,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              color: Colors.grey.shade600,
                              Icons.arrow_left,
                            ),
                            // SizedBox(width: 2),
                          ],
                        ),
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b2
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.mainText,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                    fontSize: theme.mobileTexts.b3.fontSize,
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

class TabContainer extends StatelessWidget {
  const TabContainer({
    super.key,
    required this.theme,
    required this.backGround,
    required this.border,
    required this.price,
    required this.text,
    required this.isMoney,
    this.priceTextSize,
    this.isDiscount,
  });
  final Color backGround;
  final Color border;
  final double price;
  final ThemeProvider theme;
  final String text;
  final bool isMoney;
  final bool? isDiscount;
  final double? priceTextSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 7,
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
                  fontSize:
                      priceTextSize ??
                      theme.mobileTexts.b2.fontSize,
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
