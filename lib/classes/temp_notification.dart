class TempNotification {
  final int? id;
  final String notifId;
  final int shopId;
  final int productId;
  final String title;
  final String text;
  final DateTime date;
  final String category;
  bool isViewed;

  TempNotification({
    this.id,
    required this.shopId,
    required this.notifId,
    required this.productId,
    required this.title,
    required this.text,
    required this.date,
    required this.isViewed,
    required this.category,
  });

  factory TempNotification.fromJson(
    Map<String, dynamic> json,
  ) {
    return TempNotification(
      id: json['id'],
      notifId: json['notif_id'],
      shopId: json['shop_id'],
      productId: json['product_id'],
      title: json['title'],
      text: json['text'],
      date: DateTime.parse(json['date']),
      isViewed: json['is_viewed'],
      category: json['category'],
    );
  }
}
