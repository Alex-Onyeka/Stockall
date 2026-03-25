import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/unsynced/created_category/created_category.dart';

class CreatedCategoriesFunc {
  static final CreatedCategoriesFunc instance =
      CreatedCategoriesFunc._internal();
  factory CreatedCategoriesFunc() => instance;
  CreatedCategoriesFunc._internal();

  Box<CreatedCategory>? _createdCategoriesBox;
  final String createdCategoriesBoxName =
      'createdCategoriesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedCategoryAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedCategoryAdapter());
      print('Created Categories Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdCategoriesBoxName)) {
      _createdCategoriesBox =
          await Hive.openBox<CreatedCategory>(
            createdCategoriesBoxName,
          );
      print('Created Categories Box opened ✅');
    } else {
      _createdCategoriesBox = Hive.box<CreatedCategory>(
        createdCategoriesBoxName,
      );
      print(
        'Created Categories Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedCategory> get createdCategoriesBox {
    if (_createdCategoriesBox == null) {
      throw Exception(
        "Created Categories Func not initialized. Call await CreatedCategoriesFunc.instance.init() first.",
      );
    }
    return _createdCategoriesBox!;
  }

  List<CreatedCategory> getCreateCategories() {
    return createdCategoriesBox.values.toList();
  }

  Future<int> insertAllCreatedCategories(
    List<CreatedCategory> createdCategories,
  ) async {
    try {
      for (var category in createdCategories) {
        await createdCategoriesBox.put(
          category.category.uuid,
          category,
        );
      }
      print("Offline Created Categories inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Created Categories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createCategory(
    CreatedCategory createdCategory,
  ) async {
    try {
      await createdCategoriesBox.put(
        createdCategory.category.uuid,
        createdCategory,
      );
      print(
        'Offline Created Categories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Categories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateCategory(
    CreatedCategory createdCategory,
  ) async {
    try {
      await createdCategoriesBox.put(
        createdCategory.category.uuid,
        createdCategory,
      );
      print(
        'Offline Created Categories inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Categories insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteCategory(String uuid) async {
    try {
      print(
        createdCategoriesBox.containsKey(uuid).toString(),
      );
      await createdCategoriesBox.delete(uuid);
      print('Category Deleted');
      return 1;
    } catch (e) {
      print('Category Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearCategories() async {
    try {
      await createdCategoriesBox.clear();
      print('All Created Categories cleared ✅');
      return 1;
    } catch (e) {
      print(
        'Error while clearing Created Categories ❌: $e',
      );
      return 0;
    }
  }
}
