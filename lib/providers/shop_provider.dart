import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  Future<void> createShop(TempShopClass shop) async {
    shop.updatedAt = DateTime.now();
    // Insert the shop
    await supabase.from('shops').insert(shop.toJson());

    // Fetch the newly created shop
    final response = await getUserShop(shop.userId);

    if (response != null) {
      setShop(response);
    }
  }

  Future<TempShopClass?> getUserShop(String userId) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final response =
          await supabase.from('shops').select().contains(
            'employees',
            [userId],
          ).maybeSingle();

      if (response == null) {
        // await ShopFunc().clearShop();
        print('User Shop not found');
        return null;
      }
      setShop(TempShopClass.fromJson(response));
      print('User Shop found ${userShop?.name}');
      notifyListeners();
      await ShopFunc().insertShop(userShop!);
    } else {
      setShop(ShopFunc().getShop());
    }
    notifyListeners();

    return userShop;
  }

  Future<void> updatePrintType({
    required int shopId,
    required int? type,
  }) async {
    try {
      bool isOnline = await connectivity.isOnline();
      if (isOnline) {
        await supabase
            .from('shops')
            .update({'print_type': type})
            .eq('shop_id', shopId)
            .maybeSingle();

        final response = await getUserShop(
          AuthService().currentUser!,
        );
        if (response != null) {
          setShop(response);
          notifyListeners();
        }
      } else {
        TempShopClass? shop = ShopFunc().getShop();
        if (shop != null) {
          shop.printType = type;
          shop.updatedAt = DateTime.now();
          ShopFunc().updateShop(shop);
          UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: shop),
          );
          setShop(shop);
          notifyListeners();
        }
      }
    } catch (e) {
      print("❌ Failed to update print type: $e");
    }
  }

  Future<void> updateShopContactDetails({
    required int shopId,
    required String name,
    required String email,
    required String? phoneNumber,
  }) async {
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      try {
        await supabase
            .from('shops')
            .update({
              'name': name,
              'email': email,
              'phone_number': phoneNumber,
              'updated_at':
                  DateTime.now().toIso8601String(),
            })
            .eq('shop_id', shopId)
            .maybeSingle();

        final response = await getUserShop(
          AuthService().currentUser!,
        );

        if (response != null) {
          setShop(response);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Failed to update contact details: $e");
      }
    } else {
      TempShopClass? shop = ShopFunc().getShop();
      shop?.updatedAt = DateTime.now();
      shop?.email = email;
      shop?.phoneNumber = phoneNumber;
      shop?.name = name;
      await ShopFunc().updateShop(shop);
      shop != null
          ? await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: shop),
          )
          : {};
    }
  }

  Future<void> updateShopCurrency({
    required int shopId,
    required String currency,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        await supabase
            .from('shops')
            .update({
              'currency': currency,
              'updated_at':
                  DateTime.now().toIso8601String(),
            })
            .eq('shop_id', shopId)
            .maybeSingle();

        final response = await getUserShop(
          AuthService().currentUser!,
        );

        if (response != null) {
          setShop(response);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Failed to update contact details: $e");
      }
    } else {
      TempShopClass? shop = ShopFunc().getShop();
      shop?.updatedAt = DateTime.now();
      shop?.currency = currency;
      await ShopFunc().updateShop(shop);

      if (shop != null) {
        await UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: shop),
        );
        setShop(shop);
        notifyListeners();
      }
    }
  }

  Future<void> updateShopLocation({
    required int shopId,
    required String country,
    required String state,
    required String city,
    required String? address,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        final response =
            await supabase
                .from('shops')
                .update({
                  'country': country,
                  'state': state,
                  'city': city,
                  'shop_address': address,
                  'updated_at':
                      DateTime.now().toIso8601String(),
                })
                .eq('shop_id', shopId)
                .maybeSingle();
        final shop = await getUserShop(
          AuthService().currentUser!,
        );

        if (response != null) {
          setShop(shop!);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Failed to update location: $e");
      }
    } else {
      TempShopClass? shop = ShopFunc().getShop();
      shop?.updatedAt = DateTime.now();
      shop?.country = country;
      shop?.state = state;
      shop?.city = city;
      shop?.shopAddress = address;
      await ShopFunc().updateShop(shop);
      if (shop != null) {
        await UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: shop),
        );
        setShop(shop);
        notifyListeners();
      }
    }
  }

  Future<List<String>> fetchShopCategories(
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final response =
          await supabase
              .from('shops')
              .select('categories')
              .eq('shop_id', shopId)
              .single();

      final List<dynamic> categories =
          response['categories'] ?? [];
      notifyListeners();
      return categories.cast<String>();
    } else {
      TempShopClass? shop = ShopFunc().getShop();
      if (shop != null) {
        final List<String>? categories = shop.categories;
        return categories ?? [];
      } else {
        return [];
      }
    }
  }

  Future<void> appendShopCategories({
    required int shopId,
    required List<String> newCategories,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        // Step 1: Fetch existing categories
        final response =
            await supabase
                .from('shops')
                .select('categories')
                .eq('shop_id', shopId)
                .maybeSingle();

        List<String> existingCategories =
            (response?['categories'] as List<dynamic>?)
                ?.cast<String>() ??
            [];

        // Step 2: Merge and deduplicate
        final updatedCategories =
            {
              ...existingCategories,
              ...newCategories,
            }.toList();

        // Step 3: Update in database

        await supabase
            .from('shops')
            .update({'categories': updatedCategories})
            .eq('shop_id', shopId)
            .select();

        await getUserShop(AuthService().currentUser!);
        notifyListeners();

        // print('Updated categories: $updateResult');
      } catch (e) {
        // print('Error appending categories: $e');
        rethrow;
      }
    } else {
      TempShopClass? shop = ShopFunc().getShop();
      if (shop != null) {
        shop.updatedAt = DateTime.now();
        shop.categories =
            {
              ...shop.categories ?? [],
              ...newCategories,
            }.toList();
        await ShopFunc().updateShop(shop);
        await UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: shop),
        );
        setShop(shop);
        notifyListeners();
      }
    }
  }

  Future<void> addEmployeeToShop({
    required int shopId,
    required String newEmployeeId,
  }) async {
    try {
      // Step 1: Get the current list of employees
      final response =
          await supabase
              .from('shops')
              .select('employees')
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        print('Shop not found');
        return;
      }

      List<String> currentEmployees = [];

      if (response['employees'] != null) {
        currentEmployees = List<String>.from(
          response['employees'],
        );
      }

      // Step 2: Add the new employee only if it's not already in the list
      if (!currentEmployees.contains(newEmployeeId)) {
        currentEmployees.add(newEmployeeId);
      }

      // Step 3: Update the shop's employees field
      final updateResponse = await supabase
          .from('shops')
          .update({'employees': currentEmployees})
          .eq('shop_id', shopId);

      if (updateResponse != null) {
        print('Failed to update shop: $updateResponse');
      } else {
        print('Employee added successfully.');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  Future<void> removeEmployeeFromShop({
    required int shopId,
    required String employeeIdToRemove,
  }) async {
    try {
      // Step 1: Get the current list of employees
      final response =
          await supabase
              .from('shops')
              .select('employees')
              .eq('shop_id', shopId)
              .maybeSingle();

      if (response == null) {
        print('Shop not found');
        return;
      }

      List<String> currentEmployees = [];

      if (response['employees'] != null) {
        currentEmployees = List<String>.from(
          response['employees'],
        );
      }

      // Step 2: Remove the employee if they exist in the list
      if (currentEmployees.contains(employeeIdToRemove)) {
        currentEmployees.remove(employeeIdToRemove);
      } else {
        print('Employee not found in the shop');
        return;
      }

      // Step 3: Update the shop's employees field
      final updateResponse = await supabase
          .from('shops')
          .update({'employees': currentEmployees})
          .eq(
            'shop_id',
            shopId,
          ); // Required to actually perform the update

      if (updateResponse != null) {
        print('Failed to update shop: $updateResponse');
      } else {
        print('Employee removed successfully.');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  // ShopProvider() {
  //   _init();
  // }
  // Future<void> _init() async {
  //   final userId = AuthService().currentUser;
  //   if (userShop == null) {
  //     final shop = await getUserShop(userId!);
  //     if (shop != null) {
  //       setShop(shop);
  //     }
  //   }
  // }

  bool isUpdated = false;

  void toggleUpdated(bool value) {
    isUpdated = value;
    notifyListeners();
  }

  TempShopClass? userShop;

  void clearShop() {
    userShop = null;
    notifyListeners();
  }

  void setShop(TempShopClass? shop) {
    userShop = shop;
    notifyListeners();
  }

  String name = '';
  String country = '';
  String? email;
  String? phone;
  String state = '';
  String city = '';
  String address = '';

  //
  //
  //
  //
  //
  //
  //
  //

  //
  //
  //
  //

  Future<void> updateShopSync(BuildContext context) async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        UpdatedShopFunc()
            .getUpdatedShop()
            .length
            .toString(),
      );

      if (UpdatedShopFunc().getUpdatedShop().isNotEmpty &&
          isOnline) {
        final updatedShop =
            UpdatedShopFunc().getUpdatedShop();

        for (final updated in updatedShop) {
          final localShop = updated.shop;

          localShop.updatedAt ??= DateTime.now().toUtc();

          if (localShop.shopId == null) {
            print('⚠️ Local shopId is null, skipping');
            continue;
          }
          final remoteData =
              await supabase
                  .from('shops')
                  .select('shop_id, updated_at')
                  .eq('shop_id', localShop.shopId!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('shops')
                .insert(localShop.toJson());
            print(
              'Inserted Shop with Shop Id ${localShop.shopId}',
            );
            await UpdatedShopFunc().deleteUpdatedShop(
              localShop.shopId!,
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

            localShop.updatedAt =
                (localShop.updatedAt ?? DateTime.now())
                    .toUtc();
            print(
              "Local updatedAt: ${localShop.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localShop.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('shops')
                  .update(localShop.toJson())
                  .eq('shop_id', localShop.shopId!);
              print(
                'Updated Shop with shopId ${localShop.shopId}',
              );
              await UpdatedShopFunc().deleteUpdatedShop(
                localShop.shopId!,
              );
            } else {
              print(
                'Skipped Shop ${localShop.shopId}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedShopFunc().clearUpdatedShop();
        print('Unsynced updated Shop cleared');
        if (context.mounted) {
          print('Mounted, refreshing Shop ✅');
          await getUserShop(AuthService().currentUser!);
        }
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }
}
