import 'package:flutter/material.dart';
import 'package:stockall/main.dart';

/// While items are selected on All Items, Back (system back,
/// browser back, or the app bar arrow when it calls `maybePop`)
/// clears the selection instead of leaving the page.
///
/// Listens to the selection, so it stays correct when the
/// selection is cleared from provider code (after a bulk action).
class SelectionBackScope extends StatelessWidget {
  final VoidCallback onCancelSelection;
  final Widget child;

  const SelectionBackScope({
    super.key,
    required this.onCancelSelection,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isSelecting =
        returnData(context: context).isSelectProducts;
    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (returnData().isSelectProducts) {
          onCancelSelection();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
