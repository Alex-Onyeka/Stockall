import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/unsynced/updated/updated_category.dart';

class UpdatedCategoriesFunc {
  static final UpdatedCategoriesFunc instance =
      UpdatedCategoriesFunc._internal();
  factory UpdatedCategoriesFunc() => instance;
  UpdatedCategoriesFunc._internal();

  Box<UpdatedCategory>? _updatedCategoriesBox;
  final String updatedCategoriesBoxName =
      'updatedCategoriesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedCategoryAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedCategoryAdapter());
      print('Updated Categories Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedCategoriesBoxName)) {
      _updatedCategoriesBox =
          await Hive.openBox<UpdatedCategory>(
            updatedCategoriesBoxName,
          );
      print('Updated Categories Box opened ✅');
    } else {
      _updatedCategoriesBox = Hive.box<UpdatedCategory>(
        updatedCategoriesBoxName,
      );
      print(
        'Updated Categories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<UpdatedCategory> get updatedCategoriesBox {
    if (_updatedCategoriesBox == null) {
      throw Exception(
        "Updated Categories Func not initialized. Call await updated Categories Func.instance.init() first.",
      );
    }
    return _updatedCategoriesBox!;
  }

  List<UpdatedCategory> getCategories() {
    return updatedCategoriesBox.values.toList();
  }

  Future<int> createUpdatedCategory(
    UpdatedCategory updatedCategory,
  ) async {
    try {
      updatedCategory.category.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedCategoriesBox.put(
        updatedCategory.category.uuid,
        updatedCategory,
      );
      print(
        'Offline updated Categories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Categories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedCategory(String uuid) async {
    try {
      print(
        updatedCategoriesBox.containsKey(uuid).toString(),
      );
      await updatedCategoriesBox.delete(uuid);
      print('Updated Category Deleted');
      return 1;
    } catch (e) {
      print('Category Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearUpdatedCategory() async {
    try {
      await updatedCategoriesBox.clear();
      print('All updated Categories cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing updated Categories ❌: $e',
      );
      return 0;
    }
  }
}
