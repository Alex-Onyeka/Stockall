import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/temp_shop/unsynced/updated_shop.dart';
import 'package:stockall/classes/temp_shop_logos/temp_shop_logos.dart';
import 'package:stockall/local_database/shop/shop_func.dart';
import 'package:stockall/local_database/shop/updated_shop/updated_shop_func.dart';
import 'package:stockall/local_database/shop_logos/created_shop_logo/created_shop_logos_func.dart';
import 'package:stockall/local_database/shop_logos/shop_logos_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

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

  Future<List<TempShopClass>> getAllUserShops(
    String userId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final response = await supabase
          .from('shops')
          .select()
          .eq('user_id', userId);

      // if (response == null) {
      //   // await ShopFunc().clearShop();
      //   print('User Shop not found');
      //   return null;
      // }
      print('User Shop Branches found ${response.length}');
      addShopBranch(
        response
            .map((res) => TempShopClass.fromJson(res))
            .toList(),
      );
      notifyListeners();
      await ShopFunc().insertAllShopBranches(
        response
            .map((res) => TempShopClass.fromJson(res))
            .toList(),
      );
    } else {
      addShopBranch(ShopFunc().getAllShopBranches());
    }
    notifyListeners();

    return shopBranches;
  }

  Future<void> makePayment(DateTime date, int plan) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('shops')
          .update({
            'next_payment': date.toIso8601String(),
            'plan': plan,
          })
          .eq('shop_id', userShop!.shopId!)
          .maybeSingle();
      print(
        'Shop Next Payment date Set: ${date.toString()} and Plan Set: $plan',
      );

      final response = await getUserShop(
        AuthService().currentUser!,
      );
      if (response != null) {
        setShop(response);
        notifyListeners();
      }
    } else {
      print('Next Payment cant be set offline');
    }
  }

  // Future<void> setShopPaymentPlan(int plan) async {
  //   bool isOnline = await connectivity.isOnline();
  //   if (isOnline) {
  //     await supabase
  //         .from('shops')
  //         .update({'plan': plan})
  //         .eq('shop_id', userShop!.shopId!)
  //         .maybeSingle();
  //     print('Shop Payment Plan Set: $plan');

  //     final response = await getUserShop(
  //       AuthService().currentUser!,
  //     );
  //     if (response != null) {
  //       setShop(response);
  //       notifyListeners();
  //     }
  //   } else {
  //     print('Next Payment cant be set offline');
  //   }
  // }

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

  // TempShopClass? userShop;

  List<TempShopClass> shopBranches = [];

  void addShopBranch(List<TempShopClass> shop) {
    shopBranches.addAll(shop);
    notifyListeners();
  }

  int currentIndex = 0;

  TempShopClass? currentShop() {
    return shopBranches.isEmpty
        ? null
        : shopBranches[currentIndex];
  }

  void clearShop() {
    // userShop = null;
    shopBranches.clear();
    notifyListeners();
  }

  void setCurrentShop(int index) {
    currentIndex = index;
    notifyListeners();
  }

  // void setShop(TempShopClass? shop) {
  //   shop != null ? shopBranches.add(shop) : {};
  //   notifyListeners();
  // }

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
              .eq('shop_id', userShop!.shopId!);
          userShop?.logoUrl = publicUrl;
          userShop?.imageHeight = imageHeight;
          userShop?.imageWidth = imageWidth;
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
          await getUserShop(AuthService().currentUser!);
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
    userShop!.bottomText = newText;
    notifyListeners();
  }

  void resetBottomText() {
    userShop!.bottomText = null;
    notifyListeners();
  }

  void showEmailAction() {
    userShop!.showEmail = !userShop!.showEmail!;
    notifyListeners();
  }

  void showShopNameAction() {
    userShop!.showShopName = !userShop!.showShopName!;
    notifyListeners();
  }

  void showAddressAction() {
    userShop!.showAddress = !userShop!.showAddress!;
    notifyListeners();
  }

  void showPhoneAction() {
    userShop!.showPhone = !userShop!.showPhone!;
    notifyListeners();
  }

  void showFirstSectionAction() {
    userShop!.showFirst = !userShop!.showFirst!;
    notifyListeners();
  }

  void showSecondSectionAction() {
    userShop!.showSecond = !userShop!.showSecond!;
    notifyListeners();
  }

  void showThirdSectionAction() {
    userShop!.showThird = !userShop!.showThird!;
    notifyListeners();
  }

  void showInstaDownAction() {
    userShop!.showInstaDown = !userShop!.showInstaDown!;
    notifyListeners();
  }

  void showInstaTopAction() {
    userShop!.showInstaTop = !userShop!.showInstaTop!;
    notifyListeners();
  }

  void showFacebookDownAction() {
    userShop!.showFacebookDown =
        !userShop!.showFacebookDown!;
    notifyListeners();
  }

  void showFacebookTopAction() {
    userShop!.showFacebookTop = !userShop!.showFacebookTop!;
    notifyListeners();
  }

  Future<int> updateShopPrintDetails(
    BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (logoPicked && selectedLogo != null) {
      var res = await uploadLogo(
        image: rawImage!,
        // ignore: use_build_context_synchronously
        context: context,
      );
      if (res == 0) {
        return 0;
      }
    }
    if (selectedLogo == null) {
      userShop?.logoUrl = null;
      userShop?.imageHeight = null;
      userShop?.imageWidth = null;
      await ShopLogosFunc().clearLogos();
      await CreatedShopLogosFunc().clearCreatedLogos();
      notifyListeners();
    }
    if (isOnline) {
      userShop!.updatedAt = DateTime.now();
      try {
        await supabase
            .from('shops')
            .update(userShop!.toJson())
            .eq('shop_id', userShop!.shopId!)
            .maybeSingle();

        final response = await getUserShop(
          AuthService().currentUser!,
        );

        if (response != null) {
          setShop(response);
          notifyListeners();
        }
        return 1;
      } catch (e) {
        print(
          "❌ Failed to update Print Details details Online: $e",
        );
        return 0;
      }
    } else {
      try {
        TempShopClass? shop = ShopFunc().getShop();
        if (shop != null) {
          userShop?.updatedAt = DateTime.now();
          await ShopFunc().updateShop(userShop);
        }
        shop != null
            ? await UpdatedShopFunc().createUpdatedShop(
              UpdatedShop(shop: shop),
            )
            : {};
        return 1;
      } catch (e) {
        print(
          "❌ Failed to update Print Details details Offline: $e",
        );
        return 0;
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
                .eq('shop_id', userShop!.shopId!)
                .maybeSingle();
        final shop = await getUserShop(
          AuthService().currentUser!,
        );

        if (response != null) {
          setShop(shop!);
          notifyListeners();
        }
        return 1;
      } catch (e) {
        print("❌ Failed to update location Online: $e");
        return 0;
      }
    } else {
      try {
        TempShopClass? shop = ShopFunc().getShop();
        shop?.updatedAt = DateTime.now();
        shop?.instaHandle = insta;
        shop?.faceBookHandle = face;
        await ShopFunc().updateShop(shop);
        if (shop != null) {
          await UpdatedShopFunc().createUpdatedShop(
            UpdatedShop(shop: shop),
          );
          setShop(shop);
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
        await getUserShop(AuthService().currentUser!);
        notifyListeners();
        final logoUrl = userShop?.logoUrl;
        if (logoUrl == null ||
            userShop?.imageHeight == null ||
            userShop?.imageWidth == null) {
          // clearImage();
          return null;
        }

        final onlineBytes = await fetchImageBytes(logoUrl);

        if (onlineBytes != null) {
          await ShopLogosFunc().createLogo(
            TempShopLogos(
              logoPath: base64Encode(onlineBytes),
              imageName: logoUrl,
              imageHeight: userShop!.imageHeight!,
              imageWidth: userShop!.imageWidth!,
            ),
            // ignore: use_build_context_synchronously
            context,
          );
        }
        selectedLogo = onlineBytes;
        imageHeight = userShop?.imageHeight;
        imageWidth = userShop?.imageWidth;
        // imag
        notifyListeners();
        return onlineBytes;
      } catch (e) {
        print('Error: ${e.toString()}');
        // clearImage();
        return null;
      }
    } else {
      try {
        await getUserShop(AuthService().currentUser!);
        var logo = ShopLogosFunc().getLogo();
        if (logo == null) {
          // clearImage();
          notifyListeners();
          return null;
        } else {
          var imageBytes = base64Decode(logo.logoPath);
          selectedLogo = imageBytes;
          imageHeight = userShop?.imageHeight;
          imageWidth = userShop?.imageWidth;
          notifyListeners();
          return imageBytes;
        }
      } catch (e) {
        print('Error: ${e.toString()}');
        // clearImage();
        return null;
      }
    }
  }

  Future<int> uploadLogo({
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
        'logos/${userShop!.shopId!}-${DateTime.now().millisecondsSinceEpoch}.$ext';
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
            .eq('shop_id', userShop!.shopId!);
        userShop?.logoUrl = publicUrl;
        userShop?.imageHeight = imageHeight;
        userShop?.imageWidth = imageWidth;
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
        return 1;
      } catch (e) {
        print('❌ Error uploading logo: $e');
        return 0;
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
        // userShop?.logoUrl = publicUrl;
        userShop?.imageHeight = imageHeight;
        userShop?.imageWidth = imageWidth;
        notifyListeners();
        print(
          '✅  Offline Logo uploaded and saved successfully!',
        );
        return 1;
      } catch (e) {
        print('Error: ${e.toString()}');
        return 0;
      }
    }
  }
}
