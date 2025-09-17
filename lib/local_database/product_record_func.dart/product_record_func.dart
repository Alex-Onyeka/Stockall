import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';

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
    print('Product Record Box Initialized');
  }

  List<TempProductSaleRecord> getProductRecords() {
    return productRecordBox.values.toList();
  }

  Future<int> insertAllProductRecords(
    List<TempProductSaleRecord> records,
  ) async {
    try {
      for (var record in records) {
        await productRecordBox.put(
          record.productRecordId,
          record,
        );
      }
      print('Offline Record insert Successful');
      return 1;
    } catch (e) {
      print('Record Insert Error: ${e.toString()}');
      return 0;
    }
  }
}
