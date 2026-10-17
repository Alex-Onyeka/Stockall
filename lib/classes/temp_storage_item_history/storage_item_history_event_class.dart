class StorageItemHistoryEventClass {
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
