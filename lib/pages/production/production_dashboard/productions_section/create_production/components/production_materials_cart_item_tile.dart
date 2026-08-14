import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions_cart/temp_production_material_cart_item/production_material_cart_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class ProductionMaterialCartItemTile
    extends StatefulWidget {
  const ProductionMaterialCartItemTile({
    super.key,
    required this.productionMaterialCartItem,
    this.editAction,
  });
  final ProductionMaterialCartItem
  productionMaterialCartItem;
  final Function()? editAction;

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
      padding: const EdgeInsets.symmetric(
        vertical: 3.0,
        horizontal: 5,
      ),
      child: Container(
        padding: EdgeInsets.fromLTRB(8, 15, 15, 15),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(20, 0, 0, 0),
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Visibility(
              visible:
                  screenWidth(context) > mobileScreenSmall,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.lightModeColor.tertColor50,
                ),
                child: Icon(
                  color: theme.lightModeColor.tertColor200,
                  size: 18,
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
                        CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
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
                      Row(
                        spacing: 5,
                        children: [
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: widget.editAction,
                              mouseCursor:
                                  SystemMouseCursors.click,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 8,
                                    ),
                                child: Icon(
                                  size: 20,
                                  color:
                                      Colors.grey.shade400,
                                  Icons.edit,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            type: MaterialType.transparency,
                            child: InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (firstContext) {
                                    return ConfirmationAlert(
                                      theme: theme,
                                      message:
                                          'You are about to remove this material from the cart. Are you sure you want to proceed?',
                                      title:
                                          'Remove Material From Cart',
                                      action: () {
                                        returnProductionsActionProvider()
                                            .removeMaterialItemFromCart(
                                              item:
                                                  widget
                                                      .productionMaterialCartItem,
                                            );
                                        Navigator.of(
                                          context,
                                        ).pop();
                                      },
                                    );
                                  },
                                );
                              },
                              mouseCursor:
                                  SystemMouseCursors.click,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                      horizontal: 8,
                                    ),
                                child: Icon(
                                  size: 20,
                                  color:
                                      Colors.red.shade400,
                                  Icons.clear,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.grey.shade400,
                    thickness: 0.5,
                    height: 1,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 5,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                color: Colors.grey.shade600,
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
                                          .costPrice ??
                                      0,
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              color:
                                  theme
                                      .lightModeColor
                                      .prColor250,
                            ),
                            formatLargeNumberDouble(
                              widget
                                  .productionMaterialCartItem
                                  .quantity,
                            ),
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              color: Colors.grey.shade600,
                            ),
                            widget
                                .productionMaterialCartItem
                                .getUnit(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
