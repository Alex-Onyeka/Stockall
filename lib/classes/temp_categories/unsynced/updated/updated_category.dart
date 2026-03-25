import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
part 'updated_category.g.dart';

@HiveType(typeId: 64)
class UpdatedCategory extends HiveObject {
  @HiveField(0)
  CategoryClass category;

  UpdatedCategory({required this.category});
}
