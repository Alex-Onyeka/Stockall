import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/local_database/category/unsync_funcs/created_categories/created_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/deleted_categories/deleted_categories_func.dart';
import 'package:stockall/local_database/category/unsync_funcs/updated_categories/updated_categories_func.dart';
import 'package:stockall/main.dart';

class CategoryFunc {
  static final CategoryFunc instance =
      CategoryFunc._internal();
  factory CategoryFunc() => instance;
  CategoryFunc._internal();
  late Box<CategoryClass> categoryBox;
  final String categoryBoxName = 'categoryBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(CategoryClassAdapter());
    categoryBox = await Hive.openBox(categoryBoxName);
    await CreatedCategoriesFunc().init();
    await DeletedCategoriesFunc().init();
    await UpdatedCategoriesFunc().init();
    await mainLocalLog('Category Box Initialized');
  }

  List<CategoryClass> getCategories() {
    List<CategoryClass> categories =
        categoryBox.values.toList();
    categories.sort((a, b) => a.name.compareTo(b.name));
    return categories;
  }

  Future<int> insertAllCategories(
    List<CategoryClass> category,
  ) async {
    await clearCategories();
    try {
      for (var category in category) {
        await categoryBox.put(category.uuid, category);
      }
      await mainLocalLog('Offline Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Exp Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createCategory(CategoryClass category) async {
    try {
      await categoryBox.put(category.uuid, category);
      await mainLocalLog('Offline Category Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Category Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateCategory(CategoryClass category) async {
    category.updatedAt = DateTime.now().add(
      (Duration(hours: 1)),
    );
    try {
      await categoryBox.put(category.uuid, category);
      await mainLocalLog('Offline Category Updated');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Category Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteCategory(String uuid) async {
    try {
      await categoryBox.delete(uuid);
      await mainLocalLog('Offline Category Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Category Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearCategories() async {
    try {
      await categoryBox.clear();
      await mainLocalLog('Offline Category Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Category Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedCategoriesFunc()
            .getCreateCategories()
            .isEmpty &&
        UpdatedCategoriesFunc().getCategories().isEmpty &&
        DeletedCategoriesFunc().getCategoryIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
