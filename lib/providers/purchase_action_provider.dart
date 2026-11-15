import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_edit_rules.dart';
import 'package:stockall/classes/temp_purchase/purchase_list_item/purchase_list_item.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/local_database/purchases/purchase_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/create_purchase.dart';

class PurchaseActionProvider extends ChangeNotifier {
  static final PurchaseActionProvider _instance =
      PurchaseActionProvider._internal();
  factory PurchaseActionProvider() => _instance;
  PurchaseActionProvider._internal();
  List<PurchaseListItem> purchaseListItems = [];

  List<PurchaseListItem> purchaseItemReversed() {
    return purchaseListItems.reversed.toList();
  }

  void clearAll() {
    purchaseListItems.clear();
    // isGroup = false;
    tempSupplier = null;
    trackingNumber = null;
    customTotalAmount = null;
    notifyListeners();
  }

  String itemUnit({required PurchaseListItem purchaseItem}) {
    final selectedUnitName = purchaseItem.getSelectedUnit().name;
    if (selectedUnitName.isNotEmpty) {
      return selectedUnitName;
    }
    List<TempProductClass> products =
        returnData().productListMain
            .where(
              (item) =>
                  item.uuid ==
                  (purchaseItem.itemUuid ?? purchaseItem.storageItemUuid),
            )
            .toList();
    if (products.isNotEmpty) {
      var product = products.first;
      return (purchaseItem.isGroup ? product.groupUnit : product.unit) ??
          'unit';
    } else {
      return purchaseItem.unit ?? 'unit';
    }
  }

  void addItemToList({required PurchaseListItem item}) {
    if (purchaseListItems.contains(item)) {
      purchaseListItems.remove(item);
    } else {
      purchaseListItems.add(item);
    }
    notifyListeners();
  }

  void updateItem({required PurchaseListItem item}) {
    var temp =
        purchaseListItems.where((purch) {
          if (item.storageItemUuid != null) {
            return purch.storageItemUuid == item.storageItemUuid;
          } else {
            return purch.itemUuid == item.itemUuid;
          }
        }).toList();
    if (temp.isNotEmpty) {
      temp.first.quantity = item.quantity;
      temp.first.totalPrice = item.totalPrice;
      temp.first.customPrice = item.customPrice;
      temp.first.isGroup = item.isGroup;
      temp.first.unitUuid = item.unitUuid;
      temp.first.unit = item.unit;
      temp.first.unitsList = item.unitsList;
      temp.first.qttyPerGroup = item.qttyPerGroup;
      temp.first.widthDimension = item.widthDimension;
      temp.first.heightDimension = item.heightDimension;
      temp.first.trackingNumber = item.trackingNumber;
      temp.first.supplierId = item.supplierId;
      temp.first.supplierName = item.supplierName;
    }
    notifyListeners();
  }

  SuppliersClass? tempSupplier;

  void selectSupplier({SuppliersClass? supplier}) {
    tempSupplier = supplier;
    notifyListeners();
  }

  String? trackingNumber;

  void setTrackingNumber(String? value) {
    final trimmed = value?.trim();
    trackingNumber =
        (trimmed == null || trimmed.isEmpty) ? null : trimmed;
    notifyListeners();
  }

  double? customTotalAmount;

  void setCustomTotalAmount(double? total) {
    customTotalAmount = total;
    notifyListeners();
  }

  double totalPurchaseAmount() {
    if (customTotalAmount != null) {
      return customTotalAmount ?? 0;
    } else {
      return purchaseListItems
          .map((item) => item.getPrice())
          .fold(0.0, (a, b) => a + b);
    }
  }

  Future<int> createPurchaseAction({
    TempPurchase? purchase,
    bool? updateInventory,
    double? paymentAmount,
    String? paymentMethod,
  }) async {
    try {
      if (purchase != null) {
        return await _updatePurchaseInPlace(purchase);
      }
      var tempUuid = uuidGen();
      var tempPurchase = TempPurchase(
        createdAt: purchase?.createdAt ?? DateTime.now(),
        shopId: purchase?.shopId ?? shopId(),
        staffId: purchase?.staffId ?? currentUser().userId,
        staffName: purchase?.staffName ?? currentUser().name,
        supplierId: tempSupplier?.uuid,
        supplierName: tempSupplier?.name,
        trackingNumber: trackingNumber,
        total: totalPurchaseAmount(),
        uuid: purchase?.uuid ?? tempUuid,
        isCustomPriceSet: customTotalAmount != null,
        updatedAt: DateTime.now(),
        purchasePayments:
            purchase != null
                ? purchase.purchasePayments
                : paymentAmount == null
                ? []
                : [
                  PurchasePayments(
                    uuid: uuidGen(),
                    purchaseId: tempUuid,
                    createdAt: DateTime.now(),
                    amount: paymentAmount,
                    userId: purchase?.staffId ?? currentUser().userId!,
                    paymentMethod: paymentMethod ?? 'Cash',
                    staffName: purchase?.staffName ?? currentUser().name,
                  ),
                ],
      );
      final isManageStorage =
          returnShopProvider().userShop()?.manageInventoryStorage == true;
      // Built before the purchase is saved so the same lines are
      // stored in purchase.items and in item_purchase_records.
      List<TempItemPurchaseRecord> purchaseRecords =
          purchaseListItems
              .map(
                (item) {
                  final isStorageLine =
                      (item.storageItemUuid != null &&
                          item.storageItemUuid!.isNotEmpty) ||
                      (isManageStorage &&
                          (item.itemUuid == null ||
                              item.itemUuid!.isEmpty));
                  return TempItemPurchaseRecord(
                    unitUuid: item.unitUuid,
                    unitsList: item.getUnitListFinal(),
                    unit: item.getSelectedUnit().name,
                    customPrice: item.customPrice,
                    originalPrice: item.originalPrice,
                    createdAt: purchase?.createdAt ?? DateTime.now(),
                    shopId: purchase?.shopId ?? shopId(),
                    staffId: purchase?.staffId ?? currentUser().userId,
                    itemId: isStorageLine ? null : item.itemUuid,
                    storageItemId:
                        isStorageLine
                            ? (item.storageItemUuid ?? item.itemUuid)
                            : null,
                    itemName: item.itemName,
                    purchaseId: purchase?.uuid ?? tempUuid,
                    quantity: item.quantity,
                    supplierId: item.supplierId,
                    supplierName: item.supplierName,
                    globalSupplierId: tempSupplier?.uuid,
                    globalSupplierName: tempSupplier?.name,
                    total: item.getPrice(),
                    uuid: uuidGen(),
                    isGroup: item.isGroup,
                    qttyPerGroup: item.qttyPerGroup,
                    widthDimension: item.widthDimension,
                    heightDimension: item.heightDimension,
                    trackingNumber: item.trackingNumber,
                    globalTrackingNumber: trackingNumber,
                  );
                },
              )
              .toList();
      tempPurchase.items = purchaseRecords;

      var purchaseRes = await returnPurchaseProvider().createPurchase(
        tempPurchase,
      );

      if (purchaseRes == null) {
        return 0;
      }

      if (purchase != null) {
        if (isManageStorage) {
          await returnStorageProductProvider().getStorageProductsOffline(
            shopId(),
          );
        }
        await returnData().getProductsOffline(shopId());
      }
      await returnPurchaseProvider().createItemPurchaseRecord(purchaseRecords);
      clearAll();
      if (isManageStorage) {
        await returnStorageProductProvider().getStorageProductsOffline(
          shopId(),
        );
      }
      await returnData().getProductsOffline(shopId());
      syncData();
      await returnPurchaseProvider().loadPurchases(shopId());
      return 1;
    } catch (e) {
      await mainLocalLog('Error Creating Purchase Action: ${e.toString()}');
      return 0;
    }
  }

  // Saves the edit of [purchase] under the same uuid. Date, staff,
  // department and payments are kept from the current local copy;
  // stock changes only by the difference between the old and new
  // lines, after the purchase is saved.
  Future<int> _updatePurchaseInPlace(TempPurchase purchase) async {
    final purchaseUuid = purchase.uuid;
    if (purchaseUuid == null || purchaseUuid.isEmpty) {
      return 0;
    }
    final base =
        PurchaseFunc().getSinglePurchase(uuid: purchaseUuid) ?? purchase;
    // Backstop for editPurchase: without stored lines the old stock
    // is unknown.
    if (!canEditPurchase(base)) {
      await mainLocalLog('Purchase Edit Blocked, No Stored Items');
      return 0;
    }
    final oldItems = List<TempItemPurchaseRecord>.from(base.items!);

    // The supplier may have been deleted since: keep the saved one
    // unless another was picked.
    final supplierDeleted =
        base.supplierId != null &&
        !returnSuppliersProvider().suppliers.any(
          (supp) => supp.uuid == base.supplierId,
        );
    final keepSupplier = tempSupplier == null && supplierDeleted;

    final isManageStorage =
        returnShopProvider().userShop()?.manageInventoryStorage == true;
    final effectiveGlobalSupplierId =
        keepSupplier ? base.supplierId : tempSupplier?.uuid;
    final effectiveGlobalSupplierName =
        keepSupplier ? base.supplierName : tempSupplier?.name;
    List<TempItemPurchaseRecord> purchaseRecords =
        purchaseListItems
            .map(
              (item) {
                final isStorageLine =
                    (item.storageItemUuid != null &&
                        item.storageItemUuid!.isNotEmpty) ||
                    (isManageStorage &&
                        (item.itemUuid == null ||
                            item.itemUuid!.isEmpty));
                return TempItemPurchaseRecord(
                  unitUuid: item.unitUuid,
                  unitsList: item.getUnitListFinal(),
                  unit: item.getSelectedUnit().name,
                  customPrice: item.customPrice,
                  originalPrice: item.originalPrice,
                  createdAt: base.createdAt,
                  shopId: base.shopId,
                  staffId: base.staffId,
                  itemId: isStorageLine ? null : item.itemUuid,
                  storageItemId:
                      isStorageLine
                          ? (item.storageItemUuid ?? item.itemUuid)
                          : null,
                  itemName: item.itemName,
                  purchaseId: purchaseUuid,
                  quantity: item.quantity,
                  supplierId: item.supplierId,
                  supplierName: item.supplierName,
                  globalSupplierId: effectiveGlobalSupplierId,
                  globalSupplierName: effectiveGlobalSupplierName,
                  total: item.getPrice(),
                  uuid: uuidGen(),
                  isGroup: item.isGroup,
                  qttyPerGroup: item.qttyPerGroup,
                  widthDimension: item.widthDimension,
                  heightDimension: item.heightDimension,
                  trackingNumber: item.trackingNumber,
                  globalTrackingNumber: trackingNumber,
                );
              },
            )
            .toList();

    var updatedPurchase = TempPurchase(
      createdAt: base.createdAt,
      shopId: base.shopId,
      staffId: base.staffId,
      staffName: base.staffName,
      departmentUuid: base.departmentUuid,
      departmentName: base.departmentName,
      supplierId: effectiveGlobalSupplierId,
      supplierName: effectiveGlobalSupplierName,
      trackingNumber: trackingNumber,
      total: totalPurchaseAmount(),
      uuid: purchaseUuid,
      isCustomPriceSet: customTotalAmount != null,
      updatedAt: DateTime.now(),
      purchasePayments: base.purchasePayments,
      items: purchaseRecords,
    );

    var purchaseRes = await returnPurchaseProvider().updatePurchase(
      updatedPurchase,
    );
    if (purchaseRes == null) {
      return 0;
    }

    await returnPurchaseProvider().applyPurchaseEditInventory(
      oldItems: oldItems,
      newItems: purchaseRecords,
      purchaseUuid: purchaseUuid,
      createdAt: base.createdAt,
    );
    clearAll();
    if (isManageStorage) {
      await returnStorageProductProvider().getStorageProductsOffline(
        shopId(),
      );
    }
    await returnData().getProductsOffline(shopId());
    syncData();
    await returnPurchaseProvider().loadPurchases(shopId());
    return 1;
  }

  void editPurchase({
    required TempPurchase purchase,
    required BuildContext context,
  }) {
    try {
      // Purchases saved before lines were stored can't be edited:
      // the old stock is unknown and saving would wipe the lines.
      if (!canEditPurchase(purchase)) {
        showDialog(
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  "This purchase was recorded before item lines were saved, so it can't be edited. Delete it (with 'update inventory' off) and record it again if needed.",
              title: "Can't Edit Purchase",
            );
          },
        );
        return;
      }
      // List<TempItemPurchaseRecord> records =
      //     returnPurchaseProvider()
      //         .itemPurchaseRecords()
      //         .where(
      //           (rec) => rec.purchaseId == purchase.uuid,
      //         )
      //         .toList();

      List<PurchaseListItem> itemList =
          (purchase.items ?? [])
              .map(
                (item) {
                  // Older purchases copied purchase.supplierId into
                  // item.supplierId without globalSupplierId.
                  final isLegacyGlobalCopy =
                      item.globalSupplierId == null &&
                      item.supplierName == null &&
                      item.supplierId == purchase.supplierId;
                  final itemSuppId =
                      isLegacyGlobalCopy ? null : item.supplierId;
                  final itemSuppName =
                      isLegacyGlobalCopy
                          ? null
                          : (item.supplierName ??
                              (itemSuppId != null
                                  ? returnSuppliersProvider()
                                      .suppliers
                                      .where((s) => s.uuid == itemSuppId)
                                      .firstOrNull
                                      ?.name
                                  : null));
                  return PurchaseListItem(
                    unitUuid: item.unitUuid,
                    unitsList: item.getUnitListFinal(),
                    itemName: item.itemName ?? 'Item Name',
                    unit: item.unit ?? 'unit',
                    itemUuid: item.itemId,
                    totalPrice: item.total,
                    quantity: item.quantity ?? 0,
                    customPrice: item.customPrice,
                    originalPrice: item.originalPrice,
                    storageItemUuid: item.storageItemId,
                    isGroup: item.isGroup ?? false,
                    qttyPerGroup: item.qttyPerGroup,
                    widthDimension: item.widthDimension,
                    heightDimension: item.heightDimension,
                    trackingNumber: item.trackingNumber,
                    supplierId: itemSuppId,
                    supplierName: itemSuppName,
                  );
                },
              )
              .toList();

      purchaseListItems = itemList;
      var sups = returnSuppliersProvider().suppliers.where(
        (supp) => supp.uuid == purchase.supplierId,
      );
      tempSupplier = sups.isEmpty ? null : sups.first;
      trackingNumber = purchase.trackingNumber;

      customTotalAmount = purchase.isCustomPriceSet ? purchase.total : null;
      notifyListeners();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return CreatePurchase(purchase: purchase);
          },
        ),
      );
    } catch (e) {
      mainLocalLog('Error Initiating Edit Purchase: ${e.toString()}');
    }
  }
}