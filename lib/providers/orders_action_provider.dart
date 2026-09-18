import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/main.dart';

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
    comment = null;
    paymentOption = 1;
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

  int addAllItemsToList({required List<OrderItems> items}) {
    var value = 1;
    for (var item in items) {
      var products = returnData().productListMain.where(
        (it) => it.uuid == item.productUuid,
      );
      if (products.isNotEmpty) {
        var pr = products.first;
        if ((pr.quantity ?? 0) > item.getActualQuantity()) {
          addItemToList(item: item);
        } else {
          value = 0;
        }
      } else {
        addItemToList(item: item);
      }
    }
    notifyListeners();
    return value;
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
          .map((item) => item.getTotalRevenue())
          .fold(0.0, (a, b) => a + b);
    }
  }

  String? comment;

  void setComment({required String? newComment}) {
    comment = newComment;
    notifyListeners();
  }

  int paymentOption = 1;

  void changePaymentOptions(int index) {
    paymentOption = index;
    notifyListeners();
  }

  bool isBalanceSufficient(String customerUuid) {
    List<TempCustomersClass> customers =
        returnCustomersSingle().customers
            .where((item) => item.uuid == customerUuid)
            .toList();
    if (customers.isNotEmpty) {
      var customer = customers.first;
      return customer.getBalance() >= totalOrdersAmount();
    } else {
      return false;
    }
  }
}
