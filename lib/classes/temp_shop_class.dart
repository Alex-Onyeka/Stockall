class TempShopClass {
  final int shopId;
  final DateTime createdAt;
  final String userId;
  String email;
  String name;
  String? state;
  String? city;
  String? shopAddress;
  List<String>? categories;
  List<String>? colors;

  TempShopClass({
    required this.shopId,
    required this.createdAt,
    required this.userId,
    required this.email,
    required this.name,
    this.state,
    this.city,
    this.shopAddress,
    this.categories,
    this.colors,
  });
}
