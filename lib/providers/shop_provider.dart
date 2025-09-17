import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<void> createShop(TempShopClass shop) async {
    // Insert the shop
    await supabase.from('shops').insert(shop.toJson());

    // Fetch the newly created shop
    final response = await getUserShop(shop.userId);

    if (response != null) {
      setShop(response);
    }
  }

  Future<TempShopClass?> getUserShop(String userId) async {
    bool isOnline = await ConnectivityProvider().isOnline();
    if (isOnline) {
      final response =
          await supabase.from('shops').select().contains(
            'employees',
            [userId],
          ).maybeSingle();

      if (response == null) {
        return null;
      }
      userShop = TempShopClass.fromJson(response);
      notifyListeners();
      await ShopFunc().insertShop(userShop!);
    } else {
      userShop = ShopFunc().getShop();
    }
    notifyListeners();

    return userShop;
  }

  Future<void> updatePrintType({
    required int shopId,
    required int? type,
  }) async {
    try {
      await supabase
          .from('shops')
          .update({'print_type': type})
          .eq('shop_id', shopId)
          .maybeSingle();

      final response = await getUserShop(
        AuthService().currentUser!.id,
      );

      if (response != null) {
        setShop(response);
        notifyListeners();
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
    try {
      await supabase
          .from('shops')
          .update({
            'name': name,
            'email': email,
            'phone_number': phoneNumber,
          })
          .eq('shop_id', shopId)
          .maybeSingle();

      final response = await getUserShop(
        AuthService().currentUser!.id,
      );

      if (response != null) {
        setShop(response);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to update contact details: $e");
    }
  }

  Future<void> updateShopCurrency({
    required int shopId,
    required String currency,
  }) async {
    try {
      await supabase
          .from('shops')
          .update({'currency': currency})
          .eq('shop_id', shopId)
          .maybeSingle();

      final response = await getUserShop(
        AuthService().currentUser!.id,
      );

      if (response != null) {
        setShop(response);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to update contact details: $e");
    }
  }

  Future<void> updateShopLocation({
    required int shopId,
    required String country,
    required String state,
    required String city,
    required String? address,
  }) async {
    try {
      final response =
          await supabase
              .from('shops')
              .update({
                'country': country,
                'state': state,
                'city': city,
                'shop_address': address,
              })
              .eq('shop_id', shopId)
              .maybeSingle();
      final shop = await getUserShop(
        AuthService().currentUser!.id,
      );

      if (response != null) {
        setShop(shop!);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to update location: $e");
    }
  }

  Future<List<String>> fetchShopCategories(
    int shopId,
  ) async {
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
  }

  Future<void> appendShopCategories({
    required int shopId,
    required List<String> newCategories,
  }) async {
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

      await getUserShop(AuthService().currentUser!.id);
      notifyListeners();

      // print('Updated categories: $updateResult');
    } catch (e) {
      // print('Error appending categories: $e');
      rethrow;
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

  ShopProvider() {
    _init();
  }
  Future<void> _init() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId != null) {
      final shop = await getUserShop(userId);
      if (shop != null) {
        setShop(shop);
      }
    }
  }

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
}
