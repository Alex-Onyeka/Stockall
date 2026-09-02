import 'package:hive/hive.dart';
part 'continuous_print_docket.g.dart';

@HiveType(typeId: 138)
class ContinuousPrintDocket extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  bool isOn;

  ContinuousPrintDocket({
    required this.id,
    required this.isOn,
  });

  factory ContinuousPrintDocket.fromJson(
    Map<String, dynamic> json,
  ) {
    return ContinuousPrintDocket(
      id: json['id'] as int,
      isOn: json['is_on'] as bool,
    );
  }
}
