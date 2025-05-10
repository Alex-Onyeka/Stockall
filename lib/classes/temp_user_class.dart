class TempUserClass {
  final String userId;
  final DateTime createdAt;
  String name;
  String email;
  String phone;
  String role;
  String? image;
  int shopId;

  TempUserClass({
    required this.userId,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.image,
    required this.shopId,
  });
}
