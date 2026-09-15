import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';

class OrdersActionProvider extends ChangeNotifier {
  static final OrdersActionProvider _instance =
      OrdersActionProvider._internal();
  factory OrdersActionProvider() => _instance;
  OrdersActionProvider._internal();
  List<OrderItems> orderListItems = [];

  List<OrderItems> orderItemReversed() {
    return orderListItems.reversed.toList();
  }

  void clearAll() {
    orderListItems.clear();
    // isGroup = false;
    customTotalAmount = null;
    notifyListeners();
  }

  String itemUnit({required OrderItems orderItem}) {
    return orderItem.getUnit();
  }

  void addItemToList({required OrderItems item}) {
    if (orderListItems.contains(item)) {
      orderListItems.remove(item);
    }
    orderListItems.add(item);
    notifyListeners();
  }

  void removeItemFromList({required OrderItems item}) {
    orderListItems.remove(item);
    notifyListeners();
  }

  double? customTotalAmount;

  void setCustomTotalAmount(double? total) {
    customTotalAmount = total;
    notifyListeners();
  }

  double totalOrdersAmount() {
    if (customTotalAmount != null) {
      return customTotalAmount ?? 0;
    } else {
      return orderListItems
          .map((item) => item.revenue)
          .fold(0.0, (a, b) => a + b);
    }
  }
}
