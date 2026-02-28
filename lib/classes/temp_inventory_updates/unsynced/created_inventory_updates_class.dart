import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_inventory_updates/temp_inventory_update_class.dart';

part 'created_inventory_updates_class.g.dart';

@HiveType(typeId: 53)
class CreatedInventoryUpdatesClass {
  @HiveField(0)
  final TempInventoryUpdateClass inventoryUpdate;
  CreatedInventoryUpdatesClass({
    required this.inventoryUpdate,
  });
}
