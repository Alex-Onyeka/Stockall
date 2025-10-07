import 'package:hive/hive.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
part 'logged_in_user.g.dart';

@HiveType(typeId: 13)
class LoggedInUser extends HiveObject {
  @HiveField(0)
  final TempUserClass? loggedInUser;

  LoggedInUser({required this.loggedInUser});
}
