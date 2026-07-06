import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';

class QuantityUpdateFunc {
  static final QuantityUpdateFunc instance =
      QuantityUpdateFunc._internal();
  factory QuantityUpdateFunc() => instance;
  QuantityUpdateFunc._internal();

  Box<QuantityUpdate>? _quantityUpdateBox;
  final String quantityUpdateBoxName =
      'quantityUpdateBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      QuantityUpdateAdapter().typeId,
    )) {
      Hive.registerAdapter(QuantityUpdateAdapter());
      print('Quantity Update Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(quantityUpdateBoxName)) {
      _quantityUpdateBox =
          await Hive.openBox<QuantityUpdate>(
            quantityUpdateBoxName,
          );
      print('Quantity Update Box opened ✅');
    } else {
      _quantityUpdateBox = Hive.box<QuantityUpdate>(
        quantityUpdateBoxName,
      );
      print('Quantity Update Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<QuantityUpdate> get quantityUpdateBox {
    if (_quantityUpdateBox == null) {
      throw Exception(
        " Quantity Update Func not initialized. Call await QuantityUpdateFunc.instance.init() first.",
      );
    }
    return _quantityUpdateBox!;
  }

  List<QuantityUpdate> getQuantitiesUpdate() {
    return quantityUpdateBox.values.toList();
  }

  Future<int> createQuantityUpdate(
    QuantityUpdate quantityUpdate,
  ) async {
    try {
      await quantityUpdateBox.put(
        quantityUpdate.uuid,
        quantityUpdate,
      );
      print(
        'Offline Quantity Update inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Quantity Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteQuantityUpdate({required String uuid}) async {
    try {
      await quantityUpdateBox.delete(uuid);
      print('Quantity Update Deleted ✅');
      return 1;
    } catch (e) {
      print('Error while Deleting Quantity Update ❌: $e');
      return 0;
    }
  }

  Future<int> clearQuantitiesUpdate() async {
    try {
      await quantityUpdateBox.clear();
      print('All Quantity Update cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Quantity Update ❌: $e');
      return 0;
    }
  }
}
