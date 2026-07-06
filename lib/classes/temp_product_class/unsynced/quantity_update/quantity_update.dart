import 'package:hive/hive.dart';
part 'quantity_update.g.dart';

@HiveType(typeId: 96)
class QuantityUpdate extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  double createdAt;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  final String productUuid;

  @HiveField(4)
  final bool isIncrement;

  @HiveField(5)
  final String? otherUuid;

  QuantityUpdate({
    required this.uuid,
    required this.createdAt,
    required this.quantity,
    required this.productUuid,
    required this.isIncrement,
    required this.otherUuid,
  });
}
