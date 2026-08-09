import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ProductionMaterialCartItemTile
    extends StatefulWidget {
  const ProductionMaterialCartItemTile({
    super.key,
    required this.productionMaterialCartItem,
  });
  final ProductionMaterialCartItem
  productionMaterialCartItem;

  @override
  State<ProductionMaterialCartItemTile> createState() =>
      ProductionMaterialCartItemTileState();
}

class ProductionMaterialCartItemTileState
    extends State<ProductionMaterialCartItemTile> {
  String cutLongText(String text) {
    if (text.length >
        (screenWidth(context) > mobileScreen ? 25 : 15)) {
      return '${text.substring(0, (screenWidth(context) > mobileScreen ? 25 : 15))}...';
    } else {
      return text;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          onTap: () {
            // showDialog(
            //   context: context,
            //   builder: (firstContext) {
            //     return DialogTemplate(
            //       theme: theme,
            //       message: 'View Item History Details',
            //       title: 'Usage Details',
            //       action: () {},
            //       showBottomActionButtons: false,
            //       widget: SizedBox(
            //         height: screenHeight(context) - 200,
            //         child: MaterialUsageDetailsWidget(
            //           productionMaterialCartItem:
            //               widget.productionMaterialCartItem,
            //           fromDetails: widget.fromDetails,
            //         ),
            //       ),
            //     );
            //   },
            // );
          },
          borderRadius: BorderRadius.circular(5),
          child: Container(
            padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Visibility(
                  visible:
                      screenWidth(context) >
                      mobileScreenSmall,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          theme.lightModeColor.tertColor50,
                    ),
                    child: Icon(
                      color:
                          theme.lightModeColor.tertColor200,
                      size: 20,
                      Icons.border_horizontal_rounded,
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    children: [
                      Row(
                        spacing: 15,
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              spacing: 5,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                    ),
                                    (widget
                                        .productionMaterialCartItem
                                        .name),
                                  ),
                                ),
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
                                  ),
                                  formatLargeNumberDouble(
                                    widget
                                        .productionMaterialCartItem
                                        .quantity,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            size: 15,
                            color: Colors.grey.shade400,
                            Icons.arrow_forward_ios_rounded,
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      Divider(
                        color: Colors.grey.shade400,
                        thickness: 0.5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          // top: 5.0,
                          // bottom: 5,
                          right: 15,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                    'Cost:',
                                  ),
                                  Flexible(
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        color:
                                            theme
                                                .lightModeColor
                                                .prColor300,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      formatMoneyBig(
                                        amount:
                                            widget
                                                .productionMaterialCartItem
                                                .getCostPrice(),
                                        context: context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              spacing: 3,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  formatLargeNumberDouble(
                                    widget
                                        .productionMaterialCartItem
                                        .quantity,
                                  ),
                                ),
                              ],
                            ),
                          ],
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
  }
}
