import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/created/created_drafts_func.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/deleted/deleted_drafts_func.dart';
import 'package:stockall/local_database/drafts_func/unsync_funcs/updated/updated_drafts_func.dart';
import 'package:stockall/main.dart';

class DraftsFunc {
  static final DraftsFunc instance = DraftsFunc._internal();
  factory DraftsFunc() => instance;
  DraftsFunc._internal();
  late Box<Drafts> draftBox;
  final String draftBoxName = 'mainDraftsBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(DraftsAdapter());
    Hive.registerAdapter(DraftItemsAdapter());
    draftBox = await Hive.openBox(draftBoxName);
    await CreatedDraftsFunc().init();
    await DeletedDraftsFunc().init();
    await UpdatedDraftsFunc().init();
    await mainLocalLog('Draft Box Initialized');
  }

  List<Drafts> getDrafts() {
    List<Drafts> drafts = draftBox.values.toList();
    drafts.sort(
      (a, b) => (b.updatedAt ?? b.createdAt).compareTo(
        a.updatedAt ?? a.createdAt,
      ),
    );
    return drafts;
  }

  Future<int> insertAllDrafts(List<Drafts> drafts) async {
    await clearDrafts();
    try {
      for (var rec in drafts) {
        await draftBox.put(rec.uuid, rec);
      }
      await mainLocalLog('Offline Draft Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Draft Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createDraft(Drafts rec) async {
    try {
      await draftBox.put(rec.uuid, rec);
      await mainLocalLog('Offline Draft Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Draft Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteDraft(String uuid) async {
    try {
      await draftBox.delete(uuid);
      await mainLocalLog('Offline Draft Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearDrafts() async {
    try {
      await draftBox.clear();
      await mainLocalLog('Offline Drafts Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Draft Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedDraftsFunc().getDrafts().isEmpty &&
        UpdatedDraftsFunc().getDraftIds().isEmpty &&
        DeletedDraftsFunc().getDraftIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
