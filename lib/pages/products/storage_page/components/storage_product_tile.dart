import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/storage_details_page.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Card-style tile for a storage item, styled after [ProductTileMain]
/// while displaying In Storage, In Sales, and Overall Total quantities.
class StorageProductTile extends StatelessWidget {
  const StorageProductTile({
    super.key,
    required this.theme,
    required this.product,
  });

  final ThemeProvider theme;
  final TempStorageProducts product;

  double _getTotalInStorage() {
    return product.getProductUnit().getQuantityEquivDivided(
      index: 4,
    );
  }

  double _getTotalInSales() {
    final List<TempProductClass> items =
        returnData().productListMain
            .where((item) => item.storageUuid == product.uuid)
            .toList();

    final double totalSalesActual = items
        .map((item) => item.getActualQuantity() ?? 0)
        .fold(0.0, (a, b) => a + b);

    return product.getProductUnit().getQuantityEquivDivided(
      index: 4,
      newQuantity: totalSalesActual,
    );
  }

  void _openDetails(BuildContext context) {
    if (screenWidth(context) > mobileScreen) {
      returnData().unFocusSearchNode();
      returnData().removeSearchNodeListener();
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return StorageDetailsPage(
            productUuid: product.uuid!,
          );
        },
      ),
    ).then((_) {
      if (context.mounted &&
          screenWidth(context) > mobileScreen) {
        returnData().requestFocusSearchNode();
        returnData().addSearchNodeListener();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unitName = product.getProductUnit().name;
    final inStorage = _getTotalInStorage();
    final inSales = _getTotalInSales();
    final overallTotal = inStorage + inSales;
    final canViewQty = authorization(
      authorized: Authorizations().viewItemQuantity,
    );
    final isOutOfStock = inStorage <= 0;

    final subtitleParts = <String>[
      if (product.hasDimensions &&
          product.widthDimension != null &&
          product.heightDimension != null)
        '${formatLargeNumberDouble(product.widthDimension!)} × ${formatLargeNumberDouble(product.heightDimension!)} ${product.dimensionUnit ?? ''}'
            .trim(),
      if (product.desc != null &&
          product.desc!.trim().isNotEmpty)
        product.desc!.trim(),
    ];

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Color.fromARGB(24, 158, 158, 158),
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
            onTap: () => _openDetails(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.grey.shade200,
                    ),
                    child: const Icon(
                      Icons.warehouse_outlined,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  if (subtitleParts
                                      .isNotEmpty)
                                    Text(
                                      subtitleParts.join(
                                        '  |  ',
                                      ),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            theme
                                                .lightModeColor
                                                .secColor200,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Icon(
                              size: 18,
                              color: Colors.grey.shade400,
                              Icons
                                  .arrow_forward_ios_rounded,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Wrap(
                                spacing: 10,
                                runSpacing: 2,
                                crossAxisAlignment:
                                    WrapCrossAlignment
                                        .center,
                                children: [
                                  if (product
                                          .sellingPrice !=
                                      null)
                                    Text(
                                      formatMoneyMid(
                                        amount:
                                            product
                                                .sellingPrice!,
                                        context: context,
                                      ),
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
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
                                    canViewQty
                                        ? 'In Sales: ${formatLargeNumberDouble(inSales)} $unitName'
                                        : 'In Sales: ****',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.w600,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                  ),
                                  Text(
                                    canViewQty
                                        ? 'Total: ${formatLargeNumberDouble(overallTotal)} $unitName'
                                        : 'Total: ****',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          theme
                                              .lightModeColor
                                              .secColor200,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    !canViewQty
                                        ? Colors
                                            .grey
                                            .shade100
                                        : isOutOfStock
                                        ? const Color.fromARGB(
                                          255,
                                          255,
                                          232,
                                          231,
                                        )
                                        : Colors
                                            .grey
                                            .shade100,
                                border: Border.all(
                                  color:
                                      !canViewQty
                                          ? Colors
                                              .grey
                                              .shade700
                                          : isOutOfStock
                                          ? const Color.fromARGB(
                                            255,
                                            255,
                                            142,
                                            134,
                                          )
                                          : Colors
                                              .grey
                                              .shade700,
                                ),
                                borderRadius:
                                    BorderRadius.circular(
                                      20,
                                    ),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                      vertical: 3,
                                    ),
                                child: Text(
                                  !canViewQty
                                      ? '****'
                                      : isOutOfStock
                                      ? 'Stock Out'
                                      : 'In Storage: ${formatLargeNumberDouble(inStorage)} $unitName',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        !canViewQty
                                            ? Colors
                                                .grey
                                                .shade700
                                            : isOutOfStock
                                            ? const Color.fromARGB(
                                              255,
                                              255,
                                              142,
                                              134,
                                            )
                                            : Colors
                                                .grey
                                                .shade700,
                                  ),
                                ),
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
          ),
        ),
      ),
    );
  }
}
