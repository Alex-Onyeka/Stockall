import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_drafts/draft_items.dart';
import 'package:stockall/classes/temp_drafts/drafts.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';

void main() {
  final caseUnit = ProductUnitsClass(
    uuid: 'unit-case',
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 12,
    name: 'Case',
    isPrimary: false,
    productUuid: 'product-1',
  );

  DraftItems item({String uuid = 'item-1', bool? isVoid}) {
    return DraftItems(
      uuid: uuid,
      draftId: 'draft-1',
      createdAt: DateTime.utc(2026, 10, 8),
      productUuid: 'product-1',
      productName: 'Soda',
      quantity: 2,
      customPrice: 1500,
      setCustomPrice: true,
      setTotalPrice: false,
      useWholeSalePrice: false,
      addToStock: false,
      discount: 5,
      fixedDiscount: null,
      useGroupQuantity: true,
      qttyPerGroup: 12,
      isVoid: isVoid,
      unit: 'Bottle',
      groupUnit: 'Case',
      unitUuid: 'unit-case',
      unitsList: [caseUnit],
      priceUuid: 'price-1',
      pricesList: [],
      sellingPrice: 150,
      costPrice: 100,
      isProductManaged: true,
      revenue: 2850,
    );
  }

  Drafts draft() {
    return Drafts(
      uuid: 'draft-1',
      createdAt: DateTime.utc(2026, 10, 8, 9),
      updatedAt: DateTime.utc(2026, 10, 8, 10),
      shopId: 7,
      staffId: 'staff-1',
      staffName: 'Ada',
      subStaffUuid: null,
      subStaffName: null,
      customerUuid: 'customer-1',
      customerName: 'Bola',
      departmentUuid: 'dept-1',
      departmentName: 'Main',
      cartName: 'Table 4',
      comment: 'Pick up later',
      generalDiscount: null,
      fixedDiscount: 200,
      total: 2650,
      draftItems: [item(), item(uuid: 'item-2', isVoid: true)],
    );
  }

  test('draft item keeps uuid, draft id and cart inputs through JSON', () {
    final restored = DraftItems.fromJson(item().toJson());

    expect(restored.uuid, 'item-1');
    expect(restored.draftId, 'draft-1');
    expect(restored.productUuid, 'product-1');
    expect(restored.quantity, 2);
    expect(restored.customPrice, 1500);
    expect(restored.setCustomPrice, isTrue);
    expect(restored.discount, 5);
    expect(restored.useGroupQuantity, isTrue);
    expect(restored.unitUuid, 'unit-case');
    expect(restored.unitsList?.single.conversion, 12);
    expect(restored.priceUuid, 'price-1');
    expect(restored.revenue, 2850);
  });

  test('draft stores items as a JSON list on the record', () {
    final json = draft().toJson();

    expect(json['items'], isA<List>());
    expect((json['items'] as List).length, 2);

    final restored = Drafts.fromJson(json);
    expect(restored.uuid, 'draft-1');
    expect(restored.shopId, 7);
    expect(restored.cartName, 'Table 4');
    expect(restored.fixedDiscount, 200);
    expect(restored.draftItems.map((e) => e.uuid), [
      'item-1',
      'item-2',
    ]);
    expect(restored.getItemCount(), 1);
  });

  test('integer amounts from jsonb are read as doubles', () {
    final json = item().toJson()
      ..['quantity'] = 3
      ..['custom_price'] = 1000
      ..['revenue'] = 3000;

    final restored = DraftItems.fromJson(json);
    expect(restored.quantity, 3.0);
    expect(restored.customPrice, 1000.0);
    expect(restored.revenue, 3000.0);
  });
}
