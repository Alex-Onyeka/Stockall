import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

TempExpensesClass expense({
  String uuid = 'e1',
  double amount = 100,
  String expenseType = ExpenseType.simpleExpense,
  String? categoryUuid,
  String? categoryName,
  DateTime? createdDate,
  String userId = 'u1',
}) {
  return TempExpensesClass(
    uuid: uuid,
    shopId: 1,
    name: 'Expense $uuid',
    amount: amount,
    creator: 'U',
    userId: userId,
    departmentName: null,
    departmentUuid: null,
    createdDate: createdDate ?? DateTime(2026, 11, 10, 12),
    expenseType: expenseType,
    expenseCategoryUuid: categoryUuid,
    expenseCategoryName: categoryName,
  );
}

ExpenseCategory category(String uuid, String name) =>
    ExpenseCategory(uuid: uuid, shopId: 1, name: name);

void main() {
  group('live category label', () {
    test('a custom category shows its current name after a rename', () {
      final exp = expense(
        expenseType: ExpenseType.custom,
        categoryUuid: 'c1',
        categoryName: 'Utility',
      );
      expect(
        exp.categoryLabelWith([category('c1', 'Utilities')]),
        'Utilities',
      );
    });

    test('falls back to the saved name when the category is not loaded', () {
      final exp = expense(
        expenseType: ExpenseType.custom,
        categoryUuid: 'c1',
        categoryName: 'Utility',
      );
      expect(exp.categoryLabelWith(const []), 'Utility');
      expect(
        exp.categoryLabelWith([category('other', 'Logistics')]),
        'Utility',
      );
    });

    test('falls back to the saved name when the category was deleted', () {
      // Deleting a category clears the uuid and keeps the name.
      final exp = expense(
        expenseType: ExpenseType.custom,
        categoryUuid: null,
        categoryName: 'Utility',
      );
      expect(
        exp.categoryLabelWith([category('c1', 'Utilities')]),
        'Utility',
      );
    });

    test('system categories keep their labels', () {
      final categories = [category('c1', 'Utilities')];
      expect(
        expense().categoryLabelWith(categories),
        'Simple Expenses',
      );
      expect(
        expense(
          expenseType: ExpenseType.staffSalary,
        ).categoryLabelWith(categories),
        'Staff Salary',
      );
      expect(
        expense(
          expenseType: ExpenseType.stockPurchase,
        ).categoryLabelWith(categories),
        'Stock Purchase',
      );
    });
  });

  group('reserved category names', () {
    test('system names are rejected in any case, trimmed', () {
      for (final name in [
        'Simple Expense',
        'Simple Expenses',
        '  simple expenses  ',
        'SIMPLE EXPENSE',
        'Staff Salary',
        'staff salary',
        'Stock Purchase',
        ' STOCK PURCHASE ',
      ]) {
        expect(ExpenseType.isReservedName(name), isTrue, reason: name);
      }
    });

    test('other names are allowed', () {
      for (final name in [
        'Utility',
        'Logistics',
        'Simple',
        'Staff Salaries Bonus',
        'Stock Purchases 2',
      ]) {
        expect(ExpenseType.isReservedName(name), isFalse, reason: name);
      }
    });
  });

  group('stock purchase expenses are left out of expense totals', () {
    final period = ReceiptsReportPeriod.day(DateTime(2026, 11, 10));
    final expenses = [
      expense(uuid: 'simple', amount: 1000),
      expense(
        uuid: 'salary',
        amount: 5000,
        expenseType: ExpenseType.staffSalary,
      ),
      expense(
        uuid: 'custom',
        amount: 2000,
        expenseType: ExpenseType.custom,
        categoryUuid: 'c1',
        categoryName: 'Rent',
      ),
      expense(
        uuid: 'stock',
        amount: 3000,
        expenseType: ExpenseType.stockPurchase,
      ),
    ];

    test('general report: inPeriod and total skip stock purchases', () {
      final inPeriod = GeneralReportExpenses.inPeriod(expenses, period);
      expect(
        inPeriod.map((e) => e.uuid),
        unorderedEquals(['simple', 'salary', 'custom']),
      );
      expect(GeneralReportExpenses.total(inPeriod), 8000);
      // total skips them even when handed the full list.
      expect(GeneralReportExpenses.total(expenses), 8000);
    });

    test('general report: net profit is not lowered by stock purchases', () {
      final figures = GeneralReportFigures.build(
        receiptRows: const [],
        purchaseRows: const [],
        expenses: expenses,
        period: period,
        profitVisible: true,
      );
      expect(figures.totalExpenses, 8000);
      expect(figures.expenseCount, 3);
      expect(figures.netProfit, -8000);
    });

    test('staff report: scopeExpenses skips stock purchases', () {
      const access = StaffReportAccess(
        departmentsEnabled: false,
        canViewAllDepartments: true,
        currentDepartmentUuid: null,
        canViewAllTransactions: true,
        currentUserId: 'u1',
        showOrders: true,
        showPurchases: true,
        showExpenses: true,
        canPickDate: true,
      );
      expect(
        access.scopeExpenses(expenses).map((e) => e.uuid),
        unorderedEquals(['simple', 'salary', 'custom']),
      );
    });
  });
}
