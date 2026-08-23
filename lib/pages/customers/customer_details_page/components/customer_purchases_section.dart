import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerPurchasesSection extends StatelessWidget {
  final String customerUuid;
  const CustomerPurchasesSection({
    super.key,
    required this.customerUuid,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempMainReceipt> sales =
        returnReceiptProvider(context)
                    .returnOwnReceiptsByDayOrWeek()
                    .where(
                      (item) =>
                          item.customerUuid == customerUuid,
                    )
                    .length >
                5
            ? returnReceiptProvider(context)
                .returnOwnReceiptsByDayOrWeek()
                .where(
                  (item) =>
                      item.customerUuid == customerUuid,
                )
                .toList()
                .sublist(0, 4)
            : returnReceiptProvider(context)
                .returnOwnReceiptsByDayOrWeek()
                .where(
                  (item) =>
                      item.customerUuid == customerUuid,
                )
                .toList();

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
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
                          return TotalSalesPage(
                            customerUuid: customerUuid,
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
          Expanded(
            child: Builder(
              builder: (context) {
                if (sales.isEmpty) {
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
                  return SingleChildScrollView(
                    child: Column(
                      spacing: 5,
                      children:
                          sales
                              .map(
                                (item) =>
                                    CustomerPurchasesList(
                                      receipt: item,
                                      theme: theme,
                                    ),
                              )
                              .toList(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CustomerPurchasesList extends StatelessWidget {
  final TempMainReceipt receipt;
  const CustomerPurchasesList({
    super.key,
    required this.theme,
    required this.receipt,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ReceiptPage(
                  isMain: false,
                  response: CheckoutResponse(
                    resUuid: receipt.uuid!,
                    isReceipt: true,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 10,
          ),
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    formatMoneyBig(
                      amount: receipt.getTotalRevenue(),
                      context: context,
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                    formatDateTime(receipt.createdAt),
                  ),
                  Icon(
                    size: 12,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
