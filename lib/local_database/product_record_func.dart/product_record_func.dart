import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/main.dart';

class ProductRecordFunc {
  static final ProductRecordFunc instance =
      ProductRecordFunc._internal();
  factory ProductRecordFunc() => instance;
  ProductRecordFunc._internal();
  late Box<TempProductSaleRecord> productRecordBox;
  final String productRecordBoxName =
      'productRecordBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempProductSaleRecordAdapter());
    productRecordBox = await Hive.openBox(
      productRecordBoxName,
    );
    await CreatedRecordsFunc().init();
    await mainLocalLog('Product Record Box Initialized');
  }

  List<TempProductSaleRecord> getProductRecords() {
    List<TempProductSaleRecord> records =
        productRecordBox.values.toList();
    records.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    return records;
  }

  Future<int> insertAllProductRecords(
    List<TempProductSaleRecord> records,
  ) async {
    await clearRecords();
    try {
      for (var record in records) {
        await productRecordBox.put(record.uuid, record);
      }
      await mainLocalLog(
        'Offline Record insert Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Insert Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> insertSalesProductRecords(
    List<TempProductSaleRecord> records,
  ) async {
    try {
      for (var record in records) {
        await productRecordBox.put(record.uuid, record);
      }
      await mainLocalLog(
        'Offline Record insert Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Insert Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createRecord(
    TempProductSaleRecord record,
  ) async {
    try {
      await productRecordBox.put(record.uuid, record);
      await mainLocalLog(
        'Offline Record insert Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Insert Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteRecord(String uuid) async {
    try {
      await productRecordBox.delete(uuid);
      await mainLocalLog(
        'Offline Record Deleted Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Delete Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteRecordsInReceipt({
    required TempMainReceipt receipt,
  }) async {
    await mainLocalLog('Deleting Records in Receipt');
    try {
      TempMainReceipt newReceipt = receipt.copyWith();
      List<TempProductSaleRecord> records =
          (newReceipt.tempItems ?? newReceipt.getItems())
              .toList()
              .map((item) => item.copy())
              .toList();
      if (records.isEmpty && newReceipt.uuid != null) {
        records =
            productRecordBox.values
                .where(
                  (item) =>
                      item.receiptUuid == newReceipt.uuid,
                )
                .toList();
      }
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      final groupedRecords =
          <String, List<TempProductSaleRecord>>{};
      for (final record in records) {
        final key =
            (record.productUuid != null &&
                    record.productUuid!.isNotEmpty)
                ? record.productUuid!
                : 'record_${record.uuid}';
        groupedRecords
            .putIfAbsent(key, () => [])
            .add(record);
      }

      for (final group in groupedRecords.values) {
        final activeRecords =
            group.where((r) => r.isVoid != true).toList();
        if (activeRecords.isEmpty) continue;

        final refRecord = activeRecords.first;
        final isProductManaged =
            refRecord.isProductManaged ?? false;
        final productUuid = refRecord.productUuid;

        List<TempProductClass> products =
            returnData().productListMain
                .where((item) => item.uuid == productUuid)
                .toList();

        if (products.isNotEmpty) {
          var oldProduct = products.first;
          var product = oldProduct.copyWith();
          final oldQuantity =
              oldProduct.getActualQuantity() ?? 0;

          double totalStockChange = 0.0;
          double totalDisplayChange = 0.0;
          double totalWastageInSaleUnit = 0.0;
          bool anyWithWastage = false;

          for (final record in activeRecords) {
            final withWastage =
                record.manageSalesWastage == true;
            if (withWastage) anyWithWastage = true;
            final quantityChange =
                withWastage
                    ? record.getStockQuantity()
                    : record.getActualQuantity();
            totalStockChange += quantityChange;
            totalDisplayChange +=
                withWastage
                    ? record.historyQuantityChange(
                      product: product,
                    )
                    : (record.quantity ?? 0);
            totalWastageInSaleUnit += record
                .wastageInSaleUnit(product: product);
          }

          final restoredArea =
              oldQuantity + totalStockChange;
          final primaryUnit = product.getPrimaryUnit();
          final primaryQtyEquiv = primaryUnit
              .getQuantityEquivDivided(
                index: 1,
                newQuantity: totalStockChange,
                product: product,
              );
          final historyUnitName = formatHistoryUnit(
            selectedUnit: refRecord.getSelectedUnit().name,
            primaryUnit: primaryUnit.name,
            primaryQuantity: primaryQtyEquiv,
          );
          final primUnitName =
              primaryUnit.name == 'Others' ? 'Unit(s)' : primaryUnit.name;
          final wastageText =
              totalWastageInSaleUnit > 1e-9
                  ? ' (including ${formatDimension(totalWastageInSaleUnit)} $primUnitName wastage)'
                  : '';

          if (isProductManaged) {
            product.quantity =
                product.quantityType == 2
                    ? restoredArea / product.dimensionArea()
                    : restoredArea;

            ItemHistory itemHistory = ItemHistory(
              isManaged: true,
              source: 'receipt',
              event: ItemHistoryEventClass.returnEvent,
              shopId: shopId(),
              title: 'Item Returned',
              desc:
                  anyWithWastage
                      ? '${formatDimension(totalDisplayChange)} $historyUnitName$wastageText of This Item was Returned. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}.'
                      : '${formatDimension(totalDisplayChange)} $historyUnitName of This Item was Returned. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}.',
              quantityChange: totalDisplayChange,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          product.getActualQuantity(),
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          oldProduct.getActualQuantity(),
                      product: product,
                    ),
              ),
              unit: historyUnitName,
              primaryUnit: primaryUnit.name,
            );

            await returnData().updateProduct(
              itemHistory: itemHistory,
              includeQuantity: false,
              isMultipleUpdate: true,
              product: product,
              isQuantityUpdate: true,
              quantityChange:
                  product.quantityType == 2
                      ? totalStockChange /
                          product.dimensionArea()
                      : totalStockChange,
              isIncrement: true,
            );
          } else {
            ItemHistory itemHistory = ItemHistory(
              isManaged: false,
              source: ItemHistoryEventClass.receiptSource,
              event: ItemHistoryEventClass.returnEvent,
              shopId: shopId(),
              title: 'Receipt Deleted (Unmanaged)',
              desc:
                  '${formatDimension(totalDisplayChange)} $historyUnitName of This Item was Returned, but this item unmanaged when the sales was made, so the quantity did not increase. Receipt Id: #${returnOnlyDigits(receipt.uuid ?? '')}.',
              quantityChange: 0,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          product.getActualQuantity(),
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          product.getActualQuantity(),
                      product: product,
                    ),
              ),
              unit: historyUnitName,
              primaryUnit: product.getPrimaryUnit().name,
            );
            itemHistory.itemName = product.name;
            itemHistory.itemUuid = product.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
      }

      for (var record in records) {
        await productRecordBox.delete(record.uuid);
        var containsCreated = CreatedRecordsFunc()
            .getRecords()
            .where(
              (sales) => sales.record.uuid == record.uuid,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedRecordsFunc().deleteRecords(
            record.uuid!,
          );
        }
        await mainLocalLog(
          'Records Deleted: ${record.productName}',
        );
      }
      await mainLocalLog(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Delete Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int>
  deleteRecordsInReceiptWithoutUpdatingInventory({
    required TempMainReceipt receipt,
  }) async {
    await mainLocalLog('Deleting Records in Receipt 2');
    try {
      List<TempProductSaleRecord> records = [];
      if (receipt.uuid != null &&
          receipt.uuid!.isNotEmpty) {
        records =
            productRecordBox.values
                .where(
                  (item) =>
                      item.receiptUuid == receipt.uuid,
                )
                .toList();
      }
      if (records.isEmpty) {
        records =
            (receipt.tempItems ?? receipt.getItems())
                .toList();
      }
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      for (var record in records) {
        await productRecordBox.delete(record.uuid);
        var containsCreated = CreatedRecordsFunc()
            .getRecords()
            .where(
              (sales) => sales.record.uuid == record.uuid,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedRecordsFunc().deleteRecords(
            record.uuid!,
          );
        }
        await mainLocalLog(
          'Records Deleted: ${record.productName}',
        );
      }
      await mainLocalLog(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Delete Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteRecordsInInvoice({
    required TempInvoice invoice,
  }) async {
    await mainLocalLog('Deleting Records in Invoice');
    try {
      List<TempProductSaleRecord> records =
          (invoice.tempItems ?? invoice.getItems())
              .toList();
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      final groupedRecords =
          <String, List<TempProductSaleRecord>>{};
      for (final record in records) {
        final key =
            (record.productUuid != null &&
                    record.productUuid!.isNotEmpty)
                ? record.productUuid!
                : 'record_${record.uuid}';
        groupedRecords
            .putIfAbsent(key, () => [])
            .add(record);
      }

      for (final group in groupedRecords.values) {
        final activeRecords =
            group.where((r) => r.isVoid != true).toList();
        if (activeRecords.isEmpty) continue;

        final refRecord = activeRecords.first;
        final isProductManaged =
            refRecord.isProductManaged ?? false;
        final productUuid = refRecord.productUuid;

        List<TempProductClass> products =
            returnData().productListMain
                .where((item) => item.uuid == productUuid)
                .toList();

        if (products.isNotEmpty) {
          var oldProduct = products.first;
          var product = oldProduct.copyWith();
          final oldQuantity =
              oldProduct.getActualQuantity() ?? 0;

          double totalStockChange = 0.0;
          double totalDisplayChange = 0.0;
          double totalWastageInSaleUnit = 0.0;

          for (final record in activeRecords) {
            totalStockChange += record.getStockQuantity();
            totalDisplayChange += record
                .historyQuantityChange(product: product);
            totalWastageInSaleUnit += record
                .wastageInSaleUnit(product: product);
          }

          final restoredArea =
              oldQuantity + totalStockChange;
          final primaryUnit = product.getPrimaryUnit();
          final primaryQtyEquiv = primaryUnit
              .getQuantityEquivDivided(
                index: 1,
                newQuantity: totalStockChange,
                product: product,
              );
          final historyUnitName = formatHistoryUnit(
            selectedUnit: refRecord.getSelectedUnit().name,
            primaryUnit: primaryUnit.name,
            primaryQuantity: primaryQtyEquiv,
          );
          final primUnitName =
              primaryUnit.name == 'Others' ? 'Unit(s)' : primaryUnit.name;
          final wastageText =
              totalWastageInSaleUnit > 1e-9
                  ? ' (including ${formatDimension(totalWastageInSaleUnit)} $primUnitName wastage)'
                  : '';

          if (isProductManaged) {
            product.quantity =
                product.quantityType == 2
                    ? restoredArea / product.dimensionArea()
                    : restoredArea;

            ItemHistory itemHistory = ItemHistory(
              isManaged: true,
              source: 'invoice',
              event: ItemHistoryEventClass.returnEvent,
              shopId: shopId(),
              title: 'Item Returned',
              desc:
                  '${formatDimension(totalDisplayChange)} $historyUnitName$wastageText of This Item was Returned. Invoice Id: #${returnOnlyDigits(invoice.uuid ?? '')}.',
              quantityChange: totalDisplayChange,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          product.getActualQuantity(),
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          oldProduct.getActualQuantity(),
                      product: product,
                    ),
              ),
              unit: historyUnitName,
              primaryUnit: primaryUnit.name,
            );

            await returnData().updateProduct(
              itemHistory: itemHistory,
              includeQuantity: false,
              isMultipleUpdate: true,
              product: product,
              isQuantityUpdate: true,
              quantityChange:
                  product.quantityType == 2
                      ? totalStockChange /
                          product.dimensionArea()
                      : totalStockChange,
              isIncrement: true,
            );
          } else {
            ItemHistory itemHistory = ItemHistory(
              event: ItemHistoryEventClass.returnEvent,
              source: ItemHistoryEventClass.invoiceSource,
              isManaged: false,
              shopId: shopId(),
              title: 'Invoice Deleted (Unmanaged)',
              desc:
                  '${formatDimension(totalDisplayChange)} $historyUnitName of This Item was Returned, but this item was unmanaged when the sales was made, so the quantity did not increase. Invoice Id: #${returnOnlyDigits(invoice.uuid ?? '')}.',
              quantityChange: 0,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          product.getActualQuantity(),
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity:
                          oldProduct.getActualQuantity(),
                      product: product,
                    ),
              ),
              unit: historyUnitName,
              primaryUnit: product.getPrimaryUnit().name,
            );
            itemHistory.itemName = product.name;
            itemHistory.itemUuid = product.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
      }

      for (var record in records) {
        await productRecordBox.delete(record.uuid);
        var containsCreated = CreatedRecordsFunc()
            .getRecords()
            .where(
              (sales) => sales.record.uuid == record.uuid,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedRecordsFunc().deleteRecords(
            record.uuid!,
          );
        }
        await mainLocalLog(
          'Records Deleted: ${record.productName}',
        );
      }
      await mainLocalLog(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Delete Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int>
  deleteRecordsInInvoiceWithoutUpdatingInventory({
    required TempInvoice invoice,
  }) async {
    await mainLocalLog(
      'Deleting Records in Invoice Without Updating Products',
    );
    try {
      List<TempProductSaleRecord> records = [];
      if (invoice.uuid != null &&
          invoice.uuid!.isNotEmpty) {
        records =
            productRecordBox.values
                .where(
                  (item) =>
                      item.invoiceUuid == invoice.uuid,
                )
                .toList();
      }
      if (records.isEmpty) {
        records =
            (invoice.tempItems ?? invoice.getItems())
                .toList();
      }
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      for (var record in records) {
        await productRecordBox.delete(record.uuid);
        var containsCreated = CreatedRecordsFunc()
            .getRecords()
            .where(
              (sales) => sales.record.uuid == record.uuid,
            );
        if (containsCreated.isNotEmpty) {
          await CreatedRecordsFunc().deleteRecords(
            record.uuid!,
          );
        }
        await mainLocalLog(
          'Records Deleted: ${record.productName}',
        );
      }
      await mainLocalLog(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Delete Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await productRecordBox.clear();
      await mainLocalLog(
        'Offline Record Cleared Successful',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Record Clear Error: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedRecordsFunc().getRecords().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
