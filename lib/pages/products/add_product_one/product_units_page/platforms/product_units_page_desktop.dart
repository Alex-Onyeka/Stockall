import 'package:flutter/material.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/create_product_unit_widget.dart';
import 'package:stockall/pages/products/add_product_one/product_units_page/components/product_units_list_tile_widget.dart';

class ProductUnitsPageDesktop extends StatefulWidget {
  final String productUuid;
  final TextEditingController quantityController;
  final TextEditingController nameController;
  const ProductUnitsPageDesktop({
    super.key,
    required this.productUuid,
    required this.quantityController,
    required this.nameController,
  });

  @override
  State<ProductUnitsPageDesktop> createState() =>
      _ProductUnitsPageDesktopState();
}

class _ProductUnitsPageDesktopState
    extends State<ProductUnitsPageDesktop> {
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
                      'Units',
                    ),
                    Text(
                      style:
                          theme
                              .mobileTexts
                              .b3
                              .textStyleNormal,
                      "Manage Your Items Units",
                    ),
                  ],
                ),
              ),
              CreateProductUnitWidget(
                productUuid: widget.productUuid,
                nameController: widget.nameController,
                quantityController:
                    widget.quantityController,
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
                if (returnData().tempUnitsList.isEmpty) {
                  return Material(
                    color: Colors.transparent,
                    child: EmptyWidgetDisplayOnly(
                      title: 'No Units Added',
                      subText:
                          'You have not added any Product Unit.',
                      theme: theme,
                      height: 25,
                      altAction: () {
                        addProductUnitAction(
                          context: context,
                          nameController:
                              widget.nameController,
                          productUuid: widget.productUuid,
                          quantityController:
                              widget.quantityController,
                          setStateAction: () {
                            setState(() {});
                          },
                        );
                      },
                      altActionText: 'Create New Unit',
                      altIcon: Icons.add,
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
                                        productUnit.uuid,
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
