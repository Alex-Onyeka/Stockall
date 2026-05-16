import 'package:hive/hive.dart';
import 'package:stockall/classes/locations/country_model.dart';

class CountriesFunc {
  static final CountriesFunc instance =
      CountriesFunc._internal();
  factory CountriesFunc() => instance;
  CountriesFunc._internal();
  late Box<CountryModel> countrysBox;
  final String countrysBoxName = 'countrysBoxStockall';
  // final String locationBoxName = 'locationBoxStockall';

  Future<void> init() async {
    // try {
    //   await Hive.deleteBoxFromDisk(locationBoxName);
    // } catch (e) {
    //   print('Error Deleting Location Box: ${e.toString()}');
    // }
    Hive.registerAdapter(CountryModelAdapter());
    countrysBox = await Hive.openBox(countrysBoxName);
    print('✅Countries Box Initialized');
  }

  List<CountryModel> getCountryModel() {
    return countrysBox.values.toList();
  }

  Future<int> insertCountries(
    List<CountryModel> countrys,
  ) async {
    try {
      for (var locat in countrys) {
        await countrysBox.put(locat.country, locat);
      }
      print('Countries inserted Success');
      return 1;
    } catch (e) {
      print(
        '❌❌ Insert Countries Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearCountriess() async {
    await countrysBox.clear();
    print('Offline Countries Cleared');
  }
}
