class TempNotification {
  final int? id;
  final String notifId;
  final int shopId;
  final int? productId;
  final String? itemName;
  final int? expenseId;
  final String title;
  final String text;
  final DateTime date;
  final String category;
  bool isViewed;
  String? departmentName;
  int? departmentId;

  TempNotification({
    this.id,
    required this.shopId,
    required this.notifId,
    this.productId,
    this.expenseId,
    required this.title,
    required this.text,
    required this.date,
    required this.isViewed,
    required this.category,
    this.itemName,
    this.departmentName,
    this.departmentId,
  });

  factory TempNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempNotification(
      id: json['id'],
      notifId: json['notif_id'],
      shopId: json['shop_id'],
      productId: json['product_id'],
      expenseId: json['expense_id'],
      title: json['title'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      isViewed: json['is_viewed'],
      category: json['category'],
      itemName: json['item_name'],
      departmentId: json['department_id'],
      departmentName: json['department_name'],
    );
  }
}
