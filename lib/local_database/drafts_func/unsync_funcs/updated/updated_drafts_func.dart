import 'package:hive/hive.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/classes/temp_drafts/unsynced/updated/updated_drafts.dart';
import 'package:stockall/main.dart';

class UpdatedDraftsFunc {
  static final UpdatedDraftsFunc instance =
      UpdatedDraftsFunc._internal();
  factory UpdatedDraftsFunc() => instance;
  UpdatedDraftsFunc._internal();

  Box<UpdatedDrafts>? _updatedDraftsBox;
  final String updatedDraftsBoxName =
      'updatedDraftsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      UpdatedDraftsAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedDraftsAdapter());
      await mainLocalLog(
        'Updated Drafts Adapter registered ✅',
      );
    }

    _updatedDraftsBox = await openBoxSafely<UpdatedDrafts>(
      updatedDraftsBoxName,
    );
  }

  /// Safe getter for the box
  Box<UpdatedDrafts> get updatedDraftsBox {
    if (_updatedDraftsBox == null) {
      throw Exception(
        "Updated Drafts Func not initialized. Call await UpdatedDraftsFunc.instance.init() first.",
      );
    }
    return _updatedDraftsBox!;
  }

  List<UpdatedDrafts> getDraftIds() {
    return updatedDraftsBox.values.toList();
  }

  // Keyed by uuid so repeated edits collapse into one
  // pending update and deleteUpdatedDraft(uuid) works.
  Future<int> createUpdatedDraft(Drafts draft) async {
    try {
      await updatedDraftsBox.put(
        draft.uuid,
        UpdatedDrafts(draft: draft),
      );
      await mainLocalLog(
        'Offline Updated Draft inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Updated Draft insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedDraft(String uuid) async {
    try {
      await updatedDraftsBox.delete(uuid);
      await mainLocalLog('Updated Draft Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Draft Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearUpdatedDrafts() async {
    try {
      await updatedDraftsBox.clear();
      await mainLocalLog('All updated Drafts cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing updated Drafts ❌: $e',
      );
      return 0;
    }
  }
}
