import 'package:flutter/material.dart';
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
              ? 1620
              : screenWidth(context) > mobileScreenSmall &&
                  screenWidth(context) < tabletScreen
              ? 1520
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
                      ? 550
                      : screenWidth(context) >
                              mobileScreenSmall &&
                          screenWidth(context) <
                              tabletScreen
                      ? 900
                      : 1300,
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
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(height: 1, color: Colors.grey),
                    SizedBox(height: 15),
                    ComparisonRow(
                      title: 'Maximum Number of Inventory',
                      freePlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 0,
                              )
                              .itemsAuth
                              .numberOfItems
                              .toString(),
                      basicPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 1,
                              )
                              .itemsAuth
                              .numberOfItems
                              .toString(),
                      standardPlanString:
                          subPlans
                              .firstWhere(
                                (pl) => pl.plan == 2,
                              )
                              .itemsAuth
                              .numberOfItems
                              .toString(),
                      premiumPlanString: 'Unlimited',
                    ),
                    ComparisonRow(
                      title:
                          'Online Data Storage Time Limit',
                      freePlanString: '1 Month',
                      basicPlanString: 'Unlimited',
                      standardPlanString: 'Unlimited',
                      premiumPlanString: 'Unlimited',
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanString: 'Unlimited',
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanString: 'Unlimited',
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
                      premiumPlanBool: true,
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
                      premiumPlanString: 'Unlimited',
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
                      premiumPlanString: 'Unlimited',
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
                      premiumPlanBool: true,
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
                      premiumPlanBool: true,
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
