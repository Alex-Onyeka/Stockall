import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/local_database/products/products_func.dart';

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
    print('Product Record Box Initialized');
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
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('Record Insert Error: ${e.toString()}');
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
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('Record Insert Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createRecord(
    TempProductSaleRecord record,
  ) async {
    try {
      await productRecordBox.put(record.uuid, record);
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('Record Insert Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteRecord(String uuid) async {
    try {
      await productRecordBox.delete(uuid);
      print('Offline Record Deleted Successful');
      return 1;
    } catch (e) {
      print('Record Delete Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteRecordsInReceipt(
    String receiptUuid,
  ) async {
    print('Deleting Records in Receipt');
    try {
      List<TempProductSaleRecord> records =
          getProductRecords()
              .where(
                (record) =>
                    record.receiptUuid == receiptUuid,
              )
              .toList();
      print('Records Gotten: ${records.length}');
      for (var record in records) {
        if (record.isProductManaged!) {
          await ProductsFunc().incrementQuantity(
            quantity: record.quantity,
            uuid: record.productUuid!,
          );
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
        print('Records Deleted: ${record.productName}');
      }
      print(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      print('Record Delete Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await productRecordBox.clear();
      print('Offline Record Cleared Successful');
      return 1;
    } catch (e) {
      print('Record Clear Error: ${e.toString()}');
      return 0;
    }
  }
}
