import 'package:flutter/material.dart';

/// The open filters panel of a table page. On a phone it takes at most
/// [phoneShare] of the screen's height and scrolls, so the table and the
/// pager below it keep their room; on desktop it shows in full.
Widget productionFilterPanelBox(
  BuildContext context, {
  required bool isDesktop,
  required Widget child,
  double phoneShare = 0.3,
}) {
  if (isDesktop) return child;
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxHeight: MediaQuery.sizeOf(context).height * phoneShare,
    ),
    child: SingleChildScrollView(child: child),
  );
}
