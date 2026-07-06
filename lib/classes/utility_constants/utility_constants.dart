import 'package:hive/hive.dart';
part 'utility_constants.g.dart';

@HiveType(typeId: 90)
class UtilityConstants extends HiveObject {
  @HiveField(0)
  final String uuid;

  @HiveField(1)
  final double dollarRate;

  @HiveField(2)
  final double basicPlan;

  @HiveField(3)
  final double standardPlan;

  @HiveField(4)
  final double premiumPlan;

  @HiveField(5)
  final double silverPlan;

  @HiveField(6)
  final double goldPlan;

  @HiveField(7)
  final double sixMonthsDiscount;

  @HiveField(8)
  final double oneYearDiscount;

  @HiveField(9)
  final double vat;

  UtilityConstants({
    required this.uuid,
    required this.dollarRate,
    required this.basicPlan,
    required this.standardPlan,
    required this.premiumPlan,
    required this.silverPlan,
    required this.goldPlan,
    required this.sixMonthsDiscount,
    required this.oneYearDiscount,
    required this.vat,
  });

  factory UtilityConstants.fromJson(
    Map<String, dynamic> json,
  ) {
    return UtilityConstants(
      uuid: json['uuid'] as String,
      dollarRate: (json['dollar_rate'] as num).toDouble(),
      basicPlan: (json['basic_plan'] as num).toDouble(),
      standardPlan:
          (json['standard_plan'] as num).toDouble(),
      premiumPlan: (json['premium_plan'] as num).toDouble(),
      silverPlan: (json['silver_plan'] as num).toDouble(),
      goldPlan: (json['gold_plan'] as num).toDouble(),
      sixMonthsDiscount:
          (json['six_months_discount'] as num).toDouble(),
      oneYearDiscount:
          (json['one_year_discount'] as num).toDouble(),
      vat: (json['vat'] as num).toDouble(),
    );
  }
}
