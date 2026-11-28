import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/production_unit_snapshot.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/created_productions/created_production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/unsynced/deleted_productions/deleted_production_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/local_database/productions/production_records_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/created/created_production_record_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/deleted/deleted_production_records_func.dart';
import 'package:stockall/local_database/productions/unsync_funcs/updated/updated_production_records_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:stockall/services/lan/sync/lan_server_sync.dart';
import 'package:stockall/services/remote/remote_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductionRecordsProvider extends ChangeNotifier {
  static final ProductionRecordsProvider _instance =
      ProductionRecordsProvider._internal();
  factory ProductionRecordsProvider() => _instance;
  ProductionRecordsProvider._internal();
  bool isLoading = false;
  void toggleIsLoading(bool value) {
    isLoading = value;
    mainLocalLog(
      'Production Records is ${value ? 'Loading on' : 'Loading Off'}',
    );
    notifyListeners();
  }
  //
  //
  //

  SupabaseClient get supabase => backend();
  final ConnectivityProvider connectivity =
      ConnectivityProvider();
  // ignore: prefer_final_fields
  List<ProductionRecord> _productionRecords = [];

  List<ProductionRecord> get productionRecords =>
      _productionRecords;
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor)))
        return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      _fetchedDateKeys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  final String tableName = 'production_records';

  void clearProductionRecords() {
    _productionRecords.clear();
    _fetchedDateKeys.clear();
    _fetchedShopId = null;
    mainLocalLog('Production Records Cleared');
    notifyListeners();
  }

  ProductionRecord? getSingleProductionRecord({
    required String recordUuid,
  }) {
    return productionRecords
            .where((item) => item.uuid == recordUuid)
            .isNotEmpty
        ? productionRecords
            .where((item) => item.uuid == recordUuid)
            .first
        : null;
  }

  bool _usesProductionItemInventory(
    ProductionRecord record,
  ) {
    if (record.itemUuid != null &&
        record.salesItemUuid == null) {
      return true;
    }
    if (record.salesItemUuid != null &&
        record.itemUuid == null) {
      return false;
    }
    return returnShopProvider()
            .userShop()
            ?.manageProductionItems ??
        false;
  }

  void _snapshotProductionUnits(ProductionRecord record) {
    final useProductionItems = _usesProductionItemInventory(
      record,
    );

    if (record.unitsList == null ||
        record.unitsList!.isEmpty) {
      if (useProductionItems) {
        final items = returnProductionItemsProvider()
            .productionItemListMain
            .where((item) => item.uuid == record.itemUuid);
        if (items.isNotEmpty) {
          record.unitsList = copyProductionUnitSnapshot(
            items.first.getUnitsList(),
          );
        }
      } else {
        final items = returnData().productListMain.where(
          (item) => item.uuid == record.salesItemUuid,
        );
        if (items.isNotEmpty) {
          record.unitsList = copyProductionUnitSnapshot(
            items.first.getUnitsList(),
          );
        }
      }
    }
    if (record.unitUuid == null &&
        record.unitsList?.isNotEmpty == true) {
      record.unitUuid = legacyProductionUnitUuid(
        unitsList: record.unitsList,
        useGroupQuantity: record.useGroupQuantity,
        groupUnit: record.groupUnit,
      );
    }

    for (final materialRecord in record.materials) {
      final materials = returnMaterialsProvider()
          .materialListMain
          .where(
            (item) =>
                item.uuid == materialRecord.materialUuid,
          );
      if (materialRecord.unitsList == null ||
          materialRecord.unitsList!.isEmpty) {
        if (materials.isNotEmpty) {
          materialRecord
              .unitsList = copyProductionUnitSnapshot(
            materials.first.getUnitsList(),
          );
        }
      }
      if (materialRecord.unitUuid == null &&
          materialRecord.unitsList?.isNotEmpty == true) {
        materialRecord.unitUuid = legacyProductionUnitUuid(
          unitsList: materialRecord.unitsList,
          useGroupQuantity: materialRecord.isGroup,
          groupUnit: materialRecord.groupUnit,
        );
      }
      if (materialRecord.isManaged == null &&
          materials.isNotEmpty) {
        materialRecord.isManaged =
            materials.first.isManaged;
      }
    }
  }

  Future<void> _applyProductionInventory(
    ProductionRecord record, {
    required bool increment,
  }) async {
    final useProductionItems = _usesProductionItemInventory(
      record,
    );
    final quantity = record.getQuantity();
    final historyTitle =
        increment
            ? 'Item Produced'
            : 'Production Record Deleted';

    if (useProductionItems) {
      final items = returnProductionItemsProvider()
          .productionItemListMain
          .where((item) => item.uuid == record.itemUuid);
      if (items.isEmpty) return;
      final oldItem = items.first;
      final newItem = oldItem.copyWith();
      final signedQuantity =
          increment ? quantity : -quantity;
      newItem.quantity =
          (oldItem.quantity ?? 0) + signedQuantity;
      final primaryUnitConversion =
          productionPrimaryUnitConversion(
            record.unitsList,
            fallback: oldItem.getPrimaryUnit().conversion,
          );
      await returnProductionItemsProvider()
          .updateProductionItem(
            productionItem: newItem,
            isQuantityUpdate: true,
            includeQuantity: true,
            quantityChange: quantity,
            isIncrement: increment,
            productionItemHistory: ProductionItemHistory(
              event:
                  increment
                      ? ProductionItemHistoryEventClass
                          .productionCreated
                      : ProductionItemHistoryEventClass
                          .productionDeleted,
              source:
                  increment
                      ? ProductionItemHistoryEventClass
                          .productionSource
                      : ProductionItemHistoryEventClass
                          .productionItemSource,
              destination:
                  increment
                      ? ProductionItemHistoryEventClass
                          .productionItemDestination
                      : ProductionItemHistoryEventClass
                          .productionDestination,
              isManaged: oldItem.isManaged,
              shopId: shopId(),
              title: historyTitle,
              oldValue:
                  ((oldItem.quantity ?? 0) /
                          primaryUnitConversion)
                      .toString(),
              newValue:
                  ((newItem.quantity ?? 0) /
                          primaryUnitConversion)
                      .toString(),
              desc:
                  increment
                      ? 'This Item was Produced'
                      : 'Production Record was deleted.',
              isIncreased: increment,
              itemName: oldItem.name,
              itemUuid: oldItem.uuid,
              quantityChange:
                  (increment ? 1 : -1) *
                  (record.quantity ?? 0),
              unit: record.getUnit(),
              primaryUnit: productionPrimaryUnitName(
                record.unitsList,
                fallback: oldItem.getPrimaryUnit().name,
              ),
            ),
          );
      return;
    }

    final items = returnData().productListMain.where(
      (item) => item.uuid == record.salesItemUuid,
    );
    if (items.isEmpty) return;
    final oldItem = items.first;
    final newItem = oldItem.copyWith();
    final signedQuantity = increment ? quantity : -quantity;
    newItem.quantity =
        (oldItem.getActualQuantity() ?? 0) + signedQuantity;
    final primaryUnitConversion =
        productionPrimaryUnitConversion(
          record.unitsList,
          fallback: oldItem.getPrimaryUnit().conversion,
        );
    await returnData().updateProduct(
      product: newItem,
      isQuantityUpdate: true,
      includeQuantity: true,
      quantityChange: quantity,
      isIncrement: increment,
      itemHistory: ItemHistory(
        event:
            increment
                ? ItemHistoryEventClass.produced
                : ItemHistoryEventClass.productionDeleted,
        source:
            increment
                ? ItemHistoryEventClass.productionSource
                : ItemHistoryEventClass.productSource,
        destination:
            increment
                ? ItemHistoryEventClass.productDestination
                : ItemHistoryEventClass
                    .productionDestination,
        isManaged: oldItem.isManaged,
        shopId: shopId(),
        title: historyTitle,
        oldValue:
            ((oldItem.getActualQuantity() ?? 0) /
                    primaryUnitConversion)
                .toString(),
        newValue:
            ((newItem.getActualQuantity() ?? 0) /
                    primaryUnitConversion)
                .toString(),
        desc:
            increment
                ? 'This Item was Produced'
                : 'Production Record was deleted.',
        isIncreased: increment,
        itemName: oldItem.name,
        itemUuid: oldItem.uuid,
        quantityChange:
            (increment ? 1 : -1) * (record.quantity ?? 0),
        unit: record.getUnit(),
        primaryUnit: productionPrimaryUnitName(
          record.unitsList,
          fallback: oldItem.getPrimaryUnit().name,
        ),
      ),
    );
  }

  Future<void> _applyEmbeddedMaterialInventory(
    ProductionRecord record, {
    required bool increment,
  }) async {
    for (final materialRecord in record.materials) {
      final materials = returnMaterialsProvider()
          .materialListMain
          .where(
            (item) =>
                item.uuid == materialRecord.materialUuid,
          );
      if (materials.isEmpty) continue;

      final oldMaterial = materials.first;
      final newMaterial = oldMaterial.copyWith();
      if (materialRecord.isManaged == false) {
        await mainLocalLog(
          'Skipping stock adjustment for unmanaged material ${materialRecord.materialName}.',
        );
        continue;
      }
      final quantity = materialRecord.getActualQuantity();
      final signedQuantity =
          increment ? quantity : -quantity;
      newMaterial.quantity =
          (oldMaterial.quantity ?? 0) + signedQuantity;
      final primaryUnit = productionPrimaryUnitName(
        materialRecord.unitsList,
        fallback: oldMaterial.getPrimaryUnit().name,
      );
      final primaryUnitConversion =
          productionPrimaryUnitConversion(
            materialRecord.unitsList,
            fallback:
                oldMaterial.getPrimaryUnit().conversion,
          );
      await returnMaterialsProvider().updateMaterial(
        material: newMaterial,
        isQuantityUpdate: true,
        includeQuantity: true,
        isMultipleUpdate: true,
        quantityChange: quantity,
        isIncrement: increment,
        materialsItemHistory: MaterialsItemHistory(
          event:
              increment
                  ? MaterialItemHistoryEventClass
                      .productionDeleted
                  : MaterialItemHistoryEventClass
                      .productionCreated,
          source:
              increment
                  ? MaterialItemHistoryEventClass
                      .productionSource
                  : MaterialItemHistoryEventClass
                      .materialSource,
          destination:
              increment
                  ? MaterialItemHistoryEventClass
                      .materialDestination
                  : MaterialItemHistoryEventClass
                      .productionDestination,
          isManaged: oldMaterial.isManaged,
          shopId: oldMaterial.shopId,
          title:
              increment
                  ? 'Production Record Deleted'
                  : 'Material Used in Production',
          oldValue:
              ((oldMaterial.quantity ?? 0) /
                      primaryUnitConversion)
                  .toString(),
          newValue:
              ((newMaterial.quantity ?? 0) /
                      primaryUnitConversion)
                  .toString(),
          quantityChange:
              (increment ? 1 : -1) *
              materialRecord.quantity,
          desc:
              increment
                  ? 'Production record material usage was restored.'
                  : 'This material was used in production.',
          isIncreased: increment,
          unit: materialRecord.getUnit(),
          primaryUnit: primaryUnit,
        ),
      );
    }
  }

  Future<bool> _validateProductionRecord(
    ProductionRecord record, {
    ProductionRecord? replacedRecord,
  }) async {
    final usesProductionItems =
        _usesProductionItemInventory(record);
    final outputExists =
        usesProductionItems
            ? returnProductionItemsProvider()
                .productionItemListMain
                .any((item) => item.uuid == record.itemUuid)
            : returnData().productListMain.any(
              (item) => item.uuid == record.salesItemUuid,
            );
    if (!outputExists) {
      await mainLocalLog(
        'Production could not be saved because its output item is no longer available.',
      );
      return false;
    }
    if (!_hasValidSelectedUnit(
      unitUuid: record.unitUuid,
      unitsList: record.unitsList,
    )) {
      await mainLocalLog(
        'Production could not be saved because the output unit conversion is invalid.',
      );
      return false;
    }
    if (!record.getQuantity().isFinite ||
        record.getQuantity() <= 0) {
      await mainLocalLog(
        'Production quantity must be greater than zero.',
      );
      return false;
    }

    final materialDemand = <String, double>{};
    final restoredByOldRecord = <String, double>{};
    for (final material in record.materials) {
      if (!_hasValidSelectedUnit(
        unitUuid: material.unitUuid,
        unitsList: material.unitsList,
      )) {
        await mainLocalLog(
          'Production could not be saved because the unit conversion for ${material.materialName} is invalid.',
        );
        return false;
      }
      final quantity = material.getActualQuantity();
      if (!quantity.isFinite || quantity <= 0) {
        await mainLocalLog(
          'Production material quantity for ${material.materialName} must be greater than zero.',
        );
        return false;
      }
      if (material.isManaged == false) continue;
      materialDemand.update(
        material.materialUuid,
        (existing) => existing + quantity,
        ifAbsent: () => quantity,
      );
    }
    for (final material
        in replacedRecord?.materials ?? []) {
      if (material.isManaged == false) continue;
      final quantity = material.getActualQuantity();
      if (quantity.isFinite && quantity > 0) {
        restoredByOldRecord.update(
          material.materialUuid,
          (existing) => existing + quantity,
          ifAbsent: () => quantity,
        );
      }
    }

    for (final entry in materialDemand.entries) {
      final materials = returnMaterialsProvider()
          .materialListMain
          .where((item) => item.uuid == entry.key);
      if (materials.isEmpty) continue;
      final available =
          (materials.first.quantity ?? 0) +
          (restoredByOldRecord[entry.key] ?? 0);
      if (entry.value > available) {
        await mainLocalLog(
          'Production requires ${entry.value} primary units of ${materials.first.name}, but only $available are available.',
        );
        return false;
      }
    }
    return true;
  }

  bool _hasValidSelectedUnit({
    required String? unitUuid,
    required List<ProductUnitsClass>? unitsList,
  }) {
    final units = unitsList ?? [];
    final selected =
        units
            .where((unit) => unit.uuid == unitUuid)
            .toList();
    if (selected.isNotEmpty) {
      return selected.first.conversion.isFinite &&
          selected.first.conversion > 0;
    }
    if (unitUuid != null && units.isNotEmpty) return false;
    final primaryUnits =
        units.where((unit) => unit.isPrimary).toList();
    return primaryUnits.isEmpty ||
        (primaryUnits.first.conversion.isFinite &&
            primaryUnits.first.conversion > 0);
  }

  // CREATE a new ProductionRecords
  Future<ProductionRecord?> createProductionRecord() async {
    try {
      final cartItem =
          returnProductionsActionProvider()
              .getProductionsCart();
      final productionCart =
          returnProductionsActionProvider()
              .getProductionsCart();
      if (productionCart == null ||
          productionCart.productionsCartItem == null) {
        return null;
      }

      final productionRecord = ProductionRecord.fromCart(
        cartItem: productionCart,
        shopIdd: shopId(),
      );
      _snapshotProductionUnits(productionRecord);

      ProductionRecord? existingRecord;
      if (cartItem?.isEdit == true) {
        existingRecord = getSingleProductionRecord(
          recordUuid: cartItem?.uuid ?? '',
        );
        if (existingRecord == null) {
          await mainLocalLog(
            'The production being edited could not be found; no changes were made.',
          );
          return null;
        }
      }
      if (!await _validateProductionRecord(
        productionRecord,
        replacedRecord: existingRecord,
      )) {
        return null;
      }
      if (existingRecord != null) {
        final deleteResult = await deleteProductionRecords(
          existingRecord,
          true,
          true,
        );
        if (deleteResult != 1) return null;
      }

      await mainLocalLog(
        'Inner Production Records Creation Started',
      );
      productionRecord.createdAt = DateTime.now();
      await ProductionRecordsFunc().createProductionRecord(
        productionRecord,
      );
      await CreatedProductionRecordsFunc()
          .createProductions(
            CreatedProductionRecord(
              createdProductionRecord: productionRecord,
            ),
          );
      final usageRecordsCreated =
          await returnMaterialsUsageProvider()
              .createUsageRecordsForProduction(
                productionRecord,
              );
      if (!usageRecordsCreated) {
        await deleteProductionRecords(
          productionRecord,
          false,
          true,
        );
        return null;
      }
      notifyListeners();
      await getProductionRecordsOffline();
      await _applyProductionInventory(
        productionRecord,
        increment: true,
      );
      returnData().syncData();
      return productionRecord;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Create Production Records Error Offline: ${e.toString()}',
      );
      return null;
    }
  }

  // READ ProductionRecords for a shop (current business day by default, or specific date range)
  Future<List<ProductionRecord>> getProductionRecords(
    int shopId, {
    DateTime? startDate,
    DateTime? endDate,
    bool fetchAll = false,
    bool forceRefresh = false,
  }) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline && !LanServerSync.pullerActive &&
        ProductionRecordsFunc().isSynced() &&
        authorization(
          authorized: Authorizations().viewProductions,
        ) &&
        GeneralSettingsAuthAction().manageProductions(
          context: null,
        )) {
      final effectiveStart =
          startDate ??
          dateSet ??
          rangeStartDate ??
          resolveBusinessDate(DateTime.now());
      final effectiveEnd =
          endDate ??
          (dateSet ?? rangeEndDate ?? effectiveStart);

      if (!fetchAll &&
          !forceRefresh &&
          _isRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          )) {
        return _productionRecords;
      }

      final windowStart = fourAm(effectiveStart);
      final windowEnd = fourAmNextDay(effectiveEnd);

      try {
        var query = supabase
            .from(tableName)
            .select()
            .eq('shop_id', shopId);
        if (!fetchAll) {
          query = query
              .gte(
                'created_at',
                windowStart.toUtc().toIso8601String(),
              )
              .lt(
                'created_at',
                windowEnd.toUtc().toIso8601String(),
              );
        }
        final data = await query.order(
          'created_at',
          ascending: false,
        );
        if (data.isNotEmpty) {
          await mainLocalLog(
            'Production Records Gotten ${data.length}',
          );
        }

        final fetched =
            (data as List)
                .map(
                  (json) => ProductionRecord.fromJson(json),
                )
                .toList();
        if (fetchAll) {
          _productionRecords = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              _productionRecords.where((rec) {
                if (fetchedUuids.contains(rec.uuid)) {
                  return false;
                }
                final created = rec.createdAt;
                if (created == null) return true;
                final inWindow =
                    !created.isBefore(windowStart) &&
                    created.isBefore(windowEnd);
                return !inWindow;
              }).toList();
          _productionRecords = [
            ...fetched,
            ...outsideWindow,
          ]..sort(
            (a, b) => (b.createdAt ?? DateTime(1970))
                .compareTo(a.createdAt ?? DateTime(1970)),
          );
          _markRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          );
        }
        await ProductionRecordsFunc()
            .insertAllProductionRecords(_productionRecords);
        await mainLocalLog('Loaded');
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          '❌ Error Getting Production Records: ${e.toString()}',
        );
        return [];
      }
    } else {
      _productionRecords =
          ProductionRecordsFunc().getProductionRecords();
      await mainLocalLog(
        'Offline Production Records Gotten',
      );
      notifyListeners();
    }
    notifyListeners();
    return _productionRecords;
  }

  Future<List<ProductionRecord>>
  getProductionRecordsOffline() async {
    _productionRecords =
        ProductionRecordsFunc().getProductionRecords();
    await mainLocalLog('Offline Production Records Gotten');
    notifyListeners();
    return _productionRecords;
  }

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      mainLocalLog('Date set: $date');
      final sId = returnShopProvider().userShop()?.shopId;
      if (sId != null) {
        getProductionRecords(
          sId,
          startDate: date,
          endDate: date,
        );
      }
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    final sId = returnShopProvider().userShop()?.shopId;
    if (sId != null) {
      getProductionRecords(
        sId,
        startDate: rangeStart,
        endDate: endOfrange,
      );
    }
    notifyListeners();
  }

  // DELETE a ProductionRecords
  Future<int> deleteProductionRecords(
    ProductionRecord productionRecord,
    bool? updateInventory,
    bool createUpdate,
  ) async {
    await mainLocalLog('Deleting Production Records');
    try {
      await mainLocalLog(
        'Deleting Production Records Offline',
      );
      await returnMaterialsUsageProvider()
          .getProductionMaterialsUsageOffline();
      final linkedUsageRecords =
          returnMaterialsUsageProvider()
              .productionMaterialsUsage
              .where(
                (usage) =>
                    usage.productionRecordUuid ==
                    productionRecord.uuid,
              )
              .toList();
      for (final usage in linkedUsageRecords) {
        final usageDeleteResult =
            await returnMaterialsUsageProvider()
                .deleteProductionMaterialsUsage(
                  usage,
                  updateInventory,
                  createUpdate,
                  allowProductionLinked: true,
                );
        if (usageDeleteResult != 1) return 0;
      }
      await ProductionRecordsFunc().deleteProductionRecord(
        productionRecord.uuid!,
      );
      var containsCreated =
          CreatedProductionRecordsFunc()
              .getProductions()
              .where(
                (productRecord) =>
                    productRecord
                        .createdProductionRecord
                        .uuid ==
                    productionRecord.uuid,
              )
              .toList();
      var containsUpdate = UpdatedProductionRecordsFunc()
          .getProductionIds()
          .where(
            (productRecord) =>
                productRecord
                    .updatedProductionRecord
                    .uuid ==
                productionRecord.uuid!,
          );
      if (containsCreated.isNotEmpty) {
        await CreatedProductionRecordsFunc()
            .deleteProduction(productionRecord.uuid!);
      } else {
        await DeletedProductionRecordsFunc()
            .createDeletedProductionRecords(
              DeletedProductionRecord(
                productionRecordUuid:
                    productionRecord.uuid!,
              ),
            );
      }
      if (containsUpdate.isNotEmpty) {
        await UpdatedProductionRecordsFunc()
            .deleteUpdatedProductionRecords(
              productionRecord.uuid!,
            );
      }
      if (updateInventory == true) {
        await _applyProductionInventory(
          productionRecord,
          increment: false,
        );
        if (linkedUsageRecords.isEmpty) {
          await _applyEmbeddedMaterialInventory(
            productionRecord,
            increment: true,
          );
        }
      }
      returnData().syncData();

      await mainLocalLog(
        '✅ Production Records succesfully Delete.',
      );
      notifyListeners();
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error Deleting Production Records: ${e.toString()}',
      );
      return 0;
    }
  }

  //
  //
  //
  //

  Future<void> createProductionRecordSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedProductionRecordsFunc()
              .getProductions()
              .isNotEmpty &&
          isOnline) {
        final tempProductionRecords =
            CreatedProductionRecordsFunc()
                .getProductions()
                .toList();
        var newProductionRecords = tempProductionRecords
            .map((rec) {
              rec.createdProductionRecord.createdAt =
                  rec.createdProductionRecord.createdAt
                      ?.toUtc();
              return rec;
            });
        final payload =
            newProductionRecords
                .map(
                  (p) => p.createdProductionRecord.toJson(),
                )
                .toList();

        // Insert all at once
        final data = await supabase
            .from(tableName)
            .insert(payload)
            .select('uuid');

        await mainLocalLog(
          '${data.length} items added succesfully ✅',
        );
        await CreatedProductionRecordsFunc()
            .clearProductions();
        await mainLocalLog(
          'Unsynced Production Records Cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  //
  //
  //
  //
  //

  Future<void> deleteProductionRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (DeletedProductionRecordsFunc()
              .getProductionIds()
              .isNotEmpty &&
          isOnline) {
        final tempProductionRecords =
            DeletedProductionRecordsFunc()
                .getProductionIds()
                .toList();

        for (var rec in tempProductionRecords) {
          await supabase
              .from(tableName)
              .delete()
              .eq('uuid', rec.productionRecordUuid);
          // await DeletedProductionRecordsFunc()
          //     .deletedDeletedProductionRecords(rec.productionRecordUuid);
        }

        await mainLocalLog(
          '${tempProductionRecords.length} Production Records Created succesfully ✅',
        );
        await DeletedProductionRecordsFunc()
            .clearDeletedProductionRecords();
        await mainLocalLog(
          'Unsynced Deleted Production Records Cleared',
        );

        await mainLocalLog(
          'Mounted, refreshing Production Records ✅',
        );
        await getProductionRecords(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records Deleted failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //

  Future<void> updateProductionRecordsSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedProductionRecordsFunc()
            .getProductionIds()
            .length
            .toString(),
      );

      if (UpdatedProductionRecordsFunc()
              .getProductionIds()
              .isNotEmpty &&
          isOnline) {
        final updatedProductionRecords =
            UpdatedProductionRecordsFunc()
                .getProductionIds();

        for (final updated in updatedProductionRecords) {
          final localProductionRecords =
              updated.updatedProductionRecord;

          localProductionRecords.updatedAt ??=
              DateTime.now().toLocal();

          if (localProductionRecords.uuid == null) {
            await mainLocalLog(
              'Local Production Records Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from(tableName)
                  .select('uuid, updated_at')
                  .eq('uuid', localProductionRecords.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from(tableName)
                .insert(localProductionRecords.toJson());
            await mainLocalLog(
              'Inserted product with uuid ${localProductionRecords.uuid}',
            );
            await UpdatedProductionRecordsFunc()
                .deleteUpdatedProductionRecords(
                  localProductionRecords.uuid ?? '',
                );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localProductionRecords.updatedAt =
                (localProductionRecords.updatedAt ??
                        DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localProductionRecords.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localProductionRecords.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from(tableName)
                  .update(localProductionRecords.toJson())
                  .eq('uuid', localProductionRecords.uuid!);
              await mainLocalLog(
                'Updated ProductionRecords with uuid ${localProductionRecords.uuid}',
              );
              await UpdatedProductionRecordsFunc()
                  .deleteUpdatedProductionRecords(
                    localProductionRecords.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Production Records ${localProductionRecords.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedProductionRecordsFunc()
            .clearUpdatedProductionRecordsRecord();
        await mainLocalLog(
          'Unsynced Production Records products cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Production Records ✅',
        );
        await getProductionRecords(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Production Records update failed ❌: $e',
      );
    }
  }
  //
  //

  //
  //
  //

  List<ProductionRecord> departmentProductionRecords() {
    return productionRecords.where((cat) {
      return returnDepartmentProvider()
          .matchesCurrentDepartment(
            departmentUuid: cat.departmentId,
          );
    }).toList();
  }

  List<ProductionRecord>
  returnProductionRecordsByDayOrWeek() {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentProductionRecords().where((
          productionRecord,
        ) {
          final created =
              productionRecord.createdAt!.toLocal();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        final currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentProductionRecords()
            .where(
              (productionRecord) =>
                  !productionRecord.createdAt!.isBefore(
                    fourAm(currentDate),
                  ) &&
                  productionRecord.createdAt!.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionRecords.where((
            productionRecord,
          ) {
            final created =
                productionRecord.createdAt!.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return productionRecords.where((
            productionRecord,
          ) {
            final created =
                productionRecord.createdAt!.toLocal();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                productionRecord.staffId ==
                    currentUser().userId;
          }).toList();
        }
      } else {
        final currentDate = dateSet ?? DateTime.now();

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return productionRecords
              .where(
                (productionRecord) =>
                    !productionRecord.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !productionRecord.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return productionRecords
              .where(
                (productionRecord) =>
                    !productionRecord.createdAt!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    !productionRecord.createdAt!.isAfter(
                      fourAmNextDay(currentDate),
                    ) &&
                    productionRecord.staffId ==
                        currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  double getTotalProducedInProduction({
    required List<ProductionRecord>? records,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .map((item) => (item.quantity ?? 0))
          .toList()
          .fold(0, (a, b) => a + b);
    } else {
      return (records ??
              returnProductionRecordsByDayOrWeek())
          .map((item) => (item.quantity ?? 0))
          .toList()
          .fold(0, (a, b) => a + b);
    }
  }

  List<ProductionRecordMaterials>
  returnAllProductionRecordMaterials({
    required List<ProductionRecord>? productionRecords,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .expand((item) => item.materials)
          .toList();
    } else {
      return (productionRecords ??
              returnProductionRecordsByDayOrWeek())
          .expand((item) => item.materials)
          .toList();
    }
  }

  double getTotalMaterialsUsed({
    required List<ProductionRecord>? productionRecords,
    List<String>? recordUuids,
  }) {
    if (recordUuids != null) {
      List<ProductionRecord> tempItems = [];
      for (var item
          in returnProductionRecordsByDayOrWeek()) {
        if (recordUuids.contains(item.uuid)) {
          tempItems.add(item);
        }
      }
      return (tempItems)
          .map((item) => item.quantity)
          .fold(0.0, (a, b) => a + (b ?? 0));
    } else {
      return returnAllProductionRecordMaterials(
            productionRecords: productionRecords,
          )
          .map((item) => item.quantity)
          .fold(0.0, (a, b) => a + b);
    }
  }

  double getTotalCostForProduction({
    required List<ProductionRecord> productionRecords,
  }) {
    return productionRecords
        .map((item) => item.getTotalCost())
        .fold(0, (a, b) => a + b);
  }
}
