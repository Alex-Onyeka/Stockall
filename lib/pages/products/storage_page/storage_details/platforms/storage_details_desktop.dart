import 'package:flutter/material.dart';
// import 'package:path/path.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/storage_page/storage_details/components.dart';
import 'package:stockall/providers/theme_provider.dart';

class StorageDetailsDesktop extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  const StorageDetailsDesktop({
    super.key,
    required this.theme,
    required this.productUuid,
  });

  @override
  State<StorageDetailsDesktop> createState() =>
      _StorageDetailsDesktopState();
}

class _StorageDetailsDesktopState
    extends State<StorageDetailsDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    List<TempStorageProducts>? productList =
        returnStorageProductProvider(context: context)
            .storageProductListMain
            .where(
              (product) =>
                  product.uuid == widget.productUuid,
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
      TempStorageProducts product = productList.first;
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
                                                    .b3
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
                                          'Date Created:  ${formatDateTime(product.createdAt ?? DateTime.now())}',
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    Column(
                                      spacing: 10,
                                      children: [
                                        Row(
                                          spacing:
                                              shop(context)
                                                          ?.useGroupUnit ==
                                                      true
                                                  ? 10
                                                  : 0,
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
                                          children: [
                                            Visibility(
                                              visible:
                                                  shop(
                                                    context,
                                                  )?.useGroupUnit ==
                                                  true,
                                              child: Expanded(
                                                child: TabContainer(
                                                  isMoney:
                                                      false,
                                                  text:
                                                      'Group Quantity',
                                                  price:
                                                      (product.quantity ??
                                                          0) /
                                                      (product.qttyPerGroup ??
                                                          1),
                                                  theme:
                                                      widget
                                                          .theme,
                                                  backGround:
                                                      const Color.fromARGB(
                                                        10,
                                                        58,
                                                        58,
                                                        58,
                                                      ),
                                                  border:
                                                      const Color.fromARGB(
                                                        31,
                                                        30,
                                                        30,
                                                        32,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: TabContainer(
                                                isMoney:
                                                    false,
                                                text:
                                                    'Unit Quantity',
                                                price:
                                                    product
                                                        .quantity ??
                                                    0,
                                                theme:
                                                    widget
                                                        .theme,
                                                backGround:
                                                    const Color.fromARGB(
                                                      10,
                                                      58,
                                                      58,
                                                      58,
                                                    ),
                                                border:
                                                    const Color.fromARGB(
                                                      31,
                                                      30,
                                                      30,
                                                      32,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        EditButton(
                                          theme:
                                              widget.theme,
                                          action: () async {
                                            updateStorageQuantity(
                                              storageProduct:
                                                  product,
                                              context:
                                                  context,
                                              theme:
                                                  widget
                                                      .theme,
                                            );
                                          },
                                          text:
                                              'Update Quantity',
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
                                          'Products',
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
                                          ManageProductsStorage(
                                            productUuid:
                                                widget
                                                    .productUuid,
                                            theme:
                                                widget
                                                    .theme,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Column(
                                            children:
                                                returnData(
                                                      context:
                                                          context,
                                                    )
                                                    .productListMain
                                                    .where(
                                                      (
                                                        pr,
                                                      ) =>
                                                          pr.storageUuid ==
                                                          widget.productUuid,
                                                    )
                                                    .toList()
                                                    .map(
                                                      (
                                                        pro,
                                                      ) => ProductTileMain(
                                                        product:
                                                            pro,
                                                        theme:
                                                            widget.theme,
                                                        action: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (
                                                                context,
                                                              ) {
                                                                return ProductDetailsPage(
                                                                  productUuid:
                                                                      pro.uuid!,
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
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
                                                returnStorageProductProvider();
                                            var shopId =
                                                returnShopProvider()
                                                    .userShop()!
                                                    .shopId!;
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
                                                await provider
                                                    .getStorageProducts(
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
                                                productStorage:
                                                    product,
                                                isStorage:
                                                    true,
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
          ],
        ),
      );
    }
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
                '${isMoney ? currencySymbol(context: context) : ''}${formatLargeNumberDouble(price)}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
