import 'package:hive/hive.dart';

part 'country_model.g.dart';

@HiveType(typeId: 91)
class CountryModel extends HiveObject {
  @HiveField(0)
  String? country;

  @HiveField(1)
  String? countryCode;

  @HiveField(2)
  String? currency;

  @HiveField(3)
  String? currencySymbol;

  @HiveField(4)
  String? currencyName;

  CountryModel({
    this.country,
    this.countryCode,
    this.currency,
    this.currencySymbol,
    required this.currencyName,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      country: json['name'],
      countryCode: json['iso2'],
      currency: json['currency'],
      currencySymbol: json['currencySymbol'],
      currencyName: json['currencyName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': country,
      'iso2': countryCode,
      'currency': currency,
      'currencySymbol': currencySymbol,
      'currencyName': currencyName,
    };
  }
}

class StateModel {
  final String? stateName;
  final String code;

  StateModel({required this.stateName, required this.code});
}

class CurrencyModel {
  final String currency;
  final String currencyName;
  final String symbol;
  final String country;

  CurrencyModel({
    required this.currency,
    required this.currencyName,
    required this.symbol,
    required this.country,
  });
}
