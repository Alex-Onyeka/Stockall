import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/classes/temp_waybills/waybill_items.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/created/created_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/deleted/deleted_waybills_func.dart';
import 'package:stockall/local_database/waybills/unsync_funcs/updated/updated_waybills_func.dart';

class WaybillsFunc {
  static final WaybillsFunc instance =
      WaybillsFunc._internal();
  factory WaybillsFunc() => instance;
  WaybillsFunc._internal();
  late Box<TempWayBills> waybillBox;
  final String waybillBoxName = 'waybillBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(WaybillItemsAdapter());
    Hive.registerAdapter(TempWayBillsAdapter());
    waybillBox = await Hive.openBox(waybillBoxName);
    await CreatedWaybillsFunc().init();
    await DeletedWaybillsFunc().init();
    await UpdatedWaybillsFunc().init();
    print('Waybill Box Initialized');
  }

  List<TempWayBills> getWaybills() {
    List<TempWayBills> waybills =
        waybillBox.values.toList();
    waybills.sort(
      (a, b) => b.createdAt!.compareTo(a.createdAt!),
    );
    return waybills;
  }

  Future<int> insertAllWaybills(
    List<TempWayBills> waybills,
  ) async {
    await clearWaybills();
    try {
      for (var waybill in waybills) {
        await waybillBox.put(waybill.uuid, waybill);
      }
      print('Offline Waybill Success');
      return 1;
    } catch (e) {
      print('Offline Waybill Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createWaybill(TempWayBills waybill) async {
    try {
      await waybillBox.put(waybill.uuid, waybill);
      print('Offline Waybill Created');
      return 1;
    } catch (e) {
      print('Offline Waybill Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> updateWaybill(TempWayBills waybill) async {
    try {
      await waybillBox.put(waybill.uuid, waybill);
      print('Offline Waybill Updated');
      return 1;
    } catch (e) {
      print(
        'Offline Waybill Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteWaybill(String uuid) async {
    try {
      await waybillBox.delete(uuid);
      print('Offline Waybill Deleted');
      return 1;
    } catch (e) {
      print('Offline Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearWaybills() async {
    try {
      await waybillBox.clear();
      print('Offline Waybills Cleared');
      return 1;
    } catch (e) {
      print(
        'Offline Waybill Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }
}
