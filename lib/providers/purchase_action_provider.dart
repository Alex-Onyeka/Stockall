import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/constants/calculations.dart';
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
    customTotalAmount = null;
    notifyListeners();
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
            return purch.storageItemUuid ==
                item.storageItemUuid;
          } else {
            return purch.itemUuid == item.itemUuid;
          }
        }).toList();
    if (temp.isNotEmpty) {
      temp.first.quantity = item.quantity;
      temp.first.totalPrice = item.totalPrice;
      temp.first.customPrice = item.customPrice;
      temp.first.isGroup = item.isGroup;
    }
    notifyListeners();
  }

  SuppliersClass? tempSupplier;

  void selectSupplier({SuppliersClass? supplier}) {
    tempSupplier = supplier;
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
  }) async {
    try {
      if (purchase != null) {
        var res = await returnPurchaseProvider()
            .deletePurchase(
              purchase,
              updateInventory,
              false,
            );
        if (res == 0) {
          return 0;
        }
      }
      var tempUuid = uuidGen();
      var tempPurchase = TempPurchase(
        createdAt: purchase?.createdAt ?? DateTime.now(),
        shopId: purchase?.shopId ?? shopId(),
        staffId: purchase?.staffId ?? currentUser().userId,
        staffName:
            purchase?.staffName ?? currentUser().name,
        supplierId: tempSupplier?.uuid,
        supplierName: tempSupplier?.name,
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
                    userId:
                        purchase?.staffId ??
                        currentUser().userId!,
                    paymentMethod: 'Cash',
                    staffName:
                        purchase?.staffName ??
                        currentUser().name,
                  ),
                ],
      );
      var purchaseRes = await returnPurchaseProvider()
          .createPurchase(tempPurchase);

      if (purchaseRes == null) {
        return 0;
      }

      List<TempItemPurchaseRecord> purchaseRecords =
          purchaseListItems
              .map(
                (item) => TempItemPurchaseRecord(
                  customPrice: item.customPrice,
                  originalPrice: item.originalPrice,
                  createdAt:
                      purchase?.createdAt ?? DateTime.now(),
                  shopId: purchase?.shopId ?? shopId(),
                  staffId:
                      purchase?.staffId ??
                      currentUser().userId,
                  itemId: item.itemUuid,
                  storageItemId: item.storageItemUuid,
                  itemName: item.itemName,
                  purchaseId: purchase?.uuid ?? tempUuid,
                  quantity: item.quantity,
                  supplierId: tempSupplier?.uuid,
                  total: item.getPrice(),
                  uuid: uuidGen(),
                  isGroup: item.isGroup,
                  qttyPerGroup: item.qttyPerGroup,
                ),
              )
              .toList();
      if (purchase != null) {
        await returnData().getProducts(shopId());
      }
      await returnPurchaseProvider()
          .createItemPurchaseRecord(purchaseRecords);
      clearAll();
      await returnPurchaseProvider().loadPurchases(
        shopId(),
      );
      if (returnShopProvider()
              .userShop()
              ?.manageInventoryStorage ==
          true) {
        await returnStorageProductProvider()
            .getStorageProducts(shopId());
      } else {
        await returnData().getProducts(shopId());
      }
      syncData();

      return 1;
    } catch (e) {
      print(
        'Error Creating Purchase Action: ${e.toString()}',
      );
      return 0;
    }
  }

  void editPurchase({
    required TempPurchase purchase,
    required BuildContext context,
  }) {
    try {
      List<TempItemPurchaseRecord> records =
          returnPurchaseProvider().itemPurchaseRecords
              .where(
                (rec) => rec.purchaseId == purchase.uuid,
              )
              .toList();

      List<PurchaseListItem> itemList =
          records
              .map(
                (item) => PurchaseListItem(
                  itemName: item.itemName ?? 'Item Name',
                  itemUuid: item.itemId,
                  totalPrice: item.total,
                  quantity: item.quantity ?? 0,
                  customPrice: item.customPrice,
                  originalPrice: item.originalPrice,
                  storageItemUuid: item.storageItemId,
                  isGroup: item.isGroup ?? false,
                  qttyPerGroup: item.qttyPerGroup,
                ),
              )
              .toList();

      purchaseListItems = itemList;
      var sups = returnSuppliersProvider().suppliers.where(
        (supp) => supp.uuid == purchase.supplierId,
      );
      tempSupplier = sups.isEmpty ? null : sups.first;

      customTotalAmount =
          purchase.isCustomPriceSet ? purchase.total : null;
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
      print(
        'Error Initiating Edit Purchase: ${e.toString()}',
      );
    }
  }
}

class PurchaseListItem {
  String itemName;
  String? itemUuid;
  String? storageItemUuid;
  double? totalPrice;
  double quantity;
  double? customPrice;
  double? originalPrice;
  bool isGroup;
  double? qttyPerGroup;

  PurchaseListItem({
    required this.itemName,
    required this.itemUuid,
    required this.totalPrice,
    required this.quantity,
    required this.customPrice,
    required this.originalPrice,
    required this.storageItemUuid,
    required this.isGroup,
    required this.qttyPerGroup,
  });

  PurchaseListItem copyWith({
    String? itemUuid,
    String? itemName,
    double? totalPrice,
    double? quantity,
    double? customPrice,
    double? originalPrice,
    String? storageItemUuid,
    bool? isGroup,
    double? qttyPerGroup,
  }) {
    return PurchaseListItem(
      itemName: itemName ?? this.itemName,
      itemUuid: itemUuid ?? this.itemUuid,
      totalPrice: totalPrice ?? this.totalPrice,
      quantity: quantity ?? this.quantity,
      customPrice: customPrice ?? this.customPrice,
      originalPrice: originalPrice ?? this.originalPrice,
      storageItemUuid:
          storageItemUuid ?? this.storageItemUuid,
      isGroup: isGroup ?? this.isGroup,
      qttyPerGroup: qttyPerGroup ?? this.qttyPerGroup,
    );
  }

  double getPrice() {
    // if (isGroup) {
    //   return (totalPrice ?? 0) * quantity;
    // } else {
    return totalPrice ?? 0;
    // }
  }
}
