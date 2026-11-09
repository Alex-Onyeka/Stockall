import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_drafts/unsynced/deleted/deleted_drafts.dart';
import 'package:stockall/main.dart';

class DeletedDraftsFunc {
  static final DeletedDraftsFunc instance =
      DeletedDraftsFunc._internal();
  factory DeletedDraftsFunc() => instance;
  DeletedDraftsFunc._internal();

  Box<DeletedDrafts>? _deletedDraftsBox;
  final String deletedDraftsBoxName =
      'deletedDraftsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      DeletedDraftsAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedDraftsAdapter());
      await mainLocalLog(
        'Deleted Drafts Adapter registered ✅',
      );
    }

    _deletedDraftsBox = await openBoxSafely<DeletedDrafts>(
      deletedDraftsBoxName,
    );
  }

  /// Safe getter for the box
  Box<DeletedDrafts> get deletedDraftsBox {
    if (_deletedDraftsBox == null) {
      throw Exception(
        "Deleted Drafts Func not initialized. Call await DeletedDraftsFunc.instance.init() first.",
      );
    }
    return _deletedDraftsBox!;
  }

  List<DeletedDrafts> getDraftIds() {
    return deletedDraftsBox.values.toList();
  }

  // Keyed by uuid so deletedDeletedDraft(uuid) works.
  Future<int> createDeletedDraft(
    DeletedDrafts deletedDraft,
  ) async {
    try {
      await deletedDraftsBox.put(
        deletedDraft.draftUuid,
        deletedDraft,
      );
      await mainLocalLog(
        'Offline Deleted Draft inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Deleted Draft insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deletedDeletedDraft(String uuid) async {
    try {
      await deletedDraftsBox.delete(uuid);
      await mainLocalLog('Delete Draft cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while Deleting Deleted Draft ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedDrafts() async {
    try {
      await deletedDraftsBox.clear();
      await mainLocalLog('All Deleted Drafts cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Deleted Drafts ❌: $e',
      );
      return 0;
    }
  }
}
