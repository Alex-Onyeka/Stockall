class MaterialItemHistoryEventClass {
  static String usageDeleted = 'usage_deleted';
  static String productionDeleted = 'production_deleted';
  static String usageCreated = 'usage_created';
  static String productionCreated = 'production_created';

  static String transferedIn = 'transfered_in';
  static String transferedOut = 'transfered_out';

  static String departmentSource = 'department';
  static String productionSource = 'production';
  static String materialSource = 'material';
  static String materialUsageSource = 'material_usage';
  static String branchStoreSource = 'branch_store';
  static String purchaseSource = 'purchase';
  static String manualSource = 'manual';

  // Destinations
  static String departmentDestination = 'department';
  static String productionDestination = 'production';
  static String materialDestination = 'material';
  static String materialUsageDestination = 'material_usage';
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
