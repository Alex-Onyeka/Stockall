class ItemHistoryEventClass {
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
