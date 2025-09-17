import 'package:flutter/material.dart';
import 'package:stockall/classes/product_suggestions/product_suggestion.dart';
import 'package:stockall/local_database/product_suggestion/product_suggestion_func.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductSuggestionProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<ProductSuggestion> _suggestions = [];
  List<ProductSuggestion> get suggestions => _suggestions;

  void clearSuggestionsMain() {
    _suggestions.clear();
    tempSuggestions.clear();
    notifyListeners();
  }

  List<ProductSuggestion> tempSuggestions = [];
  void addTempSugg(ProductSuggestion sug) {
    final alreadyExists =
        _suggestions.any(
          (item) =>
              item.name == sug.name &&
              item.costPrice == sug.costPrice,
        ) ||
        tempSuggestions.any(
          (item) =>
              item.name == sug.name &&
              item.costPrice == sug.costPrice,
        );

    if (!alreadyExists) {
      tempSuggestions.insert(0, sug); // Add to top
      notifyListeners();
    }
  }

  void deleteTempSugg(int sugId) {
    tempSuggestions.removeWhere((sug) => sug.id! == sugId);
    notifyListeners();
  }

  void clearSuggestions() {
    tempSuggestions.clear();
    print('Cleared');
    notifyListeners();
  }

  /// Load all suggestions for a specific shop
  Future<void> loadSuggestions(int shopId) async {
    // print('Start Loading Provider');
    bool isOnline = await ConnectivityProvider().isOnline();

    if (isOnline) {
      final res = await supabase
          .from('product_suggestions')
          .select()
          .eq('shop_id', shopId)
          .order('name', ascending: false);
      // print('Loaded Provider $res');

      _suggestions =
          (res as List)
              .map(
                (item) => ProductSuggestion.fromJson(item),
              )
              .toList();

      await ProductSuggestionFunc().insertAllSuggestions(
        _suggestions,
      );
    } else {
      _suggestions =
          ProductSuggestionFunc().getSuggestions();
    }

    notifyListeners();
  }

  Future<void> createSuggestions() async {
    if (tempSuggestions.isEmpty) {
      print('No suggestions to insert.');
      return;
    }

    final now = DateTime.now();

    // Step 1: Get all existing suggestion names from Supabase for this shop
    final shopId = tempSuggestions.first.shopId;

    final existingRes = await supabase
        .from('product_suggestions')
        .select('id, name')
        .eq('shop_id', shopId);

    final existingMap = {
      for (var item in existingRes)
        (item['name'] as String).toLowerCase():
            item['id'] as int,
    };

    // Step 2: Separate new inserts and updates
    List<Map<String, dynamic>> toInsert = [];
    List<Map<String, dynamic>> toUpdate = [];

    for (final suggestion in tempSuggestions) {
      final nameKey = suggestion.name!.toLowerCase();

      if (existingMap.containsKey(nameKey)) {
        toUpdate.add({
          'id': existingMap[nameKey],
          'cost_price': suggestion.costPrice,
          'created_at': now.toIso8601String(),
        });
      } else {
        toInsert.add({
          'created_at': now.toIso8601String(),
          'name': suggestion.name,
          'cost_price': suggestion.costPrice,
          'shop_id': suggestion.shopId,
        });
      }
    }

    // Step 3: Perform updates
    for (final item in toUpdate) {
      await supabase
          .from('product_suggestions')
          .update({
            'cost_price': item['cost_price'],
            'created_at': item['created_at'],
          })
          .eq('id', item['id']);
    }

    // Step 4: Perform inserts
    if (toInsert.isNotEmpty) {
      await supabase
          .from('product_suggestions')
          .insert(toInsert);
    }

    print(
      'Inserted ${toInsert.length}, Updated ${toUpdate.length}',
    );

    // Refresh local list
    await loadSuggestions(shopId);
    tempSuggestions.clear();
    notifyListeners();
  }

  /// Update a suggestion by ID
  Future<void> updateSuggestion({
    required int id,
    String? name,
    double? costPrice,
  }) async {
    final updateData = <String, dynamic>{};
    if (name != null) updateData['name'] = name;
    if (costPrice != null) {
      updateData['cost_price'] = costPrice;
    }

    await supabase
        .from('product_suggestions')
        .update(updateData)
        .eq('id', id);

    // Refresh the local list after update
    final index = _suggestions.indexWhere(
      (s) => s.id == id,
    );
    if (index != -1) {
      final updated =
          await supabase
              .from('product_suggestions')
              .select()
              .eq('id', id)
              .single();
      _suggestions[index] = ProductSuggestion.fromJson(
        updated,
      );
      notifyListeners();
    }
  }

  /// Delete a suggestion
  Future<void> deleteSuggestion(int id) async {
    await supabase
        .from('product_suggestions')
        .delete()
        .eq('id', id);
    _suggestions.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}
