import 'package:hive/hive.dart';
part 'quantity_update.g.dart';

@HiveType(typeId: 96)
class QuantityUpdate extends HiveObject {
  @HiveField(0)
  String? uuid;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  double quantity;

  @HiveField(3)
  final String productUuid;

  @HiveField(4)
  bool isIncrement;

  @HiveField(5)
  bool isStorage;

  // @HiveField(5)
  // final String? otherUuid;

  QuantityUpdate({
    this.uuid,
    this.createdAt,
    required this.quantity,
    required this.productUuid,
    this.isIncrement = true,
    required this.isStorage,
    // required this.otherUuid,
  });
}
