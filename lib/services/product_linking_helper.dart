import 'package:flutter/foundation.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
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

class ProductLinkingHelper {
  /// Resolves the corresponding product in [destinationProducts] for [sourceProduct].
  ///
  /// Supports:
  /// 1. Direct link: destination product UUID == sourceProduct.transferedProductId
  /// 2. Reverse link: destination product has transferedProductId == sourceProduct.uuid (e.g. duplicated from source)
  /// 3. Sibling link: both products share the same root transferedProductId
  static TempProductClass? resolveLinkedProduct({
    required TempProductClass sourceProduct,
    required List<TempProductClass> destinationProducts,
  }) {
    // 1. Direct link: destination UUID matches source's pointer
    final srcTargetId = sourceProduct.transferedProductId;
    if (srcTargetId != null &&
        srcTargetId.trim().isNotEmpty) {
      for (final dest in destinationProducts) {
        if (dest.uuid != null && dest.uuid == srcTargetId) {
          return dest;
        }
      }
    }

    // 2. Reverse link: destination points to source (e.g. was duplicated from source)
    final srcUuid = sourceProduct.uuid;
    if (srcUuid != null && srcUuid.trim().isNotEmpty) {
      for (final dest in destinationProducts) {
        if (dest.transferedProductId != null &&
            dest.transferedProductId == srcUuid) {
          return dest;
        }
      }
    }

    // 3. Sibling link: both share the same root transferedProductId
    if (srcTargetId != null &&
        srcTargetId.trim().isNotEmpty) {
      for (final dest in destinationProducts) {
        if (dest.transferedProductId != null &&
            dest.transferedProductId == srcTargetId &&
            dest.uuid != sourceProduct.uuid) {
          return dest;
        }
      }
    }

    return null;
  }

  /// Manually links [sourceProduct] (current shop) to [targetProduct] (in branch [targetShopId]).
  /// Establishes two-way linking so future transfers in either direction work seamlessly.
  static Future<bool> linkProducts({
    required TempProductClass sourceProduct,
    required TempProductClass targetProduct,
  }) async {
    try {
      // 1. Update source product locally
      sourceProduct.transferedProductId =
          targetProduct.uuid;
      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      if (resSource == null) {
        return false;
      }

      // 2. Update destination product remotely in target branch
      final updatedTarget = targetProduct.copyWith(
        transferedProductId: sourceProduct.uuid,
      );
      final resTarget = await returnData()
          .updateProductForOtherShops(
            product: updatedTarget,
            itemHistory: null,
          );

      return resTarget != null;
    } catch (e) {
      debugPrint('Error linking products: $e');
      return false;
    }
  }

  /// Safely unlinks [sourceProduct] from its branch counterpart.
  /// Does NOT delete products or modify quantities.
  static Future<bool> unlinkProduct({
    required TempProductClass sourceProduct,
    required List<TempShopClass> otherShops,
  }) async {
    try {
      final oldTargetId = sourceProduct.transferedProductId;
      final sourceUuid = sourceProduct.uuid;

      // 1. Clear source product link
      sourceProduct.transferedProductId = null;
      final resSource = await returnData().updateProduct(
        product: sourceProduct,
        isQuantityUpdate: false,
        includeQuantity: false,
        quantityChange: null,
        isIncrement: null,
        itemHistory: null,
      );

      if (resSource == null) {
        return false;
      }

      // 2. Also try to clear counterpart link in other branches if accessible
      final currentShopId = shopId();
      for (final shop in otherShops) {
        if (shop.shopId == null ||
            shop.shopId == currentShopId)
          continue;
        try {
          final remoteProducts = await returnData()
              .getProductsForOtherShops(shop.shopId!);
          for (final remote in remoteProducts) {
            if ((oldTargetId != null &&
                    remote.uuid == oldTargetId) ||
                (sourceUuid != null &&
                    remote.transferedProductId ==
                        sourceUuid)) {
              final clearedRemote = remote.copyWith(
                transferedProductId: null,
              );
              await returnData().updateProductForOtherShops(
                product: clearedRemote,
                itemHistory: null,
              );
            }
          }
        } catch (e) {
          debugPrint(
            'Error clearing remote link in shop ${shop.shopId}: $e',
          );
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error unlinking product: $e');
      return false;
    }
  }

  /// Finds details of the linked product across other branch shops.
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
          'Error finding linked product details in shop ${shop.shopId}: $e',
        );
      }
    }
    return null;
  }
}
