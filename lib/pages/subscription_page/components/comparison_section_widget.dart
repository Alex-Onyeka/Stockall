import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
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
    double calcPrice(double price) {
      if (returnSubPaymentProvider(
            context: context,
          ).currencyIndex ==
          0) {
        return price;
      } else {
        return price /
            (returnUtilityConstantProvider()
                    .utilityConstants
                    ?.dollarRate ??
                0);
      }
    }

    var theme = returnTheme(context);
    return SizedBox(
      height:
          screenWidth(context) < mobileScreenSmall
              ? 1500
              : screenWidth(context) > mobileScreenSmall &&
                  screenWidth(context) < tabletScreen
              ? 1650
              : 1480,
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
                      freePlanString: formatMoneyAlt(
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                        amount: calcPrice(
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .price,
                        ),
                      ),
                      basicPlanString: formatMoneyAlt(
                        amount: calcPrice(
                          returnSubPaymentProvider(
                                context: context,
                              ).subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .price,
                        ),
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                      ),
                      standardPlanString: formatMoneyAlt(
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                        amount: calcPrice(
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .price,
                        ),
                      ),

                      premiumPlanString: formatMoneyAlt(
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                        amount: calcPrice(
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .price,
                        ),
                      ),
                      silverPlanString: formatMoneyAlt(
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                        amount: calcPrice(
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .price,
                        ),
                      ),
                      goldPlanString: formatMoneyAlt(
                        currency:
                            returnSubPaymentProvider(
                              context: context,
                            ).currencySymbol(),
                        amount: calcPrice(
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .price,
                        ),
                      ),
                    ),
                    ComparisonRow(
                      title: 'Maximum Number of Inventory',
                      freePlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
                            .firstWhere(
                              (pl) => pl.plan == 0,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      basicPlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
                            .firstWhere(
                              (pl) => pl.plan == 1,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      standardPlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
                            .firstWhere(
                              (pl) => pl.plan == 2,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),

                      premiumPlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
                            .firstWhere(
                              (pl) => pl.plan == 3,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      silverPlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
                            .firstWhere(
                              (pl) => pl.plan == 4,
                            )
                            .itemsAuth
                            .numberOfItems
                            .toString(),
                      ),
                      goldPlanString: formatLargeNumber(
                        returnSubPaymentProvider().subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .generateItemBarcode,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .applyVariationToItems,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .setexpiryDate,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .itemsAuth
                              .allowStockallToManageInventory,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .useOfBarcode,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .useOfBarcode,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .useOfBarcode,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .useOfBarcode,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .useOfBarcode,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      basicPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      standardPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      premiumPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      silverPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .numberOfCarts
                              .toString(),
                      goldPlanString:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .applyDiscount,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .applyDiscount,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .applyDiscount,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .applyDiscount,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .applyDiscount,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .applyDiscount,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Invoices',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .invoiceManagement,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .invoiceManagement,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .invoiceManagement,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .invoiceManagement,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .invoiceManagement,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .paymentMethodSelection,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addCustomerToSell,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .addCustomerToSell,
                    ),
                    ComparisonRow(
                      title: 'Download Sales Receipt',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .downloadReceipt,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .downloadReceipt,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .downloadReceipt,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .downloadReceipt,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .downloadReceipt,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .editReceipt,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .editReceipt,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .editReceipt,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .editReceipt,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .editReceipt,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .editReceipt,
                    ),
                    ComparisonRow(
                      title: 'Print Receipts',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .printReceipt,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .printReceipt,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .printReceipt,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .printReceipt,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .printReceipt,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .salesAuth
                              .addItemToStockAfterCustomSale,
                    ),
                    ComparisonRow(
                      title: 'Add Custom Item to Cart',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .salesAuth
                              .addCustomItemToCart,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .calculatorAuth
                              .useCalculator,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .calculatorAuth
                              .useCalculator,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .calculatorAuth
                              .useCalculator,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .calculatorAuth
                              .useCalculator,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .calculatorAuth
                              .useCalculator,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .calculatorAuth
                              .useCalculator,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Customers',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .customerAuth
                              .createCustomer,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .customerAuth
                              .createCustomer,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .customerAuth
                              .createCustomer,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .customerAuth
                              .createCustomer,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .customerAuth
                              .createCustomer,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .customerAuth
                              .createCustomer,
                    ),
                    ComparisonRow(
                      title: 'Create and Manage Staffs',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .employeesAuth
                              .addAndManageEmployees,
                    ),
                    ComparisonRow(
                      title: 'Maximum Number of Staffs',
                      freePlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      basicPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      standardPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      premiumPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      silverPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .employeesAuth
                              .numberOfEmployees
                              .toString(),
                      goldPlanString:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .expensesAuth
                              .deleteAndEditExpenses,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      basicPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      standardPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      premiumPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      silverPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .expensesAuth
                              .numberOfDailyExpenses
                              .toString(),
                      goldPlanString:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .addSocials,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .generalSettingsAuth
                              .addSocials,
                    ),
                    ComparisonRow(
                      title: 'Customize Receipt Template',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .generalSettingsAuth
                              .customizeReceiptTemplate,
                    ),
                    ComparisonRow(
                      title: 'Use Application Offline',
                      freePlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .generalSettingsAuth
                              .allowOfflineUse,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 5,
                              )
                              .multipleStoresAuth
                              .createMultipleStores,
                    ),
                    ComparisonRow(
                      title: 'Number of Stores',
                      freePlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      basicPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      standardPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      premiumPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      silverPlanString:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .multipleStoresAuth
                              .numberOfStores
                              .toString(),
                      goldPlanString:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .reportAuth
                              .viewItemsGeneralReport,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .reportAuth
                              .printGeneralReport,
                      basicPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .reportAuth
                              .printGeneralReport,
                      standardPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .reportAuth
                              .printGeneralReport,
                      premiumPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 3,
                              )
                              .reportAuth
                              .printGeneralReport,
                      silverPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
                              .firstWhere(
                                (pl) => pl.plan == 4,
                              )
                              .reportAuth
                              .printGeneralReport,
                      goldPlanBool:
                          returnSubPaymentProvider()
                              .subPlans
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
