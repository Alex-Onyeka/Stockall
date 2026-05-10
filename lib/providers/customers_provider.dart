import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_customers/unsynced/created_customers/created_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/deleted_customers/deleted_customers.dart';
import 'package:stockall/classes/temp_customers/unsynced/updated/updated_customers.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
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

  void clearCustomers() {
    customers.clear();
    print('Customers Cleared');
    notifyListeners();
  }

  List<TempCustomersClass> customersMain() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (!authorization(
        authorized: Authorizations().viewAllDepartments,
      )) {
        return customers.where((cat) {
          if (cat.departmentUuid == null) {
            return true;
          } else {
            return cat.departmentUuid ==
                returnDepartmentProvider()
                    .currentDepartment()
                    ?.uuid;
          }
        }).toList();
      } else {
        if (returnDepartmentProvider()
                .currentDepartment()
                ?.uuid ==
            null) {
          return customers;
        } else {
          return customers.where((cat) {
            if (cat.departmentUuid == null) {
              return true;
            } else {
              return cat.departmentUuid ==
                  returnDepartmentProvider()
                      .currentDepartment()
                      ?.uuid;
            }
          }).toList();
        }
      }
    } else {
      return customers;
    }
  }

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

      customers =
          (data as List)
              .map(
                (json) => TempCustomersClass.fromJson(json),
              )
              .toList();

      await CustomerFunc().insertAllCustomers(customers);
    } else {
      customers = CustomerFunc().getCustomers();
    }
    notifyListeners();
    return customers;
  }

  /// Add a new customer
  Future<void> addCustomerMain(
    TempCustomersClass customer,
    final BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
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
      await returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
        ).customerAdapter(customer, 1),
        // ignore: use_build_context_synchronously
      );
    } else {
      GeneralSettingsAuthAction().allowOfflineUseAction(
        context: context,
        action: () async {
          await CustomerFunc().createCustomer(customer);
          await CreatedCustomersFunc().createCustomers(
            CreatedCustomers(customer: customer),
          );
          await returnEventsLogProvider(
            // ignore: use_build_context_synchronously
          ).createLog(
            returnEventsLogProvider(
              // ignore: use_build_context_synchronously
              // ignore: use_build_context_synchronously
            ).customerAdapter(customer, 1),
            // ignore: use_build_context_synchronously
          );
        },
      );
    }
    // customers.insert(0, newCustomer);
    await fetchCustomers(shopProvider.userShop()!.shopId!);
    notifyListeners();
  }

  /// Update a customer by ID
  Future<void> updateCustomerMain(
    TempCustomersClass customer,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      customer.updatedAt = DateTime.now();
      await supabase
          .from('customers')
          .update(customer.toJson())
          .eq('uuid', customer.uuid!);
      await returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
        ).customerAdapter(customer, 2),
        // ignore: use_build_context_synchronously
      );
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
      await returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
        ).customerAdapter(customer, 1),
        // ignore: use_build_context_synchronously
      );
    }
    await fetchCustomers(shopProvider.userShop()!.shopId!);
    notifyListeners();
  }

  /// Delete a customer by ID
  Future<void> deleteCustomerMain(
    TempCustomersClass customer,
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('customers')
          .delete()
          .eq('uuid', customer.uuid!);
      print('Customer Deleted');
      var res = await returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
        ).customerAdapter(customer, 3),
        // ignore: use_build_context_synchronously
      );
      if (res == 1) {
        print('Customer Delete Logged');
      } else {
        print('Customer Delete Log Failed');
      }
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
      await CustomerFunc().deleteCustomer(customer.uuid!);
      if (containsCreated.isNotEmpty) {
        await CreatedCustomersFunc().deleteCustomer(
          customer.uuid!,
        );
      } else {
        await DeletedCustomersFunc().createDeletedCustomer(
          DeletedCustomers(
            customerUuid: customer.uuid!,
            shopId:
                returnShopProvider().userShop()!.shopId!,
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
    }

    await fetchCustomers(shopProvider.userShop()!.shopId!);
    notifyListeners();
  }

  /// Get single customer by ID
  TempCustomersClass? getCustomerByIdMain(String uuid) {
    try {
      return customers.firstWhere((c) => c.uuid == uuid);
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

  // String? selectedCustomerId;
  // String? selectedCustomerName;
  // SalesProvider salesProvider = SalesProvider();

  void clearSelectedCustomer(BuildContext context) {
    returnSalesProvider().currentCart().selectedCustomer =
        null;
    returnSalesProvider()
        .currentCart()
        .selectedCustomerName = null;
    CartFunc().updateMainCart(
      returnSalesProvider().currentMainCart(),
    );
    notifyListeners();
  }

  void selectCustomer({
    required String id,
    required String name,
    required BuildContext context,
  }) {
    returnSalesProvider().currentCart().selectedCustomer =
        id;
    returnSalesProvider()
        .currentCart()
        .selectedCustomerName = name;
    notifyListeners();
    CartFunc().updateMainCart(
      returnSalesProvider().currentMainCart(),
    );
  }

  //
  //
  //
  //
  //

  Future<void> createCustomersSync(
    BuildContext context,
  ) async {
    final shopProvider = returnShopProvider();
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
            shopProvider.userShop()!.shopId!,
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
    final shopProvider = returnShopProvider();
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
            shopProvider.userShop()!.shopId!,
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
    final shopProvider = returnShopProvider();
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
            shopProvider.userShop()!.shopId!,
          );
        }
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }
  }
}
