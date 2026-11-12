import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_invoices_section.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_orders_section.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_sales_section.dart';
import 'package:stockall/providers/invoices_provider.dart';
import 'package:stockall/providers/orders_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'customer_report_fixtures.dart'
    show testCustomer, testInvoice, testReceipt;
import 'order_report_fixtures.dart' show testOrder;
import 'report_export_screen_harness.dart';

// The customer details page's Sales, Invoices and Orders sections at
// the narrowest widths they get: a 360 px phone (stacked, as
// CustomerDetailsMobile), and the 950 px desktop breakpoint with two
// sections per row (as CustomerDetailsDesktop, with its wider 50 px
// padding). Long amounts and a status chip stress the rows; any
// overflow fails.

final customer = testCustomer();

/// Today's sales of the signed-out test user (currentUser().userId is
/// ''), unpaid invoices and orders, all of [customer], with long
/// amounts.
void seedRecords() {
  final now = DateTime.now();
  ReceiptsProvider().receipts.addAll([
    for (var i = 1; i <= 6; i++)
      testReceipt(
        uuid: 'r-narrow-$i',
        cash: 98765432.1 * i / 6,
        staffId: '',
        createdAt: now,
      ),
  ]);
  InvoicesProvider().invoicesMain.addAll([
    for (var i = 1; i <= 3; i++)
      testInvoice(uuid: 'i-narrow-$i', total: 98765432.1, createdAt: now),
  ]);
  OrdersProvider().orders.addAll([
    for (var i = 1; i <= 3; i++)
      testOrder(uuid: 'o-narrow-$i', total: 98765432.1, createdAt: now),
  ]);
}

void clearRecords() {
  bool ours(String? uuid, String prefix) => uuid?.startsWith(prefix) ?? false;
  ReceiptsProvider().receipts.removeWhere((r) => ours(r.uuid, 'r-narrow'));
  InvoicesProvider().invoicesMain.removeWhere((i) => ours(i.uuid, 'i-narrow'));
  OrdersProvider().orders.removeWhere((o) => ours(o.uuid, 'o-narrow'));
}

Widget sales() => CustomerSalesSection(customerUuid: customer.uuid!);
Widget invoices() => CustomerInvoicesSection(customer: customer);
Widget orders() => CustomerOrdersSection(customer: customer);

/// CustomerDetailsDesktop's row of two sections.
Widget pair(Widget a, Widget b) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 10.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: a),
      Expanded(
        child: Row(children: [const SizedBox(width: 10), Expanded(child: b)]),
      ),
    ],
  ),
);

Future<void> pumpSections(WidgetTester tester, {required bool desktop}) async {
  tester.view.physicalSize = Size(desktop ? 950 : 360, 3000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final body =
      desktop
          // CustomerDetailsDesktop without account/reward: 50 px each
          // side, the narrowest of its two paddings.
          ? Padding(
            padding: const EdgeInsets.fromLTRB(50, 0, 50, 30),
            child: SingleChildScrollView(
              child: Column(
                children: [pair(sales(), invoices()), pair(orders(), sales())],
              ),
            ),
          )
          // CustomerDetailsMobile: 15 px each side, stacked.
          : ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  spacing: 5,
                  children: [
                    for (final s in [sales(), invoices(), orders()])
                      Row(children: [Expanded(child: s)]),
                  ],
                ),
              ),
            ],
          );

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<ReceiptsProvider>.value(
          value: ReceiptsProvider(),
        ),
      ],
      child: MaterialApp(home: Scaffold(body: body)),
    ),
  );
  await settleReportScreen(tester);
}

void main() {
  setUpAll(setUpScreenEnvironment);
  setUp(seedRecords);
  tearDown(clearRecords);

  for (final desktop in [false, true]) {
    final width = desktop ? 950 : 360;
    testWidgets('no row overflows at $width wide', (tester) async {
      await pumpSections(tester, desktop: desktop);
      expect(tester.takeException(), isNull);
      // The rows were built, with their status chips.
      expect(find.byType(CustomerSalesList), findsWidgets);
      expect(find.byType(CustomerInvoicesList), findsWidgets);
      expect(find.byType(CustomerdOrdersList), findsWidgets);
      expect(find.byType(InvoicePaymentStatusWidget), findsWidgets);
      expect(find.byType(OrdersPaymentStatusWidget), findsWidgets);
    });
  }
}
