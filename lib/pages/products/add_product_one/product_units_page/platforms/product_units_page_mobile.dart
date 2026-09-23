import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/create_product_unit_widget.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/product_units_list_tile_widget.dart';

class ProductUnitsPageMobile extends StatefulWidget {
  final String productUuid;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  const ProductUnitsPageMobile({
    super.key,
    required this.productUuid,
    required this.quantityController,
    required this.nameController,
  });

  @override
  State<ProductUnitsPageMobile> createState() =>
      _ProductUnitsPageMobileState();
}

class _ProductUnitsPageMobileState
    extends State<ProductUnitsPageMobile> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Product Units',
        backAction: () {
          Navigator.of(context).pop();
        },
        widget: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: CreateProductUnitWidget(
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
                    if (returnData().unitsList().isEmpty) {
                      return Material(
                        color: Colors.transparent,
                        child: EmptyWidgetDisplayOnly(
                          title: 'No Product Units Added',
                          subText:
                              'You have not added any Product Unit.',
                          theme: theme,
                          height: 25,
                          altAction: () {
                            // returnData().getProducts(
                            //   shopId(),
                            // );
                          },
                          altActionText: 'Refresh',
                          altIcon: Icons.refresh,
                          icon: Icons.clear,
                        ),
                      );
                    } else {
                      return ListView(
                        // shrinkWrap: true,
                        children:
                            returnData(context: context)
                                .tempUnitsListSorted()
                                .map(
                                  (productUnit) =>
                                      ProductUnitListTileWidget(
                                        unitUuid:
                                            productUnit
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
