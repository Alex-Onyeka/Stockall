import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/barcode_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/printer_settings/printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_barcode_printer_class/temp_barcode_printer_class/temp_barcode_printer_class.dart';
import 'package:stockall/classes/temp_current_shop/temp_current_shop.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_and_barcode_printer_class%20copy/price_and_barcode_printer_settings/price_and_barcode_printer_settings.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_local.dart';
import 'package:stockall/classes/temp_generated_prints/temp_price_tag_printer_class/price_tag_printer_settings/price_tag_printer_settings.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/classes/temp_shop_owner/shop_owner.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/subscription/multiple_stores_auth.dart';
import 'package:stockall/local_database/barcode_printer_func/barcode_printer_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_and_barcode_local_func.dart';
import 'package:stockall/local_database/barcode_printer_func/price_tag_printer_func.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_current/current_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/local_database/shop_owner/shop_owner_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/base_page/base_page.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ShopProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  static final ShopProvider _instance =
      ShopProvider._internal();
  factory ShopProvider() => _instance;
  ShopProvider._internal();

  Future<void> createShop(
    TempShopClass shop,
    BuildContext context,
  ) async {
    print('Starting Creating Shop');
    var response =
        await supabase
            .from('subscription')
            .select()
            .eq('user_id', AuthService().currentUser!)
            .maybeSingle();
    shop.manageInventoryStorage = false;
    shop.bulkSale = false;

    print('Subscription Result: $response');
    if (response == null) {
      print('Subscription is Null');
      var sub = await returnSubcsription(
        // ignore: use_build_context_synchronously
        context,
        listen: false,
        // ignore: use_build_context_synchronously
      ).createSubscription(context);
      if (sub != null) {
        print('Subscription Created');
        MultipleStoresAuthAction().numberOfStoresAction(
          // ignore: use_build_context_synchronously
          context: context,
          action: () async {
            shop.updatedAt = DateTime.now();
            if (tempRole != 'Owner') {
              shop.employees!.add(
                AuthService().currentUser!,
              );
            }
            print('Creating Shop');
            print('App State Role: $tempRole');
            // Insert the shop
            shop.refCode?.toLowerCase();
            var createdShop =
                await supabase
                    .from('shops')
                    .insert(shop.toJson())
                    .select()
                    .maybeSingle();

            if (createdShop != null) {
              print(
                'Created Shop Name: ${createdShop['name']}',
              );
              print('Updating User Role');
              var user =
                  await supabase
                      .from('users')
                      .update({'role': tempRole})
                      .eq(
                        'user_id',
                        AuthService().currentUser!,
                      )
                      .select()
                      .maybeSingle();
              print('User Role Updated: $user');
              if (user != null) {
                print(user['name']);
              }
            }

            // Fetch All Shops
            final response = await getUserShops();

            if (response.isNotEmpty) {
              setShops(response);
            }
          },
        );
      }
    } else {
      MultipleStoresAuthAction().numberOfStoresAction(
        // ignore: use_build_context_synchronously
        context: context,
        action: () async {
          shop.updatedAt = DateTime.now();
          shop.isHeadQuarters = false;
          shop.refCode?.toLowerCase();
          var createdShop =
              await supabase
                  .from('shops')
                  .insert(shop.toJson())
                  .select()
                  .maybeSingle();

          if (createdShop != null) {
            print(createdShop['name']);
            var user =
                await supabase
                    .from('users')
                    .update({'role': 'Owner'})
                    .eq(
                      'user_id',
                      AuthService().currentUser!,
                    )
                    .select()
                    .maybeSingle();
            if (user != null) {
              print(user['name']);
            }
          }

          // Fetch All Shops
          final response = await getUserShops();

          if (response.isNotEmpty) {
            setShops(response);
          }
        },
      );
    }
    // setRole('Owner');
  }

  Future<int> deleteShop({
    required BuildContext context,
  }) async {
    if (userShops.length < 2) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have only one store. You cannot delete the only store you have.',
            title: 'Action Not Allowed',
          );
        },
      );
      return 0;
    }
    if (userShop()?.isHeadQuarters == true) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You cannot delete you head quarter. Try selecting another store as your head quarter before deleting this one.',
            title: 'Action Not Allowed',
          );
        },
      );
      return 0;
    }
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        var res =
            await supabase
                .from('shops')
                .delete()
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res != null) {
          // ignore: use_build_context_synchronously
          clearAll(context);
          returnNavProvider(
            context,
            listen: false,
          ).navigate(0);
          // var shops = await getUserShops(
          //   AuthService().currentUser!,
          // );
          // setShops(shops);
          // notifyListeners();
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) {
                return Home();
              },
            ),
          );
          return 1;
        } else {
          return 0;
        }
      } catch (e) {
        print("Error Deleting Shop: ${e.toString()}");
        return 0;
      }
    } else {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You must be connected to the internet to be able to delete a shop.',
            title: 'No internet Connection',
          );
        },
      );
      return 0;
    }
  }

  TempUserClass? shopOwnerUser;

  Future<List<TempShopClass>> getUserShops() async {
    bool isOnline = await connectivity.isOnline();

    try {
      if (isOnline) {
        var user =
            await supabase
                .from('users')
                .select()
                .eq(
                  'user_id',
                  AuthService().currentUser ?? '',
                )
                .maybeSingle();

        if (user != null) {
          var tempUser = TempUserClass.fromJson(user);

          List<dynamic> response = [];

          if (tempUser.role == "Owner") {
            response = await supabase
                .from('shops')
                .select()
                .eq('user_id', tempUser.userId ?? '')
                .eq('is_allowed_by_subscription', true);
          } else {
            response = await supabase
                .from('shops')
                .select()
                .contains('employees', [
                  AuthService().currentUser ?? '',
                ])
                .eq('is_allowed_by_subscription', true);
          }

          if (response.isEmpty) {
            return [];
          }

          final shops =
              response
                  .map((res) => TempShopClass.fromJson(res))
                  .toList();

          shops.sort((a, b) {
            final aHQ = a.isHeadQuarters ?? false;
            final bHQ = b.isHeadQuarters ?? false;
            return (bHQ ? 1 : 0).compareTo(aHQ ? 1 : 0);
          });

          await ShopFunc().insertShops(shops);

          setShops(shops);
          notifyListeners();
        }
        var res =
            await supabase
                .from('users')
                .select()
                .eq('user_id', userShop()!.userId)
                .maybeSingle();

        if (res == null) {
          print('Shop Owner not gotten');
        } else {
          // print('Shop Owner Gotten: ${res.toString()}');
          shopOwnerUser = TempUserClass.fromJson(res);
          await ShopOwnerFunc().insertShopOwner(
            ShopOwner(shopOwner: shopOwnerUser!),
          );
          notifyListeners();
        }
      } else {
        /// Offline mode
        print('Gettiing Stores Offline');
        final shops = ShopFunc().getShops();

        shops.sort((a, b) {
          final aHQ = a.isHeadQuarters ?? false;
          final bHQ = b.isHeadQuarters ?? false;
          return (bHQ ? 1 : 0).compareTo(aHQ ? 1 : 0);
        });

        setShops(shops);
        shopOwnerUser =
            ShopOwnerFunc().getShopOwnerUser()?.shopOwner;
      }
      await returnCategoriesProvider().getCategories(
        userShop()!.shopId!,
      );
      notifyListeners();
      return userShops;
    } catch (e) {
      print('Error Getting Stores: ${e.toString()}');
      return [];
    }
  }

  Future<void> setHeadQuarters(TempShopClass shop) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        await supabase
            .from('shops')
            .update({'is_head_quarters': true})
            .eq('shop_id', shop.shopId!)
            .maybeSingle();
        // print('Shop Payment Plan Set: $plan');

        final response = await getUserShops(
          // AuthService().currentUser!,
        );
        if (response.isNotEmpty) {
          setShops(response);
          notifyListeners();
        }
      } catch (e) {
        print(
          '❌ Error Setting Company as head quarter Online: ${e.toString()}',
        );
      }
    } else {
      // List<TempShopClass> shop = ShopFunc().getShops();
      try {
        shop.isHeadQuarters = true;
        shop.updatedAt = DateTime.now();

        ShopFunc().setHeadQuarters(shop);
        UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: shop),
        );
        await getUserShops();
        // setShops(shop);
        notifyListeners();
      } catch (e) {
        print(
          '❌ Error Setting Company as head quarter Offline: ${e.toString()}',
        );
      }
    }
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

        final response = await getUserShops();
        if (response.isNotEmpty) {
          setShops(response);
          notifyListeners();
        }
      } else {
        // TempShopClass? shop = ShopFunc().getShops()[currentIndex];
        userShop()!.printType = type;
        userShop()!.updatedAt = DateTime.now();
        ShopFunc().updateShop(userShop()!);
        UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: userShop()!),
        );
        // setShops(shop);
        notifyListeners();
      }
    } catch (e) {
      print("❌ Failed to update print type: $e");
    }
  }

  Future<void> updateShopContactDetails({
    required int shopId,
    required String name,
    String? email,
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

        final response = await getUserShops();

        if (response.isNotEmpty) {
          setShops(response);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Failed to update contact details: $e");
      }
    } else {
      // TempShopClass? shop = ShopFunc().getShop();
      userShop()!.updatedAt = DateTime.now();
      userShop()!.email = email;
      userShop()!.phoneNumber = phoneNumber;
      userShop()!.name = name;
      await ShopFunc().updateShop(userShop()!);
      userShop() != null
          ? await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: userShop()!),
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

        final response = await getUserShops();

        if (response.isNotEmpty) {
          setShops(response);
          notifyListeners();
        }
      } catch (e) {
        print("❌ Failed to update contact details: $e");
      }
    } else {
      // TempShopClass? shop = ShopFunc().getShop();
      userShop()!.updatedAt = DateTime.now();
      userShop()!.currency = currency;
      await ShopFunc().updateShop(userShop()!);

      if (userShop() != null) {
        await UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: userShop()!),
        );
        // setShop(shop);
        notifyListeners();
      }
    }
  }

  Future<void> updateShopLocation({
    // required int shopId,
    required String country,
    required String state,
    required String city,
    required String? address,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      print("userShop(): ${userShop()?.name}");
      print("shopId: ${userShop()?.shopId}");
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
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        print("✅ Updated response: $response");
        final shop = await getUserShops();

        if (response != null && response.isNotEmpty) {
          setShops(shop);
          // userShops[ind] = TempShopClass.fromJson(response);
          notifyListeners();
        } else {
          print('No Shop Found');
        }
      } catch (e, stack) {
        print("❌ Failed to update location: $e");
        print(stack);
      }
    } else {
      // TempShopClass? shop = ShopFunc().getShop();
      userShop()!.updatedAt = DateTime.now();
      userShop()!.country = country;
      userShop()!.state = state;
      userShop()!.city = city;
      userShop()!.shopAddress = address;
      await ShopFunc().updateShop(userShop()!);
      if (userShop() != null) {
        await UpdatedShopFunc().createUpdatedShop(
          UpdatedShop(shop: userShop()!),
        );
        // setShop(shop);
        notifyListeners();
      }
    }
  }

  Future<void> addEmployeeToShop({
    required String newEmployeeId,
    required String role,
    required BuildContext context,
  }) async {
    try {
      if (role != 'Owner') {
        final response =
            await supabase
                .from('shops')
                .select('employees')
                .eq('shop_id', userShop()!.shopId!)
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
        } else {
          return;
        }

        // Step 3: Update the shop's employees field
        final updateResponse = await supabase
            .from('shops')
            .update({'employees': currentEmployees})
            .eq('shop_id', userShop()!.shopId!);

        if (updateResponse != null) {
          print('Failed to update shop: $updateResponse');
        } else {
          print('Employee added successfully.');
        }
      } else {
        var res =
            await supabase
                .from('shops')
                .update({'user_id': newEmployeeId})
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();

        if (res == null) {
          print('Shop not found');
          return;
        }
        print('Shop Owner Added Successfully');

        var userRes =
            await supabase
                .from('users')
                .select()
                .eq('user_id', newEmployeeId)
                .maybeSingle();
        if (userRes == null) {
          print('User not found');
          return;
        }
        var currUser = TempUserClass.fromJson(userRes);

        Map<String, dynamic>? subRes =
            await supabase
                .from('subscription')
                .update({
                  'user_id': newEmployeeId,
                  'user_name':
                      '${currUser.name} ${currUser.lastName ?? ''}',
                })
                .eq(
                  'subscription_id',
                  returnSubcsription(
                    context,
                    listen: false,
                  ).subscription!.subscriptionId!,
                )
                .select()
                .maybeSingle();
        if (subRes == null) {
          print('Subscription User Id Failed');
          return;
        }
        print('Subscription Update Success');
      }
    } catch (e) {
      print('An Error occurred: $e');
    }
  }

  Future<void> removeEmployeeFromShop({
    required String employeeIdToRemove,
    required BuildContext context,
  }) async {
    try {
      // Step 1: Get the current list of employees
      final response =
          await supabase
              .from('shops')
              .select('employees')
              .eq('shop_id', userShop()!.shopId!)
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
          .eq('shop_id', userShop()!.shopId!);

      if (updateResponse != null) {
        print('Failed to update shop: $updateResponse');
      } else {
        print('Employee removed successfully.');
        try {
          var res =
              await supabase
                  .from('users')
                  .update({'department_uuids': []})
                  .eq('user_id', employeeIdToRemove)
                  .select()
                  .maybeSingle();
          if (res != null) {
            var newRes = TempUserClass.fromJson(res);
            print('Staff Department updated Successfully');
            print(newRes.departmentUuids?.length);
          }
        } catch (e) {
          print(
            'Staff Department Updated Failed: ${e.toString()}',
          );
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  List<TempShopClass> userShops = [];

  Future<void> selectShop(
    BuildContext context,
    TempShopClass shopC,
  ) async {
    var isOnline = await connectivity.isOnline();
    // ignore: use_build_context_synchronously
    if (returnData().isSynced() == 0 && isOnline) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'You have unsynced data. Synchronize data to proceed.',
            title: 'Unsynced Records Detected.',
          );
        },
      );
      // ignore: use_build_context_synchronously
      returnData().syncData(context);
    } else {
      try {
        var safeContext = context;
        print('Shop Selection Started');
        // await returnData(
        //   context,
        //   listen: false,
        // ).clearTotalCache();
        // print('Total Cache Cleared');
        var res = await CurrentShopFunc().createCurrentShop(
          TempCurrentShop(currentShopId: shopC.shopId!),
        );
        if (res == 1) {
          print(
            'Current Shop set: ${CurrentShopFunc().getCurrentShop()?.currentShopId}',
          );
          // ignore: use_build_context_synchronously
          clearAll(safeContext);
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            safeContext,
            MaterialPageRoute(
              builder: (context) {
                return BasePage();
              },
            ),
          );
          print('Navigated');
          notifyListeners();
        } else {
          print('Shop Selection Failed');
          notifyListeners();
        }
      } catch (e) {
        print('❌❌ Select Shop Error: ${e.toString()}');
      }
    }
  }

  void clearAll(BuildContext context) {
    returnCustomers(
      context,
      listen: false,
    ).clearCustomers();
    returnData().clearProducts();
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenses();
    returnNotificationProvider(
      context,
      listen: false,
    ).clearNotifications();
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceipts();
    returnReceiptProvider(
      context,
      listen: false,
    ).load(false);
    returnSalesProvider().clearCart();
    returnShopProvider().clearShop();
    returnUserProvider(context, listen: false).clearUsers();
  }

  TempShopClass? userShop() {
    var offlineShop = CurrentShopFunc().getCurrentShop();
    if (offlineShop != null) {
      try {
        var shops = userShops.where(
          (shop) =>
              shop.shopId == offlineShop.currentShopId,
        );
        return shops.isEmpty ? null : shops.first;
      } catch (e) {
        print('Error With Shop First: ${e.toString()}');
        return null;
      }
    } else {
      if (userShops.isNotEmpty) {
        try {
          CurrentShopFunc().createCurrentShop(
            TempCurrentShop(
              currentShopId:
                  userShops
                      .where(
                        (shop) =>
                            shop.isHeadQuarters == true,
                      )
                      .first
                      .shopId!,
            ),
          );
          var shops = userShops.where(
            (shop) => shop.isHeadQuarters == true,
          );
          return shops.isEmpty ? null : shops.first;
        } catch (e) {
          print('Error With Shop Second: ${e.toString()}');
          return null;
        }
      } else {
        return null;
      }
    }
  }

  double getVat() {
    if (userShop()?.applyVAT == true) {
      return vat;
    } else {
      return 0;
    }
  }

  void clearShop() {
    userShops.clear();
    notifyListeners();
  }

  void setState() {
    notifyListeners();
  }

  void setShops(List<TempShopClass> shops) {
    userShops = shops;
    var localShop = CurrentShopFunc().getCurrentShop();
    if (shops
        .where(
          (sh) => sh.shopId == localShop?.currentShopId,
        )
        .toList()
        .isEmpty) {
      CurrentShopFunc().createCurrentShop(
        TempCurrentShop(currentShopId: shops.first.shopId!),
      );
    }
    notifyListeners();
  }

  bool isVatLoading = false;

  Future<int> toggleApplyVAT() async {
    bool isOnline = await connectivity.isOnline();
    isVatLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'apply_vat': !userShop()!.applyVAT!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('VAT Update Failed');
          isVatLoading = false;
          notifyListeners();
          return 0;
        }

        var shops = await getUserShops();
        setShops(shops);
        isVatLoading = false;
        notifyListeners();
        return 1;
      } else {
        try {
          userShop()!.updatedAt = DateTime.now();
          userShop()!.applyVAT = !userShop()!.applyVAT!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          isVatLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Apply VAT Offline: ${e.toString()}",
          );
          isVatLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print("❌ Failed to Apply VAT: ${e.toString()}");
      isVatLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool isWholeSaleLoading = false;

  Future<int> toggleWholeSale() async {
    bool isOnline = await connectivity.isOnline();
    isWholeSaleLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'whole_sale': !userShop()!.wholeSale!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Whole Sale Update Failed');
          isWholeSaleLoading = false;
          notifyListeners();
          return 0;
        }

        var shops = await getUserShops();
        setShops(shops);
        isWholeSaleLoading = false;
        notifyListeners();
        return 1;
      } else {
        try {
          userShop()!.updatedAt = DateTime.now();
          userShop()!.wholeSale = !userShop()!.wholeSale!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            notifyListeners();
          }
          isWholeSaleLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Toggle Whole Sale Offline: ${e.toString()}",
          );
          isWholeSaleLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Toggle Whole Sale: ${e.toString()}",
      );
      isWholeSaleLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool ismanageInventoryStorageLoading = false;

  Future<int> togglemanageInventoryStorage() async {
    bool isOnline = await connectivity.isOnline();
    ismanageInventoryStorageLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'manage_inventory_storage':
                      !userShop()!.manageInventoryStorage!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Manage Inventory Storage Update Failed');
          ismanageInventoryStorageLoading = false;
          notifyListeners();
          return 0;
        }

        var shops = await getUserShops();
        setShops(shops);
        ismanageInventoryStorageLoading = false;
        notifyListeners();
        return 1;
      } else {
        try {
          userShop()!.updatedAt = DateTime.now();
          userShop()!.manageInventoryStorage =
              !userShop()!.manageInventoryStorage!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          ismanageInventoryStorageLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Manage Inventory Storage Offline: ${e.toString()}",
          );
          ismanageInventoryStorageLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Manage Inventory Storage: ${e.toString()}",
      );
      ismanageInventoryStorageLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool isUseGroupUnitLoading = false;

  Future<int> toggleUseGroupUnit() async {
    bool isOnline = await connectivity.isOnline();
    isUseGroupUnitLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'use_group_unit':
                      !userShop()!.useGroupUnit!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Use Group Unit Update Failed');
          isUseGroupUnitLoading = false;
          notifyListeners();
          return 0;
        }

        var shops = await getUserShops();
        setShops(shops);
        isUseGroupUnitLoading = false;
        notifyListeners();
        return 1;
      } else {
        try {
          userShop()!.updatedAt = DateTime.now();
          userShop()!.useGroupUnit =
              !userShop()!.useGroupUnit!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          isUseGroupUnitLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Use Group Unit Offline: ${e.toString()}",
          );
          isUseGroupUnitLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Use Group Unit: ${e.toString()}",
      );
      isUseGroupUnitLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool allowBulkSale = false;

  Future<int> toggleAllowBulkSale() async {
    bool isOnline = await connectivity.isOnline();
    allowBulkSale = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'bulk_sale': !userShop()!.bulkSale!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Toggle Bulk Sale Update Failed');
          allowBulkSale = false;
          notifyListeners();
          return 0;
        }

        var shops = await getUserShops();
        setShops(shops);
        allowBulkSale = false;
        returnSalesProvider().selectFistMainCart();
        notifyListeners();
        return 1;
      } else {
        try {
          userShop()!.updatedAt = DateTime.now();
          userShop()!.bulkSale = !userShop()!.bulkSale!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          allowBulkSale = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Toggle Bulk Sale Offline: ${e.toString()}",
          );
          allowBulkSale = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Toggle Bulk Sale: ${e.toString()}",
      );
      allowBulkSale = false;
      notifyListeners();
      return 0;
    }
  }

  bool manageDepartmentsLoading = false;

  Future<int> toggleManageDepartments() async {
    bool isOnline = await connectivity.isOnline();
    manageDepartmentsLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'manage_departments':
                      !userShop()!.manageDepartments!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Manage Departments Update Failed');
          manageDepartmentsLoading = false;
          notifyListeners();
          return 0;
        }

        if (userShop()!.manageDepartments!) {
          await returnDepartmentProvider()
              .clearDepartments();
        }
        var shops = await getUserShops();
        setShops(shops);
        manageDepartmentsLoading = false;
        // returnSalesProvider().selectFistMainCart();
        notifyListeners();
        return 1;
      } else {
        try {
          if (userShop()!.manageDepartments!) {
            await returnDepartmentProvider()
                .clearDepartments();
          }
          userShop()!.updatedAt = DateTime.now();
          userShop()!.manageDepartments =
              !userShop()!.manageDepartments!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          manageDepartmentsLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Manage Departments Offline: ${e.toString()}",
          );
          manageDepartmentsLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Manage Departments: ${e.toString()}",
      );
      manageDepartmentsLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool isSetCloseSaleTimeLoading = false;

  Future<int> setCloseSaleTime({TimeOfDay? time}) async {
    bool isOnline = await connectivity.isOnline();
    isSetCloseSaleTimeLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'close_sale_time': timeOfDayToPostgres(
                    time,
                  ),
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Close Sale Update Failed');
          isSetCloseSaleTimeLoading = false;
          notifyListeners();
          return 0;
        }

        // if (userShop()!.useCloseSale!) {
        //   returnDepartmentProvider().selectDepartment();
        // }
        var shops = await getUserShops();
        setShops(shops);
        isSetCloseSaleTimeLoading = false;
        // returnSalesProvider().selectFistMainCart();
        notifyListeners();
        return 1;
      } else {
        try {
          // if (userShop()!.useCloseSale!) {
          //   returnDepartmentProvider().selectDepartment();
          // }
          userShop()!.updatedAt = DateTime.now();
          userShop()!.closeSaleTimeString =
              time != null
                  ? timeOfDayToPostgres(time)
                  : null;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          isSetCloseSaleTimeLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Close Sale Offline: ${e.toString()}",
          );
          isSetCloseSaleTimeLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Close Sale: ${e.toString()}",
      );
      isSetCloseSaleTimeLoading = false;
      notifyListeners();
      return 0;
    }
  }

  bool printSalesDocketLoading = false;

  Future<int> togglePrintSalesDocket() async {
    bool isOnline = await connectivity.isOnline();
    printSalesDocketLoading = true;
    notifyListeners();
    try {
      if (isOnline) {
        Map<String, dynamic>? res =
            await supabase
                .from('shops')
                .update({
                  'print_sales_docket':
                      !userShop()!.printSalesDocket!,
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res == null) {
          print('Print Sales Docket Update Failed');
          printSalesDocketLoading = false;
          notifyListeners();
          return 0;
        }

        // if (userShop()!.printSalesDocket!) {
        //   returnDepartmentProvider().selectDepartment();
        // }
        var shops = await getUserShops();
        setShops(shops);
        printSalesDocketLoading = false;
        // returnSalesProvider().selectFistMainCart();
        notifyListeners();
        return 1;
      } else {
        try {
          // if (userShop()!.manageDepartments!) {
          //   returnDepartmentProvider().selectDepartment();
          // }
          userShop()!.updatedAt = DateTime.now();
          userShop()!.printSalesDocket =
              !userShop()!.printSalesDocket!;
          await ShopFunc().updateShop(userShop()!);
          if (userShop() != null) {
            await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            );
            // setShops(shop);
            notifyListeners();
          }
          printSalesDocketLoading = false;
          notifyListeners();
          return 1;
        } catch (e) {
          print(
            "❌ Failed to Update Print Sales Docket Offline: ${e.toString()}",
          );
          printSalesDocketLoading = false;
          notifyListeners();
          return 0;
        }
      }
    } catch (e) {
      print(
        "❌ Failed to Update Print Sales Docket: ${e.toString()}",
      );
      printSalesDocketLoading = false;
      notifyListeners();
      return 0;
    }
  }

  String name = '';
  String country = '';
  String? email;
  String? phone;
  String state = '';
  String city = '';
  String address = '';
  String tempRole = '';

  void setRole(String newRole) {
    tempRole = newRole;
    notifyListeners();
  }

  List<String> roles = ['Owner', 'General Manager'];

  double? generalPercentDiscount;
  double? generalFixedDiscount;

  int discountIndex = 0;

  double? currentDiscount() {
    return userShop()!.fixedDiscount ??
        userShop()!.percentDiscount;
  }

  void switchDiscountIndex(int index) {
    discountIndex = index;
    notifyListeners();
  }

  void clearDiscountsCache() {
    generalPercentDiscount = null;
    generalFixedDiscount = null;
    notifyListeners();
  }

  void setGeneralPercentageDiscountCache(double? discount) {
    generalPercentDiscount = discount;
    generalFixedDiscount = null;
    notifyListeners();
  }

  void setGeneralFixedDiscountCache(double? discount) {
    generalPercentDiscount = null;
    generalFixedDiscount = discount;
    notifyListeners();
  }

  Future<void> setFixedDiscount({double? discount}) async {
    var isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        var res =
            await supabase
                .from('shops')
                .update({
                  'fixed_discount': discount?.toDouble(),
                  'percent_discount': null,
                  'updated_at':
                      DateTime.now().toIso8601String(),
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res != null) {
          var shops = await getUserShops();
          setShops(shops);
        }
      } catch (e) {
        print(
          '❌❌ Error Updating Fixed Discount Online: ${e.toString()}',
        );
      }
    } else {
      try {
        // TempShopClass? shop = ShopFunc().getShop();
        userShop()!.updatedAt = DateTime.now();
        userShop()!.fixedDiscount = discount?.toDouble();
        userShop()!.percentDiscount = null;
        await ShopFunc().updateShop(userShop()!);
        if (userShop() != null) {
          await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: userShop()!),
          );
          // setShops(shop);
          notifyListeners();
        }
      } catch (e) {
        print(
          "❌ Failed to Set Fixed Discount Offline: ${e.toString()}",
        );
      }
    }
  }

  Future<void> setPercentDiscount({
    double? discount,
  }) async {
    var isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        var res =
            await supabase
                .from('shops')
                .update({
                  'fixed_discount': null,
                  'percent_discount': discount?.toDouble(),
                  'updated_at':
                      DateTime.now().toIso8601String(),
                })
                .eq('shop_id', userShop()!.shopId!)
                .select()
                .maybeSingle();
        if (res != null) {
          var shops = await getUserShops();
          setShops(shops);
        }
        clearDiscountsCache();
      } catch (e) {
        print(
          '❌❌ Error Updating Percentage Discount Online: ${e.toString()}',
        );
      }
    } else {
      try {
        // TempShopClass? shop = ShopFunc().getShop();
        userShop()!.updatedAt = DateTime.now();
        userShop()!.fixedDiscount = null;
        userShop()!.percentDiscount = discount?.toDouble();
        await ShopFunc().updateShop(userShop()!);
        if (userShop() != null) {
          await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: userShop()!),
          );
          // setShops(shop);
          notifyListeners();
        }
        clearDiscountsCache();
      } catch (e) {
        print(
          "❌ Failed to Set Percentage Discount Offline: ${e.toString()}",
        );
      }
    }
  }

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
          await getUserShops();
        }
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }
  }

  //
  //
  //

  Future<void> uploadShopLogoSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
        CreatedShopLogosFunc().getCreatedLogo().toString(),
      );

      if (CreatedShopLogosFunc().getCreatedLogo() != null &&
          isOnline) {
        final createdLogo =
            CreatedShopLogosFunc().getCreatedLogo();
        var filePath = createdLogo!.imageName;
        var imageBytes = base64Decode(createdLogo.logoPath);
        var mimeType = "image/${filePath.split('.').last}";

        try {
          await supabase.storage
              .from('logos')
              .uploadBinary(
                filePath,
                imageBytes,
                fileOptions: FileOptions(
                  contentType: mimeType,
                ),
              );

          final String publicUrl = supabase.storage
              .from('logos')
              .getPublicUrl(filePath);

          await supabase
              .from('shops')
              .update({
                'logo_url': publicUrl,
                'image_height': imageHeight,
                'image_width': imageWidth,
              })
              .eq('shop_id', userShop()!.shopId!);
          userShop()!.logoUrl = publicUrl;
          userShop()!.imageHeight = imageHeight;
          userShop()!.imageWidth = imageWidth;
          notifyListeners();
          print(
            '✅  Online Logo uploaded and saved successfully!',
          );
          await ShopLogosFunc().createLogo(
            TempShopLogos(
              logoPath: base64Encode(imageBytes),
              imageName: filePath,
              imageHeight: imageHeight!,
              imageWidth: imageWidth!,
            ),
            // ignore: use_build_context_synchronously
            context,
          );
        } catch (e) {
          print('❌ Error Syncing logo: $e');
        }

        await CreatedShopLogosFunc().clearCreatedLogos();
        print('Unsynced updated Shop Logo cleared');
        if (context.mounted) {
          print('Mounted, refreshing Shop ✅');
          await getUserShops();
        }
      }
    } catch (e) {
      print('Logo Sync failed ❌: $e');
    }
  }

  //
  //
  //
  //

  void setBottomText(String newText) {
    userShop()!.bottomText = newText;
    notifyListeners();
  }

  void resetBottomText() {
    userShop()!.bottomText = null;
    notifyListeners();
  }

  void showEmailAction() {
    userShop()!.showEmail = !userShop()!.showEmail!;
    notifyListeners();
  }

  void showShopNameAction() {
    userShop()!.showShopName = !userShop()!.showShopName!;
    notifyListeners();
  }

  void showAddressAction() {
    userShop()!.showAddress = !userShop()!.showAddress!;
    notifyListeners();
  }

  void showPhoneAction() {
    userShop()!.showPhone = !userShop()!.showPhone!;
    notifyListeners();
  }

  void showFirstSectionAction() {
    userShop()!.showFirst = !userShop()!.showFirst!;
    notifyListeners();
  }

  void showSecondSectionAction() {
    userShop()!.showSecond = !userShop()!.showSecond!;
    notifyListeners();
  }

  void showThirdSectionAction() {
    userShop()!.showThird = !userShop()!.showThird!;
    notifyListeners();
  }

  void showInstaDownAction() {
    userShop()!.showInstaDown = !userShop()!.showInstaDown!;
    notifyListeners();
  }

  void showInstaTopAction() {
    userShop()!.showInstaTop = !userShop()!.showInstaTop!;
    notifyListeners();
  }

  void showFacebookDownAction() {
    userShop()!.showFacebookDown =
        !userShop()!.showFacebookDown!;
    notifyListeners();
  }

  void showFacebookTopAction() {
    userShop()!.showFacebookTop =
        !userShop()!.showFacebookTop!;
    notifyListeners();
  }

  Future<String> updateShopPrintDetails(
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (logoPicked && selectedLogo != null) {
      try {
        var res = await uploadLogo(
          image: rawImage!,
          // ignore: use_build_context_synchronously
          context: context,
        );
        if (res != 'success') {
          print(res);
          return res;
        }
      } catch (e) {
        print('Error: ${e.toString()}');
        return e.toString();
      }
    }
    if (selectedLogo == null) {
      userShop()!.logoUrl = null;
      userShop()!.imageHeight = null;
      userShop()!.imageWidth = null;
      await ShopLogosFunc().clearLogos();
      await CreatedShopLogosFunc().clearCreatedLogos();
      notifyListeners();
    }
    if (isOnline) {
      userShop()!.updatedAt = DateTime.now();
      try {
        var resp =
            await supabase
                .from('shops')
                .update(userShop()!.toJson())
                .eq('shop_id', userShop()!.shopId!)
                .maybeSingle();
        if (resp == null) {}

        final response = await getUserShops();

        if (response.isNotEmpty) {
          setShops(response);
          notifyListeners();
        }
        return 'success';
      } catch (e) {
        print(
          "❌ Failed to update Print Details Online: $e",
        );
        clearImage();
        return e.toString();
      }
    } else {
      try {
        // TempShopClass? shop = ShopFunc().getShops();
        if (userShop() != null) {
          userShop()!.updatedAt = DateTime.now();
          await ShopFunc().updateShop(userShop()!);
        }
        userShop() != null
            ? await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: userShop()!),
            )
            : {};
        return 'success';
      } catch (e) {
        print(
          "❌ Failed to update Print Details Offline: $e",
        );
        clearImage();
        return e.toString();
      }
    }
  }

  Future<int> updateShopSocials({
    required String? face,
    required String? insta,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      try {
        final response =
            await supabase
                .from('shops')
                .update({
                  'insta_handle': insta,
                  'facebook_handle': face,
                  'updated_at':
                      DateTime.now().toIso8601String(),
                })
                .eq('shop_id', userShop()!.shopId!)
                .maybeSingle();
        final shop = await getUserShops();

        if (response != null) {
          setShops(shop);
          notifyListeners();
        }
        return 1;
      } catch (e) {
        print("❌ Failed to update location Online: $e");
        return 0;
      }
    } else {
      try {
        // TempShopClass? shop = ShopFunc().getShop();
        userShop()!.updatedAt = DateTime.now();
        userShop()!.instaHandle = insta;
        userShop()!.faceBookHandle = face;
        await ShopFunc().updateShop(userShop()!);
        if (userShop() != null) {
          await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: userShop()!),
          );
          // setShops(shop);
          notifyListeners();
        }
        return 1;
      } catch (e) {
        print("❌ Failed to update location Offline: $e");
        return 0;
      }
    }
  }

  Future<Uint8List?> fetchImageBytes(
    String imageUrl,
  ) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print(
          '⚠️ Failed to load image: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print('❌ Error fetching image bytes: $e');
      return null;
    }
  }

  Future<ui.Image> getImageInfo(
    Uint8List imageBytes,
  ) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(imageBytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  final ImagePicker _picker = ImagePicker();
  Uint8List? selectedLogo;
  XFile? rawImage;
  // String? imageName;
  int? imageWidth;
  int? imageHeight;

  void clearImage() {
    selectedLogo = null;
    imageWidth = null;
    imageHeight = null;
    rawImage = null;
    print('Image Cleared');
    notifyListeners();
  }

  bool logoPicked = false;

  void switchLogoPicked(bool value) {
    logoPicked = value;
    print(
      "Logo Picked Value is Now: ${logoPicked.toString()}",
    );
    notifyListeners();
  }

  Future<XFile?> pickLogoImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (image == null) {
        print('No image selected.');
        return null;
      }

      final Uint8List imageBytes =
          await image.readAsBytes();

      final imageSize = await getImageInfo(imageBytes);

      imageWidth = imageSize.width;
      imageHeight = imageSize.height;
      selectedLogo = imageBytes;
      rawImage = image;
      print(
        'Image selected: ${image.name} (${imageBytes.length} $imageHeight x $imageWidth bytes)',
      );
      switchLogoPicked(true);
      notifyListeners();
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  Future<Uint8List?> getLogoImage(
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();

    if (isOnline) {
      try {
        await getUserShops();
        notifyListeners();
        final logoUrl = userShop()!.logoUrl;
        if (logoUrl == null ||
            userShop()!.imageHeight == null ||
            userShop()!.imageWidth == null) {
          // clearImage();
          return null;
        }

        final onlineBytes = await fetchImageBytes(logoUrl);

        if (onlineBytes != null) {
          await ShopLogosFunc().createLogo(
            TempShopLogos(
              logoPath: base64Encode(onlineBytes),
              imageName: logoUrl,
              imageHeight: userShop()!.imageHeight!,
              imageWidth: userShop()!.imageWidth!,
            ),
            // ignore: use_build_context_synchronously
            context,
          );
        }
        selectedLogo = onlineBytes;
        imageHeight = userShop()!.imageHeight;
        imageWidth = userShop()!.imageWidth;
        // imag
        notifyListeners();
        return onlineBytes;
      } catch (e) {
        print('❌❌ Get Logo Error: ${e.toString()}');
        // clearImage();
        return null;
      }
    } else {
      try {
        await getUserShops();
        var logo = ShopLogosFunc().getLogo();
        if (logo == null) {
          // clearImage();
          notifyListeners();
          return null;
        } else {
          var imageBytes = base64Decode(logo.logoPath);
          selectedLogo = imageBytes;
          imageHeight = userShop()!.imageHeight;
          imageWidth = userShop()!.imageWidth;
          notifyListeners();
          return imageBytes;
        }
      } catch (e) {
        print('❌❌ Get Logo Offline Error: ${e.toString()}');
        // clearImage();
        return null;
      }
    }
  }

  Future<String> uploadLogo({
    required XFile image,
    required BuildContext context,
  }) async {
    final bool isOnline = await connectivity.isOnline();
    final imageBytes = await image.readAsBytes();
    final String ext =
        image.name.split('.').last.toLowerCase();

    final String mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };

    final String filePath =
        'logos/${userShop()!.shopId!}-${DateTime.now().millisecondsSinceEpoch}.$ext';
    if (isOnline) {
      try {
        await supabase.storage
            .from('logos')
            .uploadBinary(
              filePath,
              imageBytes,
              fileOptions: FileOptions(
                contentType: mimeType,
              ),
            );

        final String publicUrl = supabase.storage
            .from('logos')
            .getPublicUrl(filePath);

        await supabase
            .from('shops')
            .update({
              'logo_url': publicUrl,
              'image_height': imageHeight,
              'image_width': imageWidth,
            })
            .eq('shop_id', userShop()!.shopId!);
        userShop()!.logoUrl = publicUrl;
        userShop()!.imageHeight = imageHeight;
        userShop()!.imageWidth = imageWidth;
        notifyListeners();
        print(
          '✅  Online Logo uploaded and saved successfully!',
        );
        await ShopLogosFunc().createLogo(
          TempShopLogos(
            logoPath: base64Encode(imageBytes),
            imageName: filePath,
            imageHeight: imageHeight!,
            imageWidth: imageWidth!,
          ),
          // ignore: use_build_context_synchronously
          context,
        );
        return 'success';
      } catch (e) {
        print('❌ Error uploading logo: $e');
        clearImage();
        return 'Error uploading logo: The File extension type you selected is not Support. Please Select .jpeg, .jpg, or .png images.';
      }
    } else {
      try {
        await ShopLogosFunc().createLogo(
          TempShopLogos(
            logoPath: base64Encode(imageBytes),
            imageName: filePath,
            imageHeight: imageHeight!,
            imageWidth: imageWidth!,
          ),
          // ignore: use_build_context_synchronously
          context,
        );
        await CreatedShopLogosFunc().createCreatedShopLogo(
          TempShopLogos(
            logoPath: base64Encode(imageBytes),
            imageName: filePath,
            imageHeight: imageHeight!,
            imageWidth: imageWidth!,
          ),
          context,
        );
        // userShop()!.logoUrl = publicUrl;
        userShop()!.imageHeight = imageHeight;
        userShop()!.imageWidth = imageWidth;
        notifyListeners();
        print(
          '✅  Offline Logo uploaded and saved successfully!',
        );
        return 'success';
      } catch (e) {
        print(
          '❌❌ Upload Logo Offline Error: ${e.toString()}',
        );
        clearImage();
        return 'Error uploading logo: The File extension type you selected is not Support. Please Select .jpeg, .jpg, or .png images.';
      }
    }
  }

  TempBarcodePrinterClass? printerCache;

  void setPrinterCache() {
    printerCache =
        BarcodePrinterLocalFunc()
            .getbarcodePrinterLocal()
            ?.printer;
  }

  PrinterSettings? printerSettings;

  PriceTagPrinterSettings? priceTagPrinterSettings;

  PriceAndBarcodePrinterSettings?
  priceAndBarcodePrinterSettings;

  void setPrinterSettingsCache() {
    printerSettings =
        BarcodePrinterLocalFunc()
            .getbarcodePrinterLocal()
            ?.settings ??
        PrinterSettings(
          widthMm: defaultPrinterSettings.widthMm,
          heightMm: defaultPrinterSettings.heightMm,
          startX: defaultPrinterSettings.startX,
          startY: defaultPrinterSettings.startY,
          gapMm: defaultPrinterSettings.gapMm,
          barcodeHeight:
              defaultPrinterSettings.barcodeHeight,
          barcodeScale: defaultPrinterSettings.barcodeScale,
          verticalSpacing:
              defaultPrinterSettings.verticalSpacing,
        );

    priceTagPrinterSettings =
        PriceTagPrinterFunc()
            .getPriceTagPrinterLocal()
            ?.settings ??
        defaultPriceTagPrinterSettings;

    priceAndBarcodePrinterSettings =
        PriceAndBarcodePrinterLocalFunc()
            .getpriceAndBarcodePrinterLocal()
            ?.settings ??
        defaultPriceAndBarcodePrinterSettings;
  }

  // void setPrinterSettingsCacheInit() {
  //   printerSettings =
  //       BarcodePrinterLocalFunc()
  //           .getbarcodePrinterLocal()
  //           ?.settings ??
  //       defaultPrinterSettings;
  //   // notifyListeners();
  // }

  PrinterSettings defaultPrinterSettings = PrinterSettings(
    widthMm: 58,
    heightMm: 25,
    startX: 25,
    startY: 65,
    gapMm: 2,
    barcodeHeight: 70,
    barcodeScale: 3,
    verticalSpacing: 10,
  );

  PriceAndBarcodePrinterSettings
  defaultPriceAndBarcodePrinterSettings =
      PriceAndBarcodePrinterSettings(
        widthMm: 58,
        heightMm: 25,
        startX: 25,
        startY: 55,
        gapMm: 2,
        barcodeHeight: 70,
        barcodeScale: 3,
        verticalSpacing: 10,
      );

  PriceTagPrinterSettings defaultPriceTagPrinterSettings =
      PriceTagPrinterSettings(
        startPriceY: 90,
        labelWidth: 58,
        gapMm: 2,
        verticalSpacing: 20,
      );

  bool isDesktop() {
    if (!kIsWeb) {
      if (Platform.isLinux ||
          Platform.isMacOS ||
          Platform.isWindows) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<void> updatePrinterSettings(
    PrinterSettings newSettings,
    PriceTagPrinterSettings priceNewSettings,
    PriceAndBarcodePrinterSettings
    priceAndBarcodePrinterSettingsNew,
  ) async {
    if (isDesktop()) {
      await BarcodePrinterLocalFunc().insertbarcodePrinter(
        BarcodePrinterLocal(
          printer: printerCache!,
          settings: newSettings,
        ),
      );
      await PriceTagPrinterFunc().insertPriceTagPrinter(
        PriceTagPrinterLocal(
          printer: printerCache!,
          settings: priceNewSettings,
        ),
      );
      await PriceAndBarcodePrinterLocalFunc()
          .insertpriceBarcodeAndPrinter(
            PriceAndBarcodePrinterLocal(
              printer: printerCache!,
              settings: priceAndBarcodePrinterSettingsNew,
            ),
          );
      printerSettings = newSettings;
      priceTagPrinterSettings = priceNewSettings;
      priceAndBarcodePrinterSettings =
          priceAndBarcodePrinterSettingsNew;
      notifyListeners();
    }
  }

  List<TempBarcodePrinterClass> printers = [];

  void listPrintersSub(TempBarcodePrinterClass printer) {
    printers.add(printer);
    // notifyListeners();
  }

  void clearPrinters() {
    printers.clear();
    // notifyListeners();
  }

  Future<void> selectPrinter(
    TempBarcodePrinterClass newPrinter,
    BuildContext context,
  ) async {
    if (isDesktop()) {
      showDialog(
        context: context,
        builder: (confirmDialog) {
          return ConfirmationAlert(
            theme: returnTheme(context, listen: false),
            message:
                'This printer will be automatically used to print all your subsiquent barcodes, unless if you select another.',
            title: 'Select Printer?',
            action: () {
              Navigator.of(confirmDialog).pop();
              if (BarcodePrinterLocalFunc()
                      .getbarcodePrinterLocal() ==
                  null) {
                BarcodePrinterLocalFunc()
                    .insertbarcodePrinter(
                      BarcodePrinterLocal(
                        printer: newPrinter,
                        settings: defaultPrinterSettings,
                      ),
                    );
              } else {
                BarcodePrinterLocalFunc()
                    .insertbarcodePrinter(
                      BarcodePrinterLocal(
                        printer: newPrinter,
                        settings: printerSettings!,
                      ),
                    );
              }
              printerCache = newPrinter;
              notifyListeners();
            },
          );
        },
      );
    }
  }
}
