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

  static String itemCreated = 'created';
  static String itemDeleted = 'deleted';
  static String itemDuplicated = 'duplicated';

  static String quantityUpdatedIncrease =
      'quantity_increase';
  static String quantityUpdatedDecrease =
      'quantity_decrease';

  static String unKnownSource = 'not_set';
}
