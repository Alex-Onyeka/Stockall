import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/bottom_sheet_widgets.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class UseMultipleToggleAddItemPage extends StatelessWidget {
  const UseMultipleToggleAddItemPage({
    super.key,
    required this.theme,
    required this.title,
    required this.description,
    required this.value,
    required this.onTap,
  });

  final ThemeProvider theme;
  final String title;
  final String description;
  final bool value;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        onTap();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
                Text(style: TextStyle(fontSize: 10), description),
              ],
            ),
          ),
          Checkbox(
            activeColor: theme.lightModeColor.secColor100,
            value: value,
            onChanged: (value) {
              onTap();
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ],
      ),
    );
  }
}

//
//
// Item unit gating. Kept in one place so it can be changed
// later: who can see the unit field, and which plans can set it.

bool canSeeItemUnit() {
  return authorization(
    authorized: Authorizations().manageMultipleUnits,
  );
}

bool itemUnitAuthAction({
  required BuildContext context,
  Function()? action,
}) {
  return ItemsAuthAction().applyVariationsAction(
    context: context,
    action: action,
  );
}

//
//
// Prices

void toggleMultiplePricesAction({
  required BuildContext context,
  required TextEditingController sellingController,
  required String productUuid,
}) {
  final provider = returnData();
  if (!provider.useMultiplePrices) {
    // Carry the typed price over as the primary price.
    final priceValue = double.tryParse(
      sellingController.text.replaceAll(',', '').trim(),
    );
    if (priceValue != null) {
      provider.setPrimaryPriceValue(
        productUuid: productUuid,
        priceValue: priceValue,
      );
    }
    provider.setUseMultiplePrices(true);
    return;
  }

  void switchOff() {
    final primary = ProductPricesClass.primaryOf(
      provider.tempPricesList,
    );
    sellingController.text =
        primary != null ? primary.priceValue.toString() : '';
    provider.setUseMultiplePrices(false);
  }

  if (ProductPricesClass.hasMultiple(provider.tempPricesList)) {
    final primary = ProductPricesClass.primaryOf(
      provider.tempPricesList,
    );
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          title: 'Use a Single Price?',
          message:
              'Only the primary price (${primary?.priceValue ?? 0}) will be kept when you save. The other prices will be removed. Drafts, orders and invoices that use other prices will switch to the primary price when reopened for editing.',
          action: () {
            Navigator.of(confirmDialog).pop();
            switchOff();
          },
        );
      },
    );
  } else {
    switchOff();
  }
}

//
//
// Units

void toggleMultipleUnitsAction({required BuildContext context}) {
  final provider = returnData();
  if (!provider.useMultipleUnits) {
    itemUnitAuthAction(
      context: context,
      action: () {
        provider.setUseMultipleUnits(true);
      },
    );
    return;
  }

  if (ProductUnitsClass.hasMultiple(provider.tempUnitsList)) {
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          title: 'Use a Single Unit?',
          message:
              'Only the primary unit (${provider.singleUnitName() ?? 'Unit(s)'}) will be kept when you save. The other units will be removed. Drafts, orders and invoices that use other units will switch to the primary unit when reopened for editing.',
          action: () {
            Navigator.of(confirmDialog).pop();
            provider.setUseMultipleUnits(false);
          },
        );
      },
    );
  } else {
    provider.setUseMultipleUnits(false);
  }
}

// Single unit mode: pick from the units bottom sheet. The
// item keeps exactly one unit; picking another renames it.
void selectSingleUnitAction({
  required BuildContext context,
  required String productUuid,
  required bool isDimensional,
}) {
  itemUnitAuthAction(
    context: context,
    action: () {
      final provider = returnData();
      provider.selectedUnit = provider.singleUnitName();
      unitsBottomSheet(context, () {
        final name = provider.selectedUnit;
        if (name != null && name != provider.singleUnitName()) {
          provider.setSinglePrimaryUnit(
            name: name,
            productUuid: productUuid,
            isDimensional: isDimensional,
          );
        }
      });
    },
  );
}
