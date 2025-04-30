class Customer {
  final int customerId;
  final int? shopId;
  final DateTime createdAt;
  final String? name;
  final String? email;
  final String? phone;

  Customer({
    required this.customerId,
    this.shopId,
    required this.createdAt,
    this.name,
    this.email,
    this.phone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      shopId: json['shop_id'],
      createdAt: DateTime.parse(json['created_at']),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'shop_id': shopId,
      'created_at': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'phone': phone,
    };
  }
}
