import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';

class LoggedInUserFunc {
  static final LoggedInUserFunc instance =
      LoggedInUserFunc._internal();
  factory LoggedInUserFunc() => instance;
  LoggedInUserFunc._internal();
  late Box<LoggedInUser> loggedInUserBox;
  final String loggedInUserBoxName =
      'loggedInUserBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(LoggedInUserAdapter());
    loggedInUserBox = await Hive.openBox(
      loggedInUserBoxName,
    );
    print('Logged In User Box Initialized');
  }

  LoggedInUser? getLoggedInUser() {
    return loggedInUserBox.values.isNotEmpty
        ? loggedInUserBox.values.first
        : null;
  }

  Future<int> insertLoggedInUser(LoggedInUser user) async {
    await logOut();
    try {
      await loggedInUserBox.put(
        user.loggedInUser!.userId,
        user,
      );
      print('Logged In User inserted Success');
      return 1;
    } catch (e) {
      print('Error: ${e.toString()}');
      return 0;
    }
  }

  Future<int> logOut() async {
    try {
      await loggedInUserBox.clear();
      print('Offline Logout Success');
      return 1;
    } catch (e) {
      print('Offline Logout Error: ${e.toString()}');
      return 0;
    }
  }
}
