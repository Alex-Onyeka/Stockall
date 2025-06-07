class TempCustomersClass {
  final int? id;
  final DateTime dateAdded;
  final int shopId;
  String? country;
  String name;
  String email;
  String phone;
  String? address;
  String? city;
  String? state;
  String? departmentName;
  int? departmentId;

  TempCustomersClass({
    this.country,
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.state,
    required this.dateAdded,
    required this.shopId,
    this.departmentName,
    this.departmentId,
  });

  factory TempCustomersClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempCustomersClass(
      id: json['id'],
      dateAdded: DateTime.parse(json['date_added']),
      shopId: json['shop_id'],
      country: json['country'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date_added': dateAdded.toIso8601String(),
      'shop_id': shopId,
      'country': country,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'department_id': departmentId,
      'department_name': departmentName,
    };
  }
}
