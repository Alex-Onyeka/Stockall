import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/subscription_page/components/comparison_row.dart';

class ComparisonSectionWidget extends StatelessWidget {
  const ComparisonSectionWidget({
    super.key,
    required this.fullComparisonSection,
  });

  final GlobalKey<State<StatefulWidget>>
  fullComparisonSection;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SizedBox(
      height:
          screenWidth(context) < mobileScreenSmall
              ? 1550
              : screenWidth(context) > mobileScreenSmall &&
                  screenWidth(context) < tabletScreen
              ? 1600
              : 1420,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          Center(
            child: Container(
              key: fullComparisonSection,
              padding: EdgeInsets.all(15),
              width:
                  screenWidth(context) <= mobileScreenSmall
                      ? 800
                      : screenWidth(context) >
                              mobileScreenSmall &&
                          screenWidth(context) <
                              tabletScreen
                      ? 1150
                      : 1350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.grey.shade100,
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Features',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Free',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Basic',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Standard',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Premium',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Silver',
                            ),
                          ),
                          Expanded(
                            flex:
                                screenWidth(context) >
                                        mobileScreenSmall
                                    ? 2
                                    : 1,
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              'Gold',
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey),
                    SizedBox(height: 15),
                    ComparisonRow(
                      title: 'Monthly Price',
                      freePlanString: formatMoneyMid(
                        context: context,
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 0,
                                )
                                .price,
                      ),
                      basicPlanString: formatMoneyMid(
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 1,
                                )
                                .price,
                        context: context,
                      ),
                      standardPlanString: formatMoneyMid(
                        context: context,
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 2,
                                )
                                .price,
                      ),

                      premiumPlanString: formatMoneyMid(
                        context: context,
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 3,
                                )
                                .price,
                      ),
                      silverPlanString: formatMoneyMid(
                        context: context,
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 4,
                                )
                                .price,
                      ),
                      goldPlanString: formatMoneyMid(
                        context: context,
                        amount:
                            subPlans
                                .firstWhere(
                                  (pl) => pl.plan == 5,
                                )
                                .price,
                      ),
                    ),
                    ComparisonRow(
                      title: 'Maximum Number of Inventory',
                      freePlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 0,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      basicPlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 1,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      standardPlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 2,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),

                      premiumPlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 3,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      silverPlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 4,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      goldPlanString: formatLargeNumber(
                        subPlans
                            .firstWhere(
                              (pl) => pl.plan == 5,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                    ),
                    ComparisonRow(
                      title:
                          'Online Data Storage Time Limit',
                      freePlanString: '1 Month',
                      basicPlanString: 'Unlimited',
                      standardPlanString: 'Unlimited',
                      premiumPlanString: 'Unlimited',
                      silverPlanString: 'Unlimited',
                      goldPlanString: 'Unlimited',
                    ),
                    ComparisonRow(
                      title: 'Generate And Print Barcode',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                    ),
                    ComparisonRow(
                      title:
                          'Apply Variations and Categories to Items',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                    ),
                    ComparisonRow(
                      title:
                          'Manage Expiring Dates for Inventories',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .itemsAuth
                              .setexpiryDate,
                    ),
                    ComparisonRow(
                      title:
                          'Get Notifications for Low quantities Items',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                    ),
                    ComparisonRow(
                      title:
                          'Use Of Barcode For Sales and Inventory',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .useOfBarcode,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .useOfBarcode,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .useOfBarcode,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .useOfBarcode,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .useOfBarcode,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .useOfBarcode,
                    ),
                    ComparisonRow(
                      title:
                          'Number of Simulatneous sales/cart processing',
                      freePlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      basicPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      standardPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      premiumPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      silverPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      goldPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                    ),
                    ComparisonRow(
                      title:
                          'Apply And Manage Sales Discounts',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .applyDiscount,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .applyDiscount,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .applyDiscount,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .applyDiscount,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .applyDiscount,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .applyDiscount,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Invoices',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .invoiceManagement,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .invoiceManagement,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .invoiceManagement,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .invoiceManagement,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .invoiceManagement,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .invoiceManagement,
                    ),
                    ComparisonRow(
                      title:
                          'Receive Payments from Multiple Channels',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                    ),
                    ComparisonRow(
                      title:
                          'Add Customer to Sales Receipt',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .addCustomerToSell,
                    ),
                    ComparisonRow(
                      title: 'Download Sales Receipt',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .downloadReceipt,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .downloadReceipt,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .downloadReceipt,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .downloadReceipt,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .downloadReceipt,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .downloadReceipt,
                    ),
                    ComparisonRow(
                      title:
                          'Manage Returns/Refunds and Sales Edit',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .editReceipt,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .editReceipt,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .editReceipt,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .editReceipt,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .editReceipt,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .editReceipt,
                    ),
                    ComparisonRow(
                      title: 'Print Receipts',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .printReceipt,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .printReceipt,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .printReceipt,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .printReceipt,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .printReceipt,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .printReceipt,
                    ),
                    ComparisonRow(
                      title:
                          'Add Item to Stock After Custom Sale',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                    ),
                    ComparisonRow(
                      title: 'Add Custom Item to Cart',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                    ),
                    ComparisonRow(
                      title:
                          'Use In-App Standard Calculator',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .calculatorAuth
                              .useCalculator,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .calculatorAuth
                              .useCalculator,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .calculatorAuth
                              .useCalculator,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .calculatorAuth
                              .useCalculator,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .calculatorAuth
                              .useCalculator,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .calculatorAuth
                              .useCalculator,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Customers',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .customerAuth
                              .createCustomer,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .customerAuth
                              .createCustomer,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .customerAuth
                              .createCustomer,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .customerAuth
                              .createCustomer,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .customerAuth
                              .createCustomer,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .customerAuth
                              .createCustomer,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Staffs',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                    ),
                    ComparisonRow(
                      title: 'Maximum Number of Staffs',
                      freePlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      basicPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      standardPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      premiumPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      silverPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      goldPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                    ),
                    ComparisonRow(
                      title:
                          'Create and Manage Manage Expenses',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                    ),
                    ComparisonRow(
                      title:
                          'Maximum Numbers of Daily Expenses',
                      freePlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      basicPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      standardPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      premiumPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      silverPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      goldPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                    ),
                    ComparisonRow(
                      title:
                          'Add Social Handles to Receipt',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .generalSettingsAuth
                              .addSocials,
                    ),
                    ComparisonRow(
                      title: 'Customize Receipt Template',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                    ),
                    ComparisonRow(
                      title: 'Use Application Offline',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                    ),
                    ComparisonRow(
                      title:
                          'Create/Manage Multiple Store/Branches',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                    ),
                    ComparisonRow(
                      title: 'Number of Stores',
                      freePlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      basicPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      standardPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      premiumPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      silverPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      goldPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                    ),
                    ComparisonRow(
                      title:
                          'View Full Business Report Information',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                    ),
                    ComparisonRow(
                      title:
                          'Print/Download Business Report Info',
                      freePlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .reportAuth
                              .printGeneralReport,
                      basicPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .reportAuth
                              .printGeneralReport,
                      standardPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .reportAuth
                              .printGeneralReport,
                      premiumPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .reportAuth
                              .printGeneralReport,
                      silverPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .reportAuth
                              .printGeneralReport,
                      goldPlanBool:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .reportAuth
                              .printGeneralReport,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
