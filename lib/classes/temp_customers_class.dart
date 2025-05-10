class TempCustomersClass {
  final int id;
  final String dateAdded;
  final int shopId;
  String? country;
  String name;
  String email;
  String phone;
  String? address;
  String? city;
  String? state;

  TempCustomersClass({
    this.country,
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.dateAdded,
    required this.shopId,
  });
}
