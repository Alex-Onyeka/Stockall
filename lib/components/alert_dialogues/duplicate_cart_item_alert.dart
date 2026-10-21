import 'package:flutter/material.dart';
import 'package:flutter_polygon_clipper/flutter_polygon_clipper.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

enum DuplicateCartItemChoice {
  replace,
  addToQuantity,
  cancel,
}

class DuplicateCartItemAlert extends StatelessWidget {
  final ThemeProvider theme;
  final TempCartItem existingItem;
  final TempCartItem newItem;
  final double addedQuantityInOldUnit;
  final double finalQuantityAfterAdd;

  const DuplicateCartItemAlert({
    super.key,
    required this.theme,
    required this.existingItem,
    required this.newItem,
    required this.addedQuantityInOldUnit,
    required this.finalQuantityAfterAdd,
  });

  @override
  Widget build(BuildContext context) {
    final currency =
        returnShopProvider().userShop()?.currency ?? '';
    final existingUnitName =
        existingItem.getSelectedUnit().name;
    final newUnitName = newItem.getSelectedUnit().name;
    final isDifferentUnit =
        existingItem.unitUuid != newItem.unitUuid;

    final isMobile = screenWidth(context) < mobileScreen;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 0,
      ),
      contentPadding: const EdgeInsets.all(15),
      backgroundColor: Colors.white,
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const SizedBox(height: 5),
              SizedBox(
                height: 80,
                width: 80,
                child: FlutterClipPolygon(
                  sides: 8,
                  borderRadius: 10,
                  rotate: 0.0,
                  boxShadows: [
                    PolygonBoxShadow(
                      color: const Color.fromARGB(
                        101,
                        0,
                        0,
                        0,
                      ),
                      elevation: 1.0,
                    ),
                    PolygonBoxShadow(
                      color: const Color.fromARGB(
                        129,
                        158,
                        158,
                        158,
                      ),
                      elevation: 3.0,
                    ),
                  ],
                  child: Container(
                    color: theme.lightModeColor.prColor300,
                    child: const Center(
                      child: Icon(
                        Icons.add_shopping_cart_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 10 : 20.0,
                ),
                child: Column(
                  children: [
                    Text(
                      'Item Already in Cart',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h3.fontSize,
                        fontWeight:
                            theme
                                .mobileTexts
                                .h3
                                .fontWeightBold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${newItem.item.name} already exists in your cart. Would you like to replace the existing item or add the new quantity to it?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              // Summary comparison card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current in Cart',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatLargeNumberDouble(existingItem.quantity)} $existingUnitName',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '$currency${formatLargeNumberDouble(existingItem.totalCost())}',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Selection',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${formatLargeNumberDouble(newItem.quantity)} $newUnitName',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                ),
                              ),
                              Text(
                                '$currency${formatLargeNumberDouble(newItem.totalCost())}',
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  color:
                                      Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isDifferentUnit) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                              BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.blue.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.blue.shade800,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Adding will convert ${formatLargeNumberDouble(newItem.quantity)} $newUnitName to ${formatLargeNumberDouble(addedQuantityInOldUnit)} $existingUnitName (New Total: ${formatLargeNumberDouble(finalQuantityAfterAdd)} $existingUnitName).',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.blue.shade900,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius:
                              BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.green.shade100,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 14,
                              color: Colors.green.shade800,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Adding will make a total of ${formatLargeNumberDouble(finalQuantityAfterAdd)} $existingUnitName.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      Colors.green.shade900,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Action buttons
              if (isMobile)
                Column(
                  spacing: 8,
                  children: [
                    _buildActionButton(
                      context: context,
                      label: 'Add to Quantity',
                      backgroundColor:
                          theme.lightModeColor.prColor300,
                      textColor: Colors.white,
                      choice:
                          DuplicateCartItemChoice
                              .addToQuantity,
                    ),
                    _buildActionButton(
                      context: context,
                      label: 'Replace Item',
                      backgroundColor:
                          Colors.orange.shade700,
                      textColor: Colors.white,
                      choice:
                          DuplicateCartItemChoice.replace,
                    ),
                    _buildActionButton(
                      context: context,
                      label: 'Cancel',
                      backgroundColor: Colors.grey.shade200,
                      textColor: Colors.grey.shade800,
                      choice:
                          DuplicateCartItemChoice.cancel,
                    ),
                  ],
                )
              else
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildActionButton(
                        context: context,
                        label: 'Cancel',
                        backgroundColor:
                            Colors.grey.shade200,
                        textColor: Colors.grey.shade800,
                        choice:
                            DuplicateCartItemChoice.cancel,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildActionButton(
                        context: context,
                        label: 'Replace Item',
                        backgroundColor:
                            Colors.orange.shade700,
                        textColor: Colors.white,
                        choice:
                            DuplicateCartItemChoice.replace,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildActionButton(
                        context: context,
                        label: 'Add to Quantity',
                        backgroundColor:
                            theme.lightModeColor.prColor300,
                        textColor: Colors.white,
                        choice:
                            DuplicateCartItemChoice
                                .addToQuantity,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required DuplicateCartItemChoice choice,
  }) {
    return Ink(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: backgroundColor,
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(5),
        onTap: () {
          Navigator.of(context).pop(choice);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
