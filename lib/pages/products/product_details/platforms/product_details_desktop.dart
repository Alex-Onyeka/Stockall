import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/text_fields/edit_cart_text_field.dart';
import 'package:stockall/components/text_fields/money_textfield.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ProductDetailsDesktop extends StatefulWidget {
  final ThemeProvider theme;
  final int productId;
  const ProductDetailsDesktop({
    super.key,
    required this.theme,
    required this.productId,
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
  bool isAddToQuantity = true;

  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController discountController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    costController.dispose();
    sellingController.dispose();
    quantityController.dispose();
    discountController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final shopI =
        returnShopProvider(
          context,
          listen: false,
        ).userShop!.shopId!;
    List<TempProductClass>? productList =
        returnData(context).productList
            .where(
              (product) => product.id! == widget.productId,
            )
            .toList();
    if (productList.isEmpty) {
      return Scaffold(
        body: returnCompProvider(
          context,
          listen: false,
        ).showLoader('Loading...'),
      );
    } else {
      TempProductClass product = productList.first;
      return Scaffold(
        key: _scaffoldKey,
        drawer: MyDrawerWidgetDesktopMain(
          action: () {
            var safeContext = context;
            showDialog(
              context: context,
              builder: (context) {
                return ConfirmationAlert(
                  theme: widget.theme,
                  message: 'You are about to Logout',
                  title: 'Are you Sure?',
                  action: () async {
                    Navigator.of(context).pop();
                    setState(() {
                      isLoading = true;
                    });
                    if (safeContext.mounted) {
                      await AuthService().signOut(
                        safeContext,
                      );
                    }
                  },
                );
              },
            );
          },
          theme: widget.theme,
          notifications:
              returnNotificationProvider(
                    context,
                  ).notifications.isEmpty
                  ? []
                  : returnNotificationProvider(
                    context,
                  ).notifications,
          globalKey: _scaffoldKey,
        ),
        body: Row(
          spacing: 15,
          children: [
            Visibility(
              visible: screenWidth(context) > mobileScreen,
              child: MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: widget.theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () {
                          AuthService().signOut(context);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AuthScreensPage();
                              },
                            ),
                          );
                          returnNavProvider(
                            context,
                            listen: false,
                          ).navigate(0);
                        },
                      );
                    },
                  );
                },
                theme: widget.theme,
                notifications:
                    returnNotificationProvider(
                      context,
                    ).notifications,
              ),
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
                          visible: authorization(
                            authorized:
                                Authorizations()
                                    .updateProduct,
                            context: context,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return AddProduct(
                                      product: product,
                                    );
                                  },
                                ),
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
                                              .b1
                                              .fontSize,
                                    ),
                                    'Edit',
                                  ),
                                  Icon(
                                    Icons.edit_note_rounded,
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
                                    Column(
                                      children: [
                                        Row(
                                          spacing: 15,
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
                                                    product
                                                        .costPrice,
                                                theme:
                                                    widget
                                                        .theme,
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
                                              child: TabContainer(
                                                isMoney:
                                                    true,
                                                text:
                                                    'Selling Price',
                                                price:
                                                    product
                                                        .sellingPrice ??
                                                    0,
                                                theme:
                                                    widget
                                                        .theme,
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
                                            Expanded(
                                              child: TabContainer(
                                                isMoney:
                                                    false,
                                                text:
                                                    'Quantity In Stock',
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
                                          ],
                                        ),
                                        Visibility(
                                          visible: authorization(
                                            authorized:
                                                Authorizations()
                                                    .updateProduct,
                                            context:
                                                context,
                                          ),
                                          child: SizedBox(
                                            height: 15,
                                          ),
                                        ),
                                        Row(
                                          spacing: 15,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Visibility(
                                                visible: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .updateProduct,
                                                  context:
                                                      context,
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
                                                              ? product.sellingPrice.toString().split(
                                                                '.',
                                                              )[0]
                                                              : '';

                                                      costController.text =
                                                          product.costPrice.toString().toString().split(
                                                            '.',
                                                          )[0];
                                                    });
                                                    showGeneralDialog(
                                                      context:
                                                          context,
                                                      pageBuilder: (
                                                        context,
                                                        animation,
                                                        secondaryAnimation,
                                                      ) {
                                                        return Material(
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
                                                                              IconButton(
                                                                                onPressed: () {
                                                                                  Navigator.of(
                                                                                    context,
                                                                                  ).pop();
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.clear,
                                                                                ),
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
                                                                              if (costController.text.isNotEmpty) {
                                                                                showDialog(
                                                                                  context:
                                                                                      safeContext,
                                                                                  builder: (
                                                                                    context,
                                                                                  ) {
                                                                                    return ConfirmationAlert(
                                                                                      theme:
                                                                                          widget.theme,
                                                                                      message:
                                                                                          'Are you sure you want to proceed?',
                                                                                      title:
                                                                                          'Proceed?',
                                                                                      action: () async {
                                                                                        final dataProvider = returnData(
                                                                                          context,
                                                                                          listen:
                                                                                              false,
                                                                                        );
                                                                                        if (safeContext.mounted) {
                                                                                          Navigator.of(
                                                                                            safeContext,
                                                                                          ).pop();
                                                                                        }
                                                                                        setState(
                                                                                          () {
                                                                                            isLoading =
                                                                                                true;
                                                                                          },
                                                                                        );
                                                                                        await dataProvider.updateProduct(
                                                                                          context:
                                                                                              context,
                                                                                          product: TempProductClass(
                                                                                            updatedAt:
                                                                                                DateTime.now(),
                                                                                            setCustomPrice:
                                                                                                product.setCustomPrice,
                                                                                            isManaged:
                                                                                                product.isManaged,
                                                                                            id:
                                                                                                product.id,
                                                                                            name:
                                                                                                product.name,
                                                                                            unit:
                                                                                                product.unit,
                                                                                            isRefundable:
                                                                                                product.isRefundable,
                                                                                            costPrice: double.parse(
                                                                                              costController.text.replaceAll(
                                                                                                ',',
                                                                                                '',
                                                                                              ),
                                                                                            ),
                                                                                            sellingPrice:
                                                                                                sellingController.text.isNotEmpty
                                                                                                    ? double.tryParse(
                                                                                                      sellingController.text.replaceAll(
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
                                                                                            category:
                                                                                                product.category,
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
                                                                                        );

                                                                                        if (safeContext.mounted) {
                                                                                          await dataProvider.getProducts(
                                                                                            shopI,
                                                                                          );
                                                                                        }

                                                                                        setState(
                                                                                          () {
                                                                                            isLoading =
                                                                                                false;
                                                                                            showSuccess =
                                                                                                true;
                                                                                          },
                                                                                        );

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

                                                                                        setState(
                                                                                          () {
                                                                                            showSuccess =
                                                                                                false;
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                );
                                                                              } else {
                                                                                showDialog(
                                                                                  context:
                                                                                      context,
                                                                                  builder: (
                                                                                    context,
                                                                                  ) {
                                                                                    return InfoAlert(
                                                                                      theme:
                                                                                          widget.theme,
                                                                                      message:
                                                                                          'Cost price and Selling price must be set.',
                                                                                      title:
                                                                                          'Empty Fields',
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
                                                        );
                                                      },
                                                    );
                                                  },
                                                  text:
                                                      'Edit Prices',
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Visibility(
                                                visible: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .updateProduct,
                                                  context:
                                                      context,
                                                ),
                                                child: EditButton(
                                                  theme:
                                                      widget
                                                          .theme,
                                                  action: () {
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
                                                                                      'Edit Quantity',
                                                                                    ),
                                                                                    IconButton(
                                                                                      onPressed: () {
                                                                                        Navigator.of(
                                                                                          context,
                                                                                        ).pop();
                                                                                      },
                                                                                      icon: Icon(
                                                                                        Icons.clear,
                                                                                      ),
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
                                                                                          ? 'Not Set'
                                                                                          : 'Current Quantity Amount : ${product.quantity!.toStringAsFixed(0)}',
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
                                                                                      10,
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
                                                                                                10,
                                                                                            vertical:
                                                                                                10,
                                                                                          ),
                                                                                          child: Row(
                                                                                            spacing:
                                                                                                10,
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
                                                                                                      16,
                                                                                                  color:
                                                                                                      Colors.white,
                                                                                                  Icons.check,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                style: TextStyle(
                                                                                                  fontSize:
                                                                                                      widget.theme.mobileTexts.b3.fontSize,
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
                                                                                                10,
                                                                                            horizontal:
                                                                                                10,
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
                                                                                                      16,
                                                                                                  color:
                                                                                                      Colors.white,
                                                                                                  Icons.check,
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                style: TextStyle(
                                                                                                  fontSize:
                                                                                                      widget.theme.mobileTexts.b3.fontSize,
                                                                                                  fontWeight:
                                                                                                      FontWeight.bold,
                                                                                                ),
                                                                                                'Replace Qauntity',
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

                                                                                    final dataProvider = returnData(
                                                                                      context,
                                                                                      listen:
                                                                                          false,
                                                                                    );

                                                                                    showDialog(
                                                                                      context:
                                                                                          safeContext,
                                                                                      builder: (
                                                                                        context,
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
                                                                                                safeContext,
                                                                                              ).pop();
                                                                                            }
                                                                                            setState(
                                                                                              () {
                                                                                                isLoading =
                                                                                                    true;
                                                                                              },
                                                                                            );
                                                                                            await dataProvider.updateQuantity(
                                                                                              context:
                                                                                                  context,
                                                                                              productId:
                                                                                                  product.id!,

                                                                                              newQuantity:
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
                                                                                                        quantityController.text,
                                                                                                      )
                                                                                                      : quantityController.text.isNotEmpty &&
                                                                                                          isAddToQuantity
                                                                                                      ? double.parse(
                                                                                                            quantityController.text,
                                                                                                          ) +
                                                                                                          (product.quantity ??
                                                                                                              0)
                                                                                                      : product.quantity,
                                                                                            );

                                                                                            setState(
                                                                                              () {
                                                                                                isLoading =
                                                                                                    false;
                                                                                                showSuccess =
                                                                                                    true;
                                                                                              },
                                                                                            );
                                                                                            if (safeContext.mounted) {
                                                                                              await dataProvider.getProducts(
                                                                                                shopI,
                                                                                              );
                                                                                            }
                                                                                            if (safeContext.mounted) {
                                                                                              await dataProvider.getProducts(
                                                                                                shopI,
                                                                                              );
                                                                                            }

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

                                                                                            setState(
                                                                                              () {
                                                                                                showSuccess =
                                                                                                    false;
                                                                                              },
                                                                                            );
                                                                                          },
                                                                                        );
                                                                                      },
                                                                                    );
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
                                                        quantityController.clear();
                                                        isAddToQuantity =
                                                            true;
                                                      });
                                                    });
                                                  },
                                                  text:
                                                      'Edit Quantity',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                                        spacing: 10,
                                        children: [
                                          Row(
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
                                                          .b1
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .normal,
                                                ),
                                                'Manage this Item?',
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  var safeContext =
                                                      context;
                                                  showDialog(
                                                    context:
                                                        context,
                                                    builder: (
                                                      context,
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
                                                            context,
                                                          ).pop();
                                                          setState(
                                                            () {
                                                              isLoading =
                                                                  true;
                                                            },
                                                          );
                                                          await returnData(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).updateIsManaged(
                                                            productId:
                                                                product.id!,
                                                            context:
                                                                safeContext,
                                                            value:
                                                                product.isManaged
                                                                    ? false
                                                                    : true,
                                                            qtty:
                                                                !product.isManaged &&
                                                                        product.quantity ==
                                                                            null
                                                                    ? 0
                                                                    : product.quantity?.toInt(),
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
                                                },
                                                child: Container(
                                                  width: 50,
                                                  padding: EdgeInsets.symmetric(
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
                                            ],
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
                                          ),

                                          // Visibility(
                                          //   visible:
                                          //       product.startDate != null,
                                          //   child: BottomInfoSection(
                                          //     theme: widget.theme,
                                          //     mainText:
                                          //         product.startDate !=
                                          //                 null
                                          //             ? formatDateTime(
                                          //               product
                                          //                   .startDate!,
                                          //             )
                                          //             : 'Not Set',
                                          //     text: 'Discount Start',
                                          //   ),
                                          // ),
                                          // Visibility(
                                          //   visible:
                                          //       product.endDate != null,
                                          //   child: BottomInfoSection(
                                          //     theme: widget.theme,
                                          //     mainText:
                                          //         product.endDate != null
                                          //             ? formatDateTime(
                                          //               product.endDate!,
                                          //             )
                                          //             : 'Not Set',
                                          //     text: 'Discount End',
                                          //   ),
                                          // ),
                                          BottomInfoSection(
                                            theme:
                                                widget
                                                    .theme,
                                            mainText:
                                                '${product.unit.substring(0, 1).toUpperCase()}${product.unit.substring(1)}',
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
                                                product
                                                    .category ??
                                                'Not Set',
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
                                          // BottomInfoSection(
                                          //   theme: widget.theme,
                                          //   mainText:
                                          //       product.isRefundable
                                          //           ? 'True'
                                          //           : 'False',
                                          //   text: 'Is Refundable?',
                                          // ),
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
                                    context: context,
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
                                            context,
                                          ) {
                                            var provider =
                                                returnData(
                                                  context,
                                                  listen:
                                                      false,
                                                );
                                            var shopId =
                                                returnShopProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).userShop!.shopId!;
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
                                                if (safeContext
                                                    .mounted) {
                                                  Navigator.of(
                                                    safeContext,
                                                  ).pop();
                                                }
                                                setState(() {
                                                  isLoading =
                                                      true;
                                                });
                                                await provider
                                                    .deleteProductMain(
                                                      widget
                                                          .productId,
                                                      context,
                                                    );
                                                await provider
                                                    .getProducts(
                                                      shopId,
                                                    );
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
                                    context: context,
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
                      ).showLoader('Updating'),
                    ),
                  ],
                ),
              ),
            ),
            RightSideBar(theme: widget.theme),
          ],
        ),
      );
    }
    // return Scaffold(
    //   body: Center(
    //     child: InkWell(
    //       onTap: () {
    //         Navigator.of(context).pop();
    //       },
    //       child: Padding(
    //         padding: const EdgeInsets.all(20.0),
    //         child: Text(productList.first.name),
    //       ),
    //     ),
    //   ),
    // );
  }
}

class BottomInfoSection extends StatelessWidget {
  const BottomInfoSection({
    super.key,
    required this.theme,
    required this.text,
    required this.mainText,
  });

  final ThemeProvider theme;
  final String text;
  final String mainText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b1.fontSize,
            fontWeight: FontWeight.normal,
          ),
          '$text:',
        ),
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b2.fontSize,
            fontWeight: FontWeight.bold,
          ),
          mainText,
        ),
      ],
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
          padding: EdgeInsets.symmetric(vertical: 9),

          child: Center(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: theme.lightModeColor.prColor300,
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  text,
                ),
                Icon(
                  size: 20,
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
      padding: EdgeInsets.all(10),
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
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.normal,
                ),
                text,
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                '${isMoney ? currencySymbol(context: context) : ''}${formatLargeNumberDouble(price)}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
