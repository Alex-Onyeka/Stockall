import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/providers/theme_provider.dart';

class OrderItemListTileOrderPage extends StatelessWidget {
  const OrderItemListTileOrderPage({
    super.key,
    required this.theme,
    required this.record,
  });

  final ThemeProvider theme;
  final OrderItems record;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.fromLTRB(
        15.0,
        10.0,
        15.0,
        10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [
          Expanded(
            flex: 10,
            child: Column(
              spacing: 2,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  '${record.productName}${record.dimensionsLabel()}',
                ),
                Column(
                  spacing: 3,
                  children: [
                    Row(
                      spacing: 3,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b5
                                    .fontSize,
                            fontWeight: FontWeight.normal,
                          ),
                          'Original Qtty: ',
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          "${formatLargeNumberDouble(record.quantity)} ${record.getUnit()}",
                        ),
                      ],
                    ),
                    Visibility(
                      visible:
                          (record.quantity >
                              (record.remainingQuantity ??
                                  record.quantity)),
                      child: Row(
                        spacing: 3,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b5
                                      .fontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            'Remaining Qtty: ',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            "${formatLargeNumberDouble(record.remainingQuantity ?? record.quantity)} ${record.getUnit()}",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  formatMoneyBig(
                    amount: record.getTotalRevenue(),
                    context: context,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
