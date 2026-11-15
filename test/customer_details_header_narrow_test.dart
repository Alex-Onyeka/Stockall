import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/customers/customer_details_page/platforms/customer_details_mobile.dart';
import 'package:stockall/providers/customers_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'customer_report_fixtures.dart' show testCustomer;
import 'report_export_screen_harness.dart';

// The customer details mobile header at a 360 px phone:
// the back button and title, the icon-only Print Record button and
// the ⋮ menu on one row. Any overflow on the page fails.

final customer = testCustomer(uuid: 'cust-header-narrow');

Future<void> pumpPage(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<ReceiptsProvider>.value(
          value: ReceiptsProvider(),
        ),
        ChangeNotifierProvider<CustomersProvider>.value(
          value: CustomersProvider(),
        ),
      ],
      child: MaterialApp(
        home: CustomerDetailsMobile(customerUuid: customer.uuid!),
      ),
    ),
  );
  await settleReportScreen(tester);
}

void main() {
  setUpAll(setUpScreenEnvironment);
  setUp(() => CustomersProvider().customers.add(customer));
  tearDown(
    () => CustomersProvider().customers.removeWhere(
      (c) => c.uuid == customer.uuid,
    ),
  );

  for (final width in [360.0]) {
    testWidgets('header fits at ${width.toInt()} wide', (tester) async {
      await pumpPage(tester, width);
      expect(tester.takeException(), isNull);
      expect(find.text('Customer Details'), findsOneWidget);
      expect(find.byIcon(Icons.print_outlined), findsOneWidget);
      expect(find.byTooltip('Print Record'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);
      // Icon only: no pill text.
      expect(find.text('Print Record'), findsNothing);
    });
  }
}
