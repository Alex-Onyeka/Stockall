import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/create_product_price_widget.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/product_prices_list_tile_widget.dart';

class ProductPricesPageDesktop extends StatefulWidget {
  final String productUuid;
  final TextEditingController priceController;
  final TextEditingController nameController;
  final double? costPrice;

  const ProductPricesPageDesktop({
    super.key,
    required this.productUuid,
    required this.priceController,
    required this.nameController,
    this.costPrice,
  });

  @override
  State<ProductPricesPageDesktop> createState() =>
      _ProductPricesPageDesktopState();
}

class _ProductPricesPageDesktopState
    extends State<ProductPricesPageDesktop> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      mainWidget: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(height: 5),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 20,
                    ),
                    child: Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      // returnData().getProducts(shopId());
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 15,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Icon(
                            color: Colors.grey,
                            size: 18,
                            Icons.refresh,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  spacing: 8,
                  children: [
                    Text(
                      style: TextStyle(
                        color:
                            theme
                                .lightModeColor
                                .shadesColorBlack,
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight:
                            theme
                                .mobileTexts
                                .h4
                                .fontWeightBold,
                      ),
                      'Prices',
                    ),
                    Text(
                      style:
                          theme
                              .mobileTexts
                              .b3
                              .textStyleNormal,
                      "Manage Your Items Prices",
                    ),
                  ],
                ),
              ),
              CreateProductPriceWidget(
                productUuid: widget.productUuid,
                nameController: widget.nameController,
                priceController: widget.priceController,
                costPrice: widget.costPrice,
                setStateAction: () {
                  setState(() {});
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          Expanded(
            child: Builder(
              builder: (context) {
                if (returnData().tempPricesList.isEmpty) {
                  return Material(
                    color: Colors.transparent,
                    child: EmptyWidgetDisplayOnly(
                      title: 'No Prices Added',
                      subText:
                          'You have not added any Product Price.',
                      theme: theme,
                      height: 25,
                      altAction: () {
                        addProductPriceAction(
                          context: context,
                          nameController:
                              widget.nameController,
                          productUuid: widget.productUuid,
                          priceController:
                              widget.priceController,
                          costPrice: widget.costPrice,
                          setStateAction: () {
                            setState(() {});
                          },
                        );
                      },
                      altActionText: 'Create New Price',
                      altIcon: Icons.add,
                      icon: Icons.clear,
                    ),
                  );
                } else {
                  return ListView(
                    // shrinkWrap: true,
                    children:
                        returnData(context: context)
                            .tempPricesListSorted()
                            .map(
                              (productPrice) =>
                                  ProductPriceListTileWidget(
                                    priceUuid:
                                        productPrice.uuid,
                                    costPrice:
                                        widget.costPrice,
                                  ),
                            )
                            .toList(),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
