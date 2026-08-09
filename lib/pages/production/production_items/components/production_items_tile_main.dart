import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class ProductionItemsTileMain extends StatefulWidget {
  final Function() action;
  final ProductionItem productionItem;
  final bool? isSelectProductionItem;
  final List<String>? uuidList;
  final Function()? longPress;
  const ProductionItemsTileMain({
    super.key,
    required this.theme,
    required this.productionItem,
    required this.action,
    this.isSelectProductionItem,
    this.uuidList,
    this.longPress,
  });

  final ThemeProvider theme;

  @override
  State<ProductionItemsTileMain> createState() =>
      _ProductionItemsTileMainState();
}

class _ProductionItemsTileMainState
    extends State<ProductionItemsTileMain> {
  bool isManaged() {
    return widget.productionItem.isManaged;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(
                30,
                158,
                158,
                158,
              ),
              blurRadius: 5,
            ),
          ],
        ),
        child: Material(
          borderRadius: BorderRadius.circular(5),
          elevation: 0,
          color: Colors.white,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            borderRadius: BorderRadius.circular(5),
            onTap: widget.action,
            onLongPress: widget.longPress,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical:
                    widget.isSelectProductionItem != null &&
                            widget.isSelectProductionItem ==
                                true
                        ? 19
                        : 15,
              ),
              child: Row(
                children: [
                  Visibility(
                    visible:
                        widget.isSelectProductionItem !=
                            null &&
                        widget.isSelectProductionItem ==
                            true,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  widget.uuidList != null &&
                                          widget.uuidList!
                                              .contains(
                                                widget
                                                    .productionItem
                                                    .uuid!,
                                              )
                                      ? widget
                                          .theme
                                          .lightModeColor
                                          .prColor250
                                      : Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .secColor50,
                    ),
                    child: Icon(
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .secColor200,
                      Icons.api_rounded,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Row(
                      children: [
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
                          widget.productionItem.name,
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    spacing: 5,
                    children: [
                      Visibility(
                        visible:
                            widget.isSelectProductionItem ==
                                null ||
                            widget.isSelectProductionItem ==
                                false,
                        child: Icon(
                          size: 16,
                          color: Colors.grey.shade400,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 3,
                              ),
                          child: Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            widget
                                        .productionItem
                                        .expiryDate !=
                                    null
                                ? getDayDifference(
                                          widget
                                                  .productionItem
                                                  .expiryDate ??
                                              DateTime.now(),
                                        ) >=
                                        1
                                    ? widget
                                                .productionItem
                                                .quantity ==
                                            0
                                        ? 'Out of Stock'
                                        : widget
                                                .productionItem
                                                .quantity ==
                                            null
                                        ? 'Not Set'
                                        : authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewItemQuantity,
                                        )
                                        ? formatLargeNumberDouble(
                                          (widget
                                                  .productionItem
                                                  .quantity ??
                                              0),
                                        )
                                        : 'Restricted'
                                    : 'Item Expired'
                                : widget
                                        .productionItem
                                        .quantity ==
                                    0
                                ? 'Out of Stock'
                                : widget
                                        .productionItem
                                        .quantity ==
                                    null
                                ? 'Not Set'
                                : authorization(
                                  authorized:
                                      Authorizations()
                                          .viewItemQuantity,
                                )
                                ? formatLargeNumberDouble(
                                  (widget
                                          .productionItem
                                          .quantity ??
                                      0),
                                )
                                : 'Restricted',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
