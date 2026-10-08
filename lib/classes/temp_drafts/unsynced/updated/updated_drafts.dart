import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
part 'updated_drafts.g.dart';

@HiveType(typeId: 151)
class UpdatedDrafts extends HiveObject {
  @HiveField(0)
  final Drafts draft;

  UpdatedDrafts({required this.draft});
}
