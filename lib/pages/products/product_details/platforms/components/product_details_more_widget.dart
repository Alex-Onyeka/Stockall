import 'package:flutter/material.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_dashboard/productions_section/production_records_list/production_records_list.dart';
import 'package:stockall/pages/products/item_history_page/item_history_page.dart';

class ProductDetailsMoreWidget extends StatelessWidget {
  final String productUuid;

  const ProductDetailsMoreWidget({super.key, required this.productUuid});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Visibility(
      visible: authorization(authorized: Authorizations().viewItemsHistory),
      child: Builder(
        builder: (context) {
          if (returnShopProvider().userShop()?.manageProductionItems != true &&
              returnShopProvider().userShop()?.manageProductions == true) {
            return PopupMenuButton(
              offset: Offset(-20, 30),
              color: Colors.white,
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProductionRecordsList(
                              productUuid: productUuid,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 15),
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(size: 16, Icons.view_in_ar_rounded),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: theme.mobileTexts.b3.fontSize,
                            ),
                            'View Productions',
                          ),
                        ],
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ItemHistoryPage(
                              productUuid: productUuid,
                              fromItemDetails: true,
                            );
                          },
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 15),
                      child: Row(
                        spacing: 10,
                        children: [
                          Icon(size: 16, Icons.receipt_long_rounded),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: theme.mobileTexts.b3.fontSize,
                            ),
                            'View History',
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.more_vert_rounded),
              ),
            );
          } else {
            return InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return ItemHistoryPage(
                        productUuid: productUuid,
                        fromItemDetails: true,
                      );
                    },
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(right: 5),
                padding: EdgeInsets.only(
                  right: 15,
                  left: 15,
                  top: 5,
                  bottom: 5,
                ),
                decoration: BoxDecoration(),
                child: Row(
                  spacing: 3,
                  children: [
                    Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: theme.mobileTexts.b3.fontSize,
                      ),
                      'View History',
                    ),
                    Icon(size: 16, Icons.receipt_long_rounded),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
