import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/unsynced/deleted_category/deleted_category.dart';

class DeletedCategoriesFunc {
  static final DeletedCategoriesFunc instance =
      DeletedCategoriesFunc._internal();
  factory DeletedCategoriesFunc() => instance;
  DeletedCategoriesFunc._internal();

  Box<DeletedCategory>? _deletedCategoriesBox;
  final String deletedCategoriesBoxName =
      'deletedCategoriesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedCategoryAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedCategoryAdapter());
      print('Deleted Categories Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedCategoriesBoxName)) {
      _deletedCategoriesBox =
          await Hive.openBox<DeletedCategory>(
            deletedCategoriesBoxName,
          );
      print('Deleted Categories Box opened ✅');
    } else {
      _deletedCategoriesBox = Hive.box<DeletedCategory>(
        deletedCategoriesBoxName,
      );
      print(
        'Deleted Categories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<DeletedCategory> get deletedCategoriesBox {
    if (_deletedCategoriesBox == null) {
      throw Exception(
        "Deleted Categories Func not initialized. Call await Deleted Categories Func.instance.init() first.",
      );
    }
    return _deletedCategoriesBox!;
  }

  List<DeletedCategory> getCategoryIds() {
    return deletedCategoriesBox.values.toList();
  }

  Future<int> insertAllDeletedCategories(
    List<DeletedCategory> deletedCategories,
  ) async {
    try {
      for (var category in deletedCategories) {
        await deletedCategoriesBox.add(category);
      }
      print("Offline Deleted Categories inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Categories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedCategory(
    DeletedCategory deletedCategory,
  ) async {
    try {
      await deletedCategoriesBox.add(deletedCategory);
      print(
        'Offline Deleted Category inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Category insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedCategories() async {
    try {
      await deletedCategoriesBox.clear();
      print('All Deleted Categories cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Deleted Categories ❌: $e',
      );
      return 0;
    }
  }
}
