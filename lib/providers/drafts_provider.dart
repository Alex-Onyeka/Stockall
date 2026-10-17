import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/classes/temp_cart_items/temp_cart_item.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/created/created_drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/deleted/deleted_drafts.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/local_database/drafts_func/drafts_func.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/created/created_drafts_func.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/deleted/deleted_drafts_func.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/updated/updated_drafts_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/alt_display/alt_display.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DraftsProvider extends ChangeNotifier {
  static final DraftsProvider _instance =
      DraftsProvider._internal();
  factory DraftsProvider() => _instance;
  DraftsProvider._internal();

  final SupabaseClient supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  List<Drafts> _drafts = [];
  List<Drafts> get drafts => _drafts;

  final String tableName = 'drafts';

  void clearDrafts() {
    _drafts.clear();
    mainLocalLog('Drafts Cleared');
    notifyListeners();
  }

  // CREATE a new draft
  Future<Drafts?> createDraft(Drafts draft) async {
    try {
      await DraftsFunc().createDraft(draft);
      await CreatedDraftsFunc().createDrafts(
        CreatedDrafts(draft: draft),
      );
      await loadDraftsOffline(shopId());
      syncData();
      return draft;
    } catch (e) {
      await mainLocalLog(
        'Error Creating Draft: ${e.toString()}',
      );
      return null;
    }
  }

  Future<int> updateDraft({required Drafts draft}) async {
    draft.updatedAt = DateTime.now();
    try {
      await DraftsFunc().createDraft(draft);
      var containsCreated =
          CreatedDraftsFunc()
              .getDrafts()
              .where((rec) => rec.draft.uuid == draft.uuid)
              .toList();
      if (containsCreated.isEmpty) {
        await UpdatedDraftsFunc().createUpdatedDraft(draft);
      } else {
        await CreatedDraftsFunc().createDrafts(
          CreatedDrafts(draft: draft),
        );
      }
      await loadDraftsOffline(shopId());
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Updating Draft: ${e.toString()}',
      );
      notifyListeners();
      return 0;
    }
  }

  // DELETE a draft
  Future<int> deleteDraft(String draftUuid) async {
    try {
      await mainLocalLog('Deleting Draft Offline');
      await DraftsFunc().deleteDraft(draftUuid);
      var containsCreated =
          CreatedDraftsFunc()
              .getDrafts()
              .where((rec) => rec.draft.uuid == draftUuid)
              .toList();
      if (containsCreated.isNotEmpty) {
        // Never reached the server, so there is nothing
        // to delete remotely.
        await CreatedDraftsFunc().deleteDraft(draftUuid);
      } else {
        await DeletedDraftsFunc().createDeletedDraft(
          DeletedDrafts(draftUuid: draftUuid),
        );
      }
      await UpdatedDraftsFunc().deleteUpdatedDraft(
        draftUuid,
      );

      await loadDraftsOffline(shopId());
      await mainLocalLog('Totally Finished Deleting Draft');
      syncData();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Draft: ${e.toString()}',
      );
      return 0;
    }
  }

  // Called after a draft has been checked out as a
  // Real Sale, Invoice or Order.
  Future<void> completeDraft(String? draftUuid) async {
    if (draftUuid == null) {
      return;
    }
    await mainLocalLog('Completing Draft: $draftUuid');
    await deleteDraft(draftUuid);
  }

  Future<List<Drafts>> loadDrafts(int shopId) async {
    await loadDraftsOffline(shopId);
    bool isOnline = await connectivity.isOnline();
    if (isOnline && DraftsFunc().isSynced()) {
      try {
        final data = await supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId)
            .order('created_at', ascending: false)
            .range(0, 1000);
        await mainLocalLog('Drafts Gotten ${data.length}');

        _drafts =
            data
                .map((json) => Drafts.fromJson(json))
                .toList();
        await DraftsFunc().insertAllDrafts(_drafts);
        _drafts = DraftsFunc().getDrafts();
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          'Error Getting Drafts: ${e.toString()}',
        );
        return _drafts;
      }
    }
    notifyListeners();
    return _drafts;
  }

  Future<List<Drafts>> loadDraftsOffline(int shopId) async {
    _drafts =
        DraftsFunc()
            .getDrafts()
            .where((draft) => draft.shopId == shopId)
            .toList();
    await mainLocalLog('Offline Drafts Gotten');
    notifyListeners();
    return _drafts;
  }

  //
  //
  //
  //

  Future<void> createDraftsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      if (CreatedDraftsFunc().getDrafts().isNotEmpty &&
          isOnline) {
        final tempDrafts =
            CreatedDraftsFunc().getDrafts().toList();
        int count = 0;
        for (var item in tempDrafts) {
          final payload = item.draft.toJson();
          payload['created_at'] =
              item.draft.createdAt
                  .toUtc()
                  .toIso8601String();
          payload['updated_at'] =
              item.draft.updatedAt
                  ?.toUtc()
                  .toIso8601String();
          try {
            await supabase.from(tableName).insert(payload);
            count++;
            await CreatedDraftsFunc().deleteDraft(
              item.draft.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedDraftsFunc().deleteDraft(
                item.draft.uuid!,
              );
            }
            await mainLocalLog(
              'Error Synchronizing Draft ${item.draft.uuid}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count drafts added successfully ✅',
        );
        await loadDrafts(shopId());
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Drafts Insert failed ❌: $e',
      );
    }
  }

  Future<void> deleteDraftsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      if (DeletedDraftsFunc().getDraftIds().isNotEmpty &&
          isOnline) {
        final tempDrafts =
            DeletedDraftsFunc().getDraftIds().toList();

        for (var rec in tempDrafts) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.draftUuid);
          await DeletedDraftsFunc().deletedDeletedDraft(
            rec.draftUuid,
          );
        }

        await mainLocalLog(
          '${tempDrafts.length} Drafts Deleted successfully ✅',
        );
        await loadDrafts(shopId());
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Drafts Delete failed ❌: $e',
      );
    }
  }

  Future<void> updateDraftsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      if (UpdatedDraftsFunc().getDraftIds().isNotEmpty &&
          isOnline) {
        final tempDrafts =
            UpdatedDraftsFunc().getDraftIds().toList();
        for (var rec in tempDrafts) {
          final payload = rec.draft.toJson();
          payload['created_at'] =
              rec.draft.createdAt.toUtc().toIso8601String();
          payload['updated_at'] =
              rec.draft.updatedAt
                  ?.toUtc()
                  .toIso8601String();
          await supabase
              .from(tableName)
              .update(payload)
              .eq('uuid', rec.draft.uuid ?? '');
          await UpdatedDraftsFunc().deleteUpdatedDraft(
            rec.draft.uuid ?? '',
          );
        }

        await mainLocalLog(
          '${tempDrafts.length} Drafts Updated successfully ✅',
        );
        await loadDrafts(shopId());
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Drafts Update failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  List<DraftItems> cartItemsToDraftItems({
    required List<TempCartItem> cartItems,
    required String draftId,
  }) {
    return cartItems.map((cartItem) {
      final product = cartItem.getItem() ?? cartItem.item;
      return DraftItems(
        isPercentageWastage: cartItem.isPercentageWastage,
        wastageAmount: cartItem.wastageAmount,
        wastageUnitUuid: cartItem.wastageUnitUuid,
        manageSalesWastage: cartItem.manageSalesWastage,
        heightDimension: cartItem.heightDimension,
        quantityType: cartItem.quantityType,
        widthDimension: cartItem.widthDimension,
        uuid: cartItem.uuid ?? uuidGen(),
        draftId: draftId,
        createdAt: DateTime.now(),
        productUuid: cartItem.itemUuid ?? product.uuid,
        productName: product.name,
        quantity: cartItem.quantity,
        customPrice: cartItem.customPrice,
        setCustomPrice: cartItem.setCustomPrice,
        setTotalPrice: cartItem.setTotalPrice,
        useWholeSalePrice: cartItem.useWholeSalePrice,
        addToStock: cartItem.addToStock,
        discount: cartItem.discount,
        fixedDiscount: cartItem.fixedDiscount,
        useGroupQuantity: cartItem.useGroupQuantity,
        qttyPerGroup: cartItem.qttyPerGroup,
        isVoid: cartItem.isVoid,
        unit: product.unit,
        groupUnit: product.groupUnit,
        unitUuid: cartItem.unitUuid,
        unitsList: cartItem.getUnitListFinal(),
        priceUuid: cartItem.priceUuid,
        pricesList: cartItem.getPriceListFinal(),
        sellingPrice:
            cartItem.getSelectedPrice().priceValue,
        costPrice: product.costPrice,
        isProductManaged: product.isManaged,
        revenue: cartItem.revenue(),
      );
    }).toList();
  }

  // The line's unit, wastage unit and price, added back from the
  // draft line's snapshot if they were removed from the item.
  static TempProductClass editLineProduct({
    required DraftItems record,
    required TempProductClass product,
    void Function(String message)? onMissing,
  }) {
    return product.withLineSnapshot(
      unitUuids: [record.unitUuid, record.wastageUnitUuid],
      snapshotUnits: record.unitsList,
      priceUuid: record.priceUuid,
      snapshotPrices: record.pricesList,
      onMissing:
          onMissing ?? (message) => mainLocalLog(message),
    );
  }

  TempCartItem draftItemToCartItem({
    required DraftItems record,
    required TempProductClass product,
  }) {
    return TempCartItem(
      isPercentageWastage: record.isPercentageWastage,
      wastageAmount: record.wastageAmount,
      wastageUnitUuid: record.wastageUnitUuid,
      manageSalesWastage: record.manageSalesWastage,
      heightDimension: record.heightDimension,
      quantityType: record.quantityType,
      widthDimension: record.widthDimension,
      item: product,
      itemUuid: product.uuid,
      uuid: record.uuid,
      quantity: record.quantity,
      discount: record.discount,
      fixedDiscount: record.fixedDiscount,
      customPrice: record.customPrice,
      setCustomPrice: record.setCustomPrice,
      setTotalPrice: record.setTotalPrice,
      useWholeSalePrice: record.useWholeSalePrice,
      addToStock: record.addToStock,
      useGroupQuantity: record.useGroupQuantity,
      qttyPerGroup: record.qttyPerGroup,
      isVoid: record.isVoid,
      unitUuid: record.unitUuid,
      priceUuid: record.priceUuid,
    );
  }

  List<TempCartItem> convertDraftToCartItems({
    required Drafts draft,
  }) {
    List<TempCartItem> cartItems = [];

    for (var record in draft.draftItems) {
      var products = returnData().productList().where(
        (p) => p.uuid == record.productUuid,
      );

      if (products.isNotEmpty) {
        cartItems.add(
          draftItemToCartItem(
            record: record,
            product: editLineProduct(
              record: record,
              product: products.first,
            ),
          ),
        );
      } else {
        // Custom item, or the product was deleted since the
        // draft was saved: rebuild it from the snapshot.
        TempProductClass productNew = TempProductClass(
          manageSalesWastage: record.manageSalesWastage,
          heightDimension: record.heightDimension,
          quantityType: record.quantityType,
          widthDimension: record.widthDimension,
          pricesList: record.pricesList ?? [],
          unitsList: record.unitsList ?? [],
          useGroupUnit: record.useGroupQuantity ?? false,
          categories: [],
          groupUnit: record.groupUnit ?? 'Group(s)',
          storageUuid: null,
          qttyPerGroup: record.qttyPerGroup,
          name: record.productName,
          unit: record.unit ?? 'Unit(s)',
          isRefundable: false,
          costPrice: record.costPrice ?? 0,
          shopId: shopId(),
          setCustomPrice: record.setCustomPrice,
          isManaged: record.isProductManaged ?? false,
          barcode: null,
          brand: null,
          color: null,
          createdAt: DateTime.now(),
          departmentUuid: draft.departmentUuid,
          departmentName: draft.departmentName,
          discount: null,
          endDate: null,
          expiryDate: null,
          lowQtty: 10,
          quantity: null,
          sellingPrice: record.sellingPrice ?? 0,
          wholeSalePrice: record.sellingPrice ?? 0,
          size: null,
          sizeType: null,
          startDate: null,
          updatedAt: DateTime.now(),
          uuid: record.productUuid ?? uuidGen(),
        );
        cartItems.add(
          draftItemToCartItem(
            record: record,
            product: productNew,
          ),
        );
      }
    }

    return cartItems;
  }

  // Opens the draft in its own cart (or selects it if it
  // is already open), so it can be edited and checked out.
  Future<void> onContinueDraft({
    required Drafts draft,
    required BuildContext context,
  }) async {
    var openCarts = returnSalesProvider()
        .currentMainCart()
        .cartQueue
        .where((cart) => cart.draftUuid == draft.uuid);

    if (openCarts.isNotEmpty) {
      await returnSalesProvider().selectCart(
        openCarts.first.id!,
      );
      return;
    }

    final cartItems = convertDraftToCartItems(draft: draft);

    var tempCart = TempCart(
      tempCartItems: null,
      comment: draft.comment,
      timeOfDay: null,
      hasPrintedDocket: false,
      subStaffName: draft.subStaffName,
      customDate: null,
      departmentName: draft.departmentName,
      departmentUuid: draft.departmentUuid,
      staffId: draft.staffId,
      staffName: draft.staffName,
      id: uuidGen(),
      fixedDiscount: draft.fixedDiscount,
      createdDate: null,
      cartItems: cartItems,
      cartItemTypeIndex: 4,
      orderUuidEdit: null,
      discount: draft.generalDiscount,
      paymentMethod: 0,
      selectedCustomer: draft.customerUuid,
      selectedCustomerName: draft.customerName,
      isReceiptEdit: false,
      subStaffUuid: draft.subStaffUuid,
      cartName: draft.cartName,
      draftUuid: draft.uuid,
    );
    await returnSalesProvider().addNewCart(
      context,
      tempCart,
    );
    // addNewCart is gated by the cart limit and may not add it.
    if (!returnSalesProvider().checkIfCartExists(
      tempCart.id!,
    )) {
      return;
    }
    await returnMultiDisplayProvider().updateWindow(
      cartClass: AltCartClass(
        manageCustomerReward:
            returnShopProvider()
                .userShop()!
                .manageCustomerReward ??
            false,
        cartId: tempCart.id!,
        cartItems: tempCart.cartItems.reversed.toList(),
        fixedDiscount: draft.fixedDiscount,
        percentDiscount: draft.generalDiscount,
        vat:
            returnShopProvider().userShop()?.applyVAT ==
                    true
                ? vat
                : 0,
        cashBack: null,
        currency: returnShopProvider().userShop()!.currency,
      ),
    );
    notifyListeners();
  }
}
