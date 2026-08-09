import 'package:hive/hive.dart';
part 'deleted_production_item.g.dart';

@HiveType(typeId: 111)
class DeletedProductionItem extends HiveObject {
  @HiveField(0)
  final String productionItemUuid;

  DeletedProductionItem({required this.productionItemUuid});
}
