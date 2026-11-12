// Pumping helpers for the Materials widget tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/providers/theme_provider.dart';

final materialsDay2 = DateTime(2026, 10, 2);

Future<void> pumpPage(
  WidgetTester tester, {
  required bool isDesktop,
  required Widget page,
  bool tapView = true,
  double mobileHeight = 900,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1200) : Size(500, mobileHeight);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(home: page),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop && tapView) {
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}

Finder byKey(String key) => find.byKey(ValueKey(key));

/// Scrolls [finder] into view and taps near its leading edge: rows are
/// wider than a phone screen.
Future<void> tapStart(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tapAt(tester.getTopLeft(finder) + const Offset(16, 16));
  await tester.pumpAndSettle();
}
