import 'package:hive/hive.dart';
part 'deleted_drafts.g.dart';

@HiveType(typeId: 152)
class DeletedDrafts extends HiveObject {
  @HiveField(0)
  final String draftUuid;

  DeletedDrafts({required this.draftUuid});
}
