import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class UnitSelectionWidget extends StatefulWidget {
  final TempProductClass product;
  final ThemeProvider theme;
  final String? unitUuid;
  final Function(String? uuid)? setUnitUuid;
  final bool? showSelectUnitText;
  const UnitSelectionWidget({
    super.key,
    required this.product,
    required this.theme,
    required this.unitUuid,
    required this.setUnitUuid,
    this.showSelectUnitText,
  });

  @override
  State<UnitSelectionWidget> createState() =>
      _UnitSelectionWidgetState();
}

class _UnitSelectionWidgetState
    extends State<UnitSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.product.getUnitsList().length > 1,
      child: Column(
        spacing: 5,
        children: [
          Visibility(
            visible: widget.showSelectUnitText != false,
            child: Text(
              style: TextStyle(
                fontSize:
                    widget.theme.mobileTexts.b4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Select Unit:',
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 250),
            child: PopupMenuButton(
              // offset: Offset(-20, 30),
              color: Colors.white,
              itemBuilder:
                  (context) =>
                      widget.product
                          .getUnitsList()
                          .map(
                            (item) => PopupMenuItem(
                              onTap: () {
                                widget.setUnitUuid != null
                                    ? widget.setUnitUuid!(
                                      item.uuid,
                                    )
                                    : {};
                              },
                              child: SizedBox(
                                width: 201,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                widget.product
                                                            .getProductUnit(
                                                              unitUuid:
                                                                  widget.unitUuid,
                                                            )
                                                            .uuid ==
                                                        item.uuid
                                                    ? FontWeight
                                                        .bold
                                                    : null,
                                          ),
                                          item.name,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            widget.product
                                                .getProductUnit(
                                                  unitUuid:
                                                      widget
                                                          .unitUuid,
                                                )
                                                .uuid ==
                                            item.uuid,
                                        child: Icon(
                                          size: 17,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade700,
                                          Icons.check,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 5, 5),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            widget
                                .theme
                                .mobileTexts
                                .b3
                                .fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      widget.product
                          .getProductUnit(
                            unitUuid: widget.unitUuid,
                          )
                          .name,
                    ),
                    Icon(Icons.keyboard_arrow_down),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
