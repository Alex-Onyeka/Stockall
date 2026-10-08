import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_drafts/unsynced/created/created_drafts.dart';
import 'package:stockall/main.dart';

class CreatedDraftsFunc {
  static final CreatedDraftsFunc instance =
      CreatedDraftsFunc._internal();
  factory CreatedDraftsFunc() => instance;
  CreatedDraftsFunc._internal();

  Box<CreatedDrafts>? _createdDraftsBox;
  final String createdDraftsBoxName =
      'createdDraftsBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(
      CreatedDraftsAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedDraftsAdapter());
      await mainLocalLog(
        'Created Drafts Adapter registered ✅',
      );
    }

    if (!Hive.isBoxOpen(createdDraftsBoxName)) {
      _createdDraftsBox = await Hive.openBox<CreatedDrafts>(
        createdDraftsBoxName,
      );
      await mainLocalLog('Created Drafts Box opened ✅');
    } else {
      _createdDraftsBox = Hive.box<CreatedDrafts>(
        createdDraftsBoxName,
      );
      await mainLocalLog(
        'Created Drafts Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedDrafts> get createdDraftsBox {
    if (_createdDraftsBox == null) {
      throw Exception(
        "Created Drafts Func not initialized. Call await CreatedDraftsFunc.instance.init() first.",
      );
    }
    return _createdDraftsBox!;
  }

  List<CreatedDrafts> getDrafts() {
    List<CreatedDrafts> drafts =
        createdDraftsBox.values.toList();
    drafts.sort(
      (a, b) =>
          a.draft.createdAt.compareTo(b.draft.createdAt),
    );
    return drafts;
  }

  Future<int> createDrafts(
    CreatedDrafts createdDrafts,
  ) async {
    try {
      await createdDraftsBox.put(
        createdDrafts.draft.uuid,
        createdDrafts,
      );
      await mainLocalLog(
        'Offline Created Drafts inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Drafts insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteDraft(String uuid) async {
    try {
      await createdDraftsBox.delete(uuid);
      await mainLocalLog('Created Draft Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Created Drafts Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearDrafts() async {
    try {
      await createdDraftsBox.clear();
      await mainLocalLog('All Created Drafts cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Drafts ❌: $e',
      );
      return 0;
    }
  }
}
