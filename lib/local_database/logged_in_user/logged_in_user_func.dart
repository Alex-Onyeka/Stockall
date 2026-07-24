import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_logged_in_user/logged_in_user.dart';
import 'package:stockall/main.dart';

class LoggedInUserFunc {
  static final LoggedInUserFunc instance =
      LoggedInUserFunc._internal();
  factory LoggedInUserFunc() => instance;
  LoggedInUserFunc._internal();
  late Box<LoggedInUser> loggedInUserBox;
  final String loggedInUserBoxName =
      'loggedInUserBoxStockall';

  Future<void> init() async {
    // await Hive.deleteBoxFromDisk(loggedInUserBoxName);
    try {
      Hive.registerAdapter(LoggedInUserAdapter());
      loggedInUserBox = await Hive.openBox(
        loggedInUserBoxName,
      );
      await mainLocalLog('Logged In User Box Initialized');
    } catch (e) {
      await mainLocalLog(
        '❌ Error New Logged In User: ${e.toString()}',
      );
      // try {
      //   if (Hive.isBoxOpen(loggedInUserBoxName)) {
      //     await Hive.box(loggedInUserBoxName).close();
      //   }

      //   await Hive.deleteBoxFromDisk(loggedInUserBoxName);
      //   await mainLocalLog(
      //     '🧹 Deleted Corrupted Current Logged In User Box',
      //   );

      //   loggedInUserBox = await Hive.openBox(
      //     loggedInUserBoxName,
      //   );
      //   await mainLocalLog('✅ Reinitialized Logged In User Box');
      // } catch (innerError) {
      //   await mainLocalLog(
      //     '⚠️ Failed to recover Hive box Logged In User: $innerError',
      //   );
      // }
    }
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
      await mainLocalLog('Logged In User inserted Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Logged In User Error: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> logOut() async {
    try {
      await loggedInUserBox.clear();
      await mainLocalLog('Offline Logout Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        '❌❌ Offline Logout Error: ${e.toString()}',
      );
      return 0;
    }
  }
}
