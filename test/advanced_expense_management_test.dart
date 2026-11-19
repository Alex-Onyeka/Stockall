import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'purchase_report_fixtures.dart';

void main() {
  group('TempExpensesClass & ExpenseType', () {
    test('historical JSON without new columns defaults to simple_expense and Cash', () {
      final exp = TempExpensesClass.fromJson({
        'id': 42,
        'created_date': '2026-01-10T10:00:00Z',
        'shop_id': 7,
        'name': 'Stationery',
        'description': 'Pens and paper',
        'amount': 2500,
        'user_id': 'u-1',
        'creator': 'Alex',
        'department_uuid': null,
        'department_name': null,
        'uuid': 'exp-hist-1',
      });

      expect(exp.expenseType, ExpenseType.simpleExpense);
      expect(exp.isSimpleExpense, isTrue);
      expect(exp.categoryLabel, 'Simple Expenses');
      expect(exp.resolvedPaymentChannelLabel, PaymentMethods.cash);
    });

    test('staff salary expense serializes staffUuid, staffName, and paymentChannel', () {
      final exp = TempExpensesClass(
        uuid: 'exp-sal-1',
        shopId: 7,
        name: 'Salary - Ada',
        amount: 150000,
        creator: 'Owner',
        userId: 'owner-1',
        departmentName: null,
        departmentUuid: null,
        createdDate: DateTime(2026, 11, 1),
        expenseType: ExpenseType.staffSalary,
        staffUuid: 'staff-ada-1',
        staffName: 'Ada Obi',
        paymentChannel: 'GTBank (1234)',
        paymentEntries: [
          PaymentEntry(method: 'GTBank (1234)', amount: 150000),
        ],
      );

      final json = exp.toJson();
      final decoded = TempExpensesClass.fromJson(json);

      expect(decoded.isStaffSalary, isTrue);
      expect(decoded.categoryLabel, 'Staff Salary');
      expect(decoded.staffUuid, 'staff-ada-1');
      expect(decoded.staffName, 'Ada Obi');
      expect(decoded.resolvedPaymentChannelLabel, 'GTBank (1234)');
      expect(decoded.paymentEntries?.length, 1);
    });

    test('stock purchase expense preserves split payment entries', () {
      final exp = TempExpensesClass(
        uuid: 'exp-pur-1',
        shopId: 7,
        name: 'Stock Purchase (Acme)',
        amount: 80000,
        creator: 'Owner',
        userId: 'owner-1',
        departmentName: null,
        departmentUuid: null,
        createdDate: DateTime(2026, 11, 5),
        expenseType: ExpenseType.stockPurchase,
        purchaseUuid: 'pur-123',
        paymentChannel: PaymentMethods.split,
        paymentEntries: [
          PaymentEntry(method: PaymentMethods.cash, amount: 30000),
          PaymentEntry(method: 'Zenith Bank', amount: 50000),
        ],
      );

      final decoded = TempExpensesClass.fromJson(exp.toJson());
      expect(decoded.isStockPurchase, isTrue);
      expect(decoded.categoryLabel, 'Stock Purchase');
      expect(decoded.purchaseUuid, 'pur-123');
      expect(decoded.resolvedPaymentChannelLabel, PaymentMethods.split);
      expect(decoded.paymentEntries?.length, 2);
    });

    test('custom category expense keeps category label even when categoryUuid is nullified', () {
      final exp = TempExpensesClass(
        uuid: 'exp-cust-1',
        shopId: 7,
        name: 'PHCN Bill',
        amount: 12000,
        creator: 'Owner',
        userId: 'owner-1',
        departmentName: null,
        departmentUuid: null,
        expenseType: ExpenseType.custom,
        expenseCategoryUuid: null,
        expenseCategoryName: 'Electricity',
      );

      expect(exp.isCustomCategory, isTrue);
      expect(exp.categoryLabel, 'Electricity');
    });
  });

  group('ExpenseCategory', () {
    test('round-trips JSON cleanly', () {
      final cat = ExpenseCategory(
        uuid: 'cat-1',
        shopId: 7,
        name: 'Electricity',
        createdAt: DateTime.utc(2026, 11, 1),
        updatedAt: DateTime.utc(2026, 11, 2),
      );

      final decoded = ExpenseCategory.fromJson(cat.toJson());
      expect(decoded.uuid, 'cat-1');
      expect(decoded.shopId, 7);
      expect(decoded.name, 'Electricity');
    });
  });

  group('GeneralReportFigures expense aggregation', () {
    test('sums simple, salary and custom expenses; a stock purchase counts only under purchases', () {
      final day = DateTime(2026, 11, 10, 12, 0);
      final period = ReceiptsReportPeriod.day(DateTime(2026, 11, 10));
      final expenses = [
        TempExpensesClass(
          uuid: 'e1',
          shopId: 1,
          name: 'Tape',
          amount: 1000,
          creator: 'U',
          userId: 'u1',
          departmentName: null,
          departmentUuid: null,
          createdDate: day,
          expenseType: ExpenseType.simpleExpense,
        ),
        TempExpensesClass(
          uuid: 'e2',
          shopId: 1,
          name: 'Salary - Ada',
          amount: 50000,
          creator: 'U',
          userId: 'u1',
          departmentName: null,
          departmentUuid: null,
          createdDate: day,
          expenseType: ExpenseType.staffSalary,
          staffUuid: 's1',
        ),
        TempExpensesClass(
          uuid: 'e3',
          shopId: 1,
          name: 'Rent',
          amount: 20000,
          creator: 'U',
          userId: 'u1',
          departmentName: null,
          departmentUuid: null,
          createdDate: day,
          expenseType: ExpenseType.custom,
          expenseCategoryUuid: 'c1',
          expenseCategoryName: 'Rent',
        ),
        TempExpensesClass(
          uuid: 'e4',
          shopId: 1,
          name: 'Stock Purchase',
          amount: 30000,
          creator: 'U',
          userId: 'u1',
          departmentName: null,
          departmentUuid: null,
          createdDate: day,
          expenseType: ExpenseType.stockPurchase,
          purchaseUuid: 'p-000000000001',
        ),
      ];
      // The purchase that stock purchase expense e4 was paid for.
      final purchaseRows = [
        row(
          purchase(
            uuid: 'p-000000000001',
            createdAt: day,
            total: 30000,
            payments: [payment(30000)],
          ),
        ),
      ];

      final figures = GeneralReportFigures.build(
        receiptRows: const [],
        purchaseRows: purchaseRows,
        expenses: expenses,
        period: period,
        profitVisible: true,
      );

      expect(figures.totalPurchases, 30000);
      expect(figures.purchaseCount, 1);
      expect(figures.totalExpenses, 71000);
      expect(figures.expenseCount, 3);
      expect(figures.netProfit, -71000);
    });
  });
}
