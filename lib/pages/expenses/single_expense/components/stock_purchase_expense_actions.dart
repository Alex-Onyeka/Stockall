import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';
import 'package:stockall/providers/theme_provider.dart';

// Actions on a Stock Purchase expense, shared by the mobile and
// desktop expense details pages and the expense tile. The expense
// belongs to its purchase: it is changed or deleted through it.

/// Opens the purchase of a Stock Purchase expense.
void openLinkedPurchase(BuildContext context, String purchaseUuid) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PurchasePage(purchaseUuid: purchaseUuid),
    ),
  );
}

/// Asks to delete the purchase of Stock Purchase [expense] (which
/// deletes the expense with it), with the same "Update Inventory?"
/// toggle as the purchase page. If the purchase no longer exists,
/// only the expense is deleted. [onStart] runs once confirmed;
/// [onDone] gets whether anything was deleted.
void confirmDeleteStockPurchaseExpense({
  required BuildContext context,
  required ThemeProvider theme,
  required TempExpensesClass expense,
  required VoidCallback onStart,
  required void Function(bool deleted) onDone,
}) {
  final purchaseUuid = expense.purchaseUuid;
  if (purchaseUuid == null) return;
  showDialog(
    context: context,
    builder: (confirmDialog) {
      bool updateInventory = false;
      return StatefulBuilder(
        builder:
            (dialogContext, setDialogState) => DialogTemplate(
              theme: theme,
              title: 'Delete Purchase Receipt?',
              message:
                  'This expense was recorded from a purchase. Deleting it deletes the purchase receipt as well. Are you sure you want to proceed?',
              action: () async {
                Navigator.of(confirmDialog).pop();
                onStart();
                final deleted = await _deleteStockPurchaseExpense(
                  context: context,
                  expense: expense,
                  purchaseUuid: purchaseUuid,
                  updateInventory: updateInventory,
                );
                if (!deleted && context.mounted) {
                  await showDialog(
                    context: context,
                    builder:
                        (_) => InfoAlert(
                          theme: theme,
                          title: 'Delete Failed',
                          message:
                              'The purchase receipt could not be deleted. Please try again.',
                        ),
                  );
                }
                onDone(deleted);
              },
              widget: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Update Inventory?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    MyToggleButton(
                      boolValue: updateInventory,
                      toggle: () {
                        setDialogState(() {
                          updateInventory = !updateInventory;
                        });
                      },
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
      );
    },
  );
}

Future<bool> _deleteStockPurchaseExpense({
  required BuildContext context,
  required TempExpensesClass expense,
  required String purchaseUuid,
  required bool updateInventory,
}) async {
  final purchaseProvider = returnPurchaseProvider();
  final purchase = await purchaseProvider.findPurchase(purchaseUuid);
  if (purchase == null) {
    // Purchase already gone: remove the leftover expense.
    if (!context.mounted) return false;
    await returnExpensesProvider(
      context,
      listen: false,
    ).deleteExpense(expense, context);
    return true;
  }
  final res = await purchaseProvider.deletePurchase(
    purchase,
    updateInventory,
    true,
  );
  if (res == 1) {
    await purchaseProvider.loadPurchases(shopId());
  }
  return res == 1;
}
