import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/customers/customer_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/deleted/deleted_customers_func.dart';
import 'package:stockall/local_database/customers/unsync_funcs/updated/updated_customers_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersProvider extends ChangeNotifier {
  //
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<TempCustomersClass> _customers = [];

  void clearCustomers() {
    _customers.clear();
    print('Customers Cleared');
    notifyListeners();
  }

  List<TempCustomersClass> get customersMain => _customers;

  /// Fetch all customers by shop ID
  Future<List<TempCustomersClass>> fetchCustomers(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final data = await supabase
          .from('customers')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: true);
      print(data.length.toString());

      _customers =
          (data as List)
              .map(
                (json) => TempCustomersClass.fromJson(json),
              )
              .toList();
      await CustomerFunc().insertAllCustomers(_customers);
    } else {
      _customers = CustomerFunc().getCustomers();
    }
    notifyListeners();
    return _customers;
  }

  /// Add a new customer
  Future<void> addCustomerMain(
    TempCustomersClass customer,
    final BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    bool isOnline = await connectivity.isOnline();
    customer.updatedAt = DateTime.now();
    customer.dateAdded = DateTime.now();
    customer.uuid = uuidGen();
    if (isOnline) {
      final res =
          await supabase
              .from('customers')
              .insert(customer.toJson())
              .select()
              .single();
      print(res);

      final newCustomer = TempCustomersClass.fromJson(res);
      await CustomerFunc().createCustomer(newCustomer);
    } else {
      await CustomerFunc().createCustomer(customer);
      await CreatedCustomersFunc().createCustomers(
        CreatedCustomers(customer: customer),
      );
    }
    // _customers.insert(0, newCustomer);
    await fetchCustomers(shopProvider.userShop!.shopId!);
    notifyListeners();
  }

  /// Update a customer by ID
  Future<void> updateCustomerMain(
    TempCustomersClass customer,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      customer.updatedAt = DateTime.now();
      await supabase
          .from('customers')
          .update(customer.toJson())
          .eq('uuid', customer.uuid!);
    } else {
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
    }
    await fetchCustomers(shopProvider.userShop!.shopId!);
    notifyListeners();
  }

  /// Delete a customer by ID
  Future<void> deleteCustomerMain(
    String uuid,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('customers')
          .delete()
          .eq('uuid', uuid);
    } else {
      var containsCreated =
          CreatedCustomersFunc()
              .getCustomers()
              .where(
                (customer) =>
                    customer.customer.uuid == uuid,
              )
              .toList();
      var containsUpdated =
          UpdatedCustomersFunc()
              .getCustomers()
              .where(
                (customer) =>
                    customer.customer.uuid == uuid,
              )
              .toList();
      await CustomerFunc().deleteCustomer(uuid);
      if (containsCreated.isNotEmpty) {
        await CreatedCustomersFunc().deleteCustomer(uuid);
      } else {
        await DeletedCustomersFunc().createDeletedCustomer(
          DeletedCustomers(
            customerUuid: uuid,
            shopId: ShopFunc().getShop()!.shopId!,
          ),
        );
      }
      if (containsUpdated.isNotEmpty) {
        await UpdatedCustomersFunc().deleteUpdatedCustomer(
          uuid,
        );
      }
    }

    await fetchCustomers(shopProvider.userShop!.shopId!);
    notifyListeners();
  }

  /// Get single customer by ID
  TempCustomersClass? getCustomerByIdMain(String uuid) {
    try {
      return _customers.firstWhere((c) => c.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  //
  //
  //
  //
  //
  //

  // void updateCustomer({
  //   required TempCustomersClass mainCustomer,
  //   required TempCustomersClass setterCustomer,
  // }) {
  //   mainCustomer.address = setterCustomer.address;
  //   mainCustomer.city = setterCustomer.city;
  //   mainCustomer.country = setterCustomer.country;
  //   mainCustomer.email = setterCustomer.email;
  //   mainCustomer.name = setterCustomer.name;
  //   mainCustomer.phone = setterCustomer.phone;
  //   mainCustomer.state = setterCustomer.state;
  //   notifyListeners();
  // }

  String? selectedCustomerId;
  String? selectedCustomerName;

  void clearSelectedCustomer() {
    selectedCustomerId = null;
    selectedCustomerName = null;
    notifyListeners();
  }

  void selectCustomer(String id, String name) {
    selectedCustomerId = id;
    selectedCustomerName = name;
    notifyListeners();
  }

  //
  //
  //
  //
  //

  Future<void> createCustomersSync(
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
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
          print(
            'Updated Time: ${customer.customer.updatedAt?.toString()}',
          );
        }
        final payload =
            tempCustomers
                .map((p) => p.customer.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('customers')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedCustomersFunc().clearCustomers();
        print('Unsynced Customers Cleared');
        if (context.mounted) {
          print('Mounted, refreshing Customers ✅');
          await fetchCustomers(
            shopProvider.userShop!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch Customers insert failed ❌: $e');
    }
  }

  //
  //
  //
  //
  //

  Future<void> updateCustomersSync(
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
    try {
      bool isOnline = await connectivity.isOnline();
      print(
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
            print('Local Customer Uuid is Null');
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
                .insert(localCustomer.toJson());
            print(
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
            print(
              "Local updatedAt: ${localCustomer.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localCustomer.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('customers')
                  .update(localCustomer.toJson())
                  .eq('uuid', localCustomer.uuid!);
              print(
                'Updated customer with uuid ${localCustomer.uuid}',
              );
              await UpdatedCustomersFunc()
                  .deleteUpdatedCustomer(
                    localCustomer.uuid ?? '',
                  );
            } else {
              print(
                'Skipped customer ${localCustomer.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedCustomersFunc()
            .clearupdatedCustomers();
        print('Unsynced updated Customers cleared');
        if (context.mounted) {
          print('Mounted, refreshing Customers ✅');
          await fetchCustomers(
            shopProvider.userShop!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }

  //
  //
  //
  //

  Future<void> deletedCustomersSync(
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider(
      context,
      listen: false,
    );
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

        final data =
            await supabase
                .from('customers')
                .delete()
                .inFilter(
                  'uuid',
                  uuids,
                ) // delete where id is in the list
                .select();

        print(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedCustomersFunc()
            .clearDeletedCustomers();
        print('Unsynced deleted Customers cleared');
        if (context.mounted) {
          print('Mounted, refreshing Customers ✅');
          await fetchCustomers(
            shopProvider.userShop!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }
  }
}
