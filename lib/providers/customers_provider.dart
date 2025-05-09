import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';

class CustomersProvider extends ChangeNotifier {
  List<TempCustomersClass> customers = [
    TempCustomersClass(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      phone: '08012345678',
      address: '12 Adeola Street',
      city: 'Lagos',
      state: 'Lagos',
    ),
    TempCustomersClass(
      id: 2,
      name: 'Jane Smith',
      email: 'jane@example.com',
      phone: '08098765432',
      address: '45 Unity Road',
      city: 'Abuja',
      state: 'FCT',
    ),
    TempCustomersClass(
      id: 3,
      name: 'Emeka Obi',
      email: 'emeka@example.com',
      phone: '08123456789',
      address: '10 Nnamdi Avenue',
      city: 'Enugu',
      state: 'Enugu',
    ),
    TempCustomersClass(
      id: 4,
      name: 'Aisha Bello',
      email: 'aisha@example.com',
      phone: '09011223344',
      address: '23 Wuse Zone 4',
      city: 'Abuja',
      state: 'FCT',
    ),
    TempCustomersClass(
      id: 5,
      name: 'David Okoro',
      email: 'david@example.com',
      phone: '07099887766',
      address: '89 Market Road',
      city: 'Port Harcourt',
      state: 'Rivers',
    ),
  ];

  List<TempCustomersClass> getSortedCustomers() {
    customers.sort(
      (a, b) => a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      ),
    );
    return customers;
  }

  void addCustomer(TempCustomersClass customer) {
    customers.add(customer);
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

  TempCustomersClass returnCustomerById(int id) {
    return customers.firstWhere(
      (element) => element.id == id,
    );
  }

  List<TempCustomersClass> searchCustomers(String name) {
    List<TempCustomersClass> tempCustomer =
        getSortedCustomers()
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
