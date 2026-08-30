import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';

class CheckoutResponse {
  final TempInvoice? invoice;
  final TempMainReceipt? receipt;
  final Orders? order;

  CheckoutResponse({
    this.invoice,
    this.receipt,
    this.order,
  });
}
