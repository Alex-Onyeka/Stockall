import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/main.dart';

class UserFunc {
  static final UserFunc instance = UserFunc._internal();
  factory UserFunc() => instance;
  UserFunc._internal();
  late Box<TempUserClass> userBox;
  final String userBoxName = 'userBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(userBoxName);
    try {
      Hive.registerAdapter(TempUserClassAdapter());
      userBox = await Hive.openBox(userBoxName);
      await mainLocalLog('User Box Initialized');
    } catch (e) {
      await mainLocalLog(
        'Error Initializing Users Box: ${e.toString()}',
      );
    }
  }

  List<TempUserClass> getUsers() {
    List<TempUserClass> users = userBox.values.toList();
    // await mainLocalLog(users.first.name);
    // await mainLocalLog(users.last.name);
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
      // await mainLocalLog(userBox.values.length);
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
    // await mainLocalLog(userBox.values.length);
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
      await mainLocalLog('All Users Insert Success');
      return 1;
    } catch (e) {
      await mainLocalLog('Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> insertUser(TempUserClass user) async {
    try {
      await userBox.put(user.userId, user);
      await mainLocalLog('User inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Insert User Offline Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future clearUsers() async {
    await userBox.clear();
    await mainLocalLog('Offline Users Cleared');
  }
}
