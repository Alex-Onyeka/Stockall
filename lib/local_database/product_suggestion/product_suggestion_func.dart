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
    List<ProductSuggestion> suggestions =
        productSuggestionBox.values.toList();
    suggestions.sort(
      (a, b) => a.name!.toLowerCase().compareTo(
        b.name!.toLowerCase(),
      ),
    );
    return suggestions;
  }

  Future<int> insertAllSuggestions(
    List<ProductSuggestion> suggestions,
  ) async {
    await clearSuggestion();
    try {
      for (var suggestion in suggestions) {
        await productSuggestionBox.put(
          suggestion.uuid,
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
        suggestion.uuid,
        suggestion,
      );
      print('Offline Suggestion inserted Successfully');
      return 1;
    } catch (e) {
      print('Offline Suggestion Isertion Failed');
      return 0;
    }
  }

  Future<int> updateSuggestion(
    ProductSuggestion suggestion,
  ) async {
    try {
      await productSuggestionBox.put(
        suggestion.uuid,
        suggestion,
      );
      print('Offline Suggestion Updated Successfully');
      return 1;
    } catch (e) {
      print('Offline Suggestion Update Failed');
      return 0;
    }
  }

  Future<int> deleteSuggestion(String uuid) async {
    try {
      await productSuggestionBox.delete(uuid);
      print('Offline Suggestion Deleted Successfully');
      return 1;
    } catch (e) {
      print('Offline Suggestion Delete Failed');
      return 0;
    }
  }

  Future<int> clearSuggestion() async {
    try {
      await productSuggestionBox.clear();
      print('Offline Suggestion Cleared Successfully');
      return 1;
    } catch (e) {
      print('Offline Suggestion Clear Failed');
      return 0;
    }
  }
}
