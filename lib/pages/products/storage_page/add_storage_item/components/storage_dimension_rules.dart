import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_storage_product/storage_transfer.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/main.dart';

double? parseDimension(TextEditingController controller) {
  return double.tryParse(
    controller.text.replaceAll(',', '').trim(),
  );
}

// Dimensions are optional for 2D items. If provided, both must be valid.
bool validStorageDimensions({
  required BuildContext context,
  required int quantityType,
  required TextEditingController widthController,
  required TextEditingController heightController,
}) {
  final hasWidth = widthController.text.trim().isNotEmpty;
  final hasHeight = heightController.text.trim().isNotEmpty;
  if (quantityType == 2 && (hasWidth != hasHeight)) {
    showDialog(
      context: context,
      builder: (context) {
        return InfoAlert(
          theme: returnTheme(context),
          message:
              'Both Width and Height must be provided if setting dimensions, or both left empty.',
          title: 'Incomplete Dimensions',
        );
      },
    );
    return false;
  }
  if (quantityType == 2 && hasWidth && hasHeight) {
    final w =
        double.tryParse(widthController.text.replaceAll(',', '').trim()) ?? 0;
    final h =
        double.tryParse(heightController.text.replaceAll(',', '').trim()) ?? 0;
    if (w <= 0 || h <= 0) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context),
            message: 'Width and Height must be numbers greater than 0.',
            title: 'Invalid Dimensions',
          );
        },
      );
      return false;
    }
  }
  return true;
}

// Editing a storage item: its type (1D / 2D) can only change
// while it holds no stock and every sales item it manages already
// has the new type.
bool storageTypeChangeAllowed({
  required BuildContext context,
  required TempStorageProducts? storageProduct,
  required int quantityType,
}) {
  if (storageProduct == null) {
    return true;
  }
  final managed =
      returnData().productListMain
          .where((item) => item.storageUuid == storageProduct.uuid)
          .toList();
  if (canChangeStorageType(
    storage: storageProduct,
    managedProducts: managed,
    newQuantityType: quantityType,
  )) {
    return true;
  }
  showDialog(
    context: context,
    builder: (context) {
      return InfoAlert(
        theme: returnTheme(context),
        message:
            (storageProduct.quantity ?? 0) != 0
                ? 'This storage item still has stock. Its dimension type (1D / 2D) can only be changed when its quantity is 0.'
                : 'This storage item manages sales items of the other dimension type (1D / 2D). Remove them in Manage Products first.',
        title: 'Cannot Change Dimension Type',
      );
    },
  );
  return false;
}

// Editing a sales item: its type can't change to one that no
// longer matches the storage item managing it. Saving without a
// type change is always allowed (old mismatched links included).
bool salesTypeChangeAllowed({
  required BuildContext context,
  required TempProductClass product,
  required int quantityType,
}) {
  if ((product.quantityType == 2) == (quantityType == 2)) {
    return true;
  }
  final storage =
      returnStorageProductProvider().storageProductListMain
          .where((item) => item.uuid == product.storageUuid)
          .firstOrNull;
  if (storage == null ||
      (storage.quantityType == 2) == (quantityType == 2)) {
    return true;
  }
  showDialog(
    context: context,
    builder: (context) {
      return InfoAlert(
        theme: returnTheme(context),
        message:
            'This item is managed by the storage item ${storage.name}, which is ${storage.quantityType == 2 ? '2D' : '1D'}. Remove it from that storage in Manage Products before changing its dimension type.',
        title: 'Cannot Change Dimension Type',
      );
    },
  );
  return false;
}
