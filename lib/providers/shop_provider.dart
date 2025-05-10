import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_shop_class.dart';

class ShopProvider extends ChangeNotifier {
  List<TempShopClass> shops = [
    TempShopClass(
      shopId: 1,
      createdAt: DateTime.now(),
      userId: 'user_001',
      email: 'shop1@example.com',
      name: 'Alpha Footwear',
      state: 'Lagos',
      city: 'Ikeja',
      shopAddress: '23 Allen Avenue',
      categories: ['Shoes', 'Sandals'],
      colors: ['Black', 'White', 'Brown'],
    ),
    TempShopClass(
      shopId: 2,
      createdAt: DateTime.now(),
      userId: 'user_002',
      email: 'shop2@example.com',
      name: 'Urban Styles',
      state: 'Abuja',
      city: 'Wuse',
      shopAddress: 'Plot 10, Wuse Zone 4',
      categories: ['Clothing', 'Accessories'],
      colors: ['Red', 'Blue'],
    ),
    TempShopClass(
      shopId: 3,
      createdAt: DateTime.now(),
      userId: 'user_003',
      email: 'shop3@example.com',
      name: 'Naija Gadgets',
      state: 'Kano',
      city: 'Nassarawa',
      shopAddress: '45 Zaria Road',
      categories: ['Electronics'],
      colors: ['Black', 'Silver'],
    ),
  ];

  TempShopClass returnShop(String userId) {
    return shops.firstWhere(
      (shop) => shop.userId == userId,
    );
  }
}
