import 'package:flutter/foundation.dart';
import 'package:stockall/local_database/products/products_func.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

enum DuplicationQuantityMode {
  existingQuantity,
  customQuantity,
  zeroQuantity,
}

class LinkedProductInfo {
  final TempProductClass product;
  final TempShopClass shop;

  LinkedProductInfo({
    required this.product,
    required this.shop,
  });
}

class LinkedDepartmentProductInfo {
  final TempProductClass product;
  final DepartmentClass department;

  LinkedDepartmentProductInfo({
    required this.product,
    required this.department,
  });
}

class ProductLinkingHelper {
  // ==================== BRANCH LINKING ====================

  /// Resolves the corresponding product in [destinationProducts] across branches for [sourceProduct]
  /// by matching [globalProductId] cluster identity.
  static TempProductClass? resolveLinkedProduct({
    required TempProductClass sourceProduct,
    required List<TempProductClass> destinationProducts,
  }) {
    final srcGlobalId = sourceProduct.globalProductId;
    if (srcGlobalId != null &&
        srcGlobalId.trim().isNotEmpty) {
      for (final dest in destinationProducts) {
        if (dest.globalProductId != null &&
            dest.globalProductId == srcGlobalId &&
            dest.uuid != sourceProduct.uuid) {
          return dest;
        }
      }
    }
    return null;
  }

  /// Manually links [sourceProduct] (current shop) to [targetProduct] (in branch [targetShop]).
  /// Unifies them into a shared [globalProductId] cluster so all branches carrying this product connect automatically.
  static Future<bool> linkProducts({
    required TempProductClass sourceProduct,
    required TempProductClass targetProduct,
  }) async {
    try {
      final clusterId =
          sourceProduct.globalProductId ??
          targetProduct.globalProductId ??
          sourceProduct.uuid ??
          uuidGen();

      sourceProduct.globalProductId = clusterId;

      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      if (resSource == null) return false;

      final updatedTarget = targetProduct.copyWith(
        globalProductId: clusterId,
      );
      final resTarget = await returnData()
          .updateProductForOtherShops(
            product: updatedTarget,
            itemHistory: null,
          );

      return resTarget != null;
    } catch (e) {
      debugPrint(
        'Error linking products across branches: $e',
      );
      return false;
    }
  }

  /// Safely unlinks [sourceProduct] from the branch cluster by assigning it a new independent [globalProductId].
  static Future<bool> unlinkProduct({
    required TempProductClass sourceProduct,
    required List<TempShopClass> otherShops,
  }) async {
    try {
      sourceProduct.globalProductId = uuidGen();

      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      return resSource != null;
    } catch (e) {
      debugPrint('Error unlinking product from branch: $e');
      return false;
    }
  }

  /// Finds all counterpart products across all other store branches belonging to the same cluster.
  static Future<List<LinkedProductInfo>>
  findAllLinkedBranchProducts({
    required TempProductClass sourceProduct,
    required List<TempShopClass> otherShops,
  }) async {
    final results = <LinkedProductInfo>[];
    final currentShopId = shopId();
    final clusterId = sourceProduct.globalProductId;

    if (clusterId == null || clusterId.trim().isEmpty)
      return results;

    for (final shop in otherShops) {
      if (shop.shopId == null ||
          shop.shopId == currentShopId)
        continue;
      try {
        final remoteProducts = await returnData()
            .getProductsForOtherShops(shop.shopId!);
        for (final p in remoteProducts) {
          if (p.globalProductId != null &&
              p.globalProductId == clusterId &&
              p.uuid != sourceProduct.uuid) {
            results.add(
              LinkedProductInfo(product: p, shop: shop),
            );
            break;
          }
        }
      } catch (e) {
        debugPrint(
          'Error finding linked products in shop ${shop.shopId}: $e',
        );
      }
    }
    return results;
  }

  /// Finds details of the linked product across other store branches.
  static Future<LinkedProductInfo?>
  findLinkedProductDetails({
    required TempProductClass sourceProduct,
    required List<TempShopClass> otherShops,
  }) async {
    final currentShopId = shopId();
    for (final shop in otherShops) {
      if (shop.shopId == null ||
          shop.shopId == currentShopId)
        continue;
      try {
        final remoteProducts = await returnData()
            .getProductsForOtherShops(shop.shopId!);
        final match = resolveLinkedProduct(
          sourceProduct: sourceProduct,
          destinationProducts: remoteProducts,
        );
        if (match != null) {
          return LinkedProductInfo(
            product: match,
            shop: shop,
          );
        }
      } catch (e) {
        debugPrint(
          'Error finding linked product in shop ${shop.shopId}: $e',
        );
      }
    }
    return null;
  }

  // ==================== DEPARTMENT LINKING ====================

  /// Resolves the corresponding product in [destinationProducts] across departments for [sourceProduct]
  /// by matching [globalDepartmentProductId] cluster identity.
  static TempProductClass? resolveLinkedProductDepartment({
    required TempProductClass sourceProduct,
    required List<TempProductClass> destinationProducts,
  }) {
    final srcGlobalDeptId =
        sourceProduct.globalDepartmentProductId;
    if (srcGlobalDeptId != null &&
        srcGlobalDeptId.trim().isNotEmpty) {
      for (final dest in destinationProducts) {
        if (dest.globalDepartmentProductId != null &&
            dest.globalDepartmentProductId ==
                srcGlobalDeptId &&
            dest.uuid != sourceProduct.uuid) {
          return dest;
        }
      }
    }
    return null;
  }

  /// Finds all counterpart products across all other departments in the current shop belonging to the same department cluster.
  static List<LinkedDepartmentProductInfo>
  findAllLinkedDepartmentProducts({
    required TempProductClass sourceProduct,
    required List<DepartmentClass> departments,
    required List<TempProductClass> allProducts,
  }) {
    final results = <LinkedDepartmentProductInfo>[];
    final clusterId =
        sourceProduct.globalDepartmentProductId;
    if (clusterId == null || clusterId.trim().isEmpty)
      return results;

    for (final dept in departments) {
      if (dept.uuid == sourceProduct.departmentUuid)
        continue;
      for (final p in allProducts) {
        if (p.departmentUuid == dept.uuid &&
            p.globalDepartmentProductId != null &&
            p.globalDepartmentProductId == clusterId &&
            p.uuid != sourceProduct.uuid) {
          results.add(
            LinkedDepartmentProductInfo(
              product: p,
              department: dept,
            ),
          );
          break;
        }
      }
    }
    return results;
  }

  /// Links [sourceProduct] to [targetProduct] in another department.
  static Future<bool> linkProductsDepartment({
    required TempProductClass sourceProduct,
    required TempProductClass targetProduct,
  }) async {
    try {
      final clusterId =
          sourceProduct.globalDepartmentProductId ??
          targetProduct.globalDepartmentProductId ??
          sourceProduct.uuid ??
          uuidGen();

      sourceProduct.globalDepartmentProductId = clusterId;
      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      if (resSource == null) return false;

      // Always use the latest target from local storage if available so we don't stomp newly updated quantity
      final latestTarget =
          targetProduct.uuid != null
              ? (ProductsFunc().getSingleProduct(
                    uuid: targetProduct.uuid!,
                  ) ??
                  targetProduct)
              : targetProduct;

      final updatedTarget = latestTarget.copyWith(
        globalDepartmentProductId: clusterId,
      );
      final resTarget = await returnData().updateProduct(
        product: updatedTarget,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      return resTarget != null;
    } catch (e) {
      debugPrint(
        'Error linking products across departments: $e',
      );
      return false;
    }
  }

  /// Unlinks [sourceProduct] from its department counterpart.
  static Future<bool> unlinkProductDepartment({
    required TempProductClass sourceProduct,
    required List<TempProductClass> allProducts,
  }) async {
    try {
      sourceProduct.globalDepartmentProductId = uuidGen();
      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      return resSource != null;
    } catch (e) {
      debugPrint(
        'Error unlinking product from department: $e',
      );
      return false;
    }
  }

  /// Finds details of the linked product across other departments.
  static LinkedDepartmentProductInfo?
  findLinkedDepartmentProductDetails({
    required TempProductClass sourceProduct,
    required List<DepartmentClass> departments,
    required List<TempProductClass> allProducts,
  }) {
    for (final dept in departments) {
      if (dept.uuid == sourceProduct.departmentUuid)
        continue;
      final deptProducts =
          allProducts
              .where((p) => p.departmentUuid == dept.uuid)
              .toList();
      final match = resolveLinkedProductDepartment(
        sourceProduct: sourceProduct,
        destinationProducts: deptProducts,
      );
      if (match != null) {
        return LinkedDepartmentProductInfo(
          product: match,
          department: dept,
        );
      }
    }
    return null;
  }

  // ==================== CREATE PRODUCT FROM TRANSFER ====================

  /// Creates a corresponding product in [targetShop] or [targetDepartment] directly from [sourceProduct],
  /// initializing it with [enteredTransferQuantity] and establishing automatic two-way linking.
  ///
  /// Balances all model fields: resets shop/department/storage specific fields, clones units and prices
  /// with fresh UUIDs, and logs aligned ItemHistory.
  static Future<TempProductClass?>
  createDestinationProductFromTransfer({
    required TempProductClass sourceProduct,
    required double enteredTransferQuantity,
    required String? unitUuid,
    required bool isBranchTransfer,
    TempShopClass? targetShop,
    DepartmentClass? targetDepartment,
    double? customWidth,
    double? customHeight,
  }) async {
    try {
      final newUuid = uuidGen();
      final selectedUnit = sourceProduct.getProductUnit(
        unitUuid: unitUuid,
      );
      final baseQuantity = selectedUnit
          .getQuantityEquivMultiplied(
            index: 1,
            newQuantity: enteredTransferQuantity,
            product: sourceProduct,
            customWidth: customWidth,
            customHeight: customHeight,
          );
      final destArea = sourceProduct.dimensionArea();
      final calculatedQty = baseQuantity / destArea;

      // 1. Clone units with new UUIDs and updated productUuid
      final clonedUnits =
          (sourceProduct.unitsList ?? [])
              .map((u) => u.copyWith())
              .toList();
      for (final unit in clonedUnits) {
        unit.uuid = uuidGen();
        unit.productUuid = newUuid;
        unit.createdAt = DateTime.now();
      }

      // 2. Clone prices with new UUIDs and updated itemUuid
      final clonedPrices =
          (sourceProduct.pricesList ?? [])
              .map((p) => p.copyWith())
              .toList();
      for (final price in clonedPrices) {
        price.uuid = uuidGen();
        price.itemUuid = newUuid;
        price.createdAt = DateTime.now();
      }

      // 3. Balanced Product Model Creation
      final branchClusterId =
          isBranchTransfer
              ? (sourceProduct.globalProductId ??
                  sourceProduct.uuid ??
                  uuidGen())
              : uuidGen();

      final deptClusterId =
          isBranchTransfer
              ? uuidGen()
              : (sourceProduct.globalDepartmentProductId ??
                  sourceProduct.uuid ??
                  uuidGen());

      if (isBranchTransfer &&
          sourceProduct.globalProductId !=
              branchClusterId) {
        sourceProduct.globalProductId = branchClusterId;
        await returnData().updateProduct(
          product: sourceProduct,
          isQuantityUpdate: false,
          includeQuantity: false,
          quantityChange: null,
          isIncrement: null,
          itemHistory: null,
        );
      } else if (!isBranchTransfer &&
          sourceProduct.globalDepartmentProductId !=
              deptClusterId) {
        sourceProduct.globalDepartmentProductId =
            deptClusterId;
        await returnData().updateProduct(
          product: sourceProduct,
          isQuantityUpdate: false,
          includeQuantity: false,
          quantityChange: null,
          isIncrement: null,
          itemHistory: null,
        );
      }

      final newProduct = sourceProduct.copyWith(
        id: null,
        uuid: newUuid,
        shopId:
            isBranchTransfer
                ? targetShop!.shopId
                : shopId(),
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        quantity: calculatedQty,
        unitsList: clonedUnits,
        pricesList: clonedPrices,
        // Decoupled cluster identities
        globalProductId: branchClusterId,
        globalDepartmentProductId: deptClusterId,
        // Reset storage allocations since destination does not share storage
        storageUuid: null,
        totalQttyInStorage: 0,
        totalQttyInStorageDouble: 0.0,
        // Branch vs Department specific fields
        departmentUuid:
            isBranchTransfer
                ? null
                : targetDepartment?.uuid,
        departmentName:
            isBranchTransfer
                ? null
                : targetDepartment?.name,
        category:
            isBranchTransfer
                ? null
                : sourceProduct.category,
        categoryUuid:
            isBranchTransfer
                ? null
                : sourceProduct.categoryUuid,
        categories:
            isBranchTransfer
                ? []
                : (sourceProduct.categories ?? []),
      );

      final historyDesc =
          isBranchTransfer
              ? 'Item Created & Received From Branch Transfer - Source Item: ${sourceProduct.name}, Shop: ${returnShopProvider().userShop()?.name ?? 'Main Branch'}.'
              : 'Item Created & Received From Department Transfer - Source Item: ${sourceProduct.name}, Department: ${returnDepartmentProvider().currentDepartment()?.name ?? 'Not Set'}.';

      // 4. Properly aligned ItemHistory
      final history = ItemHistory(
        uuid: uuidGen(),
        event: ItemHistoryEventClass.transferedIn,
        isManaged: newProduct.isManaged,
        source:
            isBranchTransfer
                ? ItemHistoryEventClass.branchStoreSource
                : ItemHistoryEventClass.departmentSource,
        destination:
            ItemHistoryEventClass.productDestination,
        shopId: newProduct.shopId,
        title: 'Transfered In',
        desc: historyDesc,
        isIncreased: true,
        createdAt: DateTime.now(),
        itemUuid: newProduct.uuid,
        itemName: newProduct.name,
        newValue: formatLargeNumberDouble(
          newProduct
              .getProductUnit()
              .getQuantityEquivDivided(
                index: 1,
                newQuantity: baseQuantity,
                product: newProduct,
              ),
        ),
        oldValue: '0',
        quantityChange: enteredTransferQuantity,
        staffId: currentUser().userId,
        staffName: currentUser().name,
        unit: selectedUnit.name,
        primaryUnit: newProduct.getProductUnit().name,
        departmentName: newProduct.departmentName,
        departmentUuid: newProduct.departmentUuid,
      );

      if (isBranchTransfer) {
        // Insert remotely into destination shop
        await Supabase.instance.client
            .from('products')
            .insert(
              newProduct.toJson(isIncludeQuantity: true),
            );

        try {
          await Supabase.instance.client
              .from('item_history')
              .insert(history.toJson());
        } catch (e) {
          debugPrint('Error inserting remote history: $e');
        }
      } else {
        // Create in current shop's local department and queue sync
        await returnData().createProduct(
          isMultiple: false,
          product: newProduct,
          itemHistory: history,
        );
      }

      return newProduct;
    } catch (e) {
      debugPrint(
        'Error creating destination product from transfer: $e',
      );
      return null;
    }
  }
}
