import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/providers/invoices_provider.dart';

TempMainReceipt makeReceipt({
  required String uuid,
  required double cash,
  required double bank,
  String? invoiceUuid,
  bool isInvoice = false,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: '111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod: cash > 0 && bank > 0 ? 'Split' : (bank > 0 ? 'Bank' : 'Cash'),
    bank: bank,
    cashAlt: cash,
    customerAccount: 0,
    departmentName: null,
    departmentUuidNew: null,
    isInvoice: isInvoice || invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    orderUuid: null,
    generalDiscount: null,
    fixedDiscount: null,
    vat: null,
    originalCost: cash + bank,
    balance: null,
    subStaffUuid: null,
    subStaffName: null,
    cartName: null,
    comment: null,
    salesTypeIndex: 1,
    items: [],
  );
}

TempInvoice makeInvoice({
  required String uuid,
  required double cash,
  required double bank,
  double? originalCost,
  double? generalDiscount,
  double? vat,
}) {
  return TempInvoice(
    uuid: uuid,
    barcode: 'INV111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod: cash > 0 && bank > 0 ? 'Split' : (bank > 0 ? 'Bank' : 'Cash'),
    bank: bank,
    cashAlt: cash,
    departmentName: null,
    departmentUuidNew: null,
    cartName: 'Cart 1',
    subStaffName: null,
    comment: null,
    originalCost: originalCost,
    generalDiscount: generalDiscount,
    vat: vat,
    items: [],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Invoice Flow Fixes Tests', () {
    test('Customer rewards are never earned on invoices or invoice payment receipts', () {
      final invoice = makeInvoice(
        uuid: 'inv-1',
        bank: 500.0,
        cash: 500.0,
      );
      // Invoice getCustomerReward returns 0.0
      expect(invoice.getCustomerReward(), 0.0);

      final invoicePaymentReceipt = makeReceipt(
        uuid: 'rec-inv-1',
        invoiceUuid: 'inv-1',
        isInvoice: true,
        bank: 500.0,
        cash: 0.0,
      );
      // Receipt created for invoice part payment returns 0.0
      expect(invoicePaymentReceipt.getCustomerReward(), 0.0);

      final normalReceipt = makeReceipt(
        uuid: 'rec-reg-1',
        bank: 500.0,
        cash: 500.0,
      );
      // Normal receipt doesn't automatically block rewards
      expect(normalReceipt.isInvoice, isFalse);
      expect(normalReceipt.invoiceUuid, isNull);
    });

    test('Invoice VAT is calculated on discounted subtotal rather than pre-discount cost', () {
      final invoiceWithDiscount = makeInvoice(
        uuid: 'inv-vat-1',
        cash: 800.0,
        bank: 0.0,
        originalCost: 1000.0,
        generalDiscount: 200.0,
        vat: 10.0, // 10%
      );
      // Net discounted subtotal = 1000 - 200 = 800. VAT = 800 * 10% = 80.
      expect(invoiceWithDiscount.getVATInvoice(), 80.0);

      final zeroVatInvoice = makeInvoice(
        uuid: 'inv-vat-2',
        cash: 800.0,
        bank: 0.0,
        originalCost: 1000.0,
        generalDiscount: 200.0,
        vat: null,
      );
      expect(zeroVatInvoice.getVATInvoice(), 0.0);

      final zeroTotalInvoice = makeInvoice(
        uuid: 'inv-vat-3',
        cash: 0.0,
        bank: 0.0,
        originalCost: 200.0,
        generalDiscount: 200.0,
        vat: 10.0,
      );
      expect(zeroTotalInvoice.getVATInvoice(), 0.0);
    });

    test('Invoice payment line-item calculations guard against division by zero', () {
      final provider = InvoicesProvider();

      expect(
        provider.calcSalesRecordRevenue(
          invoceTotalAmount: 0.0,
          receiptPayment: 50.0,
          salesRecodRevenue: 100.0,
        ),
        0.0,
      );

      expect(
        provider.calcSalesRecordCostPrice(
          invoceTotalAmount: 0.0,
          receiptPayment: 50.0,
          salesRecodCostPrice: 40.0,
        ),
        0.0,
      );

      expect(
        provider.calcSalesRecordDiscountedAmount(
          invoceTotalAmount: 0.0,
          receiptPayment: 50.0,
          salesRecodDiscountedAmount: 10.0,
        ),
        0.0,
      );

      expect(
        provider.calcSalesRecordOriginalCost(
          invoceTotalAmount: 0.0,
          receiptPayment: 50.0,
          salesRecodOriginalCost: 100.0,
        ),
        0.0,
      );
    });

    test('PaymentBreakdown accurately assigns payment label for split deposits', () {
      final split = PaymentBreakdown.fromAmounts(
        bank: 300.0,
        cash: 200.0,
        account: 0.0,
      );
      expect(split.label, 'Split');

      final singleBank = PaymentBreakdown.fromAmounts(
        bank: 500.0,
        cash: 0.0,
        account: 0.0,
      );
      expect(singleBank.label, 'Bank');

      final singleCash = PaymentBreakdown.fromAmounts(
        bank: 0.0,
        cash: 500.0,
        account: 0.0,
      );
      expect(singleCash.label, 'Cash');
    });
  });
}

