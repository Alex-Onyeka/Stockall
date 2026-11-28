import 'package:stockall/local_database/customers/unsync_funcs/created/created_customers_func.dart';
import 'package:stockall/local_database/materials/unsync_funcs/created_materials/created_materials_func.dart';
import 'package:stockall/local_database/production_items/unsync_funcs/created/created_production_items_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/created_products/created_product_func.dart';

/// Items whose create is still in this device's created queue. A delta
/// (stock or account change) for one of them is not sent yet: the receiver
/// doesn't have the item, so the LAN server would drop the delta as
/// "deleted" once Supabase says it has no such row, and Supabase itself
/// would ignore it. It stays queued and goes in a later run, after the
/// create (each `syncData()` run sends creates before deltas).
class PendingCreates {
  PendingCreates._();

  static Set<String> products() => {
    for (final c in CreatedProductFunc().getProducts())
      if (c.product.uuid case final uuid?) uuid,
  };

  static Set<String> materials() => {
    for (final c in CreatedMaterialsFunc().getMaterials())
      if (c.material.uuid case final uuid?) uuid,
  };

  static Set<String> productionItems() => {
    for (final c in CreatedProductionItemsFunc().getProductionItems())
      if (c.productionItem.uuid case final uuid?) uuid,
  };

  static Set<String> customers() => {
    for (final c in CreatedCustomersFunc().getCustomers())
      if (c.customer.uuid case final uuid?) uuid,
  };
}
