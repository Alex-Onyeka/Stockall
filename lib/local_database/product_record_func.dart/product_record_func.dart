import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
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

  Future<int> deleteRecordsInReceipt(
    String receiptUuid,
  ) async {
    await mainLocalLog('Deleting Records in Receipt');
    try {
      List<TempProductSaleRecord> records =
          getProductRecords()
              .where(
                (record) =>
                    record.receiptUuid == receiptUuid,
              )
              .toList();
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      for (var record in records) {
        if (record.isProductManaged! && !record.isVoid!) {
          List<TempProductClass> products =
              returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == record.productUuid,
                  )
                  .toList();
          if (products.isNotEmpty) {
            var oldProduct = products.first;
            var product = oldProduct.copyWith();
            final oldQuantity = oldProduct.quantity ?? 0;
            final quantityChange =
                record.getActualQuantity();
            product.quantity = oldQuantity + quantityChange;
            final newQuantity = product.quantity ?? 0;
            final primaryUnit = product.getPrimaryUnit();
            final primaryUnitConversion =
                primaryUnit.conversion;
            ItemHistory itemHistory = ItemHistory(
              shopId: shopId(),
              title: 'Item Returned',
              desc:
                  '${record.quantity} ${record.unit} of This Item was Returned. Receipt Id: #${returnOnlyDigits(receiptUuid)}.',
              quantityChange: record.quantity,
              newValue: formatLargeNumberDouble(
                newQuantity / primaryUnitConversion,
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                oldQuantity / primaryUnitConversion,
              ),
              unit: record.unit,
              primaryUnit: primaryUnit.name,
            );
            await returnData().updateProduct(
              itemHistory: itemHistory,
              includeQuantity: false,
              isMultipleUpdate: true,
              product: product,
              isQuantityUpdate: true,
              quantityChange: record.getActualQuantity(),
              isIncrement: true,
            );
          }
        }
        if (record.isProductManaged! == false) {
          List<TempProductClass> products =
              returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == record.productUuid,
                  )
                  .toList();
          if (products.isNotEmpty) {
            var product = products.first;
            ItemHistory itemHistory = ItemHistory(
              shopId: shopId(),
              title: 'Receipt Deleted (Unmanaged)',
              desc:
                  '${record.quantity} ${record.unit} of This Item was Returned of This Item was Returned, but this item unmanaged when the sales was made, so the quantity did not increase. Receipt Id: #${returnOnlyDigits(receiptUuid)}.',
              quantityChange: 0,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: product.quantity,
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: product.quantity,
                      product: product,
                    ),
              ),
              unit: record.unit,
              primaryUnit: product.getPrimaryUnit().name,
            );
            itemHistory.itemName = product.name;
            itemHistory.itemUuid = product.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
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
  deleteRecordsInReceiptWithoutUpdatingInventory(
    String receiptUuid,
  ) async {
    await mainLocalLog('Deleting Records in Receipt 2');
    try {
      List<TempProductSaleRecord> records =
          getProductRecords()
              .where(
                (record) =>
                    record.receiptUuid == receiptUuid,
              )
              .toList();
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

  Future<int> deleteRecordsInInvoice(
    String invoiceUuid,
  ) async {
    await mainLocalLog('Deleting Records in Invoice');
    try {
      List<TempProductSaleRecord> records =
          getProductRecords()
              .where(
                (record) =>
                    record.invoiceUuid == invoiceUuid,
              )
              .toList();
      await mainLocalLog(
        'Records Gotten: ${records.length}',
      );
      for (var record in records) {
        if (record.isProductManaged! && !record.isVoid!) {
          List<TempProductClass> products =
              returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == record.productUuid,
                  )
                  .toList();
          if (products.isNotEmpty) {
            var oldProduct = products.first;
            var product = oldProduct.copyWith();
            product.quantity =
                (product.quantity ?? 0) +
                record.getSelectedUnitQuantityMultiplied();
            ItemHistory itemHistory = ItemHistory(
              shopId: shopId(),
              title: 'Item Returned',
              desc:
                  '${record.quantity} ${record.unit} of This Item was Returned. Invoice Id: #${returnOnlyDigits(invoiceUuid)}.',
              quantityChange: record.quantity,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: product.quantity,
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                oldProduct
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: oldProduct.quantity,
                      product: oldProduct,
                    ),
              ),
              unit: record.unit,
              primaryUnit: product.getPrimaryUnit().name,
            );
            await returnData().updateProduct(
              itemHistory: itemHistory,
              includeQuantity: false,
              isMultipleUpdate: true,
              product: product,
              isQuantityUpdate: true,
              quantityChange:
                  record
                      .getSelectedUnitQuantityMultiplied(),
              isIncrement: true,
            );
          }
        }

        if (record.isProductManaged! == false) {
          List<TempProductClass> products =
              returnData().productListMain
                  .where(
                    (item) =>
                        item.uuid == record.productUuid,
                  )
                  .toList();
          if (products.isNotEmpty) {
            var product = products.first;
            ItemHistory itemHistory = ItemHistory(
              shopId: shopId(),
              title: 'Invoice Deleted (Unmanaged)',
              desc:
                  '${record.quantity} ${record.unit} of This Item was Returned, but this item was unmanaged when the sales was made, so the quantity did not increase. Invoice Id: #${returnOnlyDigits(invoiceUuid)}.',
              quantityChange: 0,
              newValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: product.quantity,
                      product: product,
                    ),
              ),
              isIncreased: true,
              oldValue: formatLargeNumberDouble(
                product
                    .getProductUnit()
                    .getQuantityEquivDivided(
                      index: 1,
                      newQuantity: product.quantity,
                      product: product,
                    ),
              ),
              unit: record.unit,
              primaryUnit: product.getPrimaryUnit().name,
            );
            itemHistory.itemName = product.name;
            itemHistory.itemUuid = product.uuid;
            await returnItemHistoryProvider()
                .createItemHistory(itemHistory);
          }
        }
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
  deleteRecordsInInvoiceWithoutUpdatingInventory(
    String invoiceUuid,
  ) async {
    await mainLocalLog(
      'Deleting Records in Invoice Without Updating Products',
    );
    try {
      List<TempProductSaleRecord> records =
          getProductRecords()
              .where(
                (record) =>
                    record.invoiceUuid == invoiceUuid,
              )
              .toList();
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
