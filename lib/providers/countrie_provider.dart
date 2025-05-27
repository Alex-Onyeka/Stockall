// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// class CountrieProvider extends ChangeNotifier {
//   Future<void> fetchCountries() async {
//     final url = Uri.parse(
//       'https://api.countrystatecity.in/v1/countries',
//     );
//     final response = await http.get(
//       url,
//       headers: {'X-CSCAPI-KEY': apiKey},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = jsonDecode(
//         response.body,
//       );

//       // Convert List<dynamic> to List<String>
//       final List<String> countryNames =
//           responseData
//               .map<String>(
//                 (country) => country['name'].toString(),
//               )
//               .toList();

//       // Assign it to countries
//       setCountries(countryNames, responseData);
//     } else {
//       throw Exception('Failed to load countries');
//     }
//   }

//   void setCountries(
//     List<String> texts,
//     List<dynamic> list,
//   ) {
//     countries = texts;
//     countriesCodes = list;
//     notifyListeners();
//   }

//   Future<void> fetchStates(String countryCode) async {
//     final url = Uri.parse(
//       'https://api.countrystatecity.in/v1/countries/$countryCode/states',
//     );
//     final response = await http.get(
//       url,
//       headers: {'X-CSCAPI-KEY': apiKey},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = jsonDecode(
//         response.body,
//       );

//       final List<String> stateNames =
//           responseData
//               .map<String>(
//                 (state) => state['name'].toString(),
//               )
//               .toList();

//       setStates(stateNames, responseData);
//     } else {
//       throw Exception('Failed to load states');
//     }
//   }

//   void setStates(List<String> texts, List<dynamic> list) {
//     states = texts;
//     stateCodes = list;
//     cities = [];
//     notifyListeners();
//   }

//   Future<void> fetchCities(
//     String countryCode,
//     String stateCode,
//   ) async {
//     final url = Uri.parse(
//       'https://api.countrystatecity.in/v1/countries/$countryCode/states/$stateCode/cities',
//     );
//     final response = await http.get(
//       url,
//       headers: {'X-CSCAPI-KEY': apiKey},
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = jsonDecode(
//         response.body,
//       );

//       final List<String> cityNames =
//           responseData
//               .map<String>(
//                 (city) => city['name'].toString(),
//               )
//               .toList();

//       setCities(cityNames);
//     } else {
//       throw Exception('Failed to load cities');
//     }
//   }

//   void setCities(List<String> texts) {
//     cities = texts;

//     notifyListeners();
//   }

//   final String apiKey =
//       'ZmdubFNvNDloNjBrNWs2VGpTQ0ttem1Xa3A1SVdZZmpWTE5tdnBKVw==';

//   List<String> countries = [];
//   List<dynamic> countriesCodes = [];
//   List<String> states = [];
//   List<dynamic> stateCodes = [];
//   List<String> cities = [];

//   String? selectedCountryCode;
//   String selectedCountryName = 'Select Your Country';
//   String? selectedStateCode;
//   String selectedStateName = 'Select Your State';
//   String? selectedCity;
//   String selectedCityName = 'Select Your City';
// }
