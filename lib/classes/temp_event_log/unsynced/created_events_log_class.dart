import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_event_log/temp_event_log_class.dart';

part 'created_events_log_class.g.dart';

@HiveType(typeId: 35)
class CreatedEventsLogClass {
  @HiveField(0)
  final TempEventLogClass eventLog;
  CreatedEventsLogClass({required this.eventLog});
}
