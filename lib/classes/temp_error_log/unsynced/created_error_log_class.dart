import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_error_log/temp_error_log_class.dart';

part 'created_error_log_class.g.dart';

@HiveType(typeId: 95)
class CreatedErrorLogClass {
  @HiveField(0)
  final TempErrorLogClass errorLog;
  CreatedErrorLogClass({required this.errorLog});
}
