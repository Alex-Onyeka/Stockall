import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';

class UserFunc {
  static final UserFunc instance = UserFunc._internal();
  factory UserFunc() => instance;
  UserFunc._internal();
  late Box<TempUserClass> userBox;
  final String userBoxName = 'userBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempUserClassAdapter());
    userBox = await Hive.openBox(userBoxName);
    print('User Box Initialized');
  }

  List<TempUserClass> getUsers() {
    List<TempUserClass> users = userBox.values.toList();
    print(users.first.name);
    print(users.last.name);
    return users;
  }

  TempUserClass? getUser(String userId) {
    return userBox.values.isNotEmpty
        ? userBox.values.firstWhere(
          (user) => user.userId == userId,
        )
        : null;
  }

  TempUserClass? getUserByEmailandPassword(
    String userId,
    String email,
  ) {
    if (userBox.values.isNotEmpty) {
      print(userBox.values.length);
      if (userBox.values
          .where(
            (user) =>
                user.userId == userId &&
                user.email == email,
          )
          .isNotEmpty) {
        return userBox.values
            .where(
              (user) =>
                  user.userId == userId &&
                  user.email == email,
            )
            .first;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  TempUserClass? offlineLoginByEmailandPassword(
    String password,
    String email,
  ) {
    print(userBox.values.length);
    if (userBox.values.isNotEmpty) {
      if (userBox.values
          .where(
            (user) =>
                user.password == password &&
                user.email == email,
          )
          .isNotEmpty) {
        return userBox.values
            .where(
              (user) =>
                  user.password == password &&
                  user.email == email,
            )
            .first;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<int> insertAllUsers(
    List<TempUserClass> users,
  ) async {
    await clearUsers();
    try {
      for (var user in users) {
        await userBox.put(user.userId, user);
      }
      print('All Users Insert Success');
      return 1;
    } catch (e) {
      print('Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> insertUser(TempUserClass user) async {
    try {
      await userBox.put(user.userId, user);
      print('User inserted Success');
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }

  Future clearUsers() async {
    await userBox.clear();
    print('Offline Users Cleared');
  }
}
