import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/unsynced/quantity_update/quantity_update.dart';
import 'package:stockall/main.dart';

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
    try {
      if (!Hive.isAdapterRegistered(
        QuantityUpdateAdapter().typeId,
      )) {
        Hive.registerAdapter(QuantityUpdateAdapter());
        await mainLocalLog(
          'Quantity Update Adapter registered ✅',
        );
      }

      // Open the box only if it isn’t already open
      if (!Hive.isBoxOpen(quantityUpdateBoxName)) {
        _quantityUpdateBox =
            await Hive.openBox<QuantityUpdate>(
              quantityUpdateBoxName,
            );
        await mainLocalLog('Quantity Update Box opened ✅');
      } else {
        _quantityUpdateBox = Hive.box<QuantityUpdate>(
          quantityUpdateBoxName,
        );
        await mainLocalLog(
          'Quantity Update Box already open, reused ✅',
        );
      }
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Quantitiy Update Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
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

  // Future<int> createQuantityUpdate(
  //   QuantityUpdate quantityUpdate,
  // ) async {
  //   try {
  //     await quantityUpdateBox.put(
  //       quantityUpdate.uuid,
  //       quantityUpdate,
  //     );

  //     await mainLocalLog(
  //       'Offline Quantity Update inserted successfully ✅',
  //     );
  //     return 1;
  //   } catch (e) {
  //     await mainLocalLog(
  //       'Offline Quantity Update insertion failed ❌: $e',
  //     );
  //     return 0;
  //   }
  // }

  Future<int> createQuantityUpdate(
    QuantityUpdate quantityUpdate,
  ) async {
    try {
      final existingLogs = getQuantitiesUpdate().where(
        (item) =>
            item.productUuid == quantityUpdate.productUuid,
      );

      if (existingLogs.isEmpty) {
        await quantityUpdateBox.put(
          quantityUpdate.uuid,
          quantityUpdate,
        );

        await mainLocalLog(
          'Offline Quantity Update inserted successfully ✅',
        );
      } else {
        final existing = existingLogs.first;

        // Convert both values to signed numbers
        final double existingValue = existing.isIncrement
            ? existing.quantity
            : -existing.quantity;

        final double incomingValue =
            quantityUpdate.isIncrement
            ? quantityUpdate.quantity
            : -quantityUpdate.quantity;

        // Calculate the net value
        final double total = existingValue + incomingValue;

        // Convert back to absolute quantity + direction
        existing.quantity = total.abs();
        existing.isIncrement = total >= 0;

        // Save to Hive
        await quantityUpdateBox.put(
          existing.uuid,
          existing,
        );

        await mainLocalLog(
          'Offline Quantity Update merged successfully ✅',
        );
      }

      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Quantity Update insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteQuantityUpdate({
    required String uuid,
  }) async {
    try {
      await quantityUpdateBox.delete(uuid);
      await mainLocalLog('Quantity Update Deleted ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Quantity Update ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearQuantitiesUpdate() async {
    try {
      await quantityUpdateBox.clear();
      await mainLocalLog('All Quantity Update cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Quantity Update ❌: $e',
      );
      return 0;
    }
  }
}
