class StorageItemHistoryEventClass {
  static String returnEvent = 'return';
  static String purchase = 'purchase';

  static String purchaseDeleted = 'purchase_deleted';

  static String transferedIn = 'transfered_in';
  static String transferedOut = 'transfered_out';

  static String purchaseSource = 'purchase';
  static String productSource = 'product';
  static String branchStoreSource = 'branch_store';

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
}
