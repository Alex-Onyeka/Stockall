import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
part 'created_drafts.g.dart';

@HiveType(typeId: 150)
class CreatedDrafts extends HiveObject {
  @HiveField(0)
  final Drafts draft;

  CreatedDrafts({required this.draft});
}
