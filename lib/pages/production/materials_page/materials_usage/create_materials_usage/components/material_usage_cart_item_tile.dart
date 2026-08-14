import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_usage_cart/temp_materials_usage_cart_item/materials_usage_cart_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';

class MaterialUsageCartItemTile extends StatefulWidget {
  const MaterialUsageCartItemTile({
    super.key,
    required this.materialsUsageCartItem,
    this.editAction,
  });
  final MaterialsUsageCartItem materialsUsageCartItem;
  final Function()? editAction;

  @override
  State<MaterialUsageCartItemTile> createState() =>
      MaterialUsageCartItemTileState();
}

class MaterialUsageCartItemTileState
    extends State<MaterialUsageCartItemTile> {
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
                              .materialsUsageCartItem
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
                                        returnMaterialsUsageActionProvider()
                                            .removeMaterialItemFromCart(
                                              itemUuid:
                                                  widget
                                                      .materialsUsageCartItem
                                                      .uuid ??
                                                  '',
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
                                          .materialsUsageCartItem
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
                                  .materialsUsageCartItem
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
                            widget.materialsUsageCartItem
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
