import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';

part 'created_item_history.g.dart';

@HiveType(typeId: 98)
class CreatedItemHistory {
  @HiveField(0)
  final ItemHistory itemHistory;
  CreatedItemHistory({required this.itemHistory});
}
