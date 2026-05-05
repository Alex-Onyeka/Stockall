import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/created/created_item_purchase_func.dart';
import 'package:stockall/local_database/item_purchase_func.dart%20copy/unsync_funcs/deleted/deleted_item_purchase_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';

class ItemPurchaseFunc {
  static final ItemPurchaseFunc instance =
      ItemPurchaseFunc._internal();
  factory ItemPurchaseFunc() => instance;
  ItemPurchaseFunc._internal();
  late Box<TempItemPurchaseRecord> itemPurchaseRecordsBox;
  final String itemPurchaseRecordsBoxName =
      'itemPurchaseRecordsBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempItemPurchaseRecordAdapter());
    itemPurchaseRecordsBox = await Hive.openBox(
      itemPurchaseRecordsBoxName,
    );
    await CreatedItemPurchaseFunc().init();
    await DeletedItemPurchaseFunc().init();
    print('Item Purchase Record Box Initialized');
  }

  List<TempItemPurchaseRecord> getItemPurchaseRecords() {
    List<TempItemPurchaseRecord> records =
        itemPurchaseRecordsBox.values.toList();
    records.sort(
      (a, b) => a.createdAt.compareTo(b.createdAt),
    );
    return records;
  }

  Future<int> insertAllItemPurchaseRecords(
    List<TempItemPurchaseRecord> records,
  ) async {
    await clearRecords();
    try {
      for (var record in records) {
        await itemPurchaseRecordsBox.put(
          record.uuid,
          record,
        );
      }
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('❌❌ Record Insert Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> insertSalesItemPurchaseRecords(
    List<TempItemPurchaseRecord> records,
  ) async {
    try {
      for (var record in records) {
        await itemPurchaseRecordsBox.put(
          record.uuid,
          record,
        );
      }
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('❌❌ Record Insert Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createRecord(
    TempItemPurchaseRecord record,
  ) async {
    try {
      await itemPurchaseRecordsBox.put(record.uuid, record);
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('❌❌ Record Insert Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteRecord(String uuid) async {
    try {
      await itemPurchaseRecordsBox.delete(uuid);
      print('Offline Record Deleted Successful');
      return 1;
    } catch (e) {
      print('❌❌ Record Delete Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> deleteRecordsInPurchase(
    String purchaseUuid,
  ) async {
    print('Deleting Records in Purchase');
    try {
      List<TempItemPurchaseRecord> records =
          getItemPurchaseRecords()
              .where(
                (record) =>
                    record.purchaseId == purchaseUuid,
              )
              .toList();
      print('Records Gotten: ${records.length}');
      for (var record in records) {
        // if (record.isProductManaged!) {
        //   await ProductsFunc().incrementQuantity(
        //     quantity: record.quantity,
        //     uuid: record.productUuid!,
        //   );
        // }
        await itemPurchaseRecordsBox.delete(record.uuid);
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
        print('Records Deleted');
      }
      print(
        '${records.length}} Offline Records Deleted Successful',
      );
      return 1;
    } catch (e) {
      print('❌❌ Record Delete Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearRecords() async {
    try {
      await itemPurchaseRecordsBox.clear();
      print('Offline Record Cleared Successful');
      return 1;
    } catch (e) {
      print('❌❌ Record Clear Error: ${e.toString()}');
      return 0;
    }
  }
}
