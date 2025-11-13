import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/classes/subplan_class.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:url_launcher/url_launcher.dart';

List<SubplanClass> subPlans = [
  SubplanClass(
    plan: 2,
    planName: 'Standard',
    itemsAuth: ItemsAuth(
      numberOfItems: 1500,
      useOfBarcode: true,
      editItems: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: true,
      generateItemBarcode: true,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: true,
      numberOfCarts: 5,
      makeDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: true,
      printReceipt: true,
      salesRecordTimeLimit: 12,
      addItemToStockAfterCustomSale: true,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: false,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 5,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 10,
      expensesRecordLimit: 12,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      addSocials: true,
      receiptTemplateCustomization: true,
      allowOfflineUse: true,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 5,
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
    ),
  ),
  SubplanClass(
    plan: 1,
    planName: 'Basic',
    itemsAuth: ItemsAuth(
      numberOfItems: 600,
      useOfBarcode: false,
      editItems: true,
      applyVariationToItems: true,
      setexpiryDate: true,
      allowStockallToManageInventory: false,
      generateItemBarcode: false,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: false,
      numberOfCarts: 2,
      makeDiscount: true,
      invoiceManagement: true,
      paymentMethodSelection: true,
      addCustomerToSell: true,
      downloadReceipt: true,
      editReceipt: false,
      printReceipt: true,
      salesRecordTimeLimit: 6,
      addItemToStockAfterCustomSale: false,
      addCustomItemToCart: true,
      addStockallNameOnReceipt: true,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: true),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: true,
      numberOfEmployees: 1,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 5,
      expensesRecordLimit: 6,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      addSocials: true,
      receiptTemplateCustomization: false,
      allowOfflineUse: true,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: true,
      numberOfStores: 2,
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
    ),
  ),
  SubplanClass(
    plan: 0,
    planName: 'Free',
    itemsAuth: ItemsAuth(
      numberOfItems: 250,
      useOfBarcode: false,
      editItems: true,
      applyVariationToItems: true,
      setexpiryDate: false,
      allowStockallToManageInventory: false,
      generateItemBarcode: false,
    ),
    salesAuth: SalesAuth(
      useOfBarcode: false,
      numberOfCarts: 1,
      makeDiscount: false,
      invoiceManagement: false,
      paymentMethodSelection: false,
      addCustomerToSell: false,
      downloadReceipt: false,
      editReceipt: false,
      printReceipt: false,
      salesRecordTimeLimit: 1,
      addItemToStockAfterCustomSale: false,
      addCustomItemToCart: false,
      addStockallNameOnReceipt: true,
    ),
    calculatorAuth: CalculatorAuth(useCalculator: false),
    customerAuth: CustomerAuth(createCustomer: true),
    employeesAuth: EmployeesAuth(
      addAndManageEmployees: false,
      numberOfEmployees: 0,
    ),
    expensesAuth: ExpensesAuth(
      numberOfDailyExpenses: 2,
      expensesRecordLimit: 1,
      deleteAndEditExpenses: true,
    ),
    generalSettingsAuth: GeneralSettingsAuth(
      addSocials: false,
      receiptTemplateCustomization: false,
      allowOfflineUse: false,
    ),
    multipleStoresAuth: MultipleStoresAuth(
      createMultipleStores: false,
      numberOfStores: 1,
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
    ),
  ),
];

class ItemsAuth {
  final int numberOfItems;
  final bool useOfBarcode;
  final bool editItems;
  final bool applyVariationToItems;
  final bool setexpiryDate;
  final bool allowStockallToManageInventory;
  final bool generateItemBarcode;

  ItemsAuth({
    required this.numberOfItems,
    required this.useOfBarcode,
    required this.editItems,
    required this.applyVariationToItems,
    required this.setexpiryDate,
    required this.allowStockallToManageInventory,
    required this.generateItemBarcode,
  });
}

class SalesAuth {
  final bool useOfBarcode;
  final int numberOfCarts;
  final bool makeDiscount;
  // final bool useOfCalculator;
  final bool invoiceManagement;
  final bool paymentMethodSelection;
  final bool addCustomerToSell;
  final bool downloadReceipt;
  final bool editReceipt;
  final bool printReceipt;
  final int salesRecordTimeLimit;
  final bool addItemToStockAfterCustomSale;
  final bool addCustomItemToCart;
  final bool addStockallNameOnReceipt;

  SalesAuth({
    required this.useOfBarcode,
    required this.numberOfCarts,
    required this.makeDiscount,
    // required this.useOfCalculator,
    required this.invoiceManagement,
    required this.paymentMethodSelection,
    required this.addCustomerToSell,
    required this.downloadReceipt,
    required this.editReceipt,
    required this.printReceipt,
    required this.salesRecordTimeLimit,
    required this.addItemToStockAfterCustomSale,
    required this.addCustomItemToCart,
    required this.addStockallNameOnReceipt,
  });
}

class CustomerAuth {
  final bool createCustomer;

  CustomerAuth({required this.createCustomer});
}

class ExpensesAuth {
  final int numberOfDailyExpenses;
  final int expensesRecordLimit;
  final bool deleteAndEditExpenses;

  ExpensesAuth({
    required this.numberOfDailyExpenses,
    required this.expensesRecordLimit,
    required this.deleteAndEditExpenses,
  });
}

class ReportAuth {
  final bool printGeneralReport;
  final bool viewSalesReport;
  final bool printSalesReport;
  final bool viewItemsGeneralReport;
  final bool viewItemsAnalysisReport;
  final bool printItemsReport;
  final bool viewCustomersReport;
  final bool printCustomersReport;
  final bool viewEmployeesReport;
  final bool printEmployeesReport;
  final bool viewExpensesReport;
  final bool printExpensesReport;

  ReportAuth({
    required this.printGeneralReport,
    required this.viewSalesReport,
    required this.printSalesReport,
    required this.viewItemsGeneralReport,
    required this.viewItemsAnalysisReport,
    required this.printItemsReport,
    required this.viewCustomersReport,
    required this.printCustomersReport,
    required this.viewEmployeesReport,
    required this.printEmployeesReport,
    required this.viewExpensesReport,
    required this.printExpensesReport,
  });
}

class EmployeesAuth {
  final bool addAndManageEmployees;
  final int numberOfEmployees;

  EmployeesAuth({
    required this.addAndManageEmployees,
    required this.numberOfEmployees,
  });
}

class CalculatorAuth {
  final bool useCalculator;

  CalculatorAuth({required this.useCalculator});
}

class GeneralSettingsAuth {
  final bool addSocials;
  final bool receiptTemplateCustomization;
  final bool allowOfflineUse;

  GeneralSettingsAuth({
    required this.addSocials,
    required this.receiptTemplateCustomization,
    required this.allowOfflineUse,
  });
}

class MultipleStoresAuth {
  final bool createMultipleStores;
  final int numberOfStores;

  MultipleStoresAuth({
    required this.createMultipleStores,
    required this.numberOfStores,
  });
}

void checkSubscriptionAction(
  BuildContext context,
  Function()? action,
) {
  // var theme = returnTheme(context, listen: false);
  var subP = returnSubcsription(context, listen: false);
  // DateTime? lastDate = subP.lastPayment();

  // DateTime? nextDate = subP.nextPayment();

  // int? remainingDays = subP.remainingDays();

  int subPlan = subP.subscription!.plan!;

  if (subPlan == 0) {
    // print('Plan is 3');
    action!();
  } else {
    action!();
    // showUnauthorizedDialog(context, theme);
  }
}

Future<dynamic> showUnauthorizedDialog(
  BuildContext context,
  ThemeProvider theme,
) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withAlpha(50),
    builder: (context) {
      return SubscribeAlertDialog();
    },
  );
}

class SubscribeAlertDialog extends StatelessWidget {
  const SubscribeAlertDialog({super.key});

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
            border: Border.all(
              color: theme.lightModeColor.secColor200,
            ),
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
                          await launchSubscriptionUrl();
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
  const SubWrapper({super.key, required this.mainWidget});

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Stack(
      alignment: AlignmentGeometry.xy(1, -1),
      children: [
        mainWidget,
        Visibility(
          visible: false,
          child: Container(
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

Future<void> launchSubscriptionUrl() async {
  final Uri url = Uri.parse(
    'https://www.stockallapp.com/#/subscription',
  );
  if (!await launchUrl(
    url,
    mode: LaunchMode.externalApplication,
  )) {
    throw Exception('Could not launch $url');
  }
}
