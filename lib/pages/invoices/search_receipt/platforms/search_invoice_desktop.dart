import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/components/list_tiles/main_invoice_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

class SearchInvoiceDesktop extends StatefulWidget {
  final TextEditingController searchController;
  const SearchInvoiceDesktop({
    super.key,
    required this.searchController,
  });

  @override
  State<SearchInvoiceDesktop> createState() =>
      _SearchInvoiceDesktopState();
}

class _SearchInvoiceDesktopState
    extends State<SearchInvoiceDesktop> {
  Future<void> getMainInvoices() async {
    await RefreshFunctions(
      context,
    ).refreshInvoices(context);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnInvoicesProvider().clearDate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempInvoice> invoices =
        widget.searchController.text.isNotEmpty
            ? returnInvoicesProvider(context: context)
                .departmentInvoices()
                .where(
                  (invoice) =>
                      invoice.customerName
                              ?.toLowerCase()
                              .contains(
                                widget.searchController.text
                                    .toLowerCase(),
                              ) ==
                          true ||
                      invoice.staffName
                              .toLowerCase()
                              .contains(
                                widget.searchController.text
                                    .toLowerCase(),
                              ) ==
                          true ||
                      invoice.barcode?.contains(
                            widget.searchController.text,
                          ) ==
                          true,
                )
                .toList()
            : returnInvoicesProvider(
              context: context,
            ).returnInvoicesByDayOrWeekAll().toList();
    double totalRevenue() {
      return invoices
          .map((rec) => (rec.bank + rec.bank))
          .toList()
          .fold(0, (first, second) => first + second);
    }

    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Row(
              spacing: 15,
              children: [
                Container(
                  width:
                      screenWidth(context) <
                              tabletScreenSmall
                          ? 50
                          : (screenWidth(context) >
                                  tabletScreenSmall &&
                              screenWidth(context) <
                                  tabletScreen + 100)
                          ? 100
                          : 230,
                ),
                Expanded(
                  child: DesktopPageContainer(
                    widget: Scaffold(
                      appBar: appBar(
                        context: context,
                        title: 'Search For An Invoice',
                        widget: SizedBox(
                          width: 250,
                          height: 35,
                          child: TextFieldBarcode(
                            searchController:
                                widget.searchController,
                            onChanged: (value) {
                              setState(() {});
                            },
                            onPressedScan: () {
                              ItemsAuthAction()
                                  .useOfBArcodeAction(
                                    context: context,
                                    action: () async {
                                      String? result =
                                          await scanCode(
                                            context,
                                            'Scan Failed',
                                          );
                                      setState(() {
                                        if (result !=
                                            null) {
                                          widget
                                              .searchController
                                              .text = result;
                                        } else {
                                          return;
                                        }
                                      });
                                      if (!context
                                          .mounted) {
                                        return;
                                      }
                                      setState(() {});
                                    },
                                  );
                            },
                            clearTextField: () {
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                        ),
                        child: Column(
                          children: [
                            Material(
                              color: Colors.white,
                              child: Column(
                                children: [
                                  Row(
                                    spacing: 10,
                                    children: [
                                      ValueSummaryTabSmall(
                                        color: Colors.amber,
                                        isMoney: true,
                                        title:
                                            'Unpaid Balance',
                                        value:
                                            totalRevenue(),
                                      ),
                                      ValueSummaryTabSmall(
                                        value:
                                            invoices.length
                                                .toDouble(),
                                        title:
                                            'Invoice Number',
                                        color: Colors.green,
                                        isMoney: false,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  if (invoices.isEmpty) {
                                    return EmptyWidgetDisplayOnly(
                                      title: 'Empty List',
                                      subText:
                                          'You don\'t have any Sales under this category',
                                      icon: Icons.clear,
                                      theme: theme,
                                      height: 35,
                                      altAction: () {
                                        getMainInvoices();
                                      },
                                      altActionText:
                                          'Refresh List',
                                    );
                                  } else {
                                    return RefreshIndicator(
                                      onRefresh:
                                          getMainInvoices,
                                      backgroundColor:
                                          Colors.white,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      displacement: 10,
                                      child: ListView.builder(
                                        itemCount:
                                            invoices.length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          var invoice =
                                              invoices[index];
                                          return MainInvoiceTile(
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ReceiptPage(
                                                      isComingFromInvoice:
                                                          true,
                                                      response: CheckoutResponse(
                                                        invoice:
                                                            invoice,
                                                        isReceipt:
                                                            false,
                                                        resUuid:
                                                            invoice.uuid!,
                                                      ),
                                                      isMain:
                                                          false,
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                // invoiceFuture =
                                                //     getMainInvoices();
                                              });
                                            },
                                            key: ValueKey(
                                              invoice.uuid,
                                            ),
                                            invoice:
                                                invoice,
                                          );
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  width:
                      screenWidth(context) <
                              tabletScreenSmall
                          ? 50
                          : (screenWidth(context) >
                                  tabletScreenSmall &&
                              screenWidth(context) <
                                  tabletScreen + 100)
                          ? 100
                          : 230,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ValueSummaryTabSmall extends StatelessWidget {
  final double value;
  final String title;
  final Color color;
  final bool isMoney;

  const ValueSummaryTabSmall({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Column(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: false,
                      child: Text(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        "N",
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade700,
                      ),
                      isMoney
                          ? formatMoneyMid(
                            amount: value,
                            context: context,
                          )
                          : formatLargeNumberDoubleWidgetDecimal(
                            value,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
