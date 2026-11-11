import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';

class ProductionItemHistoryEventClass {
  /// The event of [h]. Records written before events were added, or
  /// by older app versions, have no event, so it is inferred from the
  /// title they were written with. Read-time only.
  static String? eventOf(ProductionItemHistory h) {
    final event = h.event?.trim();
    if (event != null && event.isNotEmpty) return event;

    final t = h.title.trim().toLowerCase();
    if (t == 'item created') return itemCreated;
    if (t == 'item deleted') return itemDeleted;
    if (t == 'item produced') return productionCreated;
    if (t == 'production record deleted') return productionDeleted;
    if (t == 'transfered in' || t == 'transferred in') {
      return transferedIn;
    }
    if (t == 'transfered out' || t == 'transferred out') {
      return transferedOut;
    }
    if (t == 'item quantity increased') return quantityUpdatedIncrease;
    if (t == 'item quantity reduced') return quantityUpdatedDecrease;
    if (t.contains('quantity')) {
      if (h.isIncreased == true) return quantityUpdatedIncrease;
      if (h.isIncreased == false) return quantityUpdatedDecrease;
    }
    return null;
  }

  static String productionDeleted = 'production_deleted';
  static String productionCreated = 'production_created';

  static String transferedIn = 'transfered_in';
  static String transferedOut = 'transfered_out';

  static String departmentSource = 'department';
  static String productionSource = 'production';
  static String productSource = 'product';
  static String productionItemSource = 'production_item';
  static String branchStoreSource = 'branch_store';
  static String purchaseSource = 'purchase';
  static String manualSource = 'manual';

  // Destinations
  static String departmentDestination = 'department';
  static String productionDestination = 'production';
  static String productDestination = 'product';
  static String productionItemDestination = 'production_item';
  static String branchStoreDestination = 'branch_store';
  static String purchaseDestination = 'purchase';
  static String deletedDestination = 'deleted';
  static String manualDestination = 'manual';

  static String itemCreated = 'created';
  static String itemDeleted = 'deleted';
  static String itemDuplicated = 'duplicated';

  static String quantityUpdatedIncrease = 'quantity_increase';
  static String quantityUpdatedDecrease = 'quantity_decrease';

  static String unKnownSource = 'not_set';
  static String unKnownDestination = 'not_set';
}
