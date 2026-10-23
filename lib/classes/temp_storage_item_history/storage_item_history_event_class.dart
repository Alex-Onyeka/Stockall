import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';

class StorageItemHistoryEventClass {
  /// The event of [h]. Records written before events were added
  /// (10 Oct 2026), or by older app versions, have no event, so it is
  /// inferred from the title they were written with. Read-time only.
  static String? eventOf(StorageItemHistory h) {
    final event = h.event?.trim();
    if (event != null && event.isNotEmpty) return event;

    final t = h.title.trim().toLowerCase();
    if (t == 'stock in from purchase') return purchase;
    if (t == 'purchase deleted') return purchaseDeleted;
    if (t == 'return item') return returnEvent;
    if (t == 'stock in') return stockIn;
    if (t == 'stock out') return stockOut;
    if (t == 'stock updated') {
      if (h.isIncreased == true) return quantityUpdatedIncrease;
      if (h.isIncreased == false) return quantityUpdatedDecrease;
      return null;
    }
    if (t == 'item created') return itemCreated;
    if (t == 'item deleted') return itemDeleted;
    return null;
  }

  static String returnEvent = 'return';
  static String purchase = 'purchase';

  static String purchaseDeleted = 'purchase_deleted';

  static String transferedIn = 'transfered_in';
  static String transferedOut = 'transfered_out';

  static String purchaseSource = 'purchase';
  static String productSource = 'product';
  static String storageSource = 'storage';
  static String branchStoreSource = 'branch_store';
  static String manualSource = 'manual';
  static String departmentSource = 'department';
  static String productionSource = 'production';

  // Destinations
  static String purchaseDestination = 'purchase';
  static String productDestination = 'product';
  static String storageDestination = 'storage';
  static String branchStoreDestination = 'branch_store';
  static String departmentDestination = 'department';
  static String productionDestination = 'production';
  static String deletedDestination = 'deleted';
  static String adjustmentDestination = 'adjustment';
  static String manualDestination = 'manual';

  static String itemCreated = 'created';
  static String itemDeleted = 'deleted';
  static String itemDuplicated = 'duplicated';

  static String stockIn = 'stock_in';
  static String stockOut = 'stock_out';

  static String quantityUpdatedIncrease =
      'quantity_increase';
  static String quantityUpdatedDecrease =
      'quantity_decrease';

  static String unKnownSource = 'not_set';
  static String unKnownDestination = 'not_set';
}
