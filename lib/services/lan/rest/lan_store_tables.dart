import 'package:stockall/classes/lan/lan_user_credential.dart';
import 'package:stockall/classes/temp_permission/temp_permission_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/services/lan/lan_access_policy.dart';
import 'package:stockall/services/lan/rest/lan_more_tables.dart';
import 'package:stockall/services/lan/rest/lan_table.dart';

/// The store, its users and the permissions catalogue, for this store only.
/// Reads are answered by the server; a list of other stores or of
/// other stores' staff is not (the app can ask Supabase directly when the
/// device is online).

/// A shop row as Supabase sends it: `toJson` leaves out keys `fromJson`
/// reads (`shop_id`, `active_employee`, `is_allowed_by_subscription`).
Map<String, dynamic> lanShopJson(TempShopClass shop) => {
  ...shop.toJson(),
  'shop_id': shop.shopId,
  'active_employee': shop.activeEmployee,
  'is_allowed_by_subscription': shop.isAllowedBySubscription,
};

/// Settings changes are done here and queued like the app's offline path;
/// creating or deleting a store, and changing its members or owner, need
/// Supabase (they decide who can log in).
LanTable<TempShopClass> shopsTable(
  LanRows<TempShopClass> rows, {
  LanChanges changes,
  LanWrites<TempShopClass>? writes,
}) => LanTable<TempShopClass>(
  name: 'shops',
  rows: rows,
  changes: changes,
  writes: writes,
  toJson: lanShopJson,
  shopIdOf: (s) => s.shopId,
  columns: {
    'shop_id': LanColumn(LanColumnType.number, (s) => s.shopId),
    'user_id': LanColumn(LanColumnType.text, (s) => s.userId),
    'employees': LanColumn(LanColumnType.textArray, (s) => s.employees),
    'is_allowed_by_subscription': LanColumn(
      LanColumnType.boolean,
      (s) => s.isAllowedBySubscription,
    ),
    'updated_at': LanColumn(LanColumnType.timestamp, (s) => s.updatedAt),
  },
);

/// Shop writes: [save] stores and queues an updated shop (the server's
/// ShopFunc box, its UpdatedShop queue and its in-memory shop list).
LanWrites<TempShopClass> shopWrites({
  required TempShopClass? Function(int shopId) find,
  required Future<void> Function(TempShopClass shop) save,
  Future<Map<String, dynamic>> Function(Map<String, dynamic> patch)?
  prepareUpdate,
  LanPullStore<TempShopClass>? pull,
}) {
  return LanWrites<TempShopClass>(
    fromJson: TempShopClass.fromJson,
    key: 'shop_id',
    find: (key) => int.tryParse(key) == null ? null : find(int.parse(key)),
    update: (shop, patch) => save(shop),
    prepareUpdate: prepareUpdate,
    onlineOps: const {LanWriteOp.insert, LanWriteOp.delete},
    onlineColumns: const {'employees', 'user_id'},
    queues: Map.fromEntries([lanQueue<UpdatedShop>('updatedShopBoxStockall')]),
    pull: pull,
  );
}

/// A user row from the server's LAN credential (which keeps each
/// member's profile), as Supabase sends it but with an empty password: the server
/// never sends passwords. The PIN stays: PIN switching uses it.
Map<String, dynamic> lanUserJson(LanUserCredential c) => {
  ...c.profile(),
  'user_id': c.userId,
  'password': '',
};

/// Every user write needs Supabase: users are not queued in the app.
LanTable<LanUserCredential> usersTable(LanRows<LanUserCredential> rows) =>
    LanTable<LanUserCredential>(
      name: 'users',
      rows: rows,
      toJson: lanUserJson,
      shopIdOf: (c) => c.shopId,
      writes: LanWrites<LanUserCredential>(
        fromJson: (_) => throw StateError('users are not written here'),
        find: (_) => null,
        onlineOps: const {
          LanWriteOp.insert,
          LanWriteOp.update,
          LanWriteOp.delete,
        },
      ),
      columns: {
        'user_id': LanColumn(LanColumnType.text, (c) => c.userId),
        'email': LanColumn(LanColumnType.text, (c) => c.email),
        'department_uuids': LanColumn(
          LanColumnType.textArray,
          (c) => c.departmentUuids,
        ),
      },
    );

/// `toJson` leaves out `permit_number`, which `fromJson` requires.
Map<String, dynamic> lanPermissionJson(PermissionModel p) => {
  ...p.toJson(),
  'permit_number': p.permitNumber,
};

/// The role catalogue: not per store, read only.
LanTable<PermissionModel> permissionsTable(
  LanRows<PermissionModel> rows, {
  LanPullStore<PermissionModel>? pull,
}) =>
    LanTable<PermissionModel>(
      name: 'permissions',
      rows: rows,
      pull: pull,
      global: true,
      toJson: lanPermissionJson,
      shopIdOf: (_) => null,
      columns: {
        'id': LanColumn(LanColumnType.text, (p) => p.id),
        'role': LanColumn(LanColumnType.text, (p) => p.role),
      },
    );
