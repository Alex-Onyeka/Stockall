import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
part 'created_category.g.dart';

@HiveType(typeId: 62)
class CreatedCategory extends HiveObject {
  @HiveField(0)
  final CategoryClass category;

  CreatedCategory({required this.category});
}
