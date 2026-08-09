import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/providers/theme_provider.dart';

class MaterialsTileMain extends StatefulWidget {
  final Function() action;
  final MaterialClass material;
  final bool? isSelectMaterial;
  final List<String>? uuidList;
  final Function()? longPress;
  const MaterialsTileMain({
    super.key,
    required this.theme,
    required this.material,
    required this.action,
    this.isSelectMaterial,
    this.uuidList,
    this.longPress,
  });

  final ThemeProvider theme;

  @override
  State<MaterialsTileMain> createState() =>
      _MaterialsTileMainState();
}

class _MaterialsTileMainState
    extends State<MaterialsTileMain> {
  bool isManaged() {
    return widget.material.isManaged;
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
                    widget.isSelectMaterial != null &&
                            widget.isSelectMaterial == true
                        ? 19
                        : 15,
              ),
              child: Row(
                children: [
                  Visibility(
                    visible:
                        widget.isSelectMaterial != null &&
                        widget.isSelectMaterial == true,
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
                                          widget.uuidList
                                                  ?.contains(
                                                    widget.material.uuid ??
                                                        '',
                                                  ) ==
                                              true
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
                    height: 25,
                    width: 25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .tertColor50,
                    ),
                    child: Icon(
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .tertColor200,
                      size: 20,
                      Icons.app_registration_rounded,
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
                          widget.material.name,
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
                            widget.isSelectMaterial ==
                                null ||
                            widget.isSelectMaterial ==
                                false,
                        child: Icon(
                          size: 16,
                          color: Colors.grey.shade400,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              isManaged()
                                  ? getDayDifference(
                                                widget
                                                        .material
                                                        .expiryDate ??
                                                    DateTime.now(),
                                              ) <
                                              1 &&
                                          widget
                                                  .material
                                                  .expiryDate !=
                                              null
                                      ? const Color.fromARGB(
                                        255,
                                        255,
                                        232,
                                        231,
                                      )
                                      : widget
                                                  .material
                                                  .quantity !=
                                              0 &&
                                          (widget
                                                      .material
                                                      .quantity ??
                                                  0) >
                                              (widget
                                                      .material
                                                      .lowQtty ??
                                                  10)
                                      ? Colors.grey.shade100
                                      : widget
                                                  .material
                                                  .quantity !=
                                              0 &&
                                          (widget
                                                      .material
                                                      .quantity ??
                                                  0) <=
                                              (widget
                                                      .material
                                                      .lowQtty ??
                                                  10)
                                      ? const Color.fromARGB(
                                        255,
                                        255,
                                        249,
                                        227,
                                      )
                                      : const Color.fromARGB(
                                        255,
                                        255,
                                        232,
                                        231,
                                      )
                                  : Colors.grey.shade100,
                          border: Border.all(
                            color:
                                isManaged()
                                    ? getDayDifference(
                                                  widget.material.expiryDate ??
                                                      DateTime.now(),
                                                ) <
                                                1 &&
                                            widget
                                                    .material
                                                    .expiryDate !=
                                                null
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          142,
                                          134,
                                        )
                                        : widget
                                                    .material
                                                    .quantity !=
                                                0 &&
                                            (widget.material.quantity ??
                                                    0) >
                                                (widget
                                                        .material
                                                        .lowQtty ??
                                                    10)
                                        ? Colors
                                            .grey
                                            .shade700
                                        : widget
                                                    .material
                                                    .quantity !=
                                                0 &&
                                            (widget.material.quantity ??
                                                    0) <=
                                                (widget
                                                        .material
                                                        .lowQtty ??
                                                    0)
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          229,
                                          62,
                                        )
                                        : const Color.fromARGB(
                                          255,
                                          255,
                                          142,
                                          134,
                                        )
                                    : Colors.grey.shade400,
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
                              color:
                                  isManaged()
                                      ? getDayDifference(
                                                    widget.material.expiryDate ??
                                                        DateTime.now(),
                                                  ) <
                                                  1 &&
                                              widget
                                                      .material
                                                      .expiryDate !=
                                                  null
                                          ? const Color.fromARGB(
                                            255,
                                            255,
                                            142,
                                            134,
                                          )
                                          : widget
                                                      .material
                                                      .quantity !=
                                                  0 &&
                                              (widget.material.quantity ??
                                                      0) >
                                                  (widget
                                                          .material
                                                          .lowQtty ??
                                                      10)
                                          ? Colors
                                              .grey
                                              .shade700
                                          : widget
                                                      .material
                                                      .quantity !=
                                                  0 &&
                                              (widget.material.quantity ??
                                                      0) <=
                                                  widget
                                                      .material
                                                      .lowQtty!
                                          ? const Color.fromARGB(
                                            255,
                                            132,
                                            115,
                                            1,
                                          )
                                          : const Color.fromARGB(
                                            255,
                                            255,
                                            142,
                                            134,
                                          )
                                      : Colors
                                          .grey
                                          .shade700,
                            ),
                            widget.material.expiryDate !=
                                    null
                                ? getDayDifference(
                                          widget
                                                  .material
                                                  .expiryDate ??
                                              DateTime.now(),
                                        ) >=
                                        1
                                    ? widget
                                                .material
                                                .quantity ==
                                            0
                                        ? 'Out of Stock'
                                        : widget
                                                .material
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
                                                  .material
                                                  .quantity ??
                                              0),
                                        )
                                        : 'Restricted'
                                    : 'Item Expired'
                                : widget
                                        .material
                                        .quantity ==
                                    0
                                ? 'Out of Stock'
                                : widget
                                        .material
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
                                          .material
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
