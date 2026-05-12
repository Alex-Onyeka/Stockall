import 'package:flutter/material.dart';
import 'package:stockall/classes/subplan_class.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/calculator_auth.dart';
import 'package:stockall/constants/subscription/employee_auth.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/constants/subscription/report_auth.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

class SubPaymentProvider extends ChangeNotifier {
  static final SubPaymentProvider _instance =
      SubPaymentProvider._internal();
  factory SubPaymentProvider() => _instance;
  SubPaymentProvider._internal();
  final String tableName = 'subscription_payments';

  int currentDuration = 6;

  void selectDuration(int duration) {
    var utilProvider = returnUtilityConstantProvider();
    currentDuration = duration;
    if (duration == 6) {
      discount =
          ((utilProvider
                      .utilityConstants
                      ?.sixMonthsDiscount ??
                  0) /
              100);
    } else if (duration == 12) {
      discount =
          ((utilProvider
                      .utilityConstants
                      ?.oneYearDiscount ??
                  0) /
              100);
    } else {
      discount = null;
    }
    notifyListeners();
  }

  int currencyIndex = 0;

  void selectCurrency(int index) {
    currencyIndex = index;
    notifyListeners();
  }

  String currencySymbol() {
    if (currencyIndex == 0) {
      return "₦";
    } else {
      return "\$";
    }
  }

  // int country = 0;

  // void selectCountry(int index) {
  //   country = index;
  //   notifyListeners();
  // }

  Future<void> nonNigerianSubscription({
    required int plan,
    required int duration,
  }) async {
    if (plan == 1) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/basic-plan-one-year",
        );
      }
    } else if (plan == 2) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/standard-plan-one-year",
        );
      }
    } else if (plan == 3) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/premium-plan-one-year",
        );
      }
    } else if (plan == 4) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/silver-plan-one-year",
        );
      }
    } else if (plan == 5) {
      if (duration == 1) {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-one-month",
        );
      } else if (duration == 6) {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-six-months",
        );
      } else {
        await launchUrlMain(
          "https://flutterwave.com/pay/gold-plan-one-year",
        );
      }
    }
  }

  double? discount;
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
        addSocials: true,
        customizeReceiptTemplate: true,
        allowOfflineUse: true,
        manageVAT: true,
        manageDepartments: true,
        numberOfDepartments: 5,
        useCloseSale: true,
        useFloatingButton: true,
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
        addSocials: true,
        customizeReceiptTemplate: true,
        allowOfflineUse: true,
        manageVAT: true,
        manageDepartments: false,
        numberOfDepartments: 0,
        useCloseSale: true,
        useFloatingButton: true,
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
        addSocials: true,
        customizeReceiptTemplate: true,
        allowOfflineUse: true,
        manageVAT: true,
        manageDepartments: false,
        numberOfDepartments: 0,
        useCloseSale: false,
        useFloatingButton: false,
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
        manageVAT: true,
        addSocials: true,
        customizeReceiptTemplate: false,
        allowOfflineUse: true,
        manageDepartments: false,
        numberOfDepartments: 0,
        useCloseSale: false,
        useFloatingButton: false,
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
        manageVAT: false,
        addSocials: false,
        customizeReceiptTemplate: false,
        allowOfflineUse: false,
        manageDepartments: false,
        numberOfDepartments: 0,
        useCloseSale: false,
        useFloatingButton: false,
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
}
