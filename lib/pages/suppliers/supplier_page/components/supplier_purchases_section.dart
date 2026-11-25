import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_list/purchase_list.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class SupplierPurchasesSection extends StatelessWidget {
  final String supplierUuid;
  const SupplierPurchasesSection({
    super.key,
    required this.supplierUuid,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final allTodayPurchases =
        returnPurchaseProvider(context: context)
            .returnOwnPurchasesByDayOrWeek(index: 1)
            .where(
              (item) => item.supplierId == supplierUuid,
            )
            .toList();
    final List<TempPurchase> purchases =
        allTodayPurchases.length > 5
            ? allTodayPurchases.sublist(0, 4)
            : allTodayPurchases;

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      size: 16,
                      Icons.receipt_outlined,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Today\'s Purchases'.toUpperCase(),
                  ),
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PurchaseList(
                            supplierUuid: supplierUuid,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          'View All',
                        ),
                        Icon(
                          size: 14,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Builder(
            builder: (context) {
              if (purchases.isEmpty) {
                return Center(
                  child: EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText:
                        'No Purchases Found for Today',
                    theme: theme,
                    height: 15,
                    icon: Icons.clear,
                  ),
                );
              } else {
                return Column(
                  spacing: 5,
                  children:
                      purchases
                          .map(
                            (item) => SupplierPurchasesList(
                              purchase: item,
                              theme: theme,
                            ),
                          )
                          .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class SupplierPurchasesList extends StatelessWidget {
  final TempPurchase purchase;
  const SupplierPurchasesList({
    super.key,
    required this.theme,
    required this.purchase,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          if (purchase.uuid == null) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return PurchasePage(
                  purchaseUuid: purchase.uuid!,
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 5,
          ),
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        formatMoneyBig(
                          amount: purchase.total ?? 0,
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    Flexible(
                      child: Text(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        "${formatDateTime(purchase.createdAt)} - ${formatTime(purchase.createdAt)}",
                      ),
                    ),
                    Icon(
                      size: 12,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
