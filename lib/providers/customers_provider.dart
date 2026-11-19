import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/cart_func/cart_func.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersProvider extends ChangeNotifier {
  static final CustomersProvider _instance =
      CustomersProvider._internal();
  factory CustomersProvider() => _instance;
  CustomersProvider._internal();
  //
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempCustomersClass> customers = [];
  DateTime? _lastSyncAt;
  int? _lastSyncShopId;

  void clearCustomers() {
    customers.clear();
    _lastSyncAt = null;
    _lastSyncShopId = null;
    mainLocalLog('Customers Cleared');
    notifyListeners();
  }

  List<TempCustomersClass> customersMain() {
    return customers.where((cat) {
      return returnDepartmentProvider()
          .matchesCurrentDepartment(
            departmentUuid: cat.departmentUuid,
            includeUnassignedWhenDeptSelected: true,
          );
    }).toList();
  }

  /// Fetch all customers by shop ID
  Future<List<TempCustomersClass>> fetchCustomers(
    int shopId, {
    bool forceRefresh = false,
  }) async {
    await fetchCustomersOffline();
    bool isOnline = await connectivity.isOnline();
    if (isOnline && CustomerFunc().isSynced()) {
      if (!forceRefresh &&
          _lastSyncAt != null &&
          _lastSyncShopId == shopId &&
          customers.isNotEmpty) {
        try {
          final safeSince =
              _lastSyncAt!
                  .subtract(const Duration(seconds: 5))
                  .toUtc();
          final res = await supabase
              .from('customers')
              .select()
              .eq('shop_id', shopId)
              .gt('updated_at', safeSince.toIso8601String())
              .order('updated_at', ascending: true);
          if (res.isNotEmpty) {
            final pendingUuids = {
              ...UpdatedCustomersFunc().getCustomers().map(
                (u) => u.customer.uuid,
              ),
              ...CreatedCustomersFunc().getCustomers().map(
                (c) => c.customer.uuid,
              ),
            };
            final updated =
                (res as List)
                    .map(
                      (j) => TempCustomersClass.fromJson(j),
                    )
                    .where(
                      (c) => !pendingUuids.contains(c.uuid),
                    )
                    .toList();
            for (final item in updated) {
              final idx = customers.indexWhere(
                (c) => c.uuid == item.uuid,
              );
              if (idx != -1) {
                customers[idx] = item;
              } else {
                customers.add(item);
              }
            }
            customers.sort(
              (a, b) => a.name.toLowerCase().compareTo(
                b.name.toLowerCase(),
              ),
            );
            await CustomerFunc().insertAllCustomers(
              customers,
            );
            notifyListeners();
          }
          _lastSyncAt = DateTime.now().toUtc();
          await returnCustomerAccountReceiptsProvider()
              .getCustomerAccountReceipts(shopId);
          return customers;
        } catch (e) {
          await mainLocalLog(
            'Incremental Customers Sync error: $e',
          );
        }
      }

      final data = await supabase
          .from('customers')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);
      await mainLocalLog(data.length.toString());

      customers =
          (data as List)
              .map(
                (json) => TempCustomersClass.fromJson(json),
              )
              .toList();

      await CustomerFunc().insertAllCustomers(customers);
      _lastSyncAt = DateTime.now().toUtc();
      _lastSyncShopId = shopId;
      await mainLocalLog('Customer Gotten Successfully');
      await returnCustomerAccountReceiptsProvider()
          .getCustomerAccountReceipts(shopId);
    } else {
      fetchCustomersOffline();
    }
    notifyListeners();
    return customers;
  }

  Future<List<TempCustomersClass>>
  fetchCustomersOffline() async {
    customers = CustomerFunc().getCustomers();
    // }
    await returnCustomerAccountReceiptsProvider()
        .getCustomerAccountReceiptsOffline();
    notifyListeners();

    return customers;
  }

  /// Add a new customer
  Future<void> addCustomerMain(
    TempCustomersClass customer,
    final BuildContext context,
  ) async {
    customer.updatedAt = DateTime.now();
    customer.dateAdded = DateTime.now();
    customer.uuid = uuidGen();
    await CustomerFunc().createCustomer(customer);
    await CreatedCustomersFunc().createCustomers(
      CreatedCustomers(customer: customer),
    );
    await returnEventsLogProvider(
      // ignore: use_build_context_synchronously
    ).createLog(
      returnEventsLogProvider().customerAdapter(
        customer,
        1,
      ),
    );
    await fetchCustomersOffline();
    notifyListeners();
    syncData();
  }

  /// Update a customer by ID
  Future<void> updateCustomerMain(
    TempCustomersClass customer,
  ) async {
    try {
      await CustomerFunc().updateCustomer(customer);
      var containsCreated =
          CreatedCustomersFunc()
              .getCustomers()
              .where(
                (cus) => cus.customer.uuid == customer.uuid,
              )
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedCustomersFunc().createUpdatedCustomer(
          UpdatedCustomers(customer: customer),
        );
      } else {
        await CreatedCustomersFunc().updateCustomers(
          CreatedCustomers(customer: customer),
        );
      }
      await returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
        ).customerAdapter(customer, 1),
        // ignore: use_build_context_synchronously
      );
      // }
      await fetchCustomersOffline();
      notifyListeners();
      syncData();
    } catch (e) {
      await mainLocalLog(
        'Error Updating Customer: ${e.toString()}',
      );
    }
  }

  /// Delete a customer by ID
  Future<void> deleteCustomerMain(
    TempCustomersClass customer,
  ) async {
    var containsCreated =
        CreatedCustomersFunc()
            .getCustomers()
            .where((c) => c.customer.uuid == customer.uuid)
            .toList();
    var containsUpdated =
        UpdatedCustomersFunc()
            .getCustomers()
            .where((c) => c.customer.uuid == customer.uuid)
            .toList();
    await CustomerFunc().deleteCustomer(customer.uuid!);
    if (containsCreated.isNotEmpty) {
      await CreatedCustomersFunc().deleteCustomer(
        customer.uuid!,
      );
    } else {
      await DeletedCustomersFunc().createDeletedCustomer(
        DeletedCustomers(
          customerUuid: customer.uuid!,
          shopId: returnShopProvider().userShop()!.shopId!,
        ),
      );
    }
    if (containsUpdated.isNotEmpty) {
      await UpdatedCustomersFunc().deleteUpdatedCustomer(
        customer.uuid!,
      );
    }
    await returnEventsLogProvider(
      // ignore: use_build_context_synchronously
    ).createLog(
      returnEventsLogProvider(
        // ignore: use_build_context_synchronously
        // ignore: use_build_context_synchronously
      ).customerAdapter(customer, 3),
      // ignore: use_build_context_synchronously
    );
    // }

    await fetchCustomersOffline();
    notifyListeners();
    syncData();
  }

  /// Get single customer by ID
  TempCustomersClass? getCustomerByIdMain(String uuid) {
    try {
      return customers.firstWhere((c) => c.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearSelectedCustomer(
    BuildContext context,
  ) async {
    returnSalesProvider().currentCart().selectedCustomer =
        null;
    returnSalesProvider()
        .currentCart()
        .selectedCustomerName = null;
    await CartFunc().updateMainCart(
      returnSalesProvider().currentMainCart(),
    );
    notifyListeners();
  }

  void reloadPage() {
    notifyListeners();
  }

  Future<void> selectCustomer({
    String? id,
    required String name,
    required BuildContext context,
  }) async {
    returnSalesProvider().currentCart().selectedCustomer =
        id;
    returnSalesProvider()
        .currentCart()
        .selectedCustomerName = name;

    await CartFunc().updateMainCart(
      returnSalesProvider().currentMainCart(),
    );
    notifyListeners();
  }

  //
  //
  //
  //
  //

  Future<void> createCustomersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedCustomersFunc()
              .getCustomers()
              .isNotEmpty &&
          isOnline) {
        final tempCustomers =
            CreatedCustomersFunc().getCustomers().toList();
        for (var customer in tempCustomers) {
          await mainLocalLog(
            'Updated Time: ${customer.customer.updatedAt?.toString()}',
          );
        }
        final payload =
            tempCustomers
                .map(
                  (p) => p.customer.toJson(
                    isMoneyUpdate: true,
                  ),
                )
                .toList();

        // Insert all at once
        final data = await supabase
            .from('customers')
            .insert(payload)
            .select('uuid');

        await mainLocalLog(
          '${data.length} items added successfully ✅',
        );
        await CreatedCustomersFunc().clearCustomers();
        await mainLocalLog('Unsynced Customers Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customers insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  Future<void> updateCustomersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedCustomersFunc()
            .getCustomers()
            .length
            .toString(),
      );

      if (UpdatedCustomersFunc()
              .getCustomers()
              .isNotEmpty &&
          isOnline) {
        final updatedCustomers =
            UpdatedCustomersFunc().getCustomers();

        for (final updated in updatedCustomers) {
          final localCustomer = updated.customer;

          localCustomer.updatedAt ??=
              DateTime.now().toLocal();

          if (localCustomer.uuid == null) {
            await mainLocalLog(
              'Local Customer Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from('customers')
                  .select('uuid, updated_at')
                  .eq('uuid', localCustomer.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('customers')
                .insert(
                  localCustomer.toJson(
                    isMoneyUpdate: false,
                  ),
                );
            await mainLocalLog(
              'Inserted Customer with uuid ${localCustomer.uuid}',
            );
            await UpdatedCustomersFunc()
                .deleteUpdatedCustomer(
                  localCustomer.uuid ?? '',
                );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localCustomer.updatedAt =
                (localCustomer.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localCustomer.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localCustomer.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('customers')
                  .update(
                    localCustomer.toJson(
                      isMoneyUpdate: false,
                    ),
                  )
                  .eq('uuid', localCustomer.uuid!);
              await mainLocalLog(
                'Updated customer with uuid ${localCustomer.uuid}',
              );
              await UpdatedCustomersFunc()
                  .deleteUpdatedCustomer(
                    localCustomer.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped customer ${localCustomer.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedCustomersFunc()
            .clearupdatedCustomers();
        await mainLocalLog(
          'Unsynced updated Customers cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customers update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> deletedCustomersSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedCustomersFunc()
              .getCustomerIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedCustomersFunc()
                .getCustomerIds()
                .map((p) => p.customerUuid)
                .toList();

        final data = await supabase
            .from('customers')
            .delete()
            .inFilter(
              'uuid',
              uuids,
            ) // delete where id is in the list
            .select('uuid');

        await mainLocalLog(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedCustomersFunc()
            .clearDeletedCustomers();
        await mainLocalLog(
          'Unsynced deleted Customers cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Customers Delete failed ❌: $e',
      );
    }
  }
}
