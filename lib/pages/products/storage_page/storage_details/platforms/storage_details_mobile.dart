import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/storage_page/storage_details/components.dart';
import 'package:stockall/providers/theme_provider.dart';

class StorageDetailsMobile extends StatefulWidget {
  final ThemeProvider theme;
  final String productUuid;
  const StorageDetailsMobile({
    super.key,
    required this.theme,
    required this.productUuid,
  });

  @override
  State<StorageDetailsMobile> createState() =>
      _StorageDetailsMobileState();
}

class _StorageDetailsMobileState
    extends State<StorageDetailsMobile> {
  bool isLoading = false;
  bool showSuccess = false;

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
      return Stack(
        children: [
          Scaffold(
            appBar: appBar(
              context: context,
              title: 'Details',
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
                                          .b3
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
                                spacing:
                                    shop(
                                              context,
                                            )?.useGroupUnit ==
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
                                        isMoney: false,
                                        text:
                                            'Group Quantity',
                                        price:
                                            (product.quantity ??
                                                1) /
                                            (product.qttyPerGroup ??
                                                1),
                                        theme: widget.theme,
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
                                      isMoney: false,
                                      text: 'Unit Quantity',
                                      price:
                                          product
                                              .quantity ??
                                          0,
                                      theme: widget.theme,
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
                              SizedBox(height: 12),
                              EditButton(
                                theme: widget.theme,
                                action: () async {
                                  updateStorageQuantity(
                                    product: product,
                                    context: context,
                                    theme: widget.theme,
                                  );
                                },
                                text: 'Update Quantity',
                              ),
                            ],
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
                                'Products',
                              ),
                            ],
                          ),
                          Divider(
                            height: 15,
                            color: Colors.grey.shade200,
                          ),
                          SizedBox(height: 5),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 3.0,
                                ),
                            child: Column(
                              spacing: 0,
                              children: [
                                SizedBox(height: 5),
                                ManageProductsStorage(
                                  productUuid:
                                      widget.productUuid,
                                  theme: widget.theme,
                                ),
                                SizedBox(height: 5),
                                Column(
                                  children:
                                      returnData(
                                            context:
                                                context,
                                          ).productListMain
                                          .where(
                                            (pr) =>
                                                pr.storageUuid ==
                                                widget
                                                    .productUuid,
                                          )
                                          .toList()
                                          .map(
                                            (
                                              pro,
                                            ) => ProductTileMain(
                                              product: pro,
                                              theme:
                                                  widget
                                                      .theme,
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
                      Expanded(
                        child: EditButton(
                          text: 'Delete Item',
                          action: () {
                            final safeContext = context;
                            showDialog(
                              context: safeContext,
                              builder: (confirmDialog) {
                                var provider =
                                    returnStorageProductProvider();
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
                                        .getStorageProducts(
                                          shopId,
                                        );
                                    setState(() {
                                      isLoading = false;
                                      showSuccess = true;
                                    });
                                    Future.delayed(
                                      Duration(seconds: 2),
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
                              Icons.delete_forever_outlined,
                          color: Colors.redAccent,
                        ),
                      ),
                      Expanded(
                        child: EditButton(
                          text: 'Edit Item',
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return AddProduct(
                                    productStorage: product,
                                    isStorage: true,
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
                '${isMoney ? currencySymbol(context: context) : ''}${formatLargeNumberDouble(price)}${isDiscount != null ? '%' : ''}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
