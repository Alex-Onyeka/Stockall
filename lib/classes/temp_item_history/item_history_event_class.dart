import 'package:stockall/classes/temp_item_history/item_history.dart';

class ItemHistoryEventClass {
  /// The event of [h]. Records written before events were added
  /// (10 Oct 2026), or by older app versions, have no event, so it is
  /// inferred from the title they were written with. Read-time only.
  static String? eventOf(ItemHistory h) {
    final event = h.event?.trim();
    if (event != null && event.isNotEmpty) return event;

    final t = h.title.trim().toLowerCase();
    if (t.contains('sold') || t == 'order created') return sold;
    if (t.contains('purchase deleted') ||
        t.contains('purchased deleted') ||
        t.contains('receipt deleted') ||
        t.contains('invoice deleted') ||
        t.contains('return')) {
      return returnEvent;
    }
    if (t.contains('purchase')) return purchase;
    if (t.startsWith('transfered in') ||
        t.startsWith('transferred in')) {
      return transferedIn;
    }
    if (t.startsWith('transfered out') ||
        t.startsWith('transferred out')) {
      return transferedOut;
    }
    if (t.contains('delivered')) return delivered;
    if (t.contains('production record deleted')) {
      return productionDeleted;
    }
    if (t.contains('produced')) return produced;
    if (t.contains('item deleted')) return itemDeleted;
    if (t.contains('created')) return itemCreated;
    if (t.contains('quantity')) {
      if (h.isIncreased == true) return quantityUpdatedIncrease;
      if (h.isIncreased == false) return quantityUpdatedDecrease;
    }
    return null;
  }

  static String returnEvent = 'return';
  static String sold = 'sale';
  static String delivered = 'deliver';
  static String purchase = 'purchase';

  static String receiptSource = 'receipt';
  static String invoiceSource = 'invoice';

  static String transferedIn = 'transfered_in';
  static String transferedOut = 'transfered_out';

  static String produced = 'produced';
  static String productionDeleted = 'production_deleted';

  static String departmentSource = 'department';
  static String orderSource = 'order';
  static String purchaseSource = 'purchase';
  static String productionSource = 'production';
  static String storageSource = 'storage';
  static String branchStoreSource = 'branch_store';
  static String productSource = 'product';
  static String manualSource = 'manual';

  // Destinations
  static String receiptDestination = 'receipt';
  static String invoiceDestination = 'invoice';
  static String productDestination = 'product';
  static String storageDestination = 'storage';
  static String productionDestination = 'production';
  static String purchaseDestination = 'purchase';
  static String orderDestination = 'order';
  static String departmentDestination = 'department';
  static String branchStoreDestination = 'branch_store';
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
