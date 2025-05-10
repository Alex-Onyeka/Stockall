import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/main.dart';

class CustomersProvider extends ChangeNotifier {
  List<TempCustomersClass> customers = [
    TempCustomersClass(
      shopId: 1,
      dateAdded: DateTime(2025, 8, 6),
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '08012345678',
      address: '12 Adeola Street',
      city: 'Lagos',
      state: 'Lagos',
      country: 'Nigeria',
    ),
    TempCustomersClass(
      shopId: 2,
      dateAdded: DateTime(2025, 5, 5),
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '08098765432',
      address: '45 Unity Road',
      city: 'Abuja',
      state: 'FCT',
      country: 'Nigeria',
    ),
    TempCustomersClass(
      shopId: 2,
      dateAdded: DateTime(2025, 5, 6),
      id: 3,
      name: 'Emeka Obi',
      email: 'emeka@example.com',
      phone: '08123456789',
      address: '10 Nnamdi Avenue',
      city: 'Enugu',
      state: 'Enugu',
      country: 'Nigeria',
    ),
    TempCustomersClass(
      shopId: 1,
      dateAdded: DateTime(2025, 6, 6),
      id: 4,
      name: 'Aisha Bello',
      email: 'aisha@example.com',
      phone: '09011223344',
      address: '23 Wuse Zone 4',
      city: 'Abuja',
      state: 'FCT',
      country: 'Nigeria',
    ),
    TempCustomersClass(
      shopId: 1,
      country: 'Nigeria',
      dateAdded: DateTime(2025, 5, 7),
      id: 5,
      name: 'David Okoro',
      email: 'david@example.com',
      phone: '07099887766',
      address: '89 Market Road',
      city: 'Port Harcourt',
      state: 'Rivers',
    ),
  ];

  List<TempCustomersClass> getOwnCustomer(
    BuildContext context,
  ) {
    return customers
        .where(
          (customer) =>
              customer.shopId ==
              currentShop(context).shopId,
        )
        .toList();
  }

  int getId() {
    return customers.length + 1;
  }

  List<TempCustomersClass> getSortedCustomers(
    BuildContext context,
  ) {
    final ownCustomers = getOwnCustomer(context);
    ownCustomers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return ownCustomers;
  }

  void addCustomer(TempCustomersClass customer) {
    customers.add(customer);
    notifyListeners();
  }

  void updateCustomer({
    required TempCustomersClass mainCustomer,
    required TempCustomersClass setterCustomer,
  }) {
    mainCustomer.address = setterCustomer.address;
    mainCustomer.city = setterCustomer.city;
    mainCustomer.country = setterCustomer.country;
    mainCustomer.email = setterCustomer.email;
    mainCustomer.name = setterCustomer.name;
    mainCustomer.phone = setterCustomer.phone;
    mainCustomer.state = setterCustomer.state;
    notifyListeners();
  }

  String selectedCustomerId = '';

  void clearSelectedCustomer() {
    selectedCustomerId = '';
    notifyListeners();
  }

  void selectCustomer(int id) {
    selectedCustomerId = id.toString();
    notifyListeners();
  }

  TempCustomersClass returnCustomerById(
    int id,
    BuildContext context,
  ) {
    return getOwnCustomer(
      context,
    ).firstWhere((element) => element.id == id);
  }

  List<TempCustomersClass> searchCustomers(
    String name,
    BuildContext context,
  ) {
    List<TempCustomersClass> tempCustomer =
        getSortedCustomers(context)
            .where(
              (customer) => customer.name
                  .toLowerCase()
                  .contains(name.toLowerCase()),
            )
            .toList();

    notifyListeners();
    return tempCustomer;
  }
}
