import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/create_product_price_widget.dart';
import 'package:stockall/pages/products/add_product_one/product_prices_page/components/product_prices_list_tile_widget.dart';

class ProductPricesPageMobile extends StatefulWidget {
  final String productUuid;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  const ProductPricesPageMobile({
    super.key,
    required this.productUuid,
    required this.quantityController,
    required this.nameController,
  });

  @override
  State<ProductPricesPageMobile> createState() =>
      _ProductPricesPageMobileState();
}

class _ProductPricesPageMobileState
    extends State<ProductPricesPageMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Product Prices',
        backAction: () {
          Navigator.of(context).pop();
        },
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CreateProductPriceWidget(
            nameController: widget.nameController,
            quantityController: widget.quantityController,
            productUuid: widget.productUuid,
            setStateAction: () {
              setState(() {});
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
          ),
          child: Column(
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (returnData()
                        .tempPricesList
                        .isEmpty) {
                      return Material(
                        color: Colors.transparent,
                        child: EmptyWidgetDisplayOnly(
                          title: 'No Product Prices Added',
                          subText:
                              'You have not added any Product Price.',
                          theme: theme,
                          height: 25,
                          altAction: () {
                            addProductPriceAction(
                              context: context,
                              nameController:
                                  widget.nameController,
                              productUuid:
                                  widget.productUuid,
                              quantityController:
                                  widget.quantityController,
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
                                            productPrice
                                                .uuid,
                                      ),
                                )
                                .toList(),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
