import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';

class CheckoutResponse {
  final String resUuid;
  final bool isReceipt;
  final TempInvoice? invoice;
  final TempMainReceipt? receipt;

  CheckoutResponse({
    required this.resUuid,
    required this.isReceipt,
    this.invoice,
    this.receipt,
  });
}
