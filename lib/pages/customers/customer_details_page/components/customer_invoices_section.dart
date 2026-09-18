import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/invoice_list_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerInvoicesSection extends StatelessWidget {
  final TempCustomersClass customer;
  const CustomerInvoicesSection({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempInvoice> sales =
        customer.getInvoices().length > 5
            ? customer.getInvoices().sublist(0, 4)
            : customer.getInvoices();

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      size: 16,
                      Icons.receipt_outlined,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'All Invoices'.toUpperCase(),
                  ),
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return InvoiceListPage(
                            customerUuid: customer.uuid,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          'View All',
                        ),
                        Icon(
                          size: 14,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Builder(
            builder: (context) {
              if (sales.isEmpty) {
                return Center(
                  child: EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText: 'No Invoices Found for Today',
                    theme: theme,
                    height: 15,
                    icon: Icons.clear,
                  ),
                );
              } else {
                return Column(
                  spacing: 5,
                  children:
                      sales
                          .map(
                            (item) => CustomerInvoicesList(
                              invoice: item,
                              theme: theme,
                            ),
                          )
                          .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomerInvoicesList extends StatelessWidget {
  final TempInvoice invoice;
  const CustomerInvoicesList({
    super.key,
    required this.theme,
    required this.invoice,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ReceiptPage(
                  isMain: false,
                  response: CheckoutResponse(
                    invoice: invoice,
                  ),
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 5,
          ),
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    formatMoneyBig(
                      amount:
                          invoice
                              .getTotalMainRevenueInvoice(),
                      context: context,
                    ),
                  ),
                  InvoicePaymentStatusWidget(
                    invoice: invoice,
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                    "${formatDateTime(invoice.createdAt)} - ${formatTime(invoice.createdAt)}",
                  ),
                  Icon(
                    size: 12,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InvoicePaymentStatusWidget extends StatefulWidget {
  final TempInvoice invoice;
  const InvoicePaymentStatusWidget({
    super.key,
    required this.invoice,
  });

  @override
  State<InvoicePaymentStatusWidget> createState() =>
      _InvoicePaymentStatusWidgetState();
}

class _InvoicePaymentStatusWidgetState
    extends State<InvoicePaymentStatusWidget> {
  Color mainColor() {
    return widget.invoice.getInvoiceStatus() == 1
        ? Colors.amber
        : widget.invoice.getInvoiceStatus() == 2
        ? Colors.green
        : Colors.red;
  }

  String mainText() {
    return widget.invoice.getInvoiceStatus() == 1
        ? 'Partial'
        : widget.invoice.getInvoiceStatus() == 2
        ? 'Paid'
        : 'Unpaid';
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: mainColor()),
      ),
      child: Text(
        style: TextStyle(
          color: mainColor(),
          fontSize: theme.mobileTexts.b5.fontSize,
        ),
        mainText(),
      ),
    );
  }
}
