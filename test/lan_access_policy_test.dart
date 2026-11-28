import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';

void main() {
  final a = Authorizations();

  LanPrincipal principal({
    List<String> access = const [],
    List<String> departments = const [],
    bool isOwner = false,
  }) {
    return LanPrincipal.fromCredential(
      LanUserCredential(
        shopId: 7,
        userId: 'u1',
        email: 'u1@shop.test',
        salt: '00',
        hash: '00',
        iterations: 1,
        role: isOwner ? 'Owner' : 'Cashier',
        access: access,
        departmentUuids: departments,
        isOwner: isOwner,
        profileJson: '{}',
        updatedAt: DateTime.utc(2026, 11, 25),
      ),
    );
  }

  test('membership is per shop', () {
    expect(LanAccessPolicy.isMember(principal(), 7), isTrue);
    expect(LanAccessPolicy.isMember(principal(), 8), isFalse);
    expect(LanAccessPolicy.isMember(null, 7), isFalse);
  });

  test('permissions mirror authorization(): the access list only', () {
    final cashier = principal(access: [a.makeSale]);
    final owner = principal(isOwner: true);

    expect(LanAccessPolicy.has(cashier, a.makeSale), isTrue);
    expect(LanAccessPolicy.has(cashier, a.deleteProduct), isFalse);
    // No implicit pass for owners, exactly as in the app.
    expect(LanAccessPolicy.has(owner, a.deleteProduct), isFalse);
    expect(
      () => LanAccessPolicy.require(cashier, a.deleteProduct),
      throwsA(
        isA<LanAccessDenied>().having(
          (e) => e.permission,
          'permission',
          a.deleteProduct,
        ),
      ),
    );
  });

  group('departments', () {
    bool sees(
      LanPrincipal p, {
      bool manage = true,
      String? single,
      List<String>? multi,
      bool shared = false,
    }) {
      return LanAccessPolicy.canSeeDepartment(
        p,
        manageDepartments: manage,
        departmentUuid: single,
        departmentUuids: multi,
        includeUnassigned: shared,
      );
    }

    test('departments off: everything is visible', () {
      expect(sees(principal(), manage: false, single: 'd1'), isTrue);
    });

    test('"View All Departments" sees every department', () {
      expect(
        sees(principal(access: [a.viewAllDepartments]), single: 'd9'),
        isTrue,
      );
    });

    test('staff see their departments; records in none only where the '
        'app shares them', () {
      final staff = principal(departments: ['d1', 'd2']);
      expect(sees(staff, single: 'd1'), isTrue);
      expect(sees(staff, multi: ['d3', 'd2']), isTrue);
      expect(sees(staff, single: 'd3'), isFalse);
      expect(sees(staff), isFalse);
      expect(sees(staff, single: ' ', multi: ['']), isFalse);
      expect(sees(staff, shared: true), isTrue);
      expect(sees(staff, single: 'd3', shared: true), isFalse);
    });

    test('unassigned staff see only records in no department', () {
      final unassigned = principal();
      expect(sees(unassigned), isTrue);
      expect(sees(unassigned, shared: true), isTrue);
      expect(sees(unassigned, single: 'd1'), isFalse);
      expect(sees(unassigned, single: 'd1', shared: true), isFalse);
    });
  });

  group('writes', () {
    bool can(List<String> access, String table, LanWriteOp op) =>
        LanAccessPolicy.canWrite(principal(access: access), table, op);

    test('the map uses the UI permission strings', () {
      expect(
        LanAccessPolicy.writePermissions('products', LanWriteOp.delete),
        {'Delete Items'},
      );
      expect(
        LanAccessPolicy.writePermissions('receipts', LanWriteOp.insert),
        contains('Make Sale'),
      );
      expect(
        LanAccessPolicy.writePermissions('expenses', LanWriteOp.update),
        contains(a.updateExpenses),
      );
      expect(
        LanAccessPolicy.writePermissions('users', LanWriteOp.insert),
        {a.addEmployee},
      );
    });

    test('any one of the op\'s permissions is enough', () {
      // A sale creates a custom item; the price screen updates one.
      expect(can([a.makeSale], 'products', LanWriteOp.insert), isTrue);
      expect(can([a.editSellingPrice], 'products', LanWriteOp.update), isTrue);
      expect(can([a.makeSale], 'products', LanWriteOp.delete), isFalse);
      expect(can([], 'products', LanWriteOp.insert), isFalse);
    });

    test('histories and logs need membership only', () {
      for (final table in ['item_history', 'event_logs', 'product_sales']) {
        for (final op in LanWriteOp.values) {
          expect(can([], table, op), isTrue, reason: '$table $op');
        }
      }
    });

    test('an unmapped table is denied', () {
      expect(can([a.manageShop], 'app_version', LanWriteOp.insert), isFalse);
      expect(
        LanAccessPolicy.writePermissions('app_version', LanWriteOp.insert),
        isNull,
      );
    });

    test('everyone may update their own users row', () {
      final p = principal();
      expect(
        LanAccessPolicy.canWrite(p, 'users', LanWriteOp.update),
        isFalse,
      );
      expect(
        LanAccessPolicy.canWrite(p, 'users', LanWriteOp.update, ownRow: true),
        isTrue,
      );
      expect(
        LanAccessPolicy.canWrite(p, 'users', LanWriteOp.delete, ownRow: true),
        isFalse,
      );
    });
  });
}
