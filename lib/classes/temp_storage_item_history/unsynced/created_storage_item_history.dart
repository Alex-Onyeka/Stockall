import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';

part 'created_storage_item_history.g.dart';

@HiveType(typeId: 144)
class CreatedStorageItemHistory {
  @HiveField(0)
  final StorageItemHistory storageItemHistory;
  CreatedStorageItemHistory({
    required this.storageItemHistory,
  });
}
