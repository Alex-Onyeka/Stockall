import 'package:flutter/widgets.dart';
import 'package:stockitt/classes/temp_user_class.dart';

class UserProvider extends ChangeNotifier {
  final List<TempUserClass> users = [
    TempUserClass(
      userId: 'user_001',
      createdAt: DateTime.now(),
      name: 'Alex Onyeka',
      email: 'alexonyekasm@gmail.com',
      phone: '08012345678',
      role: 'admin',
      image: null,
      shopId: 1,
    ),
    TempUserClass(
      userId: 'user_002',
      createdAt: DateTime.now(),
      name: 'Chioma Eze',
      email: 'chioma@example.com',
      phone: '08123456789',
      role: 'manager',
      image: null,
      shopId: 2,
    ),
    TempUserClass(
      userId: 'user_003',
      createdAt: DateTime.now(),
      name: 'Ahmed Musa',
      email: 'ahmed@example.com',
      phone: '09098765432',
      role: 'staff',
      image: null,
      shopId: 3,
    ),
  ];

  TempUserClass currentUser(String userId) {
    return users.firstWhere(
      (element) => element.userId == userId,
    );
  }
}
