import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/classes/subplan_class.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/calculator_auth.dart';
import 'package:stockall/constants/subscription/employee_auth.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/subscription_page/subscription_page.dart';

List<SubplanClass> subPlans = [
  SubplanClass(
    plan: 5,
    price:
        returnUtilityConstantProvider()
            .utilityConstants!
            .goldPlan,
    onlineDataBackupDuration: 12,
    planName: 'Gold',
    planDesc: 'For Running High End Business',
    itemsAuth: ItemsAuth(
      numberOfItems: 20000,
      useOfBarcode: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: true,
      generateItemBarcode: true,
      useGroupUnit: true,
      manageInventoryStorage: true,
      setWholeSale: true,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: true,
      numberOfCarts: 20,
      applyDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: true,
      printReceipt: true,
      addItemToStockAfterCustomSale: true,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
      bulkSale: true,
      numberOfMainCarts: 15,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 15,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 50,
      // expensesRecordLimit: 12,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      addSocials: true,
      customizeReceiptTemplate: true,
      allowOfflineUse: true,
      manageVAT: true,
      manageDepartments: true,
      numberOfDepartments: 10,
      useCloseSale: true,
      useFloatingButton: true,
      useOnScreenKeyboard: true,
      trackCart: true,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 10,
      manageShopDashboard: true,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: true,
      viewSalesReport: true,
      printSalesReport: true,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: true,
      printItemsReport: true,
      viewCustomersReport: true,
      printCustomersReport: true,
      viewEmployeesReport: true,
      printEmployeesReport: true,
      viewExpensesReport: true,
      printExpensesReport: true,
      viewEventLogs: true,
    ),
  ),
  SubplanClass(
    plan: 4,
    price:
        returnUtilityConstantProvider()
            .utilityConstants
            ?.silverPlan ??
        13000,
    onlineDataBackupDuration: 12,
    planName: 'Silver',
    planDesc: 'For Running Large Business',
    itemsAuth: ItemsAuth(
      numberOfItems: 10000,
      useOfBarcode: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: true,
      generateItemBarcode: true,
      manageInventoryStorage: true,
      useGroupUnit: true,
      setWholeSale: true,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: true,
      numberOfCarts: 15,
      applyDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: true,
      printReceipt: true,
      addItemToStockAfterCustomSale: true,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
      bulkSale: true,
      numberOfMainCarts: 15,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 10,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 30,
      // expensesRecordLimit: 12,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      trackCart: true,
      addSocials: true,
      customizeReceiptTemplate: true,
      allowOfflineUse: true,
      manageVAT: true,
      manageDepartments: true,
      numberOfDepartments: 5,
      useCloseSale: true,
      useFloatingButton: true,
      useOnScreenKeyboard: true,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 7,
      manageShopDashboard: true,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: true,
      viewSalesReport: true,
      printSalesReport: true,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: true,
      printItemsReport: true,
      viewCustomersReport: true,
      printCustomersReport: true,
      viewEmployeesReport: true,
      printEmployeesReport: true,
      viewExpensesReport: true,
      printExpensesReport: true,
      viewEventLogs: true,
    ),
  ),
  SubplanClass(
    plan: 3,
    price:
        returnUtilityConstantProvider()
            .utilityConstants
            ?.premiumPlan ??
        6000,
    onlineDataBackupDuration: 12,
    planName: 'Premium',
    planDesc: 'For Running Moderately Large Business',
    itemsAuth: ItemsAuth(
      numberOfItems: 6000,
      useOfBarcode: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: true,
      generateItemBarcode: true,
      manageInventoryStorage: true,
      useGroupUnit: true,
      setWholeSale: true,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: true,
      numberOfCarts: 5,
      applyDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: true,
      printReceipt: true,
      // salesRecordTimeLimit: 12,
      addItemToStockAfterCustomSale: true,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
      bulkSale: true,
      numberOfMainCarts: 5,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 4,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 15,
      // expensesRecordLimit: 12,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      trackCart: true,
      addSocials: true,
      customizeReceiptTemplate: true,
      allowOfflineUse: true,
      manageVAT: true,
      manageDepartments: false,
      numberOfDepartments: 0,
      useCloseSale: true,
      useFloatingButton: true,
      useOnScreenKeyboard: true,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 3,
      manageShopDashboard: false,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: true,
      viewSalesReport: true,
      printSalesReport: true,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: true,
      printItemsReport: true,
      viewCustomersReport: true,
      printCustomersReport: true,
      viewEmployeesReport: true,
      printEmployeesReport: true,
      viewExpensesReport: true,
      printExpensesReport: true,
      viewEventLogs: true,
    ),
  ),
  SubplanClass(
    plan: 2,
    price:
        returnUtilityConstantProvider()
            .utilityConstants
            ?.standardPlan ??
        4000,
    onlineDataBackupDuration: 12,
    planName: 'Standard',
    planDesc: 'Perfect for Running Moderate Business',
    itemsAuth: ItemsAuth(
      numberOfItems: 3000,
      useOfBarcode: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: true,
      generateItemBarcode: false,
      manageInventoryStorage: false,
      useGroupUnit: true,
      setWholeSale: true,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: true,
      numberOfCarts: 2,
      applyDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: true,
      printReceipt: true,
      // salesRecordTimeLimit: 12,
      addItemToStockAfterCustomSale: true,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
      bulkSale: true,
      numberOfMainCarts: 1,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 1,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 10,
      // expensesRecordLimit: 12,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      trackCart: false,
      addSocials: true,
      customizeReceiptTemplate: true,
      allowOfflineUse: true,
      manageVAT: true,
      manageDepartments: false,
      numberOfDepartments: 0,
      useCloseSale: false,
      useFloatingButton: false,
      useOnScreenKeyboard: false,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 1,
      manageShopDashboard: false,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: true,
      viewSalesReport: true,
      printSalesReport: true,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: true,
      printItemsReport: true,
      viewCustomersReport: true,
      printCustomersReport: true,
      viewEmployeesReport: true,
      printEmployeesReport: true,
      viewExpensesReport: true,
      printExpensesReport: true,
      viewEventLogs: true,
    ),
  ),
  SubplanClass(
    plan: 1,
    price:
        returnUtilityConstantProvider()
            .utilityConstants
            ?.basicPlan ??
        2500,
    onlineDataBackupDuration: 12,
    planName: 'Basic',
    planDesc: 'Perfect for Running Small Business',
    itemsAuth: ItemsAuth(
      numberOfItems: 1000,
      useOfBarcode: false,
      applyVariationToItems: true,
      setexpiryDate: false,
      allowStockallToManageInventory: false,
      generateItemBarcode: false,
      manageInventoryStorage: false,
      useGroupUnit: false,
      setWholeSale: false,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: false,
      numberOfCarts: 1,
      applyDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: false,
      printReceipt: true,
      // salesRecordTimeLimit: 6,
      addItemToStockAfterCustomSale: false,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
      bulkSale: false,
      numberOfMainCarts: 1,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 0,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 5,
      // expensesRecordLimit: 6,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      trackCart: false,
      manageVAT: true,
      addSocials: true,
      customizeReceiptTemplate: false,
      allowOfflineUse: true,
      manageDepartments: false,
      numberOfDepartments: 0,
      useCloseSale: false,
      useFloatingButton: false,
      useOnScreenKeyboard: false,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 1,
      manageShopDashboard: false,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: true,
      viewSalesReport: true,
      printSalesReport: false,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: false,
      printItemsReport: false,
      viewCustomersReport: true,
      printCustomersReport: false,
      viewEmployeesReport: true,
      printEmployeesReport: false,
      viewExpensesReport: true,
      printExpensesReport: false,
      viewEventLogs: false,
    ),
  ),
  SubplanClass(
    plan: 0,
    price: 0,
    planName: 'Free',
    onlineDataBackupDuration: 1,
    planDesc: 'Perfect for Testing Out',
    itemsAuth: ItemsAuth(
      numberOfItems: 300,
      manageInventoryStorage: false,
      useOfBarcode: false,
      applyVariationToItems: false,
      setexpiryDate: false,
      allowStockallToManageInventory: false,
      generateItemBarcode: false,
      useGroupUnit: false,
      setWholeSale: false,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: false,
      numberOfCarts: 1,
      applyDiscount: false,
      invoiceManagement: false,
      paymentMethodSelection: false,
      addCustomerToSell: false,
      downloadReceipt: false,
      editReceipt: false,
      printReceipt: false,
      // salesRecordTimeLimit: 1,
      addItemToStockAfterCustomSale: false,
      addCustomItemToCart: false,
      addStockallNameOnReceipt: true,
      bulkSale: false,
      numberOfMainCarts: 1,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: false),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: false,
      numberOfEmployees: 0,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 2,
      // expensesRecordLimit: 1,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      trackCart: false,
      manageVAT: false,
      addSocials: false,
      customizeReceiptTemplate: false,
      allowOfflineUse: false,
      manageDepartments: false,
      numberOfDepartments: 0,
      useCloseSale: false,
      useFloatingButton: false,
      useOnScreenKeyboard: false,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: false,
      numberOfStores: 1,
      manageShopDashboard: false,
    ),
    reportAuth: ReportAuth(
      printGeneralReport: false,
      viewSalesReport: true,
      printSalesReport: false,
      viewItemsGeneralReport: true,
      viewItemsAnalysisReport: false,
      printItemsReport: false,
      viewCustomersReport: true,
      printCustomersReport: false,
      viewEmployeesReport: true,
      printEmployeesReport: false,
      viewExpensesReport: true,
      printExpensesReport: false,
      viewEventLogs: false,
    ),
  ),
];

class CustomerAuth {
  final bool createCustomer;

  CustomerAuth({required this.createCustomer});
}

void showUnauthorizedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(50),
    builder: (context) {
      return SubscribeAlertDialog();
    },
  );
}

class SubscribeAlertDialog extends StatelessWidget {
  final String? message;
  const SubscribeAlertDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return AlertDialog(
      elevation: 0,
      shadowColor: Colors.transparent,
      contentPadding: EdgeInsets.all(0),
      insetPadding: EdgeInsets.all(15),
      backgroundColor: Colors.transparent,
      shape: BoxBorder.all(
        color: Colors.transparent,
        width: 0,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Container(
          // height: 300,
          width: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(
            //   color: theme.lightModeColor.secColor200,
            // ),
            color: Colors.white,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(size: 26, Icons.clear),
                    ),
                  ],
                ),
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  spacing: 5,
                  children: [
                    LottieBuilder.asset(
                      fit: BoxFit.contain,
                      height: 130,
                      premium,
                      repeat: false,
                    ),
                    Text(
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      'Premium Only Feature',
                    ),
                    Flexible(
                      child: Text(
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        message ??
                            'This feature is beyond your current plan. You have to upgrade your plan to be able to access this Feature.',
                      ),
                    ),
                    SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 400,
                      ),
                      child: MainButtonP(
                        themeProvider: theme,
                        action: () async {
                          // await launchUrlMain(
                          //   'https://www.stockallapp.com/#/subscription',
                          // );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return SubscriptionPage();
                              },
                            ),
                          );
                        },
                        text: 'Upgrade Subscription Plan',
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SubWrapper extends StatelessWidget {
  final Widget mainWidget;
  final bool isVisible;
  final double? y;
  final double? x;
  const SubWrapper({
    super.key,
    required this.mainWidget,
    required this.isVisible,
    this.y,
    this.x,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      alignment: AlignmentGeometry.xy(x ?? 1, y ?? -1),
      children: [
        Opacity(
          opacity: isVisible ? 0.9 : 1,
          child: mainWidget,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(
                  33,
                  255,
                  193,
                  7,
                ),
                blurRadius: 10,
                offset: Offset(-06, 0.6),
                spreadRadius: 3,
              ),
            ],
          ),
          child: Visibility(
            visible: isVisible,
            child: Icon(
              size: 18,
              color: theme.lightModeColor.secColor200,
              Icons.star_purple500_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
