import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_customers_class.dart';
import 'package:stockitt/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomersProvider extends ChangeNotifier {
  //
  //
  //
  //

  final SupabaseClient supabase = Supabase.instance.client;
  List<TempCustomersClass> _customers = [];

  List<TempCustomersClass> get customersMain => _customers;

  /// Fetch all customers by shop ID
  Future<List<TempCustomersClass>> fetchCustomers(
    int shopId,
  ) async {
    final data = await supabase
        .from('customers')
        .select()
        .eq('shop_id', shopId)
        .order('name', ascending: true);

    _customers =
        (data as List)
            .map(
              (json) => TempCustomersClass.fromJson(json),
            )
            .toList();

    notifyListeners();
    return _customers;
  }

  /// Add a new customer
  Future<void> addCustomerMain(
    TempCustomersClass customer,
  ) async {
    final res =
        await supabase
            .from('customers')
            .insert({
              'shop_id': customer.shopId,
              'country': customer.country,
              'name': customer.name,
              'email': customer.email,
              'phone': customer.phone,
              'address': customer.address,
              'city': customer.city,
              'state': customer.state,
            })
            .select()
            .single();

    final newCustomer = TempCustomersClass.fromJson(res);
    _customers.insert(0, newCustomer);
    notifyListeners();
  }

  /// Update a customer by ID
  Future<void> updateCustomerMain(
    TempCustomersClass customer,
  ) async {
    await supabase
        .from('customers')
        .update({
          'country': customer.country,
          'name': customer.name,
          'email': customer.email,
          'phone': customer.phone,
          'address': customer.address,
          'city': customer.city,
          'state': customer.state,
        })
        .eq('id', customer.id!);

    int index = _customers.indexWhere(
      (c) => c.id == customer.id,
    );
    if (index != -1) {
      _customers[index] = customer;
      notifyListeners();
    }
  }

  /// Delete a customer by ID
  Future<void> deleteCustomerMain(int id) async {
    await supabase.from('customers').delete().eq('id', id);
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  /// Get single customer by ID
  TempCustomersClass? getCustomerByIdMain(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  //
  //
  //
  //
  //
  //

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
