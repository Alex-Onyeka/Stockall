import 'package:hive/hive.dart';
import 'package:stockall/classes/product_suggestions/product_suggestion.dart';

class ProductSuggestionFunc {
  static final ProductSuggestionFunc instance =
      ProductSuggestionFunc._internal();
  factory ProductSuggestionFunc() => instance;
  ProductSuggestionFunc._internal();
  late Box<ProductSuggestion> productSuggestionBox;
  final String productSuggestionBoxName =
      'productSuggestionBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(ProductSuggestionAdapter());
    productSuggestionBox = await Hive.openBox(
      productSuggestionBoxName,
    );
    print('Product Suggestions Box Initialized');
  }

  List<ProductSuggestion> getSuggestions() {
    return productSuggestionBox.values.toList();
  }

  Future<int> insertAllSuggestions(
    List<ProductSuggestion> suggestions,
  ) async {
    try {
      for (var suggestion in suggestions) {
        await productSuggestionBox.put(
          suggestion.id,
          suggestion,
        );
      }
      print("Offline Suggestions inserted");
      return 1;
    } catch (e) {
      print(
        'Offline Suggestions Insertion failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createSuggestion(
    ProductSuggestion suggestion,
  ) async {
    try {
      await productSuggestionBox.put(
        suggestion.id,
        suggestion,
      );
      print('Offline Suggestion inserted Successfully');
      return 1;
    } catch (e) {
      print('Offline Suggestion Isertion Failed');
      return 0;
    }
  }
}
