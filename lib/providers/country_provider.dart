import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stockall/classes/locations/country_model.dart';
import 'package:stockall/local_database/countries/countries_func.dart';

class CountryProvider extends ChangeNotifier {
  static final CountryProvider _instance =
      CountryProvider._internal();
  factory CountryProvider() => _instance;
  CountryProvider._internal();
  List<CountryModel> countries = [];
  List<StateModel> states = [];
  List<String> cities = [];

  void clearAll() {
    states.clear();
    cities.clear();
    selectedCountry = null;
    selectedCurrency = null;
    selectedState = null;
    selectedCity = null;
    notifyListeners();
  }

  List<CountryModel> getCountries() {
    countries.sort(
      (a, b) => a.country!.compareTo(b.country!),
    );
    return countries.toList();
  }

  void selectCountry(String? country, bool isUpdate) async {
    selectedCountry =
        countries
                .where((coun) => coun.country == country)
                .isNotEmpty
            ? countries
                .where((coun) => coun.country == country)
                .first
            : null;
    notifyListeners();
    if (selectedCountry != null && !isUpdate) {
      selectedState = null;
      states.clear();
      notifyListeners();
      await fetchStates();
    }
  }

  List<StateModel> getStates() {
    states.sort(
      (a, b) => a.stateName!.compareTo(b.stateName!),
    );
    return states.toList();
  }

  void selectState(String? state, bool isUpdate) async {
    selectedState =
        states
                .where((coun) => coun.stateName == state)
                .isNotEmpty
            ? states
                .where((coun) => coun.stateName == state)
                .first
            : null;
    notifyListeners();
    if (selectedState != null && !isUpdate) {
      selectedCity = null;
      cities.clear();
      notifyListeners();
      await fetchCities();
    }
  }

  void setCustomState(StateModel state) {
    selectedState = state;
    selectedCity = null;
    cities.clear();
    notifyListeners();
  }

  void selectCity(String? code) {
    selectedCity = code;
    notifyListeners();
  }

  void setCustomCity(String city) {
    selectedCity = city;
    notifyListeners();
  }

  CountryModel? selectedCountry;
  StateModel? selectedState;

  String? selectedCity;

  List<CurrencyModel> getCurrencies() {
    return countries
        .map(
          (loca) => CurrencyModel(
            currency: loca.currency ?? 'Not Set',
            symbol: loca.currencySymbol ?? 'Not Sett',
            country: loca.country ?? 'not Set',
            currencyName: loca.currencyName ?? 'Not Set',
          ),
        )
        .toList();
  }

  CurrencyModel? selectedCurrency;

  void setCurrency(String symbol) {
    selectedCurrency =
        getCurrencies()
                .where(
                  (currency) => currency.symbol == symbol,
                )
                .isNotEmpty
            ? getCurrencies()
                .where(
                  (currency) => currency.symbol == symbol,
                )
                .first
            : null;
    notifyListeners();
  }

  bool isLoading = false;

  Future<void> fetchCountries() async {
    try {
      isLoading = true;
      notifyListeners();

      // prevent unnecessary API calls
      if (CountriesFunc().getCountryModel().isNotEmpty) {
        countries = CountriesFunc().getCountryModel();

        isLoading = false;
        notifyListeners();
        print(
          'Countrys Gotten Successfully Offline: ${countries.length}',
        );

        return;
      }

      final response = await http.get(
        Uri.https('api.geocoded.me', '/countries', {
          'fields':
              'name,iso2,currency,currencyName,currencySymbol',
          'limit': '250',
          'offset': '0',
        }),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          response.body,
        );

        final List countriesData = data['data'];
        List<CountryModel> locatTemp =
            countriesData
                .map((loca) => CountryModel.fromJson(loca))
                .toList();

        countries = locatTemp;

        CountriesFunc().insertCountries(locatTemp);
        isLoading = false;
        print(
          'Countrys Gotten Successfully Online: ${locatTemp.length}',
        );

        notifyListeners();
      } else {
        throw Exception(
          'Failed to fetch countries: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching countries: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStates() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.https(
          'api.geocoded.me',
          '/countries/${selectedCountry?.countryCode ?? "NGN"}/states',
          {
            'fields': 'name,iso2',
            // 'q': 'san',
            'limit': '50',
            'offset': '0',
          },
        ),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          response.body,
        );

        final List statesData = data['data'];
        List<StateModel> locatTemp =
            statesData
                .map(
                  (loca) => StateModel(
                    stateName: loca['name'],
                    code: loca['iso2'],
                  ),
                )
                .toList();

        states = locatTemp;

        isLoading = false;
        print(
          'States Gotten Successfully Online: ${locatTemp.length}',
        );

        notifyListeners();
      } else {
        throw Exception(
          'Failed to fetch states: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching states: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCities() async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.https(
          'api.geocoded.me',
          '/countries/${selectedCountry?.countryCode}/states/${selectedState?.code}/cities',
          {
            'fields': 'name',
            // 'q': 'san',
            'limit': '100',
            'offset': '0',
          },
        ),
      );
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(
          response.body,
        );

        final List citiesData = data['data'];
        List<String> locatTemp =
            citiesData
                .map((loca) => loca['name'] as String)
                .toList();

        cities = locatTemp;

        isLoading = false;
        print(
          'Cities Gotten Successfully Online: ${locatTemp.length}',
        );

        notifyListeners();
      } else {
        throw Exception(
          'Failed to fetch cities: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
