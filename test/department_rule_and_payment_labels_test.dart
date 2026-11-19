import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/payment_entry/payment_method.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/components/report_department_scope.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/providers/department_provider.dart';

import 'customer_report_fixtures.dart' show testReceipt;
import 'purchase_report_fixtures.dart' show purchase;
import 'supplier_report_fixtures.dart' show supplier;

bool visible({
  bool manageDepartments = true,
  bool canViewAll = false,
  bool isUnassignedUser = false,
  String? currentDeptUuid = 'dept-1',
  String? departmentUuid,
  List<String>? departmentUuids,
  bool includeUnassigned = false,
}) => DepartmentProvider.departmentRecordVisible(
  manageDepartments: manageDepartments,
  canViewAll: canViewAll,
  isUnassignedUser: isUnassignedUser,
  currentDeptUuid: currentDeptUuid,
  departmentUuid: departmentUuid,
  departmentUuids: departmentUuids,
  includeUnassignedWhenDeptSelected: includeUnassigned,
);

TempExpensesClass expense(String uuid, String? departmentUuid) =>
    TempExpensesClass(
      uuid: uuid,
      shopId: 1,
      name: uuid,
      amount: 10,
      creator: 'U',
      userId: 'u1',
      departmentName: null,
      departmentUuid: departmentUuid,
      createdDate: DateTime(2026, 11, 10, 12),
    );

void main() {
  group('departmentRecordVisible', () {
    test('departments off: everything is visible', () {
      expect(
        visible(manageDepartments: false, departmentUuid: 'dept-2'),
        isTrue,
      );
      expect(
        visible(
          manageDepartments: false,
          isUnassignedUser: true,
          departmentUuid: 'dept-2',
        ),
        isTrue,
      );
    });

    test('unassigned user sees only records in no department', () {
      expect(
        visible(isUnassignedUser: true, currentDeptUuid: null),
        isTrue,
      );
      expect(
        visible(
          isUnassignedUser: true,
          currentDeptUuid: null,
          departmentUuid: '  ',
          departmentUuids: const [''],
        ),
        isTrue,
      );
      expect(
        visible(
          isUnassignedUser: true,
          currentDeptUuid: null,
          departmentUuid: 'dept-1',
        ),
        isFalse,
      );
      expect(
        visible(
          isUnassignedUser: true,
          currentDeptUuid: null,
          departmentUuids: const ['dept-1', 'dept-2'],
        ),
        isFalse,
      );
      // Even with a stale current department stored.
      expect(
        visible(isUnassignedUser: true, departmentUuid: 'dept-1'),
        isFalse,
      );
    });

    test('no current department: only "view all" users see records', () {
      expect(
        visible(
          canViewAll: true,
          currentDeptUuid: null,
          departmentUuid: 'dept-2',
        ),
        isTrue,
      );
      expect(
        visible(currentDeptUuid: null, departmentUuid: 'dept-2'),
        isFalse,
      );
    });

    test('current department: its records only, single or multi', () {
      expect(visible(departmentUuid: 'dept-1'), isTrue);
      expect(visible(departmentUuid: 'dept-2'), isFalse);
      expect(
        visible(departmentUuids: const ['dept-2', 'dept-1']),
        isTrue,
      );
      expect(visible(departmentUuids: const ['dept-2']), isFalse);
      expect(
        visible(canViewAll: true, departmentUuid: 'dept-2'),
        isFalse,
      );
    });

    test('records in no department with a current department', () {
      expect(visible(), isFalse);
      expect(visible(includeUnassigned: true), isTrue);
    });
  });

  group('report department scope', () {
    test('isUnassignedDepartment: null and blank', () {
      expect(isUnassignedDepartment(null), isTrue);
      expect(isUnassignedDepartment(''), isTrue);
      expect(isUnassignedDepartment('  '), isTrue);
      expect(isUnassignedDepartment('dept-1'), isFalse);
    });

    test('reportDepartmentMatches', () {
      expect(reportDepartmentMatches('dept-1', 'dept-1'), isTrue);
      expect(reportDepartmentMatches('dept-2', 'dept-1'), isFalse);
      expect(reportDepartmentMatches(null, 'dept-1'), isFalse);
      expect(reportDepartmentMatches(null, null), isTrue);
      expect(reportDepartmentMatches('', null), isTrue);
      expect(reportDepartmentMatches('dept-1', null), isFalse);
    });

    test('receipts: no current department shows only unassigned, '
        'blank included', () {
      final receipts = [
        testReceipt(uuid: 'r1', departmentUuid: 'dept-1'),
        testReceipt(uuid: 'none', departmentUuid: null),
        testReceipt(uuid: 'blank', departmentUuid: ''),
      ];
      final out = ReceiptsReportAccess.scope(
        receipts: receipts,
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: null,
        canViewAllTransactions: true,
        currentUserId: 'staff-a',
      );
      expect(out.map((r) => r.uuid), ['none', 'blank']);
    });

    test('purchases: no current department shows only unassigned', () {
      final purchases = [
        purchase(uuid: 'p1', departmentUuid: 'dept-1'),
        purchase(uuid: 'none'),
        purchase(uuid: 'blank', departmentUuid: ''),
      ];
      final out = PurchaseReportAccess.scope(
        purchases: purchases,
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: null,
        canViewAllTransactions: true,
        currentUserId: 'staff-a',
      );
      expect(out.map((p) => p.uuid), ['none', 'blank']);
    });

    test('general report expenses: same rule', () {
      final out = GeneralReportExpenses.scope(
        expenses: [
          expense('e1', 'dept-1'),
          expense('none', null),
          expense('blank', ''),
        ],
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: null,
        canViewAllTransactions: true,
        currentUserId: 'u1',
      );
      expect(out.map((e) => e.uuid), ['none', 'blank']);
    });

    test('view all and assigned users keep today\'s behaviour', () {
      final purchases = [
        purchase(uuid: 'p1', departmentUuid: 'dept-1'),
        purchase(uuid: 'p2', departmentUuid: 'dept-2'),
        purchase(uuid: 'none'),
      ];
      List<String?> scoped({
        required bool viewAll,
        required String? current,
      }) => PurchaseReportAccess.scope(
        purchases: purchases,
        departmentsEnabled: true,
        canViewAllDepartments: viewAll,
        currentDepartmentUuid: current,
        canViewAllTransactions: true,
        currentUserId: 'staff-a',
      ).map((p) => p.uuid).toList();
      expect(scoped(viewAll: true, current: null), ['p1', 'p2', 'none']);
      expect(scoped(viewAll: true, current: 'dept-2'), ['p2']);
      expect(scoped(viewAll: false, current: 'dept-1'), ['p1']);
    });

    test('suppliers: shared suppliers stay visible, blank counts as '
        'unassigned', () {
      final suppliers = [
        supplier('s1', departmentId: 'dept-1'),
        supplier('none'),
        supplier('blank', departmentId: ''),
      ];
      final unassigned = SupplierReportAccess.scope(
        suppliers: suppliers,
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: null,
      );
      expect(unassigned.map((s) => s.uuid), ['none', 'blank']);
      final assigned = SupplierReportAccess.scope(
        suppliers: suppliers,
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: 'dept-1',
      );
      expect(assigned.map((s) => s.uuid), ['s1', 'none', 'blank']);
    });
  });

  group('PaymentMethod labels', () {
    final gtbMain = PaymentMethod(
      uuid: 'gtb-main',
      bankName: 'GTB',
      accountNumber: '0123',
    );
    final gtbPayroll = PaymentMethod(
      uuid: 'gtb-payroll',
      bankName: 'GTB',
      accountNumber: '9876',
    );
    final opay = PaymentMethod(uuid: 'opay', bankName: 'Opay');
    final methods = [gtbMain, gtbPayroll, opay];

    test('displayName is the bank name only', () {
      expect(gtbMain.displayName, 'GTB');
    });

    test('matchesLabel: new and older "Bank (account)" labels', () {
      expect(gtbMain.matchesLabel('GTB'), isTrue);
      expect(gtbMain.matchesLabel(' GTB '), isTrue);
      expect(gtbMain.matchesLabel('GTB (0123)'), isTrue);
      expect(gtbMain.matchesLabel('GTB (some note)'), isTrue);
      expect(gtbMain.matchesLabel('GTBank'), isFalse);
      expect(gtbMain.matchesLabel('Opay'), isFalse);
      expect(gtbMain.matchesLabel(null), isFalse);
      expect(gtbMain.matchesLabel(''), isFalse);
    });

    test('split keys: two methods at one bank never share a key', () {
      final keys = PaymentMethod.keysForEntries([
        PaymentEntry(method: 'GTB', amount: 10),
        PaymentEntry(method: 'GTB (9876)', amount: 20),
        PaymentEntry(method: PaymentMethods.cash, amount: 5),
      ], methods);
      expect(keys, ['gtb-main', 'gtb-payroll', PaymentMethods.cash]);
      expect(keys.toSet().length, keys.length);
    });

    test('split keys: unmatched labels stay their own key', () {
      final keys = PaymentMethod.keysForEntries([
        PaymentEntry(method: 'Old Bank', amount: 10),
        PaymentEntry(method: PaymentMethods.account, amount: 2),
      ], methods);
      expect(keys, ['Old Bank', PaymentMethods.account]);
    });

    test('labelForKey: saved label is the bank name', () {
      expect(PaymentMethod.labelForKey('gtb-payroll', methods), 'GTB');
      expect(PaymentMethod.labelForKey('opay', methods), 'Opay');
      expect(
        PaymentMethod.labelForKey(PaymentMethods.bank, methods),
        PaymentMethods.bank,
      );
      expect(PaymentMethod.labelForKey('Old Bank', methods), 'Old Bank');
    });
  });

  group('PaymentBreakdown.validate', () {
    test('Split is rejected, a custom bank name is accepted', () {
      expect(
        PaymentBreakdown([
          PaymentEntry(method: PaymentMethods.split, amount: 100),
        ]).validate(total: 100),
        'Unknown payment method.',
      );
      expect(
        PaymentBreakdown([
          PaymentEntry(method: 'GTB', amount: 100),
        ]).validate(total: 100),
        isNull,
      );
    });
  });
}
